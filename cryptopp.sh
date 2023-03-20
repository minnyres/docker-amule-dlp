#!/bin/bash

set -e

cryptopp="cryptopp870"
cryptopp_autotools="CRYPTOPP_8_7_0"

wget http://cryptopp.com/${cryptopp}.zip
wget https://github.com/noloader/cryptopp-autotools/archive/refs/tags/${cryptopp_autotools}.tar.gz -O cryptopp-autotools-${cryptopp_autotools}.tar.gz

tar -xf cryptopp-autotools-${cryptopp_autotools}.tar.gz

mkdir -p cryptopp
cd cryptopp
7z x ../${cryptopp}.zip

mv ../cryptopp-autotools-${cryptopp_autotools}/* .
mkdir -p m4

./bootstrap.sh

CPPFLAGS="-DNDEBUG" CXXFLAGS="-g0 -O3" LDFLAGS="-s" ./configure --prefix=/usr --enable-shared=no
make -j$(nproc)
make install
make clean

find /usr/lib/ -name 'libcryptopp*so*' -exec rm -f {} \;