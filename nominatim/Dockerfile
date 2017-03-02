FROM debian:jessie
MAINTAINER Fabian Köster <mail@fabian-koester.com>

EXPOSE 80

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    build-essential \
    ca-certificates \
    curl \
    libapache2-mod-php5 \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libbz2-dev \
    libexpat-dev \
    libgeos-c1 \
    libgeos++-dev \
    libpq-dev \
    libproj-dev \
    libtool \
    libxml2-dev \
    php-db \
    php5 \
    php5-json \
    php5-pgsql \
    php-pear \
    postgresql-client \
    proj-bin \
    osmosis \
    vim \ 
 && rm -rf /var/lib/apt/lists/*

# Install gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && curl -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

ARG WEBROOT=/var/www/html/nominatim
RUN groupadd -r nominatim && useradd -r -g nominatim nominatim
RUN mkdir -p ${WEBROOT} /app && chmod -R 755 ${WEBROOT} /app && chown -R nominatim:nominatim ${WEBROOT} /app

WORKDIR /app
ARG NOMINATIM_VERSION=2.5.1
ARG NOMINATIM_SHA256=0c2d7fcafc3caa42b3f5f2041ecf33bb22377ffe861a0b97a5aa27b6552d597b
RUN gosu nominatim curl -o nominatim.tar.bz2 http://www.nominatim.org/release/Nominatim-${NOMINATIM_VERSION}.tar.bz2 \
  && echo "${NOMINATIM_SHA256} nominatim.tar.bz2" | sha256sum -c \
  && gosu nominatim tar -xf nominatim.tar.bz2 --strip-components=1 \
  && rm *.tar.bz2 \
  && gosu nominatim ./configure \
  && gosu nominatim make

COPY entrypoint.sh wait-for-it.sh ./
COPY local.php ./settings/local.php
COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY apache2-foreground /usr/local/bin

#patch Luca
COPY address-json.php /app/lib/template/
COPY ReverseGeocode.php /app/lib/
COPY reverse.php /app/website/
RUN chown nominatim:nominatim /app/website/reverse.php
RUN chown nominatim:nominatim /app/lib/template/address-json.php
RUN chown nominatim:nominatim /app/lib/ReverseGeocode.php

RUN gosu nominatim /app/utils/setup.php --create-website /var/www/html/nominatim

#updater
#RUN gosu nominatim /app/utils/setup.php --osmosis-init
#RUN gosu nominatim /app/utils/setup.php --create-functions --enable-diff-updates
#constant update
#RUN gosu nominatim /app/utils/supdate.php --import-osmosis-all --no-npi
#or run
#docker exec -it dockernominatim_nominatim_1 gosu nominatim /app/utils/setup.php --osmosis-init
#docker exec -it dockernominatim_nominatim_1 gosu nominatim /app/utils/setup.php --create-functions --enable-diff-updates
#docker exec -it dockernominatim_nominatim_1 gosu nominatim /app/utils/update.php --import-osmosis-all --no-npi


VOLUME /importdata
VOLUME /app/module
CMD /app/entrypoint.sh
