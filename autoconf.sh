#!/bin/bash

set -e

autoconf_version="2.69"
wget http://ftpmirror.gnu.org/autoconf/autoconf-${autoconf_version}.tar.xz
tar -xf autoconf-${autoconf_version}.tar.xz
cd autoconf-${autoconf_version}

./configure --prefix=/usr
make -j$(nproc)
make install 
make clean