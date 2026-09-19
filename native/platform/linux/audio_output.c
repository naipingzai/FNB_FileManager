/// audio_output_linux.c - ALSA 音频输出（大 buffer 直写，ffplay 风格）
#include "bridge_api.h"
#include <alsa/asoundlib.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>
#include <stdatomic.h>

// Forward declarations
void audio_output_stop(void *handle);

typedef struct {
    snd_pcm_t *pcm;
    int sample_rate, channels, bits;
    // 线程播放（一次性 PCM 数据，兼容旧接口）
    pthread_t thread;
    atomic_int running;
    const unsigned char *pcm_data;
    int pcm_size, pcm_pos;
} AlsaCtx;

static void *play_thread(void *arg) {
    AlsaCtx *ctx = (AlsaCtx *)arg;
    int frame_bytes = ctx->channels * (ctx->bits / 8);
    snd_pcm_prepare(ctx->pcm);
    while (atomic_load(&ctx->running) && ctx->pcm_pos < ctx->pcm_size) {
        int remaining = ctx->pcm_size - ctx->pcm_pos;
        int chunk = 8192 * frame_bytes;
        if (chunk > remaining) chunk = remaining;
        if (chunk <= 0) break;
        snd_pcm_sframes_t written = snd_pcm_writei(ctx->pcm, ctx->pcm_data + ctx->pcm_pos, chunk / frame_bytes);
        if (written < 0) {
            if (written == -EPIPE) snd_pcm_prepare(ctx->pcm);
            else break;
        } else {
            ctx->pcm_pos += (int)written * frame_bytes;
        }
    }
    if (atomic_load(&ctx->running)) snd_pcm_drain(ctx->pcm);
    return NULL;
}

void *audio_output_open(int sample_rate, int channels, int bits) {
    AlsaCtx *ctx = (AlsaCtx *)calloc(1, sizeof(AlsaCtx));
    if (!ctx) return NULL;
    if (snd_pcm_open(&ctx->pcm, "default", SND_PCM_STREAM_PLAYBACK, 0) < 0) {
        free(ctx); return NULL;
    }
    snd_pcm_hw_params_t *params;
    snd_pcm_hw_params_alloca(&params);
    snd_pcm_hw_params_any(ctx->pcm, params);
    snd_pcm_hw_params_set_access(ctx->pcm, params, SND_PCM_ACCESS_RW_INTERLEAVED);
    snd_pcm_hw_params_set_format(ctx->pcm, params, SND_PCM_FORMAT_S16_LE);
    snd_pcm_hw_params_set_channels(ctx->pcm, params, channels);
    unsigned int sr = sample_rate;
    snd_pcm_hw_params_set_rate_near(ctx->pcm, params, &sr, 0);
    snd_pcm_uframes_t period_size = 4096;
    snd_pcm_uframes_t buffer_size = sr * 4;
    snd_pcm_hw_params_set_period_size_near(ctx->pcm, params, &period_size, 0);
    snd_pcm_hw_params_set_buffer_size_near(ctx->pcm, params, &buffer_size);
    snd_pcm_hw_params(ctx->pcm, params);
    snd_pcm_prepare(ctx->pcm);
    ctx->sample_rate = sr;
    ctx->channels = channels;
    ctx->bits = bits;
    atomic_store(&ctx->running, 0);
    fprintf(stderr, "[C] ALSA opened: sr=%u ch=%d period=%lu buf=%lu\n",
            sr, channels, period_size, buffer_size);
    return ctx;
}

int audio_output_write(void *handle, const unsigned char *pcm, int len) {
    if (!handle || len <= 0) return len;
    AlsaCtx *ctx = (AlsaCtx *)handle;
    int frame_bytes = ctx->channels * (ctx->bits / 8);
    if (frame_bytes <= 0) return len;
    int frames = len / frame_bytes;
    if (frames <= 0) return len;
    snd_pcm_sframes_t written = snd_pcm_writei(ctx->pcm, pcm, frames);
    if (written < 0) {
        if (written == -EPIPE) {
            snd_pcm_prepare(ctx->pcm);
            written = snd_pcm_writei(ctx->pcm, pcm, frames);
        }
    }
    return (written > 0) ? (int)written * frame_bytes : len;
}

void audio_output_play_thread(void *handle, const unsigned char *pcm, int size, int start_offset) {
    if (!handle) return;
    AlsaCtx *ctx = (AlsaCtx *)handle;
    audio_output_stop(handle);
    ctx->pcm_data = pcm + start_offset;
    ctx->pcm_size = size - start_offset;
    ctx->pcm_pos = 0;
    atomic_store(&ctx->running, 1);
    pthread_create(&ctx->thread, NULL, play_thread, ctx);
}

void audio_output_stop(void *handle) {
    if (!handle) return;
    AlsaCtx *ctx = (AlsaCtx *)handle;
    snd_pcm_drop(ctx->pcm);
    if (atomic_load(&ctx->running)) {
        atomic_store(&ctx->running, 0);
        pthread_join(ctx->thread, NULL);
    }
    ctx->pcm_data = NULL;
    ctx->pcm_size = 0;
    ctx->pcm_pos = 0;
}

void audio_output_close(void *handle) {
    if (!handle) return;
    AlsaCtx *ctx = (AlsaCtx *)handle;
    audio_output_stop(handle);
    snd_pcm_close(ctx->pcm);
    free(ctx);
}
