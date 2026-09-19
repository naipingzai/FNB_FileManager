/// archive.c - 压缩包操作模块 (miniz) - 优化版
/// 改进: 路径安全检查、缓冲区溢出保护、动态扩容、流式解压
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <pthread.h>
#include <stdatomic.h>
#define MINIZ_NO_ZLIB_COMPATIBLE_NAMES
#include "miniz.h"
#include <strings.h>
#include <sys/wait.h>
#include <unistd.h>
#include <zlib.h>
#if !defined(__ANDROID__)
#include <bzlib.h>
#include <lzma.h>
#define HAVE_BZ2 1
#define HAVE_LZMA 1
#endif

extern char *utils_strdup(const char *s);
extern unsigned char *utils_read_file(const char *path, int *out_len);
extern char *utils_error_json(const char *msg);

#define STREAM_BUF_SIZE (64 * 1024)
#define MAX_PATH_LEN 4096
#define TAR_BLOCK_SIZE 512

// Forward declarations from parts
int archive_extract_progress(const char *, const char *, const char *, char *, int);
int archive_create_progress(const char *, const char *, char *, int);
int archive_create_ex(const char *, const char *, int, char *, int);
char *archive_list(const char *path);
int archive_file_count(const char *path);
// 前置声明
static void mkdirs(const char *path);
static int is_safe_path(const char *path);
static int extract_one(mz_zip_archive *zip, mz_uint idx, const char *out_dir, const char *password);
static int zip_add_dir(mz_zip_archive *zip, const char *dir, const char *base, char *error, int error_size);
static int zip_add_file(mz_zip_archive *zip, const char *rel, const char *abs, char *error, int error_size);
static int count_files(const char *path);

// ── 进度追踪（全局状态，Dart 轮询） ──
static int g_progress_current = 0;
static int g_progress_total = 0;
static atomic_int g_progress_running = 0;
static char g_progress_file[1024] = "";

int archive_get_progress(int *current, int *total, char *filename, int fn_size) {
    if (current) *current = g_progress_current;
    if (total) *total = g_progress_total;
    if (filename) { strncpy(filename, g_progress_file, fn_size > 0 ? fn_size - 1 : 0); filename[fn_size > 0 ? fn_size - 1 : 0] = '\0'; }
    return g_progress_running;
}

int archive_is_running(void) { return g_progress_running; }

// ── 解压线程上下文 ──
typedef struct {
    char zip_path[MAX_PATH_LEN];
    char out_dir[MAX_PATH_LEN];
    char password[256];
    int result;
} ExtractThreadCtx;

static void __attribute__((unused)) *extract_thread_func(void *arg) {
    ExtractThreadCtx *ctx = (ExtractThreadCtx *)arg;
    int len = 0;
    unsigned char *data = utils_read_file(ctx->zip_path, &len);
    if (!data) { g_progress_running = 0; ctx->result = -1; free(ctx); return NULL; }

    mz_zip_archive zip;
    memset(&zip, 0, sizeof(zip));
    if (!mz_zip_reader_init_mem(&zip, data, len, 0)) {
        free(data); g_progress_running = 0; ctx->result = -1; free(ctx); return NULL;
    }

    mz_uint n = mz_zip_reader_get_num_files(&zip);
    g_progress_current = 0;
    g_progress_total = (int)n;

    const char *password = ctx->password[0] ? ctx->password : NULL;
    int failed = 0;
    for (mz_uint i = 0; i < n; i++) {
        if (!atomic_load(&g_progress_running)) break;  // 支持中途取消
        mz_zip_archive_file_stat st;
        if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
        strncpy(g_progress_file, st.m_filename, sizeof(g_progress_file) - 1);
        g_progress_file[sizeof(g_progress_file) - 1] = '\0';

        if (extract_one(&zip, i, ctx->out_dir, password) != 0) failed++;
        g_progress_current = (int)(i + 1);
    }

    mz_zip_reader_end(&zip);
    free(data);
    g_progress_running = 0;
    g_progress_file[0] = '\0';
    ctx->result = failed > 0 ? -1 : 0;
    free(ctx);
    return NULL;
}

/// 启动解压线程（立即返回，Dart 轮询 get_progress）


/// 取消正在进行的解压
int archive_cancel_extract(void) {
    if (atomic_load(&g_progress_running)) {
        atomic_store(&g_progress_running, 0);
        return 0;
    }
    return -1;
}



// ── 解压（单个文件，供进度模式使用） ──
static int extract_one(mz_zip_archive *zip, mz_uint idx, const char *out_dir, const char *password) {
    mz_zip_archive_file_stat st;
    if (!mz_zip_reader_file_stat(zip, idx, &st)) return -1;
    if (!is_safe_path(st.m_filename)) return 0;
    char full_path[MAX_PATH_LEN];
    snprintf(full_path, sizeof(full_path), "%s/%s", out_dir, st.m_filename);
    if (st.m_filename[strlen(st.m_filename) - 1] == '/') {
        mkdirs(full_path);
    } else {
        char *last_slash = strrchr(full_path, '/');
        if (last_slash) {
            char dir[MAX_PATH_LEN];
            size_t dl = last_slash - full_path;
            if (dl < sizeof(dir)) { memcpy(dir, full_path, dl); dir[dl] = '\0'; mkdirs(dir); }
        }
        if (password && password[0]) {
            // 加密文件：先解压到内存再写磁盘
            size_t uncomp_size = 0;
            void *p = mz_zip_reader_extract_to_heap(zip, idx, &uncomp_size, 0);
            if (!p) return -1;
            FILE *f = fopen(full_path, "wb");
            if (!f) { mz_free(p); return -1; }
            fwrite(p, 1, uncomp_size, f);
            fclose(f);
            mz_free(p);
        } else {
            if (!mz_zip_reader_extract_to_file(zip, idx, full_path, 0)) return -1;
        }
    }
    return 0;
}

static void mkdirs(const char *path) {
    char tmp[MAX_PATH_LEN];
    snprintf(tmp, sizeof(tmp), "%s", path);
    size_t len = strlen(tmp);
    while (len > 1 && tmp[len - 1] == '/') { tmp[--len] = '\0'; }
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') { *p = '\0'; mkdir(tmp, 0755); *p = '/'; }
    }
    mkdir(tmp, 0755);
}

/// 路径安全检查：防止路径穿越攻击
static int is_safe_path(const char *path) {
    if (!path || path[0] == '/' || strstr(path, "..") != NULL) return 0;
    return 1;
}

/// JSON 字符串转义（防止特殊字符破坏 JSON）
static size_t json_escape(char *dst, size_t cap, const char *src) {
    size_t di = 0;
    for (const char *p = src; *p && di + 6 < cap; p++) {
        char c = *p;
        if (c == '"' || c == '\\') { dst[di++] = '\\'; dst[di++] = c; }
        else if (c == '\n') { dst[di++] = '\\'; dst[di++] = 'n'; }
        else if (c == '\t') { dst[di++] = '\\'; dst[di++] = 't'; }
        else { dst[di++] = c; }
    }
    dst[di] = '\0';
    return di;
}



/// 兼容旧接口（也会启动线程）
int archive_extract(const char *zip_path, const char *out_dir, char *error, int error_size) {
    return archive_extract_progress(zip_path, out_dir, NULL, error, error_size);
}

static int zip_add_file(mz_zip_archive *zip, const char *rel, const char *abs, char *error, int error_size) {
    FILE *f = fopen(abs, "rb");
    if (!f) return -1;
    fseek(f, 0, SEEK_END);
    long sz = ftell(f);
    fseek(f, 0, SEEK_SET);
    if (sz <= 0) { fclose(f); return 0; }
    void *buf = malloc((size_t)sz);
    if (!buf) { fclose(f); return -1; }
    size_t read = fread(buf, 1, (size_t)sz, f);
    fclose(f);
    int ok = mz_zip_writer_add_mem(zip, rel, buf, read, MZ_DEFAULT_COMPRESSION);
    free(buf);
    // 更新压缩进度
    strncpy(g_progress_file, rel, sizeof(g_progress_file) - 1);
    g_progress_file[sizeof(g_progress_file) - 1] = '\0';
    return ok ? 0 : -1;
}

static int zip_add_dir(mz_zip_archive *zip, const char *dir, const char *base, char *error, int error_size) {
    DIR *d = opendir(dir);
    if (!d) return -1;
    struct dirent *ent;
    while ((ent = readdir(d)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        char full[MAX_PATH_LEN], rel[MAX_PATH_LEN];
        snprintf(full, sizeof(full), "%s/%s", dir, ent->d_name);
        snprintf(rel, sizeof(rel), "%s/%s", base, ent->d_name);
        struct stat st;
        if (stat(full, &st) == 0 && S_ISDIR(st.st_mode)) {
            mz_zip_writer_add_mem(zip, rel, NULL, 0, MZ_DEFAULT_COMPRESSION);
            zip_add_dir(zip, full, rel, error, error_size);
        } else {
            zip_add_file(zip, rel, full, error, error_size);
            g_progress_current++;
        }
    }
    closedir(d);
    return 0;
}

/// 递归统计文件数
static int count_files(const char *path) {
    struct stat st;
    if (stat(path, &st) != 0) return 0;
    if (!S_ISDIR(st.st_mode)) return 1;
    int count = 0;
    DIR *d = opendir(path);
    if (!d) return 0;
    struct dirent *ent;
    while ((ent = readdir(d)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        char child[MAX_PATH_LEN];
        snprintf(child, sizeof(child), "%s/%s", path, ent->d_name);
        count += count_files(child);
    }
    closedir(d);
    return count;
}

// ── 压缩线程上下文 ──
typedef struct {
    char src_path[MAX_PATH_LEN];
    char zip_path[MAX_PATH_LEN];
    int result;
} CreateThreadCtx;

static void __attribute__((unused)) *create_thread_func(void *arg) {
    CreateThreadCtx *ctx = (CreateThreadCtx *)arg;
    struct stat st;
    int total = (stat(ctx->src_path, &st) == 0 && S_ISDIR(st.st_mode)) ? count_files(ctx->src_path) : 1;
    g_progress_current = 0;
    g_progress_total = total;

    mz_zip_archive zip;
    memset(&zip, 0, sizeof(zip));
    if (!mz_zip_writer_init_file(&zip, ctx->zip_path, 0)) {
        g_progress_running = 0; ctx->result = -1; free(ctx); return NULL;
    }

    char error_buf[256] = "";
    if (stat(ctx->src_path, &st) == 0 && S_ISDIR(st.st_mode)) {
        zip_add_dir(&zip, ctx->src_path, "", error_buf, sizeof(error_buf));
    } else {
        const char *name = strrchr(ctx->src_path, '/');
        zip_add_file(&zip, name ? name + 1 : ctx->src_path, ctx->src_path, error_buf, sizeof(error_buf));
        g_progress_current = 1;
    }

    mz_zip_writer_finalize_archive(&zip);
    mz_zip_writer_end(&zip);
    g_progress_running = 0;
    g_progress_file[0] = '\0';
    ctx->result = 0;
    free(ctx);
    return NULL;
}



/// 兼容旧接口
int archive_create(const char *src_path, const char *zip_path, char *error, int error_size) {
    return archive_create_progress(src_path, zip_path, error, error_size);
}

// ============================================================
// TAR format
// ============================================================
#pragma pack(push, 1)
typedef struct {
    char name[100]; char mode[8]; char uid[8]; char gid[8];
    char size[12]; char mtime[12]; char chksum[8]; char typeflag;
    char linkname[100]; char magic[6]; char version[2];
    char uname[32]; char gname[32]; char devmajor[8]; char devminor[8];
    char prefix[155]; char padding[12];
} TarHeader;
#pragma pack(pop)
static unsigned int tar_octal(const char *s, int len) {
    unsigned int v = 0; for (int i = 0; i < len && s[i] >= '0' && s[i] <= '7'; i++) v = v * 8 + (s[i] - '0'); return v;
}
static unsigned int tar_cksum(const unsigned char *blk) {
    unsigned int s = 0; for (int i = 0; i < TAR_BLOCK_SIZE; i++) { s += (i >= 148 && i < 156) ? ' ' : blk[i]; } return s;
}
static int tar_valid(const unsigned char *blk) {
    if (tar_cksum(blk) != tar_octal((const char *)blk + 148, 7)) return 0;
    const TarHeader *h = (const TarHeader *)blk;
    return (h->magic[0] == '\0' || memcmp(h->magic, "ustar", 5) == 0);
}
static int tar_count(const unsigned char *d, int len) {
    int c = 0, o = 0;
    while (o + TAR_BLOCK_SIZE <= len) {
        int z = 1; for (int i = 0; i < TAR_BLOCK_SIZE; i++) if (d[o+i]) { z = 0; break; }
        if (z) break;
        if (tar_valid(d+o)) { const TarHeader *h = (const TarHeader*)(d+o); c++; o += TAR_BLOCK_SIZE + ((tar_octal(h->size,12)+TAR_BLOCK_SIZE-1)/TAR_BLOCK_SIZE)*TAR_BLOCK_SIZE; }
        else o += TAR_BLOCK_SIZE;
    }
    return c;
}
static char *tar_list(const unsigned char *d, int len) {
    if (len < TAR_BLOCK_SIZE) return utils_error_json("too small for TAR");
    int cnt = tar_count(d, len);
    size_t cap = 256 + (size_t)cnt * 300;
    char *j = (char*)malloc(cap); if (!j) return utils_error_json("alloc");
    size_t p = snprintf(j, cap, "{\"format\":\"TAR\",\"count\":%d,\"items\":[", cnt);
    int o = 0, ix = 0;
    while (o + TAR_BLOCK_SIZE <= len) {
        int z = 1; for (int i = 0; i < TAR_BLOCK_SIZE; i++) if (d[o+i]) { z = 0; break; }
        if (z) break;
        if (!tar_valid(d+o)) { o += TAR_BLOCK_SIZE; continue; }
        const TarHeader *h = (const TarHeader*)(d+o);
        unsigned int fs = tar_octal(h->size, 12); int isd = (h->typeflag=='5');
        const char *nm = h->name; char fn[256];
        if (h->prefix[0]) { snprintf(fn, sizeof(fn), "%s/%s", h->prefix, nm); nm = fn; }
        if (p+512 > cap) { cap *= 2; j = realloc(j, cap); }
        if (ix > 0 && j[p-1] != ',') j[p++] = ',';
        char esc[2048]; json_escape(esc, sizeof(esc), nm);
        p += snprintf(j+p, cap-p, "{\"name\":\"%s\",\"size\":%u,\"compressed\":0,\"isDir\":%s}", esc, fs, isd?"true":"false");
        ix++; o += TAR_BLOCK_SIZE + ((fs+TAR_BLOCK_SIZE-1)/TAR_BLOCK_SIZE)*TAR_BLOCK_SIZE;
    }
    snprintf(j+p, cap-p, "]}"); return j;
}

static int tar_extract_to_dir(const unsigned char *d, int len, const char *od) {
    if (len < TAR_BLOCK_SIZE) return -1;
    g_progress_total = tar_count(d, len);
    int o = 0, fail = 0, ix = 0;
    while (o + TAR_BLOCK_SIZE <= len) {
        if (!atomic_load(&g_progress_running)) break;
        int z = 1; for (int i = 0; i < TAR_BLOCK_SIZE; i++) if (d[o+i]) { z = 0; break; }
        if (z) break;
        if (!tar_valid(d+o)) { o += TAR_BLOCK_SIZE; continue; }
        const TarHeader *h = (const TarHeader*)(d+o);
        unsigned int fs = tar_octal(h->size, 12);
        const char *nm = h->name; char fn[256];
        if (h->prefix[0]) { snprintf(fn, sizeof(fn), "%s/%s", h->prefix, nm); nm = fn; }
        strncpy(g_progress_file, nm, sizeof(g_progress_file)-1); g_progress_file[sizeof(g_progress_file)-1]='\0';
        if (is_safe_path(nm)) {
            char fp[MAX_PATH_LEN]; snprintf(fp, sizeof(fp), "%s/%s", od, nm);
            if (h->typeflag == '5') { mkdirs(fp); }
            else { char *ls = strrchr(fp, '/'); if (ls) { char dir[MAX_PATH_LEN]; size_t dl=ls-fp; if(dl<sizeof(dir)){memcpy(dir,fp,dl);dir[dl]='\0';mkdirs(dir);} }
                FILE *f = fopen(fp, "wb"); if (f) { size_t doff=o+TAR_BLOCK_SIZE; if(doff+fs<=(size_t)len) fwrite(d+doff,1,fs,f); fclose(f); } else fail++; }
        }
        ix++; g_progress_current = ix;
        o += TAR_BLOCK_SIZE + ((fs+TAR_BLOCK_SIZE-1)/TAR_BLOCK_SIZE)*TAR_BLOCK_SIZE;
    }
    return fail > 0 ? -1 : 0;
}
static int tar_entry(FILE *tf, const char *rel, const char *ap, int *off) {
    struct stat st; if (stat(ap, &st) != 0) return -1;
    TarHeader h; memset(&h, 0, sizeof(h));
    snprintf(h.name, sizeof(h.name), "%s", rel);
    snprintf(h.mode, sizeof(h.mode), "%07o", S_ISDIR(st.st_mode) ? 0755 : 0644);
    snprintf(h.size, sizeof(h.size), "%011o", S_ISDIR(st.st_mode)?0:(unsigned)st.st_size);
    snprintf(h.mtime, sizeof(h.mtime), "%011o", (unsigned)st.st_mtime);
    h.typeflag = S_ISDIR(st.st_mode) ? '5' : '0';
    memcpy(h.magic, "ustar", 5); h.version[0]='0'; h.version[1]='0';
    memset(h.chksum, ' ', 8);
    unsigned cs = 0; const unsigned char *r = (const unsigned char*)&h;
    for (int i = 0; i < TAR_BLOCK_SIZE; i++) cs += r[i];
    snprintf(h.chksum, sizeof(h.chksum), "%06o\0", cs);
    fwrite(&h, 1, TAR_BLOCK_SIZE, tf); *off += TAR_BLOCK_SIZE;
    if (!S_ISDIR(st.st_mode) && st.st_size > 0) {
        FILE *f = fopen(ap, "rb"); if (!f) return -1;
        char buf[8192]; size_t rem = st.st_size;
        while (rem > 0) { size_t tr=rem<sizeof(buf)?rem:sizeof(buf); size_t rd=fread(buf,1,tr,f); if(!rd) break; fwrite(buf,1,rd,tf); *off+=(int)rd; rem-=rd; }
        fclose(f);
        int pad = (TAR_BLOCK_SIZE-(st.st_size%TAR_BLOCK_SIZE))%TAR_BLOCK_SIZE;
        if (pad > 0) { char z[512]={0}; fwrite(z,1,pad,tf); *off+=pad; }
    }
    strncpy(g_progress_file, rel, sizeof(g_progress_file)-1); g_progress_file[sizeof(g_progress_file)-1]='\0';
    return 0;
}
static int tar_dir_recurse(FILE *tf, const char *dir, const char *base, int *off) {
    DIR *d = opendir(dir); if (!d) return -1; struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (e->d_name[0] == '.') continue;
        char full[MAX_PATH_LEN], rel[MAX_PATH_LEN];
        snprintf(full, sizeof(full), "%s/%s", dir, e->d_name);
        snprintf(rel, sizeof(rel), "%s/%s", base, e->d_name);
        struct stat st;
        if (stat(full, &st) == 0) {
            if (S_ISDIR(st.st_mode)) { tar_entry(tf, rel, full, off); tar_dir_recurse(tf, full, rel, off); }
            else { tar_entry(tf, rel, full, off); g_progress_current++; }
        }
    }
    closedir(d); return 0;
}

// ============================================================
// Format detection
// ============================================================
typedef enum {
    FMT_UNKNOWN = 0, FMT_ZIP, FMT_TAR, FMT_GZ, FMT_TAR_GZ,
    FMT_BZ2, FMT_TAR_BZ2, FMT_XZ, FMT_TAR_XZ, FMT_7Z, FMT_RAR,
} ArchiveFormat;
static const char *path_ext(const char *p) { const char *d = strrchr(p, '.'); return d ? d : ""; }
static ArchiveFormat detect_format(const char *path) {
    char low[MAX_PATH_LEN]; snprintf(low, sizeof(low), "%s", path);
    for (char *p = low; *p; p++) if (*p >= 'A' && *p <= 'Z') *p += 32;
    if (strstr(low, ".tar.gz") || strstr(low, ".tgz"))  return FMT_TAR_GZ;
    if (strstr(low, ".tar.bz2") || strstr(low, ".tbz2") || strstr(low, ".tbz")) return FMT_TAR_BZ2;
    if (strstr(low, ".tar.xz") || strstr(low, ".txz"))  return FMT_TAR_XZ;
    const char *ext = path_ext(low);
    if (strcmp(ext, ".zip") == 0) return FMT_ZIP;
    if (strcmp(ext, ".tar") == 0) return FMT_TAR;
    if (strcmp(ext, ".gz")  == 0) return FMT_GZ;
    if (strcmp(ext, ".bz2") == 0) return FMT_BZ2;
    if (strcmp(ext, ".xz")  == 0) return FMT_XZ;
    if (strcmp(ext, ".7z")  == 0) return FMT_7Z;
    if (strcmp(ext, ".rar") == 0) return FMT_RAR;
    return FMT_UNKNOWN;
}
static const char *format_name(ArchiveFormat f) {
    switch (f) { case FMT_ZIP: return "ZIP"; case FMT_TAR: return "TAR"; case FMT_GZ: return "GZ";
        case FMT_TAR_GZ: return "TAR.GZ"; case FMT_BZ2: return "BZ2"; case FMT_TAR_BZ2: return "TAR.BZ2";
        case FMT_XZ: return "XZ"; case FMT_TAR_XZ: return "TAR.XZ"; case FMT_7Z: return "7Z"; case FMT_RAR: return "RAR";
        default: return "Unknown"; }
}
// ============================================================
// GZ (zlib)
// ============================================================
static int gz_decompress_file(const char *ip, const char *op) {
    gzFile gz = gzopen(ip, "rb"); if (!gz) return -1;
    FILE *out = fopen(op, "wb"); if (!out) { gzclose(gz); return -1; }
    char buf[65536]; int n; while ((n=gzread(gz,buf,sizeof(buf)))>0) fwrite(buf,1,n,out);
    fclose(out); gzclose(gz); return 0;
}
static int gz_compress_file(const char *ip, const char *op, int lv) {
    FILE *in = fopen(ip, "rb"); if (!in) return -1;
    gzFile gz = gzopen(op, "wb"); if (!gz) { fclose(in); return -1; }
    gzsetparams(gz, lv, Z_DEFAULT_STRATEGY);
    char buf[65536]; int n; while ((n=fread(buf,1,sizeof(buf),in))>0) gzwrite(gz,buf,n);
    gzclose(gz); fclose(in); return 0;
}
// ============================================================
// BZ2
// ============================================================
#ifdef HAVE_BZ2
static int bz2_decompress_file(const char *ip, const char *op) {
    FILE *in = fopen(ip, "rb"); if (!in) return -1;
    FILE *out = fopen(op, "wb"); if (!out) { fclose(in); return -1; }
    int be; BZFILE *bz = BZ2_bzReadOpen(NULL, in, 0, 0, NULL, 0);
    if (!bz) { fclose(in); fclose(out); return -1; }
    char buf[65536]; int n;
    while ((n=BZ2_bzRead(&be,bz,buf,sizeof(buf)))>0) fwrite(buf,1,n,out);
    BZ2_bzReadClose(&be, bz); fclose(out); fclose(in);
    return (be==BZ_OK||be==BZ_STREAM_END) ? 0 : -1;
}
static int bz2_compress_file(const char *ip, const char *op, int lv) {
    FILE *in = fopen(ip, "rb"); if (!in) return -1;
    FILE *out = fopen(op, "wb"); if (!out) { fclose(in); return -1; }
    int be; BZFILE *bz = BZ2_bzWriteOpen(&be, out, lv<1?1:(lv>9?9:lv), 0, 0);
    if (!bz) { fclose(in); fclose(out); return -1; }
    char buf[65536]; int n;
    while ((n=fread(buf,1,sizeof(buf),in))>0) BZ2_bzWrite(&be,bz,buf,n);
    BZ2_bzWriteClose(&be, bz, 0, NULL, NULL);
    fclose(in); fclose(out); return be==BZ_OK ? 0 : -1;
}
#else
static int bz2_decompress_file(const char *a, const char *b) { (void)a; (void)b; return -2; }
static int bz2_compress_file(const char *a, const char *b, int c) { (void)a; (void)b; (void)c; return -2; }
#endif
// ============================================================
// XZ/LZMA
// ============================================================
#ifdef HAVE_LZMA
static int xz_decompress_file(const char *ip, const char *op) {
    FILE *in = fopen(ip, "rb"); if (!in) return -1;
    FILE *out = fopen(op, "wb"); if (!out) { fclose(in); return -1; }
    lzma_stream s = LZMA_STREAM_INIT;
    if (lzma_stream_decoder(&s, UINT64_MAX, LZMA_CONCATENATED) != LZMA_OK) { fclose(in); fclose(out); return -1; }
    uint8_t ib[65536], ob[65536]; s.next_in=ib; s.avail_in=0; s.next_out=ob; s.avail_out=sizeof(ob);
    lzma_action a = LZMA_RUN;
    while (a != LZMA_FINISH) {
        if (s.avail_in==0 && !feof(in)) { s.next_in=ib; s.avail_in=fread(ib,1,sizeof(ib),in); if(feof(in)) a=LZMA_FINISH; }
        lzma_ret r = lzma_code(&s, a);
        if (s.avail_out==0||r==LZMA_OK) { size_t ws=sizeof(ob)-s.avail_out; if(ws>0) fwrite(ob,1,ws,out); s.next_out=ob; s.avail_out=sizeof(ob); }
        if (r!=LZMA_OK&&r!=LZMA_STREAM_END) break;
    }
    size_t ws=sizeof(ob)-s.avail_out; if(ws>0) fwrite(ob,1,ws,out);
    lzma_end(&s); fclose(in); fclose(out); return 0;
}
static int xz_compress_file(const char *ip, const char *op, int lv) {
    FILE *in = fopen(ip, "rb"); if (!in) return -1;
    FILE *out = fopen(op, "wb"); if (!out) { fclose(in); return -1; }
    lzma_stream s = LZMA_STREAM_INIT;
    lzma_options_lzma opt; lzma_lzma_preset(&opt, lv<0?6:(lv>9?9:lv));
    if (lzma_alone_encoder(&s, &opt) != LZMA_OK) { fclose(in); fclose(out); return -1; }
    uint8_t ib[65536], ob[65536]; s.next_in=ib; s.avail_in=0; s.next_out=ob; s.avail_out=sizeof(ob);
    lzma_action a = LZMA_RUN;
    while (a != LZMA_FINISH) {
        if (s.avail_in==0 && !feof(in)) { s.next_in=ib; s.avail_in=fread(ib,1,sizeof(ib),in); if(feof(in)) a=LZMA_FINISH; }
        lzma_ret r = lzma_code(&s, a);
        if (s.avail_out==0||r==LZMA_OK) { size_t ws=sizeof(ob)-s.avail_out; if(ws>0) fwrite(ob,1,ws,out); s.next_out=ob; s.avail_out=sizeof(ob); }
        if (r!=LZMA_OK&&r!=LZMA_STREAM_END) break;
    }
    size_t ws=sizeof(ob)-s.avail_out; if(ws>0) fwrite(ob,1,ws,out);
    lzma_end(&s); fclose(in); fclose(out); return 0;
}
#else
static int xz_decompress_file(const char *a, const char *b) { (void)a; (void)b; return -2; }
static int xz_compress_file(const char *a, const char *b, int c) { (void)a; (void)b; (void)c; return -2; }
#endif
// Helper: decompress outer layer to temp file
static int decompress_to_temp(const char *ip, const char *tp, ArchiveFormat fmt) {
    switch (fmt) {
        case FMT_GZ: case FMT_TAR_GZ:  return gz_decompress_file(ip, tp);
        case FMT_BZ2: case FMT_TAR_BZ2: return bz2_decompress_file(ip, tp);
        case FMT_XZ: case FMT_TAR_XZ:  return xz_decompress_file(ip, tp);
        default: return -1;
    }
}

// ============================================================
// Unified extract thread
// ============================================================
typedef struct { char ap[MAX_PATH_LEN]; char od[MAX_PATH_LEN]; char pw[256]; ArchiveFormat fmt; int res; } GECtx;
static void *gen_ext_thread(void *arg) {
    GECtx *c = (GECtx*)arg;
    switch (c->fmt) {
    case FMT_ZIP: {
        int len=0; unsigned char *d=utils_read_file(c->ap,&len);
        if(!d){g_progress_running=0;c->res=-1;free(c);return NULL;}
        mz_zip_archive z; memset(&z,0,sizeof(z));
        if(!mz_zip_reader_init_mem(&z,d,len,0)){free(d);g_progress_running=0;c->res=-1;free(c);return NULL;}
        mz_uint n=mz_zip_reader_get_num_files(&z); g_progress_current=0; g_progress_total=(int)n;
        const char *pw=c->pw[0]?c->pw:NULL; int fail=0;
        for(mz_uint i=0;i<n;i++){
            if(!atomic_load(&g_progress_running))break;
            mz_zip_archive_file_stat st;
            if(!mz_zip_reader_file_stat(&z,i,&st))continue;
            strncpy(g_progress_file,st.m_filename,sizeof(g_progress_file)-1); g_progress_file[sizeof(g_progress_file)-1]='\0';
            if(extract_one(&z,i,c->od,pw)!=0)fail++; g_progress_current=(int)(i+1);
        }
        mz_zip_reader_end(&z);free(d); c->res=fail>0?-1:0; break;
    }
    case FMT_TAR: {
        int len=0;unsigned char *d=utils_read_file(c->ap,&len);
        if(!d){g_progress_running=0;c->res=-1;free(c);return NULL;}
        c->res=tar_extract_to_dir(d,len,c->od); free(d); break;
    }
    case FMT_TAR_GZ:case FMT_TAR_BZ2:case FMT_TAR_XZ: {
        strncpy(g_progress_file,"Decompressing...",sizeof(g_progress_file)-1);
        char tp[MAX_PATH_LEN]; snprintf(tp,sizeof(tp),"/tmp/_ae_%d.tar",getpid());
        if(decompress_to_temp(c->ap,tp,c->fmt)!=0){unlink(tp);g_progress_running=0;c->res=-1;free(c);return NULL;}
        int len=0;unsigned char *d=utils_read_file(tp,&len);unlink(tp);
        if(!d){g_progress_running=0;c->res=-1;free(c);return NULL;}
        c->res=tar_extract_to_dir(d,len,c->od); free(d); break;
    }
    case FMT_GZ: { g_progress_total=1;g_progress_current=0;
        strncpy(g_progress_file,"Decompressing...",sizeof(g_progress_file)-1);
        char op[MAX_PATH_LEN];const char *nm=strrchr(c->ap,'/');nm=nm?nm+1:c->ap;
        snprintf(op,sizeof(op),"%s/%.*s",c->od,(int)(strlen(nm)>3?strlen(nm)-3:strlen(nm)),nm);
        c->res=gz_decompress_file(c->ap,op);g_progress_current=1;break; }
    case FMT_BZ2: { g_progress_total=1;g_progress_current=0;
        strncpy(g_progress_file,"Decompressing...",sizeof(g_progress_file)-1);
        char op[MAX_PATH_LEN];const char *nm=strrchr(c->ap,'/');nm=nm?nm+1:c->ap;
        snprintf(op,sizeof(op),"%s/%.*s",c->od,(int)(strlen(nm)>4?strlen(nm)-4:strlen(nm)),nm);
        c->res=bz2_decompress_file(c->ap,op);g_progress_current=1;break; }
    case FMT_XZ: { g_progress_total=1;g_progress_current=0;
        strncpy(g_progress_file,"Decompressing...",sizeof(g_progress_file)-1);
        char op[MAX_PATH_LEN];const char *nm=strrchr(c->ap,'/');nm=nm?nm+1:c->ap;
        snprintf(op,sizeof(op),"%s/%.*s",c->od,(int)(strlen(nm)>3?strlen(nm)-3:strlen(nm)),nm);
        c->res=xz_decompress_file(c->ap,op);g_progress_current=1;break; }
    case FMT_7Z: { g_progress_total=1;g_progress_current=0;
        strncpy(g_progress_file,"Extracting 7z...",sizeof(g_progress_file)-1);
        char cl[MAX_PATH_LEN*2+256]; snprintf(cl,sizeof(cl),"7z x '%s' -o'%s' -y 2>&1",c->ap,c->od);
        int r=system(cl);c->res=(WIFEXITED(r)&&WEXITSTATUS(r)==0)?0:-1;g_progress_current=1;break; }
    case FMT_RAR: { g_progress_total=1;g_progress_current=0;
        strncpy(g_progress_file,"Extracting RAR...",sizeof(g_progress_file)-1);
        char cl[MAX_PATH_LEN*2+256]; snprintf(cl,sizeof(cl),"unrar x -o+ '%s' '%s' 2>&1",c->ap,c->od);
        int r=system(cl);c->res=(WIFEXITED(r)&&WEXITSTATUS(r)==0)?0:-1;g_progress_current=1;break; }
    default: c->res=-1;
    }
    g_progress_running=0;g_progress_file[0]='\0';free(c);return NULL;
}

// ============================================================
// Override archive_list to be format-aware
// ============================================================
char *archive_list(const char *path) {
    ArchiveFormat fmt = detect_format(path);
    switch (fmt) {
    case FMT_ZIP: {
        int len=0;unsigned char *d=utils_read_file(path,&len);if(!d)return utils_error_json("read failed");
        mz_zip_archive z;memset(&z,0,sizeof(z));
        if(!mz_zip_reader_init_mem(&z,d,len,0)){free(d);return utils_error_json("not a valid ZIP");}
        mz_uint n=mz_zip_reader_get_num_files(&z);size_t cap=256+(size_t)n*300;
        char *j=(char*)malloc(cap);if(!j){mz_zip_reader_end(&z);free(d);return utils_error_json("alloc");}
        size_t p=snprintf(j,cap,"{\"format\":\"ZIP\",\"count\":%u,\"items\":[",n);
        for(mz_uint i=0;i<n;i++){mz_zip_archive_file_stat st;
            if(!mz_zip_reader_file_stat(&z,i,&st))continue;if(!is_safe_path(st.m_filename))continue;
            if(p+512>cap){cap*=2;j=realloc(j,cap);}
            if(i>0&&j[p-1]!=',')j[p++]=',';
            int isd=st.m_filename[strlen(st.m_filename)-1]=='/';
            char esc[2048];json_escape(esc,sizeof(esc),st.m_filename);
            p+=snprintf(j+p,cap-p,"{\"name\":\"%s\",\"size\":%llu,\"compressed\":%llu,\"isDir\":%s}",
                esc,(unsigned long long)st.m_uncomp_size,(unsigned long long)st.m_comp_size,isd?"true":"false");}
        p+=snprintf(j+p,cap-p,"]}");mz_zip_reader_end(&z);free(d);return j;}
    case FMT_TAR: {int len=0;unsigned char *d=utils_read_file(path,&len);if(!d)return utils_error_json("read failed");
        char *r=tar_list(d,len);free(d);return r;}
    case FMT_TAR_GZ:case FMT_TAR_BZ2:case FMT_TAR_XZ: {
        char tp[MAX_PATH_LEN];snprintf(tp,sizeof(tp),"/tmp/_al_%d.tar",getpid());
        if(decompress_to_temp(path,tp,fmt)!=0){unlink(tp);return utils_error_json("decompress failed");}
        int len=0;unsigned char *d=utils_read_file(tp,&len);unlink(tp);if(!d)return utils_error_json("read failed");
        char *r=tar_list(d,len);free(d);return r;}
    case FMT_GZ:case FMT_BZ2:case FMT_XZ: {struct stat st;if(stat(path,&st)!=0)return utils_error_json("stat failed");
        char j[512];snprintf(j,sizeof(j),"{\"format\":\"%s\",\"count\":1,\"items\":[{\"name\":\"%s\",\"size\":%lld,\"compressed\":0,\"isDir\":false}]}",
            format_name(fmt),path_ext(path)[0]?path_ext(path)+1:"data",(long long)st.st_size);return utils_strdup(j);}
    case FMT_7Z:case FMT_RAR: {const char *cmd=(fmt==FMT_7Z)?"7z l":"unrar l";
        char cl[MAX_PATH_LEN*2+64];snprintf(cl,sizeof(cl),"%s '%s' 2>&1",cmd,path);
        FILE *p=popen(cl,"r");if(!p)return utils_error_json("system command failed");
        size_t cap=4096;char *j=(char*)malloc(cap);if(!j){pclose(p);return utils_error_json("alloc");}
        size_t ps=snprintf(j,cap,"{\"format\":\"%s\",\"count\":0,\"items\":[],\"raw\":\"",format_name(fmt));
        char line[1024];while(fgets(line,sizeof(line),p)){size_t ll=strlen(line);if(ps+ll*2+16>cap){cap*=2;j=realloc(j,cap);}
            for(size_t i=0;i<ll;i++){if(line[i]=='\"'){j[ps++]='\\';j[ps++]='\"';}else if(line[i]=='\\'){j[ps++]='\\';j[ps++]='\\';}else if(line[i]=='\n'){j[ps++]='\\';j[ps++]='n';}else{j[ps++]=line[i];}}}
        ps+=snprintf(j+ps,cap-ps,"\"}");pclose(p);return j;}
    default: return utils_error_json("unsupported format");
    }
}

// Override archive_extract_progress to be format-aware
int archive_extract_progress(const char *ap, const char *od, const char *pw, char *err, int es) {
    if(atomic_load(&g_progress_running)){if(err)snprintf(err,es,"extract already running");return -1;}
    ArchiveFormat fmt=detect_format(ap);
    if(fmt==FMT_UNKNOWN){if(err)snprintf(err,es,"unsupported format");return -1;}
    GECtx *c=(GECtx*)calloc(1,sizeof(GECtx));if(!c){if(err)snprintf(err,es,"alloc failed");return -1;}
    strncpy(c->ap,ap,MAX_PATH_LEN-1);strncpy(c->od,od,MAX_PATH_LEN-1);
    if(pw&&pw[0])strncpy(c->pw,pw,255);c->fmt=fmt;
    g_progress_current=0;g_progress_total=0;g_progress_running=1;
    pthread_t t;if(pthread_create(&t,NULL,gen_ext_thread,c)!=0){g_progress_running=0;free(c);if(err)snprintf(err,es,"thread failed");return -1;}
    pthread_detach(t);if(err)err[0]='\0';return 0;
}
// Forward declaration
int archive_create_ex(const char *sp, const char *op, int lv, char *err, int es);

// ============================================================
// Compress thread
// ============================================================
typedef struct { char sp[MAX_PATH_LEN]; char op[MAX_PATH_LEN]; int fmt; int lv; int res; } CTCtx;
static void *cmp_thread(void *arg) {
    CTCtx *c=(CTCtx*)arg;struct stat st;ArchiveFormat fmt=(ArchiveFormat)c->fmt;
    g_progress_current=0;g_progress_total=0;
    switch(fmt) {
    case FMT_ZIP: {
        int tot=(stat(c->sp,&st)==0&&S_ISDIR(st.st_mode))?count_files(c->sp):1;g_progress_total=tot;
        mz_zip_archive z;memset(&z,0,sizeof(z));
        if(!mz_zip_writer_init_file(&z,c->op,0)){g_progress_running=0;c->res=-1;free(c);return NULL;}
        char eb[256]="";
        if(stat(c->sp,&st)==0&&S_ISDIR(st.st_mode))zip_add_dir(&z,c->sp,"",eb,sizeof(eb));
        else{const char *nm=strrchr(c->sp,'/');zip_add_file(&z,nm?nm+1:c->sp,c->sp,eb,sizeof(eb));g_progress_current=1;}
        mz_zip_writer_finalize_archive(&z);mz_zip_writer_end(&z);c->res=0;break;
    }
    case FMT_TAR:case FMT_TAR_GZ:case FMT_TAR_BZ2:case FMT_TAR_XZ: {
        char tp[MAX_PATH_LEN];int nt=(fmt!=FMT_TAR);
        if(nt)snprintf(tp,sizeof(tp),"/tmp/_ac_%d.tar",getpid());else snprintf(tp,sizeof(tp),"%s",c->op);
        int tot=(stat(c->sp,&st)==0&&S_ISDIR(st.st_mode))?count_files(c->sp):1;g_progress_total=tot;
        FILE *tf=fopen(tp,"wb");if(!tf){g_progress_running=0;c->res=-1;free(c);return NULL;}
        int off=0;
        if(stat(c->sp,&st)==0&&S_ISDIR(st.st_mode)){const char *nm=strrchr(c->sp,'/');tar_entry(tf,nm?nm+1:"",c->sp,&off);tar_dir_recurse(tf,c->sp,nm?nm+1:"",&off);}
        else{const char *nm=strrchr(c->sp,'/');tar_entry(tf,nm?nm+1:c->sp,c->sp,&off);g_progress_current=1;}
        char z[1024]={0};fwrite(z,1,1024,tf);fclose(tf);
        if(nt){strncpy(g_progress_file,"Compressing...",sizeof(g_progress_file)-1);
            int lv=c->lv>0?c->lv:6;
            switch(fmt){case FMT_TAR_GZ:c->res=gz_compress_file(tp,c->op,lv);break;
                case FMT_TAR_BZ2:c->res=bz2_compress_file(tp,c->op,lv);break;
                case FMT_TAR_XZ:c->res=xz_compress_file(tp,c->op,lv);break;default:c->res=-1;}
            unlink(tp);}else c->res=0;break;
    }
    default:c->res=-1;
    }
    g_progress_running=0;g_progress_file[0]='\0';free(c);return NULL;
}
int archive_create_progress(const char *sp, const char *op, char *err, int es) {
    return archive_create_ex(sp,op,-1,err,es);
}
int archive_create_ex(const char *sp, const char *op, int lv, char *err, int es) {
    if(atomic_load(&g_progress_running)){if(err)snprintf(err,es,"archive already running");return -1;}
    ArchiveFormat fmt=detect_format(op);
    if(fmt==FMT_UNKNOWN){if(err)snprintf(err,es,"unsupported format");return -1;}
    CTCtx *c=(CTCtx*)calloc(1,sizeof(CTCtx));if(!c){if(err)snprintf(err,es,"alloc failed");return -1;}
    strncpy(c->sp,sp,MAX_PATH_LEN-1);strncpy(c->op,op,MAX_PATH_LEN-1);c->fmt=fmt;c->lv=lv;
    g_progress_current=0;g_progress_total=0;g_progress_running=1;
    pthread_t t;if(pthread_create(&t,NULL,cmp_thread,c)!=0){g_progress_running=0;free(c);if(err)snprintf(err,es,"thread failed");return -1;}
    pthread_detach(t);if(err)err[0]='\0';return 0;
}

int archive_file_count(const char *path) {
    ArchiveFormat fmt=detect_format(path);
    switch(fmt){
    case FMT_ZIP:{int len=0;unsigned char *d=utils_read_file(path,&len);if(!d)return -1;
        mz_zip_archive z;memset(&z,0,sizeof(z));if(!mz_zip_reader_init_mem(&z,d,len,0)){free(d);return -1;}
        int n=(int)mz_zip_reader_get_num_files(&z);mz_zip_reader_end(&z);free(d);return n;}
    case FMT_TAR:case FMT_TAR_GZ:case FMT_TAR_BZ2:case FMT_TAR_XZ:{
        unsigned char *d=NULL;int len=0;
        if(fmt==FMT_TAR)d=utils_read_file(path,&len);
        else{char tp[MAX_PATH_LEN];snprintf(tp,sizeof(tp),"/tmp/_afc_%d.tar",getpid());
            if(decompress_to_temp(path,tp,fmt)!=0){unlink(tp);return -1;}d=utils_read_file(tp,&len);unlink(tp);}
        if(!d)return -1;int c=tar_count(d,len);free(d);return c;}
    default:return -1;
    }
}
int archive_decompress_file(const char *ip, const char *op, char *err, int es) {
    ArchiveFormat fmt=detect_format(ip);int r=-1;
    switch(fmt){case FMT_GZ:r=gz_decompress_file(ip,op);break;
        case FMT_BZ2:r=bz2_decompress_file(ip,op);break;
        case FMT_XZ:r=xz_decompress_file(ip,op);break;
        default:if(err)snprintf(err,es,"not a single-file compressed format");break;}
    if(r==-2&&err)snprintf(err,es,"format not supported on this platform");
    else if(r!=0&&r!=-2&&err)snprintf(err,es,"decompression failed");return r;
}
int archive_compress_file(const char *ip, const char *op, int lv, char *err, int es) {
    ArchiveFormat fmt=detect_format(op);int r=-1;
    switch(fmt){case FMT_GZ:r=gz_compress_file(ip,op,lv);break;
        case FMT_BZ2:r=bz2_compress_file(ip,op,lv);break;
        case FMT_XZ:r=xz_compress_file(ip,op,lv);break;
        default:if(err)snprintf(err,es,"not a single-file compression format");break;}
    if(r==-2&&err)snprintf(err,es,"format not supported on this platform");
    else if(r!=0&&r!=-2&&err)snprintf(err,es,"compression failed");return r;
}
char *archive_supported_formats(void) {
    return utils_strdup(
        "{\"zip\":true,\"tar\":true,\"tar_gz\":true,"
#ifdef HAVE_BZ2
        "\"bz2\":true,\"tar_bz2\":true,"
#else
        "\"bz2\":false,\"tar_bz2\":false,"
#endif
#ifdef HAVE_LZMA
        "\"xz\":true,\"tar_xz\":true,"
#else
        "\"xz\":false,\"tar_xz\":false,"
#endif
        "\"gz\":true,\"7z\":true,\"rar\":true}");
}

int archive_create_7z(const char *sp, const char *op, const char *pw, int lv, char *err, int es) {
    if(!sp||!op){if(err)snprintf(err,es,"invalid parameters");return -1;}
    char cmd[2048]; int lv_val = (lv >= 0 && lv <= 9) ? lv : 5;
    if(pw && pw[0])
        snprintf(cmd, sizeof(cmd), "7z a -t7z -mhe=on -p%s -mx=%d \"%s\" \"%s\"", pw, lv_val, op, sp);
    else
        snprintf(cmd, sizeof(cmd), "7z a -t7z -mx=%d \"%s\" \"%s\"", lv_val, op, sp);
    int r = system(cmd);
    if(r != 0 && err) snprintf(err, es, "7z creation failed (code=%d)", r);
    return r;
}
