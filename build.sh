#!/bin/bash

opt=$2

build-official () {
echo "Update feeds..."
./scripts/feeds update -a

echo "Install all packages from feeds..."
./scripts/feeds install -a && ./scripts/feeds install -a

echo "Copy Openwrt official config..."
release=$(grep -m1 '$(VERSION_REPO),' include/version.mk | awk -F, '{ print $3 }' | sed 's/[)]//g' | tr [:upper:] [:lower:])

wget $release/targets/ramips/mt7621/config.buildinfo -O .config

echo "Set to use default config"
make defconfig

echo "Download packages before build"
if [ "$opt" = "nodownload" ]; then
   echo "Skipping download of packages.."
else
   make download
fi

echo "Start build and log to build.log"
make -j$(($(nproc)+1)) V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log
}

build-custom () {
echo "Update feeds..."
./scripts/feeds update -a

echo "Install all packages from feeds..."
./scripts/feeds install -a && ./scripts/feeds install -a

if [ -f "Custom.config" ]; then
   echo "Copying Custom Openwrt config..."
   cp Custom.config .config
else
   echo "Custom.config does no exit! - Please copy you custom config first!"
   exit 1
fi

echo "Set to use default config"
make defconfig

echo "Download packages before build"
if [ "$opt" = "nodownload" ]; then
   echo "Skipping download of packages.."
else
   make download
fi

echo "Start build and log to build.log"
make -j$(($(nproc)+1)) V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log
}

build-rebuild () {
make clean
make defconfig
echo "Start build and log to build.log"
make -j$(($(nproc)+1)) V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"
}

build-rebuild-ignore () {
echo "Start build and log to build.log - Ignoring build errors..."
IGNORE_ERRORS=1 make -i -j$(($(nproc)+1)) V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"
}

clean-min () {
make clean
}

clean-full () {
make distclean
}

case "$1" in
  build-official)
    build-official
    ;;
  build-custom)
    build-custom
    ;;
  build-rebuild)
    build-rebuild
    ;;
  build-rebuild-ignore)
    build-rebuild-ignore
    ;;
  clean-min)
    clean-min
    ;;
  clean-full)
    clean-full
    ;;
  *)
    echo "Usage: $0 {build-official|build-custom|build-rebuild|build-rebuild-ignore|clean-min|clean-full}" >&2
    echo "build-official: {Openwrt standard config}" >&2
    echo "build-custom: {Custom config}" >&2
    echo "Optional: {nodownload = No downloads of packages}" >&2
    exit 1
    ;;
esac
shift

