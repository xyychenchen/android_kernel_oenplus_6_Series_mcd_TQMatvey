#!/bin/bash
#设置环境

# 交叉编译器路径
export PATH=$(pwd)/proton-clang/bin/:$PATH
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
# export CONFIG_BUILD_ARM64_DT_OVERLAY=y

export ARCH=arm64
export SUBARCH=arm64
# export DTC_EXT=dtc

if [ ! -d "out" ]; then
	mkdir out
fi

start_time=$(date +%Y.%m.%d-%I_%M)

start_time_sum=$(date +%s)

make ARCH=arm64 O=out CC="ccache clang" mcd_ksu_defconfig
# make ARCH=arm64 O=out CC=clang oldconfig
# 定义编译线程数
make ARCH=arm64 O=out CC="ccache clang" -j$(nproc --all) 2>&1 | tee kernel_log-${start_time}.txt

end_time_sum=$(date +%s)

end_time=$(date +%Y.%m.%d-%I_%M)

# 计算运行时间（秒）
duration=$((end_time_sum - start_time_sum))

# 将秒数转化为 "小时:分钟:秒" 形式输出
hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# 打印运行时间
echo "脚本运行时间为：${hours}小时 ${minutes}分钟 ${seconds}秒"

if [ -f out/arch/arm64/boot/Image ]; then
	echo "***Packing kernel...***"
	cp out/arch/arm64/boot/Image tools/AnyKernel3/Image
	cd tools/AnyKernel3
	echo "***Sucessfully built kernel...***"
	echo " "
	exit 0
else
	echo " "
	echo "***Failed!***"
	exit 0
fi
