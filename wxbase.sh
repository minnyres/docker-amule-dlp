#!/bin/bash

set -e

wxbase_version="3.0.5"

wget https://github.com/wxWidgets/wxWidgets/releases/download/v${wxbase_version}/wxWidgets-${wxbase_version}.tar.bz2
tar -xf wxWidgets-${wxbase_version}.tar.bz2
cd wxWidgets-${wxbase_version}
find . -name config.guess -exec cp /amule-build/config.guess {} \;
find . -name config.sub -exec cp /amule-build/config.sub {} \;

./configure --prefix=/usr --with-zlib=sys  \
    --enable-shared --disable-gui --disable-debug_flag --enable-optimise --enable-unicode --enable-monolithic
make -j$(nproc)
make install 
make clean 

find /usr/lib/ -name 'libwx_baseu*so*' -exec cp -P {} /app/lib \;