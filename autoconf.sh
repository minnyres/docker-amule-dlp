#!/bin/bash

set -e

autoconf_version="2.69"
wget https://mirrors.sarata.com/gnu/autoconf/autoconf-${autoconf_version}.tar.xz
tar -xf autoconf-${autoconf_version}.tar.xz
cd autoconf-${autoconf_version}

./configure --prefix=/usr --build=$(gcc -dumpmachine) --host=$(gcc -dumpmachine)
make -j$(nproc)
make install 
make clean