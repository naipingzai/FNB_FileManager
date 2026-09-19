#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="$SCRIPT_DIR/android"
BUILD="/tmp/native_deps_android"

# 需要设置 Android NDK 交叉编译工具链
if [ -z "$NDK_CC" ]; then
    echo "请设置 NDK 交叉编译工具链:"
    echo "  export NDK_CC=<ndk>/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang"
    echo "  export NDK_SYSROOT=<ndk>/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
    exit 1
fi

rm -rf $BUILD && mkdir -p $BUILD
NPROC=$(nproc)
CC=$NDK_CC
SYSROOT=$NDK_SYSROOT
COMMON_CFLAGS="-O2 -fPIC --sysroot=$SYSROOT"

# FFmpeg 7.0 (Android arm64)
echo "[1/3] FFmpeg 7.0 (Android arm64)"
cd $BUILD
if [ ! -d ffmpeg-7.0 ]; then
    wget -q https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz
    tar xf ffmpeg-7.0.tar.xz
fi
cd ffmpeg-7.0
./configure --prefix=$PREFIX \
    --enable-static --disable-shared \
    --disable-programs --disable-doc --disable-debug \
    --enable-gpl \
    --enable-muxers --enable-demuxers --enable-protocols \
    --enable-decoders --enable-encoders \
    --enable-swscale --enable-swresample \
    --disable-avdevice --disable-postproc --disable-network \
    --disable-autodetect --disable-runtime-cpudetect \
    --enable-cross-compile --cross-prefix=aarch64-linux-android- \
    --target-os=android --arch=aarch64 --cc=$CC --sysroot=$SYSROOT
make -j$NPROC && make install
echo "FFmpeg done"

# miniz
echo ""
echo "[2/3] miniz 3.0.2"
cd $BUILD
if [ ! -d miniz-3.0.2 ]; then
    wget -q https://github.com/richgel999/miniz/releases/download/3.0.2/miniz-3.0.2.tar.gz
    tar xzf miniz-3.0.2.tar.gz
fi
cd miniz-3.0.2
$CC $COMMON_CFLAGS -c miniz.c -o miniz.o
cp miniz.h $PREFIX/include/
ar rcs $PREFIX/lib/libminiz.a miniz.o
echo "miniz done"

# stb_image
echo ""
echo "[3/3] stb_image"
wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image.h -O $PREFIX/include/stb_image.h
echo "stb_image done"

# sqlite3
echo ""
echo "[4/4] sqlite3 3.46.1"
cd $BUILD
if [ ! -d sqlite-amalgamation-3460100 ]; then
    wget -q https://www.sqlite.org/2024/sqlite-amalgamation-3460100.zip
    unzip -q sqlite-amalgamation-3460100.zip
fi
cd sqlite-amalgamation-3460100
$CC $COMMON_CFLAGS -c sqlite3.c -o sqlite3.o -DSQLITE_THREADSAFE=1
cp sqlite3.h sqlite3ext.h $PREFIX/include/
ar rcs $PREFIX/lib/libsqlite3.a sqlite3.o
echo "sqlite3 done"

echo ""
echo "=== Android 完成 ==="
