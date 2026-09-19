/// media_tools.c - Media tools (GIF/Trim/Audio Extract/Info)
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/opt.h>
#include <libavutil/imgutils.h>
#include <libavutil/mathematics.h>
#include <libswscale/swscale.h>

extern char *utils_strdup(const char *s);
extern char *utils_error_json(const char *msg);
extern int g_progress_current;
extern int g_progress_total;
extern int g_cancel_requested;

// GIF
int video_to_gif(const char *input, const char *output,
    int start_sec, int duration_sec, int fps, int width,
    char *error, int err_sz) {
    g_progress_current = 0; g_progress_total = 0; g_cancel_requested = 0;
    AVFormatContext *ifmt = NULL; AVCodecContext *dec = NULL, *enc = NULL;
    AVFrame *frm = NULL, *rgb = NULL, *pal = NULL;
    AVPacket *ipkt = NULL, *opkt = NULL;
    struct SwsContext *sws = NULL; int vi = -1, ret = -1;
    if (avformat_open_input(&ifmt, input, NULL, NULL) < 0)
        { if (error) snprintf(error, err_sz, "cannot open input"); return -1; }
    avformat_find_stream_info(ifmt, NULL);
    for (unsigned i = 0; i < ifmt->nb_streams; i++)
        if (ifmt->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) { vi = i; break; }
    if (vi < 0) { if (error) snprintf(error, err_sz, "no video"); avformat_close_input(&ifmt); return -1; }
    AVStream *st = ifmt->streams[vi];
    const AVCodec *dc = avcodec_find_decoder(st->codecpar->codec_id);
    dec = avcodec_alloc_context3(dc); avcodec_parameters_to_context(dec, st->codecpar);
    avcodec_open2(dec, dc, NULL);
    double src_fps = av_q2d(st->avg_frame_rate);
    if (fps <= 0) fps = (int)src_fps; if (fps > 50) fps = 50;
    int dst_w = (width > 0 && dec->width > width) ? width : dec->width;
    int dst_h = (int)((double)dec->height * dst_w / dec->width);
    AVFormatContext *ofmt = NULL;
    avformat_alloc_output_context2(&ofmt, NULL, NULL, output);
    if (!ofmt) { if (error) snprintf(error, err_sz, "cannot create output"); goto gdone; }
    AVStream *ost = avformat_new_stream(ofmt, NULL);
    const AVCodec *ec = avcodec_find_encoder(AV_CODEC_ID_GIF);
    enc = avcodec_alloc_context3(ec);
    enc->width = dst_w; enc->height = dst_h;
    enc->time_base = (AVRational){1, fps};
    enc->pix_fmt = AV_PIX_FMT_PAL8;
    enc->framerate = (AVRational){fps, 1};
    avcodec_open2(enc, ec, NULL);
    avcodec_parameters_from_context(ost->codecpar, enc);
    ost->time_base = enc->time_base;
    if (!(ofmt->oformat->flags & AVFMT_NOFILE))
        if (avio_open(&ofmt->pb, output, AVIO_FLAG_WRITE) < 0)
            { if (error) snprintf(error, err_sz, "cannot open file"); goto gdone; }
    avformat_write_header(ofmt, NULL);
    if (start_sec > 0) { av_seek_frame(ifmt, -1, (int64_t)start_sec * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD); avcodec_flush_buffers(dec); }
    frm = av_frame_alloc(); rgb = av_frame_alloc(); pal = av_frame_alloc();
    ipkt = av_packet_alloc(); opkt = av_packet_alloc();
    sws = sws_getContext(dec->width, dec->height, dec->pix_fmt, dst_w, dst_h, AV_PIX_FMT_RGB24, SWS_FAST_BILINEAR, NULL, NULL, NULL);
    int frames_needed = fps * duration_sec;
    g_progress_total = frames_needed > 0 ? frames_needed : 1;
    int frame_count = 0;
    while (av_read_frame(ifmt, ipkt) >= 0 && frame_count < frames_needed && !g_cancel_requested) {
        if (ipkt->stream_index != vi) { av_packet_unref(ipkt); continue; }
        avcodec_send_packet(dec, ipkt); av_packet_unref(ipkt);
        while (avcodec_receive_frame(dec, frm) == 0) {
            frame_count++; g_progress_current = frame_count;
            av_frame_unref(rgb);
            rgb->format = AV_PIX_FMT_RGB24; rgb->width = dst_w; rgb->height = dst_h;
            av_frame_get_buffer(rgb, 32);
            uint8_t *dstp[1] = { rgb->data[0] };
            int stride[1] = { dst_w * 3 };
            sws_scale(sws, (const uint8_t **)frm->data, frm->linesize, 0, dec->height, dstp, stride);
            av_frame_unref(pal);
            pal->format = AV_PIX_FMT_PAL8; pal->width = dst_w; pal->height = dst_h;
            av_frame_get_buffer(pal, 32); pal->pts = frame_count; pal->duration = 1;
            uint8_t *rgb_d = rgb->data[0]; uint8_t *pal_d = pal->data[0];
            uint32_t *pe = (uint32_t *)pal->data[1]; int ps = 32;
            for (int c = 0; c < ps; c++)
                pe[c] = 0xFF000000 | (((c*255/ps)&0xFF)<<16) | (((c*128/ps)&0xFF)<<8) | ((c*64/ps)&0xFF);
            for (int i = 0; i < dst_w * dst_h; i++) {
                int r = rgb_d[i*3], g = rgb_d[i*3+1], b = rgb_d[i*3+2];
                pal_d[i] = (uint8_t)(((r+g+b) * ps / 768) % ps);
            }
            pal->linesize[0] = dst_w;
            avcodec_send_frame(enc, pal);
            while (avcodec_receive_packet(enc, opkt) == 0) {
                opkt->stream_index = 0;
                av_packet_rescale_ts(opkt, enc->time_base, ost->time_base);
                av_interleaved_write_frame(ofmt, opkt); av_packet_unref(opkt);
            }
            av_frame_unref(rgb); av_frame_unref(pal);
        }
    }
    av_write_trailer(ofmt); g_progress_current = g_progress_total; ret = 0;
gdone:
    if (sws) sws_freeContext(sws);
    if (frm) av_frame_free(&frm); if (rgb) av_frame_free(&rgb); if (pal) av_frame_free(&pal);
    if (ipkt) av_packet_free(&ipkt); if (opkt) av_packet_free(&opkt);
    if (dec) avcodec_free_context(&dec); if (enc) avcodec_free_context(&enc);
    if (ofmt) { if (!(ofmt->oformat->flags & AVFMT_NOFILE) && ofmt->pb) avio_closep(&ofmt->pb); avformat_free_context(ofmt); }
    if (ifmt) avformat_close_input(&ifmt);
    return ret;
}

// Trim
int video_trim(const char *input, const char *output,
    int start_sec, int end_sec, char *error, int err_sz) {
    g_progress_current = 0; g_progress_total = 0; g_cancel_requested = 0;
    AVFormatContext *ifmt = NULL, *ofmt = NULL;
    AVCodecContext *dec = NULL, *enc = NULL;
    struct SwsContext *sws = NULL;
    AVFrame *frm = NULL, *efrm = NULL;
    AVPacket *ipkt = NULL, *opkt = NULL;
    int vi = -1, ret = -1;
    if (avformat_open_input(&ifmt, input, NULL, NULL) < 0)
        { if (error) snprintf(error, err_sz, "cannot open input"); return -1; }
    avformat_find_stream_info(ifmt, NULL);
    for (unsigned i = 0; i < ifmt->nb_streams; i++)
        if (ifmt->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) { vi = i; break; }
    if (vi < 0) { if (error) snprintf(error, err_sz, "no video"); avformat_close_input(&ifmt); return -1; }
    AVStream *ist = ifmt->streams[vi];
    const AVCodec *dc = avcodec_find_decoder(ist->codecpar->codec_id);
    dec = avcodec_alloc_context3(dc);
    avcodec_parameters_to_context(dec, ist->codecpar); avcodec_open2(dec, dc, NULL);
    avformat_alloc_output_context2(&ofmt, NULL, NULL, output);
    if (!ofmt) { if (error) snprintf(error, err_sz, "cannot open output"); goto tdone; }
    AVStream *ost = avformat_new_stream(ofmt, NULL);
    const AVCodec *ec = avcodec_find_encoder(AV_CODEC_ID_H264);
    enc = avcodec_alloc_context3(ec);
    enc->width = dec->width; enc->height = dec->height;
    enc->pix_fmt = AV_PIX_FMT_YUV420P;
    enc->time_base = av_inv_q(ist->avg_frame_rate);
    enc->framerate = ist->avg_frame_rate;
    enc->bit_rate = (int64_t)dec->width * dec->height * 3 * 2;
    AVDictionary *opts = NULL; av_dict_set(&opts, "preset", "fast", 0);
    if (avcodec_open2(enc, ec, &opts) < 0)
        { if (error) snprintf(error, err_sz, "encoder failed"); goto tdone; }
    avcodec_parameters_from_context(ost->codecpar, enc);
    ost->time_base = enc->time_base;
    if (!(ofmt->oformat->flags & AVFMT_NOFILE))
        if (avio_open(&ofmt->pb, output, AVIO_FLAG_WRITE) < 0)
            { if (error) snprintf(error, err_sz, "cannot open output file"); goto tdone; }
    avformat_write_header(ofmt, NULL);
    if (start_sec > 0) {
        av_seek_frame(ifmt, -1, (int64_t)start_sec * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
        avcodec_flush_buffers(dec);
    }
    frm = av_frame_alloc(); efrm = av_frame_alloc();
    ipkt = av_packet_alloc(); opkt = av_packet_alloc();
    sws = sws_getContext(dec->width, dec->height, dec->pix_fmt,
        enc->width, enc->height, AV_PIX_FMT_YUV420P, SWS_FAST_BILINEAR, NULL, NULL, NULL);
    double dur = (end_sec > start_sec) ? (end_sec - start_sec) : 60;
    g_progress_total = (int)(av_q2d(ist->avg_frame_rate) * dur);
    if (g_progress_total <= 0) g_progress_total = 1;
    while (av_read_frame(ifmt, ipkt) >= 0 && !g_cancel_requested) {
        if (ipkt->stream_index != vi) { av_packet_unref(ipkt); continue; }
        avcodec_send_packet(dec, ipkt); av_packet_unref(ipkt);
        while (avcodec_receive_frame(dec, frm) == 0) {
            double ts = (frm->pts != AV_NOPTS_VALUE) ? (double)frm->pts * av_q2d(ist->time_base) : 0;
            if (end_sec > 0 && ts > end_sec) goto tflush;
            g_progress_current++;
            efrm->format = AV_PIX_FMT_YUV420P; efrm->width = enc->width; efrm->height = enc->height;
            efrm->pts = frm->pts; av_frame_get_buffer(efrm, 32);
            sws_scale(sws, (const uint8_t **)frm->data, frm->linesize, 0, dec->height, efrm->data, efrm->linesize);
            avcodec_send_frame(enc, efrm); av_frame_unref(efrm);
            while (avcodec_receive_packet(enc, opkt) == 0) {
                opkt->stream_index = 0; av_packet_rescale_ts(opkt, enc->time_base, ost->time_base);
                av_interleaved_write_frame(ofmt, opkt); av_packet_unref(opkt);
            }
        }
    }
tflush:
    avcodec_send_frame(enc, NULL);
    while (avcodec_receive_packet(enc, opkt) == 0) {
        opkt->stream_index = 0; av_packet_rescale_ts(opkt, enc->time_base, ost->time_base);
        av_interleaved_write_frame(ofmt, opkt); av_packet_unref(opkt);
    }
    av_write_trailer(ofmt); g_progress_current = g_progress_total; ret = 0;
tdone:
    if (sws) sws_freeContext(sws);
    if (frm) av_frame_free(&frm); if (efrm) av_frame_free(&efrm);
    if (ipkt) av_packet_free(&ipkt); if (opkt) av_packet_free(&opkt);
    if (dec) avcodec_free_context(&dec); if (enc) avcodec_free_context(&enc);
    if (ofmt) { if (!(ofmt->oformat->flags & AVFMT_NOFILE) && ofmt->pb) avio_closep(&ofmt->pb); avformat_free_context(ofmt); }
    if (ifmt) avformat_close_input(&ifmt);
    return ret;
}

// Extract Audio (stream copy)
int video_extract_audio(const char *input, const char *output, char *error, int err_sz) {
    g_progress_current = 0; g_progress_total = 0; g_cancel_requested = 0;
    AVFormatContext *ifmt = NULL, *ofmt = NULL;
    AVPacket *ipkt = NULL, *opkt = NULL;
    int ai = -1, ret = -1;
    if (avformat_open_input(&ifmt, input, NULL, NULL) < 0)
        { if (error) snprintf(error, err_sz, "cannot open input"); return -1; }
    avformat_find_stream_info(ifmt, NULL);
    for (unsigned i = 0; i < ifmt->nb_streams; i++)
        if (ifmt->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) { ai = i; break; }
    if (ai < 0) { if (error) snprintf(error, err_sz, "no audio"); avformat_close_input(&ifmt); return -1; }
    AVStream *ist = ifmt->streams[ai];
    avformat_alloc_output_context2(&ofmt, NULL, NULL, output);
    if (!ofmt) { if (error) snprintf(error, err_sz, "cannot open output"); goto aend; }
    AVStream *ost = avformat_new_stream(ofmt, NULL);
    avcodec_parameters_copy(ost->codecpar, ist->codecpar);
    ost->time_base = ist->time_base;
    if (!(ofmt->oformat->flags & AVFMT_NOFILE))
        if (avio_open(&ofmt->pb, output, AVIO_FLAG_WRITE) < 0)
            { if (error) snprintf(error, err_sz, "cannot open file"); goto aend; }
    avformat_write_header(ofmt, NULL);
    ipkt = av_packet_alloc(); opkt = av_packet_alloc();
    g_progress_total = (int)(ifmt->duration > 0 ? ifmt->duration / (AV_TIME_BASE / 10) : 1);
    if (g_progress_total <= 0) g_progress_total = 1;
    while (av_read_frame(ifmt, ipkt) >= 0 && !g_cancel_requested) {
        if (ipkt->stream_index != ai) { av_packet_unref(ipkt); continue; }
        g_progress_current = (int)(ipkt->pts > 0 ? ipkt->pts * av_q2d(ist->time_base) * 10 : g_progress_current + 1);
        opkt = av_packet_clone(ipkt); opkt->stream_index = 0;
        av_interleaved_write_frame(ofmt, opkt);
        av_packet_unref(opkt); av_packet_unref(ipkt);
        opkt = av_packet_alloc();
    }
    av_write_trailer(ofmt); g_progress_current = g_progress_total; ret = 0;
aend:
    if (ipkt) av_packet_free(&ipkt); if (opkt) av_packet_free(&opkt);
    if (ofmt) { if (!(ofmt->oformat->flags & AVFMT_NOFILE) && ofmt->pb) avio_closep(&ofmt->pb); avformat_free_context(ofmt); }
    if (ifmt) avformat_close_input(&ifmt);
    return ret;
}
char *media_get_info(const char *path) {
    AVFormatContext *ctx = NULL;
    if (avformat_open_input(&ctx, path, NULL, NULL) < 0)
        return utils_error_json("cannot open file");
    avformat_find_stream_info(ctx, NULL);
    char buf[4096]; int pos = 0;
    pos += snprintf(buf+pos, sizeof(buf)-pos, "{\"format\":\"%s\",\"duration\":%.3f,\"streams\":[",
        ctx->iformat->name ? ctx->iformat->name : "unknown",
        ctx->duration > 0 ? (double)ctx->duration / AV_TIME_BASE : 0);
    for (unsigned i = 0; i < ctx->nb_streams && pos < (int)sizeof(buf) - 256; i++) {
        AVStream *st = ctx->streams[i];
        const char *type = "unknown";
        if (st->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) type = "video";
        else if (st->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) type = "audio";
        else if (st->codecpar->codec_type == AVMEDIA_TYPE_SUBTITLE) type = "subtitle";
        if (i > 0) buf[pos++] = ',';
        pos += snprintf(buf+pos, sizeof(buf)-pos, "{\"index\":%d,\"type\":\"%s\",\"codec\":\"%s\"",
            i, type, avcodec_get_name(st->codecpar->codec_id));
        if (st->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            pos += snprintf(buf+pos, sizeof(buf)-pos, ",\"width\":%d,\"height\":%d,\"fps\":%.2f",
                st->codecpar->width, st->codecpar->height,
                st->avg_frame_rate.num > 0 ? av_q2d(st->avg_frame_rate) : 0);
        } else if (st->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            pos += snprintf(buf+pos, sizeof(buf)-pos, ",\"sample_rate\":%d,\"channels\":%d",
                st->codecpar->sample_rate, st->codecpar->ch_layout.nb_channels);
        }
        buf[pos++] = '}';
    }
    pos += snprintf(buf+pos, sizeof(buf)-pos, "]}\n");
    avformat_close_input(&ctx);
    return utils_strdup(buf);
}
