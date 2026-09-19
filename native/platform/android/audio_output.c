/// audio_output_android.c - AAudio 音频输出（同步写入 + 线程播放）
#include "bridge_api.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <aaudio/AAudio.h>
#include <pthread.h>
#include <stdatomic.h>

typedef struct {
    AAudioStreamBuilder *builder;
    AAudioStream *stream;
    int sample_rate, channels, bits;
    // 线程播放
    pthread_t thread;
    atomic_int running;
    const unsigned char *pcm_data;
    int pcm_size;
    int pcm_pos;
} AAudioCtx;

static void audio_output_stop(void *handle);
static void *play_thread(void *arg) {
    AAudioCtx *ctx = (AAudioCtx *)arg;
    int frame_bytes = ctx->channels * (ctx->bits / 8);

    while (atomic_load(&ctx->running) && ctx->pcm_pos < ctx->pcm_size) {
        int remaining = ctx->pcm_size - ctx->pcm_pos;
        int chunk = 4096 * frame_bytes;
        if (chunk > remaining) chunk = remaining;
        if (chunk <= 0) break;

        int32_t written = AAudioStream_write(ctx->stream,
            ctx->pcm_data + ctx->pcm_pos, chunk / frame_bytes, 1000);

        if (written > 0) {
            ctx->pcm_pos += written * frame_bytes;
        } else {
            // AAudio error or timeout, retry
            fprintf(stderr, "[C] AAudio thread write: %d\n", written);
            break;
        }
    }
    fprintf(stderr, "[C] AAudio thread finished: pos=%d size=%d\n", ctx->pcm_pos, ctx->pcm_size);
    AAudioStream_requestStop(ctx->stream);
    return NULL;
}

void *audio_output_open(int sample_rate, int channels, int bits) {
    AAudioCtx *ctx = (AAudioCtx *)calloc(1, sizeof(AAudioCtx));
    if (!ctx) return NULL;

    AAudio_createStreamBuilder(&ctx->builder);
    AAudioStreamBuilder_setDirection(ctx->builder, AAUDIO_DIRECTION_OUTPUT);
    AAudioStreamBuilder_setSampleRate(ctx->builder, sample_rate);
    AAudioStreamBuilder_setChannelCount(ctx->builder, channels);
    AAudioStreamBuilder_setFormat(ctx->builder, AAUDIO_FORMAT_PCM_I16);
    AAudioStreamBuilder_setPerformanceMode(ctx->builder, AAUDIO_PERFORMANCE_MODE_LOW_LATENCY);
    AAudioStreamBuilder_openStream(ctx->builder, &ctx->stream);

    ctx->sample_rate = sample_rate;
    ctx->channels = channels;
    ctx->bits = bits;
    atomic_store(&ctx->running, 0);
    return ctx;
}

int audio_output_write(void *handle, const unsigned char *pcm, int len) {
    if (!handle) return -1;
    AAudioCtx *ctx = (AAudioCtx *)handle;
    int frames = len / (ctx->channels * (ctx->bits / 8));
    AAudioStream_write(ctx->stream, pcm, frames, 1000);
    return len;
}

void audio_output_play_thread(void *handle, const unsigned char *pcm, int size, int start_offset) {
    if (!handle) return;
    AAudioCtx *ctx = (AAudioCtx *)handle;
    // 先停旧线程
    audio_output_stop(handle);
    ctx->pcm_data = pcm + start_offset;
    ctx->pcm_size = size - start_offset;
    ctx->pcm_pos = 0;
    atomic_store(&ctx->running, 1);
    pthread_create(&ctx->thread, NULL, play_thread, ctx);
}

void audio_output_stop(void *handle) {
    if (!handle) return;
    AAudioCtx *ctx = (AAudioCtx *)handle;
    if (atomic_load(&ctx->running)) {
        atomic_store(&ctx->running, 0);
        pthread_join(ctx->thread, NULL);
    }
    ctx->pcm_data = NULL;
    ctx->pcm_size = 0;
    ctx->pcm_pos = 0;
    AAudioStream_requestStop(ctx->stream);
}

void audio_output_close(void *handle) {
    if (!handle) return;
    AAudioCtx *ctx = (AAudioCtx *)handle;
    audio_output_stop(handle);
    AAudioStream_close(ctx->stream);
    AAudioStreamBuilder_delete(ctx->builder);
    free(ctx);
}
