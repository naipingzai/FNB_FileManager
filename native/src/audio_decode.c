/// audio_decode.c - FFmpeg 音频解码模块
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/channel_layout.h>
#include <libavutil/opt.h>
#include <libswresample/swresample.h>

extern char *utils_base64_encode(const unsigned char *data, int len, int *out_len);
extern char *utils_strdup(const char *s);
extern char *utils_error_json(const char *msg);

typedef struct { const unsigned char *data; int size, pos; } AudioMemReader;

static int audio_mem_read(void *opaque, uint8_t *buf, int buf_size) {
    AudioMemReader *r = (AudioMemReader *)opaque;
    int avail = r->size - r->pos;
    if (avail <= 0) return AVERROR_EOF;
    int n = buf_size > avail ? avail : buf_size;
    memcpy(buf, r->data + r->pos, n); r->pos += n;
    return n;
}

static int64_t audio_mem_seek(void *opaque, int64_t offset, int whence) {
    AudioMemReader *r = (AudioMemReader *)opaque;
    if (whence == AVSEEK_SIZE) return r->size;
    if (whence == SEEK_CUR) r->pos += (int)offset;
    else if (whence == SEEK_SET) r->pos = (int)offset;
    else r->pos = r->size + (int)offset;
    if (r->pos < 0) r->pos = 0;
    if (r->pos > r->size) r->pos = r->size;
    return r->pos;
}

char *audio_decode(const unsigned char *data, int len) {
    if (!data || len <= 0) return utils_error_json("invalid input");

    AudioMemReader reader = {data, len, 0};
    unsigned char *ioc_buf = (unsigned char *)av_malloc(32768);
    AVIOContext *avio = avio_alloc_context(ioc_buf, 32768, 0, &reader, audio_mem_read, NULL, audio_mem_seek);

    AVFormatContext *fmt_ctx = avformat_alloc_context();
    fmt_ctx->pb = avio;

    if (avformat_open_input(&fmt_ctx, NULL, NULL, NULL) < 0) {
        av_free(ioc_buf); av_free(avio);
        return utils_error_json("open failed");
    }
    avformat_find_stream_info(fmt_ctx, NULL);

    int audio_stream = -1;
    for (unsigned i = 0; i < fmt_ctx->nb_streams; i++) {
        if (fmt_ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            audio_stream = i; break;
        }
    }
    if (audio_stream < 0) {
        avformat_close_input(&fmt_ctx);
        return utils_error_json("no audio stream");
    }

    AVStream *st = fmt_ctx->streams[audio_stream];
    const AVCodec *codec = avcodec_find_decoder(st->codecpar->codec_id);
    AVCodecContext *codec_ctx = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(codec_ctx, st->codecpar);
    avcodec_open2(codec_ctx, codec, NULL);

    // 设置重采样到 S16 stereo
    struct SwrContext *swr = swr_alloc();
    AVChannelLayout out_layout = AV_CHANNEL_LAYOUT_STEREO;
    swr_alloc_set_opts2(&swr, &out_layout, AV_SAMPLE_FMT_S16, 44100,
        &codec_ctx->ch_layout, codec_ctx->sample_fmt, codec_ctx->sample_rate, 0, NULL);
    swr_init(swr);

    // 解码所有帧
    int total_samples = 0;
    int16_t *pcm_buf = NULL;
    int pcm_cap = 0;
    AVPacket *pkt = av_packet_alloc();
    AVFrame *frame = av_frame_alloc();

    while (av_read_frame(fmt_ctx, pkt) >= 0) {
        if (pkt->stream_index != audio_stream) { av_packet_unref(pkt); continue; }
        avcodec_send_packet(codec_ctx, pkt);
        while (avcodec_receive_frame(codec_ctx, frame) == 0) {
            int out_samples = swr_get_out_samples(swr, frame->nb_samples);
            int needed = total_samples + out_samples * 2; // S16 = 2 bytes per sample
            if (needed > pcm_cap) {
                pcm_cap = needed * 2;
                pcm_buf = (int16_t *)realloc(pcm_buf, pcm_cap * sizeof(int16_t));
            }
            uint8_t *out_ptr = (uint8_t *)(pcm_buf + total_samples);
            int converted = swr_convert(swr, &out_ptr, out_samples,
                (const uint8_t **)frame->data, frame->nb_samples);
            total_samples += converted * 2; // stereo
        }
        av_packet_unref(pkt);
    }

    av_packet_free(&pkt);
    av_frame_free(&frame);
    swr_free(&swr);
    avcodec_free_context(&codec_ctx);
    avformat_close_input(&fmt_ctx);
    // 注意: avformat_close_input 已经释放了 avio 和 ioc_buf，不要再 free

    // 编码为 base64
    int b64_len = 0;
    char *b64 = utils_base64_encode((unsigned char *)pcm_buf, total_samples * (int)sizeof(int16_t), &b64_len);
    free(pcm_buf);

    size_t json_sz = b64_len + 256;
    char *json = (char *)malloc(json_sz);
    snprintf(json, json_sz,
        "{\"error\":\"\",\"base64\":\"%s\",\"sample_rate\":44100,\"channels\":2,\"bits\":16,\"length\":%d}",
        b64, total_samples);
    free(b64);
    return json;
}
