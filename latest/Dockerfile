FROM alpine:edge as builder

# Install required packages
RUN buildDeps='g++ git bash patch file libtool automake make flex bison wget xz unzip gettext-dev pkgconf zlib-dev libpng-dev boost-dev geoip-dev' \
    && apk add --no-cache $buildDeps \
    && mkdir -p /amule-build /app/lib
    
COPY cryptopp.sh wxbase.sh upnp.sh autoconf.sh amule-fix-exception.patch config.sub config.guess /amule-build/

# Build dependencies
RUN cd /amule-build \
    && chmod 755 *.sh \
    && ./autoconf.sh \
    && ./wxbase.sh \
    && ./upnp.sh \
    && ./cryptopp.sh 

# Build amuleweb
RUN cd /amule-build \
    && wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz \
    && tar -xf aMule-2.3.3.tar.xz \
    && cd aMule-2.3.3 \
    && patch -p0  < /amule-build/amule-fix-exception.patch \
    && ./configure --prefix=/app --disable-monolithic --disable-amule-daemon --enable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost --with-denoise-level=0 \
    && make install -j$(nproc) \
    && make clean 

# Build amuled with DLP
RUN cd /amule-build \
    && git clone https://github.com/persmule/amule-dlp.git \
    && cd amule-dlp \
    && patch -p0 < /amule-build/amule-fix-exception.patch \
    && ./autogen.sh \
    && ./configure --prefix=/app --disable-monolithic --enable-amule-daemon --disable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost --with-denoise-level=0 \
    && make install -j$(nproc) \
    && make clean \
    && strip /app/bin/*

# Build DLP lib
RUN cd /amule-build \
    && git clone https://github.com/persmule/amule-dlp.antiLeech.git \
    && cd amule-dlp.antiLeech \
    && g++ -g0 -Os -s -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o libantiLeech.so $(wx-config --cppflags) $(wx-config --libs) \
    && mv libantiLeech.so /app/share/amule/libantiLeech.so


# Install some webui theme
RUN cd /amule-build \
    && git clone https://github.com/pedro77/amuleweb-bootstrap-template.git \
    && mv amuleweb-bootstrap-template/dist /app/share/amule/webserver/bootstrap \
    && git clone https://github.com/MatteoRagni/AmuleWebUI-Reloaded \
    && rm -rf AmuleWebUI-Reloaded/.git* AmuleWebUI-Reloaded/doc-images \
    && mv AmuleWebUI-Reloaded /app/share/amule/webserver/reloaded

# Delete some files to reduce image size
RUN cd /app/share \
    && rm -rf locale doc man cas applications pixmaps \
    && du -h -d 2 /app

#################################

FROM alpine:edge

COPY --from=builder /app /usr

ENV UID=1000 GID=1000 WEBUI=bootstrap ECPASSWD= TIMEZONE= RECURSIVE_SHARE= 

COPY amule.conf run.sh /

RUN apk add --no-cache libgcc libintl libpng libstdc++ musl zlib tzdata   \
    && mkdir /config /downloads /temp \
    && chmod 755 /run.sh \
    && ldd /usr/bin/amuled \
    && ldd /usr/bin/amuleweb 

VOLUME /config /downloads /temp

ENTRYPOINT ["/run.sh"]
