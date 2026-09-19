/// epub.c - EPUB 电子书解析模块 (miniz)
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "miniz.h"

extern char *utils_strdup(const char *s);
extern unsigned char *utils_read_file(const char *path, int *out_len);
extern char *utils_error_json(const char *msg);

char *epub_list_files(const char *path) {
    int len = 0;
    unsigned char *data = utils_read_file(path, &len);
    if (!data) return utils_error_json("read failed");

    mz_zip_archive zip;
    memset(&zip, 0, sizeof(zip));
    if (!mz_zip_reader_init_mem(&zip, data, len, 0)) {
        free(data);
        return utils_error_json("not a valid epub/zip");
    }

    mz_uint n = mz_zip_reader_get_num_files(&zip);
    size_t cap = 64 + n * 256;
    char *json = (char *)malloc(cap);
    if (!json) { mz_zip_reader_end(&zip); free(data); return utils_error_json("alloc"); }

    size_t pos = 0;
    pos += snprintf(json + pos, cap - pos, "{\"error\":\"\",\"files\":[");
    for (mz_uint i = 0; i < n; i++) {
        mz_zip_archive_file_stat st;
        if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
        if (i > 0) pos += snprintf(json + pos, cap - pos, ",");
        size_t need = 16 + strlen(st.m_filename) * 2;
        if (pos + need >= cap) { cap *= 2; json = (char *)realloc(json, cap); }
        pos += snprintf(json + pos, cap - pos, "{\"name\":\"%s\",\"size\":%llu}",
            st.m_filename, (unsigned long long)st.m_uncomp_size);
    }
    pos += snprintf(json + pos, cap - pos, "]}");

    mz_zip_reader_end(&zip);
    free(data);
    return json;
}

char *epub_extract_text(const char *path) {
    int len = 0;
    unsigned char *data = utils_read_file(path, &len);
    if (!data) return utils_error_json("read failed");

    mz_zip_archive zip;
    memset(&zip, 0, sizeof(zip));
    if (!mz_zip_reader_init_mem(&zip, data, len, 0)) {
        free(data);
        return utils_error_json("not a valid epub/zip");
    }

    // 找 content.opf
    mz_uint n = mz_zip_reader_get_num_files(&zip);
    (void)n; // suppress unused warning

    // 提取所有 xhtml/html 文件的文本
    size_t text_cap = 4096;
    char *text = (char *)malloc(text_cap);
    size_t text_pos = 0;
    text[0] = '\0';

    for (mz_uint i = 0; i < n; i++) {
        mz_zip_archive_file_stat st;
        if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
        const char *name = st.m_filename;
        if (strstr(name, ".xhtml") || strstr(name, ".html") || strstr(name, ".htm")) {
            size_t uncomp_size = 0;
            void *file_data = mz_zip_reader_extract_to_heap(&zip, i, &uncomp_size, 0);
            if (file_data && uncomp_size > 0) {
                // 简单提取：去掉 HTML 标签
                const char *src = (const char *)file_data;
                int in_tag = 0;
                for (size_t j = 0; j < uncomp_size; j++) {
                    if (src[j] == '<') in_tag = 1;
                    else if (src[j] == '>') in_tag = 0;
                    else if (!in_tag && src[j] != '\n' && src[j] != '\r') {
                        if (text_pos + 1 >= text_cap) { text_cap *= 2; text = (char *)realloc(text, text_cap); }
                        text[text_pos++] = src[j];
                    }
                }
                text[text_pos] = '\0';
                mz_free(file_data);
            }
        }
    }

    mz_zip_reader_end(&zip);
    free(data);

    // 构建 JSON
    size_t json_sz = text_pos + 128;
    char *json = (char *)malloc(json_sz);
    snprintf(json, json_sz, "{\"error\":\"\",\"text\":\"%s\"}", text);
    free(text);
    return json;
}
