#!/bin/bash

set -e

autoconf_version="2.69"
wget https://ftpmirror.gnu.org/gnu/autoconf/autoconf-${autoconf_version}.tar.xz
tar -xf autoconf-${autoconf_version}.tar.xz
cd autoconf-${autoconf_version}
cp /amule-build/config.* build-aux

./configure --prefix=/usr 
make -j$(nproc)
make install 
make clean