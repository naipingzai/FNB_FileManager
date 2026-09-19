/// video_convert.c - 视频格式转换（FFmpeg 转码）
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>

int g_progress_current = 0;
int g_progress_total = 0;
int g_cancel_requested = 0;

int video_convert_get_progress(int *current, int *total) {
    if (current) *current = g_progress_current;
    if (total) *total = g_progress_total;
    return (g_progress_current > 0 && g_progress_current < g_progress_total) ? 1 : 0;
}

int video_convert_cancel(void) { g_cancel_requested = 1; return 0; }

int video_convert(const char *input, const char *output,
                  const char *codec, const char *container, int bitrate_kbps, int max_w,
                  char *error, int err_sz) {
    if (!input || !output) { if (error) snprintf(error, err_sz, "null path"); return -1; }
    fprintf(stderr, "[CONVERT] start: input=%s output=%s codec=%s container=%s\n",
            input, output, codec ? codec : "null", container ? container : "null");
    g_progress_current = 0; g_progress_total = 0; g_cancel_requested = 0;

    // 如果指定了容器格式，追加到输出路径
    char actual_output[1024];
    if (container && container[0]) {
        snprintf(actual_output, sizeof(actual_output), "%s.%s", output, container);
    } else {
        snprintf(actual_output, sizeof(actual_output), "%s", output);
    }

    AVFormatContext *ifmt = NULL, *ofmt = NULL;
    AVCodecContext *dec = NULL, *enc = NULL;
    struct SwsContext *sws = NULL;
    AVFrame *frm = NULL, *efrm = NULL;
    AVPacket *ipkt = NULL, *opkt = NULL;
    int ret = -1;

    if (avformat_open_input(&ifmt, input, NULL, NULL) < 0) {
        if (error) snprintf(error, err_sz, "cannot open input"); return -1; }
    avformat_find_stream_info(ifmt, NULL);

    int vi = -1;
    for (unsigned i = 0; i < ifmt->nb_streams; i++)
        if (ifmt->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) { vi = i; break; }
    if (vi < 0) { if (error) snprintf(error, err_sz, "no video"); avformat_close_input(&ifmt); return -1; }

    AVStream *ist = ifmt->streams[vi];
    const AVCodec *dc = avcodec_find_decoder(ist->codecpar->codec_id);
    dec = avcodec_alloc_context3(dc);
    avcodec_parameters_to_context(dec, ist->codecpar);
    avcodec_open2(dec, dc, NULL);

    // 选择编码器
    enum AVCodecID eid = AV_CODEC_ID_H264;
    if (codec && strcmp(codec, "h265") == 0) eid = AV_CODEC_ID_HEVC;
    else if (codec && strcmp(codec, "copy") == 0) eid = ist->codecpar->codec_id;
    const AVCodec *ec = avcodec_find_encoder(eid);
    if (!ec) { ec = avcodec_find_encoder(AV_CODEC_ID_H264); eid = AV_CODEC_ID_H264; }

    avformat_alloc_output_context2(&ofmt, NULL, NULL, actual_output);
    if (!ofmt) {
        if (error) snprintf(error, err_sz, "cannot determine output format for: %s", actual_output);
        fprintf(stderr, "[CONVERT] FAIL: cannot determine format for %s\n", actual_output);
        goto done;
    }
    AVStream *ost = avformat_new_stream(ofmt, NULL);
    enc = avcodec_alloc_context3(ec);
    enc->width = (max_w > 0 && dec->width > max_w) ? max_w : dec->width;
    enc->height = (max_w > 0 && dec->width > max_w)
        ? (int)((double)dec->height * max_w / dec->width) : dec->height;
    enc->pix_fmt = AV_PIX_FMT_YUV420P;
    enc->time_base = av_inv_q(ist->avg_frame_rate);
    enc->framerate = ist->avg_frame_rate;
    enc->bit_rate = bitrate_kbps > 0 ? (int64_t)bitrate_kbps * 1000
        : (int64_t)dec->width * dec->height * 3 * 2;
    if (ofmt->oformat->flags & AVFMT_GLOBALHEADER) enc->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

    AVDictionary *opts = NULL;
    if (eid == AV_CODEC_ID_H264) { av_dict_set(&opts, "preset", "fast", 0); }
    if (avcodec_open2(enc, ec, &opts) < 0) {
        if (error) snprintf(error, err_sz, "encoder failed"); goto done; }
    avcodec_parameters_from_context(ost->codecpar, enc);
    ost->time_base = enc->time_base;

    if (!(ofmt->oformat->flags & AVFMT_NOFILE))
        if (avio_open(&ofmt->pb, actual_output, AVIO_FLAG_WRITE) < 0) {
            if (error) snprintf(error, err_sz, "cannot open output"); goto done; }
    if (avformat_write_header(ofmt, NULL) < 0) {
        if (error) snprintf(error, err_sz, "write header failed"); goto done; }

    double fps = av_q2d(ist->avg_frame_rate);
    double dur = (ifmt->duration > 0) ? (double)ifmt->duration / AV_TIME_BASE : 60;
    g_progress_total = (int)(fps * dur); if (g_progress_total <= 0) g_progress_total = 1;

    frm = av_frame_alloc(); efrm = av_frame_alloc();
    ipkt = av_packet_alloc(); opkt = av_packet_alloc();

    sws = sws_getContext(dec->width, dec->height, dec->pix_fmt,
        enc->width, enc->height, AV_PIX_FMT_YUV420P, SWS_FAST_BILINEAR, NULL, NULL, NULL);

    while (!g_cancel_requested && av_read_frame(ifmt, ipkt) >= 0) {
        if (ipkt->stream_index != vi) { av_packet_unref(ipkt); continue; }
        avcodec_send_packet(dec, ipkt); av_packet_unref(ipkt);
        while (avcodec_receive_frame(dec, frm) == 0) {
            g_progress_current++;
            efrm->format = AV_PIX_FMT_YUV420P;
            efrm->width = enc->width; efrm->height = enc->height;
            efrm->pts = frm->pts;
            av_frame_get_buffer(efrm, 32);
            sws_scale(sws, (const uint8_t **)frm->data, frm->linesize,
                0, dec->height, efrm->data, efrm->linesize);
            avcodec_send_frame(enc, efrm); av_frame_unref(efrm);
            while (avcodec_receive_packet(enc, opkt) == 0) {
                opkt->stream_index = 0;
                av_packet_rescale_ts(opkt, enc->time_base, ost->time_base);
                av_interleaved_write_frame(ofmt, opkt);
                av_packet_unref(opkt);
            }
        }
    }
    avcodec_send_frame(enc, NULL);
    while (avcodec_receive_packet(enc, opkt) == 0) {
        opkt->stream_index = 0;
        av_packet_rescale_ts(opkt, enc->time_base, ost->time_base);
        av_interleaved_write_frame(ofmt, opkt); av_packet_unref(opkt);
    }
    av_write_trailer(ofmt);
    g_progress_current = g_progress_total;
    ret = 0;

done:
    if (sws) sws_freeContext(sws);
    if (frm) av_frame_free(&frm);
    if (efrm) av_frame_free(&efrm);
    if (ipkt) av_packet_free(&ipkt);
    if (opkt) av_packet_free(&opkt);
    if (dec) avcodec_free_context(&dec);
    if (enc) avcodec_free_context(&enc);
    if (ofmt) {
        if (!(ofmt->oformat->flags & AVFMT_NOFILE) && ofmt->pb) avio_closep(&ofmt->pb);
        avformat_free_context(ofmt);
    }
    if (ifmt) avformat_close_input(&ifmt);
    return ret;
}