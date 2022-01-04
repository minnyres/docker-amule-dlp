FROM debian:bullseye-slim as builder

# Install required packages
RUN buildDeps='g++ git libtool-bin libtool autoconf automake make flex bison wget bzip2 xz-utils gettext pkg-config autopoint zlib1g-dev libupnp-dev libpng-dev libcrypto++-dev libboost-system-dev libboost-dev libgeoip-dev' \
    && apt update \
    && apt install -y $buildDeps

# Build wxBase
RUN mkdir /amule-build \
    && cd /amule-build \
    && wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.5/wxWidgets-3.0.5.tar.bz2 \
    && tar -xf wxWidgets-3.0.5.tar.bz2 \
    && cd wxWidgets-3.0.5 \
    && ./configure --prefix=/app --disable-gui --disable-debug_flag \
    && make install \
    && make clean

# Build amuled and amuleweb
RUN cd /amule-build \
    && wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz \
    && tar -xf aMule-2.3.3.tar.xz \
    && cd aMule-2.3.3 \
    && ./configure --prefix=/app --disable-monolithic --enable-amule-daemon --enable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-wx-prefix=/app --with-wx-config=/app/bin/wx-config --with-boost \
    && make install \
    && make clean

# Install some webui theme
RUN cd /amule-build \
    && git clone https://github.com/pedro77/amuleweb-bootstrap-template.git \
    && mv amuleweb-bootstrap-template/dist /app/share/amule/webserver/bootstrap \
    && git clone https://github.com/MatteoRagni/AmuleWebUI-Reloaded \
    && rm -rf AmuleWebUI-Reloaded/.git* AmuleWebUI-Reloaded/doc-images \
    && mv AmuleWebUI-Reloaded /app/share/amule/webserver/reloaded

#################################

FROM debian:bullseye-slim

COPY --from=builder /app /usr

ENV UID=1000 GID=1000 WEBUI=bootstrap ECPASSWD= TIMEZONE= RECURSIVE_SHARE=

COPY amule.conf run.sh /

RUN apt update \
    && apt install -y libupnp13 libixml10 libcrypto++8 libpng16-16 \
    && apt clean autoclean \
    && apt autoremove --yes \
    && rm -rf /var/{cache,log}/ \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /config /downloads /temp \
    && chmod 755 /run.sh

VOLUME /config /downloads /temp

ENTRYPOINT ["/run.sh"]