# native - 跨平台原生层统一构建入口
# ============================================================
# 模块化架构：
#   src/          跨平台核心实现（视频/音频/电子书/压缩包/工具）
#   platform/     平台适配（音频输出）
#   include/      对外统一 API 头文件
# ============================================================

cmake_minimum_required(VERSION 3.16)
project(native LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(NATIVE_ROOT ${CMAKE_CURRENT_SOURCE_DIR})

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

if(MSVC)
    add_compile_options(/W3 /utf-8)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS NOMINMAX)
else()
    add_compile_options(-Wall -Wextra -Wno-unused-parameter)
endif()

# ============================================================
# 源码清单
# ============================================================
set(NATIVE_SOURCES
    src/utils.c
    src/fs_ops.c
    src/video_decode.c
    src/video_convert.c
    src/media_tools.c
    src/audio_decode.c
    src/epub.c
    src/archive.c
)

# 平台音频输出
if(ANDROID)
    list(APPEND NATIVE_SOURCES platform/android/audio_output.c)
else()
    list(APPEND NATIVE_SOURCES platform/linux/audio_output.c)
endif()

# ============================================================
# 静态库
# ============================================================
add_library(native STATIC ${NATIVE_SOURCES})

target_include_directories(native PUBLIC
    ${NATIVE_ROOT}/include
    ${NATIVE_ROOT}
)

# 平台系统库
if(ANDROID)
    target_link_libraries(native PUBLIC log aaudio)
else()
    target_link_libraries(native PUBLIC asound bz2 z lzma m pthread dl rt)
endif()

# ============================================================
# 第三方库
# ============================================================
if(ANDROID)
    set(THIRD_PARTY_DIR "${NATIVE_ROOT}/third_party/android")
else()
    set(THIRD_PARTY_DIR "${NATIVE_ROOT}/third_party/linux")
endif()

if(EXISTS "${THIRD_PARTY_DIR}/include" AND EXISTS "${THIRD_PARTY_DIR}/lib")
    target_include_directories(native PRIVATE "${THIRD_PARTY_DIR}/include")
    target_link_libraries(native PUBLIC
        "${THIRD_PARTY_DIR}/lib/libavformat.a"
        "${THIRD_PARTY_DIR}/lib/libavcodec.a"
        "${THIRD_PARTY_DIR}/lib/libavutil.a"
        "${THIRD_PARTY_DIR}/lib/libswscale.a"
        "${THIRD_PARTY_DIR}/lib/libswresample.a"
        "${THIRD_PARTY_DIR}/lib/libminiz.a"
        "${THIRD_PARTY_DIR}/lib/libstb_image.a"
        "${THIRD_PARTY_DIR}/lib/libsqlite3.a"
    )
    if(NOT ANDROID)
        include(ProcessorCount)
        ProcessorCount(NPROC)
        if(NPROC EQUAL 0)
            set(NPROC 4)
        endif()

        include(ExternalProject)
        set(X264_INSTALL_DIR "${CMAKE_BINARY_DIR}/x264-install")
        ExternalProject_Add(x264_external
            GIT_REPOSITORY https://code.videolan.org/videolan/x264.git
            GIT_TAG        stable
            GIT_SHALLOW    TRUE
            INSTALL_DIR    "${X264_INSTALL_DIR}"
            CONFIGURE_COMMAND cd <SOURCE_DIR> && ./configure
                --prefix=<INSTALL_DIR>
                --enable-static --disable-shared
                --enable-pic --disable-cli
                --disable-lavf --disable-swscale
            BUILD_COMMAND     make -j${NPROC}
            INSTALL_COMMAND   make install
            BUILD_IN_SOURCE   TRUE
            BUILD_BYPRODUCTS  "${X264_INSTALL_DIR}/lib/libx264.a"
        )

        file(MAKE_DIRECTORY "${X264_INSTALL_DIR}/include")
        add_library(x264 STATIC IMPORTED)
        set_target_properties(x264 PROPERTIES
            IMPORTED_LOCATION             "${X264_INSTALL_DIR}/lib/libx264.a"
            INTERFACE_INCLUDE_DIRECTORIES "${X264_INSTALL_DIR}/include"
        )
        add_dependencies(x264 x264_external)
        add_dependencies(native x264_external)
        target_link_libraries(native PUBLIC x264)
    endif()
    message(STATUS "[native] 第三方库: ${THIRD_PARTY_DIR}")
else()
    message(FATAL_ERROR "[native] 缺少第三方库: ${THIRD_PARTY_DIR}")
endif()


