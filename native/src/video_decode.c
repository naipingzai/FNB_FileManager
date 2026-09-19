/// video_decode.c - FFmpeg 视频解码模块
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>

extern char *utils_base64_encode(const unsigned char *data, int len, int *out_len);
extern char *utils_strdup(const char *s);
extern unsigned char *utils_read_file(const char *path, int *out_len);
extern char *utils_error_json(const char *msg);

typedef struct { const unsigned char *data; int size, pos; } MemReader;

typedef struct {
    AVFormatContext *fmt_ctx;
    AVCodecContext *codec_ctx;
    int video_stream;
    struct SwsContext *sws;
    AVPacket *pkt;
    AVFrame *frame;
    int width, height;
    double duration, fps;
    unsigned char *data_copy;
    MemReader reader;
    AVCodecContext *acodec_ctx;
    struct SwrContext *swr;
    AVFrame *aframe;
    int audio_stream;
} VideoCtx;

static int mem_read(void *opaque, uint8_t *buf, int buf_size) {
    MemReader *r = (MemReader *)opaque;
    int avail = r->size - r->pos;
    if (avail <= 0) return AVERROR_EOF;
    int n = buf_size > avail ? avail : buf_size;
    memcpy(buf, r->data + r->pos, n); r->pos += n;
    return n;
}

static int64_t mem_seek(void *opaque, int64_t offset, int whence) {
    MemReader *r = (MemReader *)opaque;
    if (whence == AVSEEK_SIZE) return r->size;
    if (whence == SEEK_CUR) r->pos += (int)offset;
    else if (whence == SEEK_SET) r->pos = (int)offset;
    else r->pos = r->size + (int)offset;
    if (r->pos < 0) r->pos = 0;
    if (r->pos > r->size) r->pos = r->size;
    return r->pos;
}

void *video_open(const unsigned char *data, int len) {
    if (!data || len <= 0) return NULL;
    VideoCtx *ctx = (VideoCtx *)calloc(1, sizeof(VideoCtx));
    if (!ctx) return NULL;
    ctx->data_copy = (unsigned char *)malloc(len);
    if (!ctx->data_copy) { free(ctx); return NULL; }
    memcpy(ctx->data_copy, data, len);
    unsigned char *ioc_buf = (unsigned char *)av_malloc(32768);
    ctx->reader = (MemReader){ctx->data_copy, len, 0};
    AVIOContext *avio = avio_alloc_context(ioc_buf, 32768, 0, &ctx->reader, mem_read, NULL, mem_seek);
    ctx->fmt_ctx = avformat_alloc_context();
    ctx->fmt_ctx->pb = avio;
    if (avformat_open_input(&ctx->fmt_ctx, NULL, NULL, NULL) < 0) {
        av_free(ioc_buf); av_free(avio); free(ctx); return NULL;
    }
    avformat_find_stream_info(ctx->fmt_ctx, NULL);
    ctx->video_stream = -1;
    for (unsigned i = 0; i < ctx->fmt_ctx->nb_streams; i++) {
        if (ctx->fmt_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            ctx->video_stream = i; break;
        }
    }
    if (ctx->video_stream < 0) { avformat_close_input(&ctx->fmt_ctx); free(ctx); return NULL; }
    AVStream *st = ctx->fmt_ctx->streams[ctx->video_stream];
    const AVCodec *codec = avcodec_find_decoder(st->codecpar->codec_id);
    ctx->codec_ctx = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(ctx->codec_ctx, st->codecpar);
    avcodec_open2(ctx->codec_ctx, codec, NULL);
    ctx->width = ctx->codec_ctx->width;
    ctx->height = ctx->codec_ctx->height;
    ctx->duration = (ctx->fmt_ctx->duration > 0) ? (double)ctx->fmt_ctx->duration / AV_TIME_BASE : 0;
    ctx->fps = av_q2d(st->avg_frame_rate);
    ctx->pkt = av_packet_alloc();
    ctx->frame = av_frame_alloc();

    // 打开音频解码器 + ALSA
    ctx->audio_stream = -1;
    for (unsigned i = 0; i < ctx->fmt_ctx->nb_streams; i++) {
        if (ctx->fmt_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) { ctx->audio_stream = i; break; }
    }
    if (ctx->audio_stream >= 0) {
        AVStream *ast = ctx->fmt_ctx->streams[ctx->audio_stream];
        const AVCodec *acodec = avcodec_find_decoder(ast->codecpar->codec_id);
        if (acodec) {
            ctx->acodec_ctx = avcodec_alloc_context3(acodec);
            avcodec_parameters_to_context(ctx->acodec_ctx, ast->codecpar);
            avcodec_open2(ctx->acodec_ctx, acodec, NULL);
            ctx->aframe = av_frame_alloc();
            AVChannelLayout out_layout;
            av_channel_layout_default(&out_layout, ctx->acodec_ctx->ch_layout.nb_channels);
            swr_alloc_set_opts2(&ctx->swr, &out_layout, AV_SAMPLE_FMT_S16, ctx->acodec_ctx->sample_rate,
                &ctx->acodec_ctx->ch_layout, ctx->acodec_ctx->sample_fmt, ctx->acodec_ctx->sample_rate, 0, NULL);
            swr_init(ctx->swr);
            fprintf(stderr, "[C] video: audio=%dHz %dch, video=%dx%d %.1ffps dur=%.1fs\n",
                ctx->acodec_ctx->sample_rate, ctx->acodec_ctx->ch_layout.nb_channels,
                ctx->width, ctx->height, ctx->fps, ctx->duration);
        }
    } else {
        fprintf(stderr, "[C] video: video=%dx%d %.1ffps dur=%.1fs (no audio)\n",
            ctx->width, ctx->height, ctx->fps, ctx->duration);
    }

    return ctx;
}

char *video_get_info(void *handle) {
    if (!handle) return utils_strdup("{\"error\":\"null\"}");
    VideoCtx *ctx = (VideoCtx *)handle;
    char buf[256];
    snprintf(buf, sizeof(buf),
        "{\"error\":\"\",\"width\":%d,\"height\":%d,\"duration\":%.2f,\"fps\":%.2f}",
        ctx->width, ctx->height, ctx->duration, ctx->fps);
    return utils_strdup(buf);
}

int video_next_frame(void *handle, unsigned char *out, int out_cap,
                     int *out_w, int *out_h, double *out_ts) {
    if (!handle) return -1;
    VideoCtx *ctx = (VideoCtx *)handle;

    // 1. 先尝试从解码器内部缓冲取帧（无需读新 packet）
    fprintf(stderr, "[C] video_next_frame enter\n");
    int ret = avcodec_receive_frame(ctx->codec_ctx, ctx->frame);
    fprintf(stderr, "[C] receive_frame#1 ret=%d\n", ret);
    if (ret == 0) goto decode_frame;
    // EAGAIN = 需要新 packet, AVERROR_EOF = 流结束

    // 2. 读新 packet 并送入解码器（限制每次最多读16个packet，避免阻塞主线程）
    int packets_read = 0;
    while (av_read_frame(ctx->fmt_ctx, ctx->pkt) >= 0 && packets_read < 16) {
        packets_read++;
        if (ctx->pkt->stream_index == ctx->video_stream) {
            avcodec_send_packet(ctx->codec_ctx, ctx->pkt);
            ret = avcodec_receive_frame(ctx->codec_ctx, ctx->frame);
            av_packet_unref(ctx->pkt);
            if (ret == 0) goto decode_frame;
        } else {
            av_packet_unref(ctx->pkt);
        }
    }
    // 如果没有读到视频帧，返回EAGAIN让Dart层重试
    if (packets_read > 0) return -3; // EAGAIN-retry
    return 0;  // EOF

decode_frame:
    {
        int srcFmt = ctx->frame->format;
        if (srcFmt < 0) srcFmt = AV_PIX_FMT_YUV420P;
        if (ctx->sws) sws_freeContext(ctx->sws);
        ctx->sws = sws_getContext(ctx->frame->width, ctx->frame->height, srcFmt,
            ctx->width, ctx->height, AV_PIX_FMT_RGBA, SWS_BILINEAR, NULL, NULL, NULL);
        if (!ctx->sws) return -1;
        int need = ctx->width * ctx->height * 4;
        if (out_cap < need) return -2;
        uint8_t *dst[1] = { out }; int dstStride[1] = { ctx->width * 4 };
        // 关键：clone 帧数据，防止解码器内部缓冲被覆盖
        AVFrame *clone = av_frame_clone(ctx->frame);
        sws_scale(ctx->sws, (const uint8_t **)clone->data,
            clone->linesize, 0, clone->height, dst, dstStride);
        av_frame_free(&clone);
        if (out_w) *out_w = ctx->width;
        if (out_h) *out_h = ctx->height;
        if (out_ts) *out_ts = (ctx->frame->pts != AV_NOPTS_VALUE)
            ? (double)ctx->frame->pts * av_q2d(ctx->fmt_ctx->streams[ctx->video_stream]->time_base) : 0;
        return 1;
    }
}





void video_close(void *handle) {
    if (!handle) return;
    VideoCtx *ctx = (VideoCtx *)handle;
    if (ctx->acodec_ctx) avcodec_free_context(&ctx->acodec_ctx);
    if (ctx->swr) swr_free(&ctx->swr);
    if (ctx->aframe) av_frame_free(&ctx->aframe);
    if (ctx->sws) sws_freeContext(ctx->sws);
    if (ctx->pkt) av_packet_free(&ctx->pkt);
    if (ctx->frame) av_frame_free(&ctx->frame);
    if (ctx->codec_ctx) avcodec_free_context(&ctx->codec_ctx);
    if (ctx->fmt_ctx) avformat_close_input(&ctx->fmt_ctx);
    free(ctx->data_copy);
    free(ctx);
}

char *video_thumbnail(const char *path, int max_size) {
    int flen = 0;
    unsigned char *fdata = utils_read_file(path, &flen);
    if (!fdata) return utils_error_json("read failed");
    void *h = video_open(fdata, flen);
    free(fdata);
    if (!h) return utils_error_json("open failed");
    int w = 0, hgt = 0;
    char *info = video_get_info(h);
    const char *p = strstr(info, "\"width\":"); if (p) w = atoi(p + 8);
    p = strstr(info, "\"height\":"); if (p) hgt = atoi(p + 9);
    free(info);
    char *result = utils_error_json("no frame");
    if (w > 0 && hgt > 0) {
        unsigned char *rgba = (unsigned char *)malloc((size_t)w * hgt * 4);
        int cw = 0, chh = 0; double ts = 0;
        int r = video_next_frame(h, rgba, w * hgt * 4, &cw, &chh, &ts);
        if (r == 1 && cw > 0 && chh > 0) {
            int m = cw > chh ? cw : chh;
            float scale = (m > max_size) ? (float)max_size / m : 1.0f;
            int tw = (int)(cw * scale), th = (int)(chh * scale);
            if (tw < 1) tw = 1; if (th < 1) th = 1;
            unsigned char *thumb = (unsigned char *)malloc(tw * th * 4);
            for (int y = 0; y < th; y++)
                for (int x = 0; x < tw; x++) {
                    int sx = x * cw / tw, sy = y * chh / th;
                    unsigned char *src = rgba + (sy * cw + sx) * 4;
                    unsigned char *dst = thumb + (y * tw + x) * 4;
                    dst[0] = src[0]; dst[1] = src[1]; dst[2] = src[2]; dst[3] = src[3];
                }
            int b64_len = 0;
            char *b64 = utils_base64_encode(thumb, tw * th * 4, &b64_len);
            free(thumb);
            size_t sz = b64_len + 128;
            result = (char *)malloc(sz);
            snprintf(result, sz, "{\"error\":\"\",\"base64\":\"%s\",\"width\":%d,\"height\":%d}", b64, tw, th);
            free(b64);
        }
        free(rgba);
    }
    video_close(h);
    return result;
}

// (stream playback removed)
