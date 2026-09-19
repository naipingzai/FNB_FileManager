/// fs_ops.c - 文件系统操作 + 回收站
#include "bridge_api.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#define FS_PATH_MAX 4096
#define FS_BUF_SIZE 65536
extern char *utils_error_json(const char *msg);
extern char *utils_strdup(const char *s);

static void fs_mkdirs_internal(const char *path) {
    char t[FS_PATH_MAX]; snprintf(t,sizeof(t),"%s",path);
    for(char *p=t+1;*p;p++) { if(*p=='/'){*p='\0';mkdir(t,0755);*p='/';} }
    mkdir(t,0755);
}

static const char *fs_type_str(const char *path, struct stat *st) {
    if(S_ISDIR(st->st_mode)) return "folder";
    const char *ext=strrchr(path,'.'); if(!ext) return "file";
    if(strstr(".jpg.jpeg.png.gif.bmp.webp.",ext)) return "image";
    if(strstr(".mp4.avi.mkv.mov.wmv.flv.",ext)) return "video";
    if(strstr(".mp3.wav.flac.aac.ogg.",ext)) return "audio";
    if(strcmp(ext,".pdf")==0) return "pdf";
    if(strstr(".txt.md.log.json.xml.c.h.dart.py.js.",ext)) return "text";
    if(strstr(".zip.rar.7z.tar.gz.",ext)) return "archive";
    if(strstr(".epub.mobi.",ext)) return "ebook";
    return "file";
}

static size_t json_esc(char *d,size_t c,const char *s) {
    size_t i=0; if(!s){if(c)d[0]=0;return 0;}
    for(const char *p=s;*p&&i+6<c;p++) { char ch=*p; if(ch=='"'||ch=='\\'){d[i++]='\\';d[i++]=ch;}else d[i++]=ch;}
    if(i<c)d[i]=0; return i;
}

static int fs_copy_file(const char *s,const char *d){
    FILE *fi=fopen(s,"rb");if(!fi)return -1;FILE *fo=fopen(d,"wb");if(!fo){fclose(fi);return -1;}
    char b[FS_BUF_SIZE];size_t n;while((n=fread(b,1,FS_BUF_SIZE,fi))>0)if(fwrite(b,1,n,fo)!=n){fclose(fi);fclose(fo);return -1;}
    fclose(fi);fclose(fo);return 0;
}

static int fs_copy_dir_r(const char *s,const char *d){
    DIR *dp=opendir(s);if(!dp)return -1;mkdir(d,0755);struct dirent *e;
    while((e=readdir(dp))){if(e->d_name[0]=='.')continue;char sp[FS_PATH_MAX],dp2[FS_PATH_MAX];
    snprintf(sp,sizeof(sp),"%s/%s",s,e->d_name);snprintf(dp2,sizeof(dp2),"%s/%s",d,e->d_name);
    struct stat st;if(stat(sp,&st)!=0)continue;
    if(S_ISDIR(st.st_mode)){if(fs_copy_dir_r(sp,dp2)!=0){closedir(dp);return -1;}}
    else{if(fs_copy_file(sp,dp2)!=0){closedir(dp);return -1;}}}closedir(dp);return 0;
}

int fs_copy(const char *s,const char *d,char *e,int es){
    if(!s||!d){if(e)snprintf(e,es,"null");return -1;}
    struct stat st;if(stat(s,&st)!=0){if(e)snprintf(e,es,"not found");return -1;}
    int rc=S_ISDIR(st.st_mode)?fs_copy_dir_r(s,d):fs_copy_file(s,d);
    if(rc!=0&&e)snprintf(e,es,"copy failed: %s",strerror(errno));return rc;
}

int fs_move(const char *s,const char *d,char *e,int es){
    if(!s||!d){if(e)snprintf(e,es,"null");return -1;}
    if(rename(s,d)==0)return 0;
    if(errno==EXDEV){int rc=fs_copy(s,d,e,es);if(rc==0)fs_delete(s,NULL,0);return rc;}
    if(e)snprintf(e,es,"move failed: %s",strerror(errno));return -1;
}

static int fs_del_r(const char *p){DIR *d=opendir(p);if(!d)return -1;struct dirent *e;
    while((e=readdir(d))){if(e->d_name[0]=='.')continue;char c[FS_PATH_MAX];
    snprintf(c,sizeof(c),"%s/%s",p,e->d_name);struct stat st;if(stat(c,&st)!=0)continue;
    if(S_ISDIR(st.st_mode))fs_del_r(c);else remove(c);}closedir(d);return rmdir(p);}

int fs_delete(const char *p,char *e,int es){
    if(!p)return 0;struct stat st;if(stat(p,&st)!=0)return 0;
    int rc=S_ISDIR(st.st_mode)?fs_del_r(p):remove(p);
    if(rc!=0&&e)snprintf(e,es,"delete failed: %s",strerror(errno));return rc;
}

int fs_mkdir(const char *p,char *e,int es){if(!p){if(e)snprintf(e,es,"null");return -1;}fs_mkdirs_internal(p);return 0;}

int fs_rename(const char *o,const char *n,char *e,int es){
    if(!o||!n){if(e)snprintf(e,es,"null");return -1;}
    if(rename(o,n)==0)return 0;if(e)snprintf(e,es,"rename failed: %s",strerror(errno));return -1;
}

char *fs_properties(const char *p){
    if(!p)return utils_error_json("null path");struct stat st;if(stat(p,&st)!=0)return utils_error_json("not found");
    const char *nm=strrchr(p,'/');nm=nm?nm+1:p;long long sz=S_ISDIR(st.st_mode)?-1:(long long)st.st_size;
    char ne[1024];json_esc(ne,sizeof(ne),nm);char *j=(char*)malloc(1024);
    snprintf(j,1024,"{\"error\":\"\",\"name\":\"%s\",\"size\":%lld,\"modified\":%ld,\"is_dir\":%s}",
        ne,sz,(long)st.st_mtime,S_ISDIR(st.st_mode)?"true":"false");return j;
}

long long fs_dir_size(const char *p){
    if(!p)return -1;struct stat st;if(stat(p,&st)!=0)return -1;
    if(!S_ISDIR(st.st_mode))return(long long)st.st_size;
    long long t=0;DIR *d=opendir(p);if(!d)return -1;struct dirent *e;
    while((e=readdir(d))){if(e->d_name[0]=='.')continue;char c[FS_PATH_MAX];
    snprintf(c,sizeof(c),"%s/%s",p,e->d_name);if(stat(c,&st)!=0)continue;
    if(S_ISDIR(st.st_mode)){long long s=fs_dir_size(c);if(s>=0)t+=s;}else t+=st.st_size;}
    closedir(d);return t;
}

char *fs_list_dir(const char *path, int sh) {
    if(!path)return utils_error_json("null path");DIR *d=opendir(path);if(!d)return utils_error_json("cannot open");
    size_t cap=1024;char *j=(char*)malloc(cap);if(!j){closedir(d);return utils_error_json("alloc");}
    size_t pos=0;pos+=snprintf(j+pos,cap-pos,"{\"error\":\"\",\"entries\":[");int first=1;struct dirent *e;
    while((e=readdir(d))!=NULL){
        if(e->d_name[0]=='.'){if(!sh)continue;if(strcmp(e->d_name,".")==0||strcmp(e->d_name,"..")==0)continue;}
        char ch[FS_PATH_MAX];snprintf(ch,sizeof(ch),"%s/%s",path,e->d_name);struct stat st;if(stat(ch,&st)!=0)continue;
        if(pos+512>cap){cap*=2;char*nq=(char*)realloc(j,cap);if(!nq)break;j=nq;}
        char ne[512];json_esc(ne,sizeof(ne),e->d_name);const char *ty=fs_type_str(ch,&st);
        if(!first)j[pos++]=',';pos+=snprintf(j+pos,cap-pos,
            "{\"name\":\"%s\",\"path\":\"%s\",\"is_dir\":%s,\"size\":%lld,\"modified\":%ld,\"type\":\"%s\"}",
            ne,ch,S_ISDIR(st.st_mode)?"true":"false",(long long)st.st_size,(long)st.st_mtime,ty);first=0;
    }pos+=snprintf(j+pos,cap-pos,"]}");closedir(d);return j;
}

// ── 永久删除 ──
int fs_delete_permanent(const char *p, char *e, int es) {
    return fs_delete(p, e, es); // 永久删除直接调用 fs_delete（不经回收站）
}

// ── 新建空文件 ──
int fs_create_file(const char *path, char *err, int err_size) {
    if (!path) { if (err) snprintf(err, err_size, "null path"); return -1; }
    // 确保父目录存在
    char parent[FS_PATH_MAX]; snprintf(parent, sizeof(parent), "%s", path);
    char *slash = strrchr(parent, '/');
    if (slash) { *slash = '\0'; fs_mkdirs_internal(parent); }
    FILE *f = fopen(path, "w");
    if (!f) { if (err) snprintf(err, err_size, "create failed: %s", strerror(errno)); return -1; }
    fclose(f); return 0;
}

// ── 修改权限 ──
int fs_chmod(const char *path, int mode, char *err, int err_size) {
    if (!path) { if (err) snprintf(err, err_size, "null path"); return -1; }
    if (chmod(path, (mode_t)mode) != 0) {
        if (err) snprintf(err, err_size, "chmod failed: %s", strerror(errno)); return -1;
    }
    return 0;
}

// ── 文件哈希（简化版：读取文件内容计算） ──
// 返回 hex 字符串，调用者负责 free
static char *file_hash_hex(const char *path, int algo) {
    // algo: 0=md5, 1=sha256 — 使用 OpenSSL 或内置实现
    // 简化：直接用管道调用命令行
    const char *cmd = algo == 0
        ? "md5sum"
        : "sha256sum";
    char command[FS_PATH_MAX + 64];
    snprintf(command, sizeof(command), "%s '%s' 2>/dev/null | cut -d' ' -f1", cmd, path);
    FILE *p = popen(command, "r");
    if (!p) return NULL;
    char buf[128] = "";
    fgets(buf, sizeof(buf), p);
    pclose(p);
    // 去换行
    size_t len = strlen(buf);
    while (len > 0 && (buf[len-1] == '\n' || buf[len-1] == '\r')) buf[--len] = '\0';
    return utils_strdup(buf);
}

char *fs_file_hash(const char *path, int algo) {
    if (!path) return NULL;
    return file_hash_hex(path, algo);
}

// ── 批量重命名 ──
// names_json: JSON 数组 [{"old":"a.txt","new":"b.txt"},...]
// 返回成功/失败数 JSON: {"ok":n,"fail":n}
int fs_batch_rename(const char *dir, const char *names_json, char *err, int err_size) {
    if (!dir || !names_json) { if (err) snprintf(err, err_size, "null"); return -1; }
    int ok = 0, fail = 0;
    // 简单解析 JSON 数组
    const char *p = names_json;
    while ((p = strstr(p, "\"old\"")) != NULL) {
        p += 5; while (*p && *p != '"') p++; p++; // skip to value
        const char *os = p; while (*p && *p != '"') p++;
        char old_name[512]; size_t ol = p - os; if (ol > 511) ol = 511;
        memcpy(old_name, os, ol); old_name[ol] = '\0';
        p++; while (*p && *p != '"') p++; p++; // skip to "new"
        if (!p || !*p) break;
        const char *ns = p; while (*p && *p != '"') p++;
        char new_name[512]; size_t nl = p - ns; if (nl > 511) nl = 511;
        memcpy(new_name, ns, nl); new_name[nl] = '\0';
        char old_path[FS_PATH_MAX], new_path[FS_PATH_MAX];
        snprintf(old_path, sizeof(old_path), "%s/%s", dir, old_name);
        snprintf(new_path, sizeof(new_path), "%s/%s", dir, new_name);
        if (rename(old_path, new_path) == 0) ok++; else fail++;
    }
    if (err) { if (fail > 0) snprintf(err, err_size, "%d ok, %d fail", ok, fail); else err[0] = '\0'; }
    return (fail > 0) ? -1 : 0;
}


// ── 回收站 ──

static void ensure_trash_dirs(void) {
    const char *h = getenv("HOME") ?: "/tmp";
    char b[FS_PATH_MAX];
    snprintf(b, sizeof(b), "%s/.local/share/Trash/files", h); fs_mkdirs_internal(b);
    snprintf(b, sizeof(b), "%s/.local/share/Trash/info", h); fs_mkdirs_internal(b);
}

int fs_trash(const char *path, char *err, int err_size) {
    if (!path) { if (err) snprintf(err, err_size, "null path"); return -1; }
    struct stat st; if (stat(path, &st) != 0) return 0;
    ensure_trash_dirs();
    const char *h = getenv("HOME") ?: "/tmp";
    const char *name = strrchr(path, '/'); name = name ? name + 1 : path;
    char dest[FS_PATH_MAX], info[FS_PATH_MAX];
    snprintf(dest, sizeof(dest), "%s/.local/share/Trash/files/%s", h, name);
    snprintf(info, sizeof(info), "%s/.local/share/Trash/info/%s.trashinfo", h, name);
    // 重名处理
    if (access(dest, F_OK) == 0) {
        char d2[FS_PATH_MAX]; snprintf(d2, sizeof(d2), "%s_%ld", dest, (long)time(NULL));
        char i2[FS_PATH_MAX]; snprintf(i2, sizeof(i2), "%s_%ld.trashinfo", info, (long)time(NULL));
        snprintf(dest, sizeof(dest), "%s", d2); snprintf(info, sizeof(info), "%s", i2);
    }
    FILE *f = fopen(info, "w");
    if (f) { fprintf(f, "[Trash Info]\nPath=%s\nDeletionDate=%ld\n", path, (long)time(NULL)); fclose(f); }
    return fs_move(path, dest, err, err_size);
}

int fs_trash_restore(const char *name, char *err, int err_size) {
    if (!name) { if (err) snprintf(err, err_size, "null"); return -1; }
    const char *h = getenv("HOME") ?: "/tmp";
    char info_p[FS_PATH_MAX], trash_p[FS_PATH_MAX];
    snprintf(info_p, sizeof(info_p), "%s/.local/share/Trash/info/%s.trashinfo", h, name);
    snprintf(trash_p, sizeof(trash_p), "%s/.local/share/Trash/files/%s", h, name);
    char orig[FS_PATH_MAX] = "";
    FILE *f = fopen(info_p, "r");
    if (f) { char line[FS_PATH_MAX]; while (fgets(line, sizeof(line), f)) { if (sscanf(line, "Path=%[^\n]", orig) == 1) break; } fclose(f); }
    if (orig[0] == '\0') snprintf(orig, sizeof(orig), "%s/%s", h, name);
    // 确保父目录存在
    char *sl = strrchr(orig, '/');
    if (sl) { char pd[FS_PATH_MAX]; size_t pl = sl - orig; if (pl < sizeof(pl)) { memcpy(pd, orig, pl); pd[pl] = '\0'; fs_mkdirs_internal(pd); } }
    int rc = fs_move(trash_p, orig, err, err_size);
    if (rc == 0) remove(info_p);
    return rc;
}

int fs_trash_empty(char *err, int err_size) {
    const char *h = getenv("HOME") ?: "/tmp";
    char files[FS_PATH_MAX], info[FS_PATH_MAX];
    snprintf(files, sizeof(files), "%s/.local/share/Trash/files", h);
    snprintf(info, sizeof(info), "%s/.local/share/Trash/info", h);
    fs_delete(files, NULL, 0); fs_delete(info, NULL, 0);
    ensure_trash_dirs();
    return 0;
}

char *fs_trash_list(void) {
    const char *h = getenv("HOME") ?: "/tmp";
    char path[FS_PATH_MAX]; snprintf(path, sizeof(path), "%s/.local/share/Trash/files", h);
    return fs_list_dir(path, 1);
}

