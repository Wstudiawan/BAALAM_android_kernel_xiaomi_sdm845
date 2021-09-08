#!/usr/bin/env bash
echo "Cloning dependencies"
git clone -j8 https://github.com/z4nyx/linaro-gcc-elf -b latest-7 --depth=1 gcc
git clone -j8 --depth=1 https://github.com/Wstudiawan/AnyKernel3-1.git AnyKernel
echo "Done"
GCC="$(pwd)/gcc/bin/aarch64-elf-"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%S-%F")
START=$(date +"%s")
export ARCH=arm64
export KBUILD_BUILD_USER=wstudiawan
export KBUILD_BUILD_HOST=circle
git config --global user.email "manusiasampah7@gmail.com"
git config --global user.name "Wstudiawan"
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAADAQADHAADvi-SJce2yqOIKPDcFgQ" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot1446507242:AAFivf422Yvh3CL7y98TJmxV1KgyKByuPzM/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>-Parak Karakah Kernel- CI</b>%0AStarted on: <code>Circle CI/CD</code>%0ADevice: <b>Xiaomi Pocophone F1</b> (beryllium)%0ABranch: <code>$(git rev-parse --abbrev-ref HEAD)</code>%0AUnder Commit: <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AToolchain: <code>aarch64-elf-gcc (Linaro GCC) 7.5.0</code>%0ADate: <code>$(date)</code>%0A<b>Build Status:</b> #Nightly"
}
# Push kernel to channel
function push() {
    cd AnyKernel || exit 1
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot1446507242:AAFivf422Yvh3CL7y98TJmxV1KgyKByuPzM/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Pocophone F1 (beryllium)</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot1446507242:AAFivf422Yvh3CL7y98TJmxV1KgyKByuPzM/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
    make -s -C "$(pwd)" -j"$(nproc)" O=out beryllium_defconfig
    make -C "$(pwd)" CROSS_COMPILE="${GCC}" O=out -j"$(nproc)"
    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Parak-Karakah-Kernel-beryllium-${TANGGAL}.zip *
    cd .. #well
}
sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push