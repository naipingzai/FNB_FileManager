#!/bin/bash
set -e
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
    echo "Usage: bash build.sh [platform] [mode]"
    echo ""
    echo "Platforms:"
    echo "  linux     Linux 桌面版（默认）"
    echo "  android   Android 移动版"
    echo ""
    echo "Modes:"
    echo "  debug     调试模式 flutter run（默认）"
    echo "  release   发布模式 flutter build"
    echo ""
    echo "Examples:"
    echo "  bash build.sh                  # Linux debug"
    echo "  bash build.sh linux release    # Linux release"
    echo "  bash build.sh android release  # Android release"
}

# 解析参数
PLATFORM=${1:-linux}
MODE=${2:-debug}

if [ "$PLATFORM" = "-h" ] || [ "$PLATFORM" = "--help" ]; then
    show_help
    exit 0
fi

echo "=== FNB_FileManager 编译 ==="
echo "平台: $PLATFORM  模式: $MODE"
echo ""

# 1. 编译 native 依赖库
case "$PLATFORM" in
    linux)
        if [ ! -f "$PROJECT_DIR/native/third_party/linux/lib/libavformat.a" ]; then
            echo "编译 Linux 依赖..."
            cd "$PROJECT_DIR/native/third_party"
            bash build_linux.sh
        else
            echo "Linux 依赖库已存在，跳过"
        fi
        ;;
    android)
        if [ -z "$NDK_CC" ]; then
            echo "错误: 请先设置 Android NDK 环境变量"
            echo "  export NDK_CC=<ndk>/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang"
            echo "  export NDK_SYSROOT=<ndk>/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
            exit 1
        fi
        if [ ! -f "$PROJECT_DIR/native/third_party/android/lib/libavformat.a" ]; then
            echo "编译 Android 依赖..."
            cd "$PROJECT_DIR/native/third_party"
            bash build_android.sh
        else
            echo "Android 依赖库已存在，跳过"
        fi
        ;;
    *)
        echo "不支持的平台: $PLATFORM"
        echo "支持: linux, android"
        exit 1
        ;;
esac

# 2. Flutter 构建
echo ""
echo "Flutter 构建 ($PLATFORM $MODE)..."
cd "$PROJECT_DIR"

if [ "$PLATFORM" = "android" ]; then
    if [ "$MODE" = "release" ]; then
        flutter build apk
        echo "产物: build/app/outputs/flutter-apk/app-release.apk"
    else
        flutter run -d android
    fi
else
    if [ "$MODE" = "release" ]; then
        flutter build linux
        echo "产物: build/linux/x64/release/bundle/flutter_file_manager"
    else
        flutter run -d linux
    fi
fi
