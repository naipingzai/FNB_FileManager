#ifndef BRIDGE_API_H
#define BRIDGE_API_H

#include <stdint.h>
#include <stddef.h>

#ifdef _WIN32
#define API __declspec(dllexport)
#else
#define API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================
// 视频模块 (video_decode.c)
// ============================================================

// ============================================================
// 压缩包操作 (archive.c) - 多格式
// ============================================================

/// 列出压缩包内容 JSON（支持 ZIP/TAR/TAR.GZ/GZ/BZ2/XZ/7z/RAR）
API char *archive_list(const char *path);

/// 解压压缩包（后台线程，Dart 用 Timer 轮询 archive_get_progress）
API int archive_extract_progress(const char *archive_path, const char *out_dir,
                                 const char *password, char *error, int error_size);

/// 兼容旧接口
API int archive_extract(const char *archive_path, const char *out_dir,
                        char *error, int error_size);

/// 创建压缩包（后台线程，自动识别目标格式）
API int archive_create_progress(const char *src_path, const char *out_path,
                                char *error, int error_size);

/// 创建压缩包（带压缩级别）
API int archive_create_ex(const char *src_path, const char *out_path, int level,
                          char *error, int error_size);

/// 兼容旧接口
API int archive_create(const char *src_path, const char *zip_path,
                       char *error, int error_size);

/// 获取压缩/解压进度
API int archive_get_progress(int *current, int *total, char *filename, int fn_size);

/// 是否正在进行压缩/解压
API int archive_is_running(void);

/// 取消正在进行的解压
API int archive_cancel_extract(void);

/// 统计压缩包内文件数
API int archive_file_count(const char *path);

/// 单文件解压（同步，GZ/BZ2/XZ）
API int archive_decompress_file(const char *in_path, const char *out_path,
                                char *error, int error_size);

/// 单文件压缩（同步，GZ/BZ2/XZ）
API int archive_compress_file(const char *in_path, const char *out_path, int level,
                              char *error, int error_size);

/// 获取支持的格式列表 JSON
API char *archive_supported_formats(void);

// ============================================================
// 文件系统操作 (fs_ops.c)
// ============================================================

/// 递归复制文件/目录  →  0=成功, -1=失败
API int fs_copy(const char *src, const char *dst, char *err, int err_size);

/// 移动/重命名（跨设备自动 copy+delete）
API int fs_move(const char *src, const char *dst, char *err, int err_size);

/// 递归删除文件/目录
API int fs_delete(const char *path, char *err, int err_size);

/// 创建目录（递归 mkdir -p）
API int fs_mkdir(const char *path, char *err, int err_size);

/// 重命名
API int fs_rename(const char *old_path, const char *new_path, char *err, int err_size);

/// 获取文件/目录属性 JSON
API char *fs_properties(const char *path);

/// 递归计算目录大小（字节数）
API long long fs_dir_size(const char *path);

/// 列出目录内容 JSON
API char *fs_list_dir(const char *path, int show_hidden);

/// 永久删除（物理删除，不经回收站）
API int fs_delete_permanent(const char *path, char *err, int err_size);

/// 创建空文件
API int fs_create_file(const char *path, char *err, int err_size);

/// 修改权限 (如 0755)
API int fs_chmod(const char *path, int mode, char *err, int err_size);

/// 文件哈希 (algo: 0=md5, 1=sha256)，返回 hex 字符串
API char *fs_file_hash(const char *path, int algo);

/// 批量重命名
API int fs_batch_rename(const char *dir, const char *names_json, char *err, int err_size);

/// 移动到回收站
API int fs_trash(const char *path, char *err, int err_size);

/// 从回收站恢复
API int fs_trash_restore(const char *name, char *err, int err_size);

/// 清空回收站
API int fs_trash_empty(char *err, int err_size);

/// 列出回收站内容
API char *fs_trash_list(void);

// ============================================================
// GPU 检测 (utils.c)
// ============================================================

/// 检测GPU硬件解码能力，返回JSON:
/// {"hw_decode": true/false, "gpu": "nvidia"/"mesa"/"zink"/"none", "recommendation": "auto-safe"/"no"}
API char *gpu_detect_hw_decode(void);

// ============================================================
// 硬件解码接口（预留）
// ============================================================

/// 初始化硬件解码器（预留，当前回退软解）
API void *hw_decode_init(const unsigned char *data, int len);

/// 硬件解码下一帧，返回 1=有帧 0=EOF -1=错误
API int hw_decode_frame(void *handle, unsigned char *out, int out_cap,
                        int *out_w, int *out_h, double *out_ts);

/// 硬件解码 seek
API int hw_decode_seek(void *handle, double timestamp);

/// 关闭硬件解码器
API void hw_decode_close(void *handle);

// ============================================================
// 视频格式转换 (video_convert.c)
// ============================================================

/// 视频格式转换（同步，带进度回调）
/// codec: "h264"/"h265"/"copy", container: "mp4"/"mkv"/"avi"/"flv"/"mov"/"webm"
/// bitrate: kbps(0=自动), max_w: 缩放宽度(0=不缩放)
API int video_convert(const char *input_path, const char *output_path,
                      const char *codec, const char *container,
                      int bitrate, int max_w,
                      char *error, int error_size);

/// 获取转换进度 → current/total, 返回 1=运行中 0=完成
API int video_convert_get_progress(int *current, int *total);

/// 取消正在进行的转换
API int video_convert_cancel(void);

// ============================================================
// 媒体工具 (media_tools.c)
// ============================================================

/// 视频转 GIF
/// start_sec: 起始秒, duration_sec: 持续秒, fps: 帧率, width: 目标宽度(0=原始)
API int video_to_gif(const char *input, const char *output,
                     int start_sec, int duration_sec, int fps, int width,
                     char *error, int error_size);

/// 视频裁剪（重新编码）
API int video_trim(const char *input, const char *output,
                   int start_sec, int end_sec,
                   char *error, int error_size);

/// 音频提取（直接拷贝流）
API int video_extract_audio(const char *input, const char *output,
                            char *error, int error_size);

/// 获取媒体信息 JSON
API char *media_get_info(const char *path);

// ============================================================
// 工具函数
// ============================================================

/// 释放字符串内存
API __attribute__((used)) void bridge_free_string(char *str);

// ============================================================
// 7z 创建 (通过系统7z命令)
// ============================================================

/// 创建7z压缩包（通过系统7z命令）
API int archive_create_7z(const char *src_path, const char *out_path, 
                          const char *password, int level,
                          char *error, int error_size);

#ifdef __cplusplus
}
#endif

#endif // BRIDGE_API_H
