#!/bin/bash

set -e

upnp_version="1.14.20"

wget https://github.com/pupnp/pupnp/releases/download/release-${upnp_version}/libupnp-${upnp_version}.tar.bz2
tar -xf libupnp-${upnp_version}.tar.bz2
cd libupnp-${upnp_version}

./configure --prefix=/usr --enable-static=yes --enable-shared=no --disable-samples --disable-ipv6
make -j$(nproc)
make install
make clean
