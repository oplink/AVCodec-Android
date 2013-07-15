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
	--disable-stripping \
	--nm=$PREBUILT/bin/arm-linux-androideabi-nm \
	--sysroot=$PLATFORM \
	--enable-version3 \
	--disable-doc \
	--enable-avresample \
	--disable-everything \
	--disable-ffplay \
	--disable-ffserver \
	--enable-ffmpeg \
	--disable-ffprobe \
	--enable-muxer=mp4 \
	--enable-decoder=h264 \
	--enable-decoder=mjpeg \
	--enable-encoder=mjpeg \
	--enable-decoder=mpeg4 \
	--enable-encoder=mpeg4 \
	--enable-protocol=file \
	--enable-hwaccels \
	--disable-devices \
	--disable-avdevice \
	--extra-cflags=" -fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a" \
	--extra-ldflags=""
	make -j4 install

	$PREBUILT/bin/arm-linux-androideabi-ar d libavcodec/libavcodec.a inverse.o
	$PREBUILT/bin/arm-linux-androideabi-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -soname libffmpeg.so -shared -nostdlib  -z,noexecstack -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so libavcodec/libavcodec.a libavfilter/libavfilter.a libavresample/libavresample.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a -lc -lm -lz -ldl -llog --warn-once --dynamic-linker=/system/bin/linker $PREBUILT/lib/gcc/arm-linux-androideabi/4.4.3/libgcc.a
	$PREBUILT/bin/arm-linux-androideabi-strip $PREFIX/libffmpeg.so
	$PREBUILT/bin/arm-linux-androideabi-strip $PREFIX/bin/ffmpeg
}

build_one
