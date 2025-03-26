#!/bin/bash

set -e 

if [ "$1" = "dlp" ]; then
  config_option="--disable-amule-daemon"
else
  config_option="--enable-amule-daemon"
fi

wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz 
tar -xf aMule-2.3.3.tar.xz 
cd aMule-2.3.3 
find . -name config.guess -exec cp /amule-build/config.guess {} \;
find . -name config.sub -exec cp /amule-build/config.sub {} \;
wget https://github.com/amule-project/amule/pull/298/commits/40810d2fba2c2092efca84ed7f2017fddbb70ebd.patch 
patch -p1 < 40810d2fba2c2092efca84ed7f2017fddbb70ebd.patch 
patch -p0  < /amule-build/amule-fix-exception.patch 
./configure --prefix=/app --disable-monolithic $config_option --enable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost --with-denoise-level=0 
make install -j$(nproc) 
make clean 

if [ "$1" != "dlp" ]; then
  strip /app/bin/*
  exit 0
fi

# Build amuled with DLP
cd /amule-build 
git clone https://github.com/persmule/amule-dlp.git 
cd amule-dlp 
find . -name config.guess -exec cp /amule-build/config.guess {} \;
find . -name config.sub -exec cp /amule-build/config.sub {} \;
wget https://github.com/amule-project/amule/pull/298/commits/40810d2fba2c2092efca84ed7f2017fddbb70ebd.patch 
patch -p1 < 40810d2fba2c2092efca84ed7f2017fddbb70ebd.patch 
patch -p0 < /amule-build/amule-fix-exception.patch 
./autogen.sh 
./configure --prefix=/app --disable-monolithic --enable-amule-daemon --disable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost --with-denoise-level=0 
make install -j$(nproc) 
make clean 
strip /app/bin/*

# Build DLP lib
cd /amule-build 
git clone https://github.com/persmule/amule-dlp.antiLeech.git 
cd amule-dlp.antiLeech 
g++ -g0 -Os -s -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o libantiLeech.so $(wx-config --cppflags) $(wx-config --libs) 
mv libantiLeech.so /app/share/amule/libantiLeech.so