FROM debian:bullseye-slim as builder

# Install required packages
RUN buildDeps='g++ git libtool-bin libtool autoconf automake make flex bison wget bzip2 xz-utils gettext pkg-config autopoint zlib1g-dev libupnp-dev libpng-dev libcrypto++-dev libboost-system-dev libboost-dev libgeoip-dev libwxbase3.0-dev' \
    && echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list \ 
    && apt update \
    && apt install -y $buildDeps \
    && apt build-dep -y amule

# Build amuleweb
RUN mkdir /amule-build \
    && cd /amule-build \
    && wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz \
    && tar -xf aMule-2.3.3.tar.xz \
    && cd aMule-2.3.3 \
    && ./configure --prefix=/app --disable-monolithic --disable-amule-daemon --enable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost \
    && make install \
    && make clean

# Build amuled with DLP
RUN cd /amule-build \
    && git clone https://github.com/persmule/amule-dlp.git \
    && cd amule-dlp \
    && ./autogen.sh \
    && ./configure --prefix=/app --disable-monolithic --enable-amule-daemon --disable-webserver --disable-amulecmd --disable-amule-gui --disable-ed2k --disable-cas --disable-wxcas --disable-alc --disable-alcc --disable-fileview --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-boost \
    && make install \
    && make clean

# Build DLP lib
RUN cd /amule-build \
    && git clone https://github.com/persmule/amule-dlp.antiLeech.git \
    && cd amule-dlp.antiLeech \
    && ./autogen.sh \
    && export PATH=$PATH:/app/bin \
    && ./configure --prefix=/app \
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
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8 

COPY amule.conf run.sh /

RUN apt update \
    && apt install -y libupnp13 libixml10 libcrypto++8 libpng16-16 libwxbase3.0-0v5 libreadline8 locales \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && apt clean autoclean \
    && apt autoremove --yes \
    && rm -rf /var/{cache,log}/ \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /config /downloads /temp \
    && chmod 755 /run.sh

VOLUME /config /downloads /temp

ENTRYPOINT ["/run.sh"]
