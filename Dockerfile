ARG image_tag="alpine:edge"

FROM ${image_tag} as builder

ARG amule_version="dlp"

# Install required packages
RUN buildDeps='g++ git bash patch file libtool automake autoconf make flex bison wget xz unzip gettext-dev pkgconf zlib-dev libpng-dev boost-dev geoip-dev' \
    && apk add --no-cache $buildDeps \
    && mkdir -p /amule-build /app/lib
    
COPY cryptopp.sh amule.sh wxbase.sh upnp.sh autoconf.sh amule-fix-exception.patch config.sub config.guess /amule-build/

# Build dependencies
RUN cd /amule-build \
    && chmod 755 *.sh \
    && ./wxbase.sh \
    && ./upnp.sh \
    && ./cryptopp.sh 

# Build amule and amule-dlp
RUN cd /amule-build \
    && ./amule.sh ${amule_version}

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

FROM ${image_tag} 

COPY --from=builder /app /usr

ENV UID=1000 GID=1000 WEBUI=bootstrap ECPASSWD= TIMEZONE= RECURSIVE_SHARE= 

COPY amule.conf run.sh /

ARG boost_library

RUN apk add --no-cache libgcc libintl libpng libstdc++ musl zlib tzdata ${boost_library}   \
    && mkdir /config /downloads /temp \
    && chmod 755 /run.sh \
    && ldd /usr/bin/amuled \
    && ldd /usr/bin/amuleweb 

VOLUME /config /downloads /temp

ENTRYPOINT ["/run.sh"]
