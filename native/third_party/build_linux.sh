#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFIX="$SCRIPT_DIR/linux"
BUILD="/tmp/native_deps_linux"
rm -rf $BUILD && mkdir -p $BUILD
NPROC=$(nproc)

echo "=== Linux 依赖编译 ==="
echo "前缀: $PREFIX"

# FFmpeg 7.0 + libx264
echo ""
echo "[1/4] FFmpeg 7.0 + libx264"
cd $BUILD
if [ ! -d ffmpeg-7.0 ]; then
    wget -q https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz
    tar xf ffmpeg-7.0.tar.xz
fi
cd ffmpeg-7.0
./configure --prefix=$PREFIX \
    --enable-static --disable-shared \
    --disable-programs --disable-doc --disable-debug \
    --enable-gpl --enable-libx264 \
    --enable-muxers --enable-demuxers --enable-protocols \
    --enable-decoders --enable-encoder=libx264 \
    --enable-swscale --enable-swresample \
    --disable-avdevice --disable-postproc --disable-network \
    --disable-vaapi --disable-vdpau --disable-autodetect
make -j$NPROC && make install
echo "FFmpeg done"

# miniz 3.0.2
echo ""
echo "[2/4] miniz 3.0.2"
cd $BUILD
if [ ! -d miniz-3.0.2 ]; then
    wget -q https://github.com/richgel999/miniz/releases/download/3.0.2/miniz-3.0.2.tar.gz
    tar xzf miniz-3.0.2.tar.gz
fi
cd miniz-3.0.2
gcc -O2 -c miniz.c -o miniz.o -fPIC
cp miniz.h $PREFIX/include/
ar rcs $PREFIX/lib/libminiz.a miniz.o
echo "miniz done"

# stb_image
echo ""
echo "[3/4] stb_image"
wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image.h -O $PREFIX/include/stb_image.h
echo "stb_image done"

# sqlite3 3.46.1
echo ""
echo "[4/4] sqlite3 3.46.1"
cd $BUILD
if [ ! -d sqlite-amalgamation-3460100 ]; then
    wget -q https://www.sqlite.org/2024/sqlite-amalgamation-3460100.zip
    unzip -q sqlite-amalgamation-3460100.zip
fi
cd sqlite-amalgamation-3460100
gcc -O2 -c sqlite3.c -o sqlite3.o -fPIC -DSQLITE_THREADSAFE=1
cp sqlite3.h sqlite3ext.h $PREFIX/include/
ar rcs $PREFIX/lib/libsqlite3.a sqlite3.o
echo "sqlite3 done"

echo ""
echo "=== Linux 完成 ==="
