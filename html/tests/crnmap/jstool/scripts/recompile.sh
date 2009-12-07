#!/bin/bash

ARCH=i386
PRIVATE=$ARCH-smp-tuxonice
VERSION=2.6.22.14-$PRIVATE
KERNEL_PATH=/usr/src/kernels

## change the local version name
if [ -e .config ]; then
  cp -a .config .config.bak
  sed "s@\(CONFIG_LOCALVERSION=\)\".*\"@\1\"-$PRIVATE\"@" .config.bak > .config
else
  echo "No .config file"
  exit
fi

COMPILER="ccache gcc"

if ! [ -d $KERNEL_PATH/linux-$VERSION ]; then
  echo error: $KERNEL_PATH/linux-$VERSION
  echo "non-existent file location"
  echo "creating the necessary symlink path"
  ln -s $PWD ../linux-$VERSION
  echo "Edit your grub.conf or lilo.conf"
fi

## backup your .config elsewhere
cp -a $KERNEL_PATH/linux-$VERSION/.config /boot/config-$VERSION

cd $KERNEL_PATH/linux-$VERSION && \
make CC="$COMPILER" bzImage && \
make CC="$COMPILER" modules && \
make CC="$COMPILER" modules_install && \
echo "copying kernel image, map, config file" && \
cp -a $KERNEL_PATH/linux-$VERSION/arch/$ARCH/boot/bzImage \
	/boot/bzImage-$VERSION && \
cp -a $KERNEL_PATH/linux-$VERSION/System.map /boot/System.map-$VERSION && \
echo "running lilo..." && \
/sbin/lilo

exit
