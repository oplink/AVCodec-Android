#!/bin/bash

PLATFORM=$NDK_ROOT/platforms/android-8/arch-arm
PREBUILT=$NDK_ROOT/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86
PREFIX=android

function build_one
{
	./configure --target-os=linux --prefix=$PREFIX \
	--enable-cross-compile \
	--enable-runtime-cpudetect \
	--disable-asm \
	--arch=arm \
	--cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
	--cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
	--nm=$PREBUILT/bin/arm-linux-androideabi-nm \
	--sysroot=$PLATFORM \
	--enable-nonfree \
	--enable-version3 \
	--enable-gpl \
	--disable-doc \
	--enable-avresample \
	--disable-ffplay \
	--disable-ffserver \
	--enable-ffmpeg \
	--disable-ffprobe \
	--enable-libx264 \
	--enable-encoder=libx264 \
	--enable-decoder=h264 \
	--enable-zlib \
	--disable-devices \
	--disable-avdevice \
	--enable-debug \
	--extra-cflags="-I../x264/android/include/ -fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a" \
	--extra-ldflags="-L../x264/android/lib/"
	make -j4 install

	$PREBUILT/bin/arm-linux-androideabi-ar d libavcodec/libavcodec.a inverse.o
	$PREBUILT/bin/arm-linux-androideabi-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L../x264/android/lib  -soname libffmpeg.so -shared -nostdlib  -z,noexecstack -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so libavcodec/libavcodec.a libavfilter/libavfilter.a libavresample/libavresample.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a libpostproc/libpostproc.a libswresample/libswresample.a -lc -lm -lz -ldl -llog -lx264 --warn-once --dynamic-linker=/system/bin/linker $PREBUILT/lib/gcc/arm-linux-androideabi/4.4.3/libgcc.a
	$PREBUILT/bin/arm-linux-androideabi-strip $PREFIX/libffmpeg.so
	$PREBUILT/bin/arm-linux-androideabi-strip $PREFIX/bin/ffmpeg
}

build_one
