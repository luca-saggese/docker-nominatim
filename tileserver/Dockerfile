FROM ubuntu:trusty
MAINTAINER Fabian Köster <mail@fabian-koester.com>

EXPOSE 80

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    ca-certificates \
    curl \
    libboost-all-dev \
    subversion \
    git-core \
    tar \
    unzip \
    wget \
    bzip2 \
    build-essential \
    autoconf \
    libtool \
    libxml2-dev \
    libgeos-dev \
    libgeos++-dev \
    libpq-dev \
    libbz2-dev \
    libproj-dev \
    munin-node \
    munin \
    libprotobuf-c0-dev \
    protobuf-c-compiler \
    libfreetype6-dev \
    libpng12-dev \
    libtiff4-dev \
    libicu-dev \
    libgdal-dev \
    libcairo-dev \
    libcairomm-1.0-dev \
    apache2 \
    apache2-dev \
    libagg-dev \
    liblua5.2-dev \
    ttf-unifont \
    lua5.1 \
    liblua5.1-dev \
    node-carto \
    osm2pgsql \
    libmapnik2.2 \
    python-mapnik \
    apache2 \
    apache2-threaded-dev \
    apache2-mpm-prefork \
    apache2-utils \
    automake \
    postgresql-client \
    mapnik-utils \
    libmapnik-dev \
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








ARG WEBROOT=/var/www/html/gis
RUN groupadd -r tileserver && useradd -r -g tileserver tileserver

#install pg2sql
#RUN mkdir -p /app/src
#WORKDIR /app/src
#RUN git clone git://github.com/openstreetmap/osm2pgsql.git
#WORKDIR /app/src/osm2pgsql
#RUN ./autogen.sh
#RUN ./configure
#RUN make
#RUN make install

#install mapnik
#WORKDIR /app/src
#RUN git clone git://github.com/mapnik/mapnik
#WORKDIR /app/src/mapnik
#RUN git branch 2.2 origin/2.2.x
#RUN git checkout 2.2

#RUN python scons/scons.py configure INPUT_PLUGINS=all OPTIMIZATION=3 SYSTEM_FONTS=/usr/share/fonts/truetype/
#RUN make
#RUN make install
#RUN ldconfig

#install mod_tile


WORKDIR /app/src
RUN git clone git://github.com/openstreetmap/mod_tile.git
WORKDIR /app/src/mod_tile
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN make install-mod_tile
RUN ldconfig

#cleanup directories
WORKDIR /app


#Download OSM Bright
RUN mkdir -p /app/maps/style
RUN chown tileserver /app/maps/style
WORKDIR /app/maps/style
RUN wget https://github.com/mapbox/osm-bright/archive/master.zip
RUN wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
RUN wget http://data.openstreetmapdata.com/land-polygons-split-3857.zip
RUN mkdir ne_10m_populated_places_simple
WORKDIR /app/maps/style/ne_10m_populated_places_simple
RUN wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip
RUN unzip ne_10m_populated_places_simple.zip
RUN rm ne_10m_populated_places_simple.zip
WORKDIR /app/maps/style/

RUN unzip '*.zip'
RUN mkdir osm-bright-master/shp
RUN mv land-polygons-split-3857 osm-bright-master/shp/
RUN mv simplified-land-polygons-complete-3857 osm-bright-master/shp/
RUN mv ne_10m_populated_places_simple osm-bright-master/shp/
#To improve performance, we create index files for the larger shapefiles:
WORKDIR /app/maps/style/osm-bright-master/shp/land-polygons-split-3857
RUN shapeindex land_polygons.shp
WORKDIR /app/maps/style/osm-bright-master/shp/simplified-land-polygons-complete-3857/
RUN shapeindex simplified_land_polygons.shp

COPY configure.py /app/maps/style/osm-bright-master/
COPY osm-bright.osm2pgsql.mml /app/maps/style/osm-bright-master/osm-bright/osm-bright.osm2pgsql.mml

WORKDIR /app/maps/style/osm-bright-master/
RUN ./make.py
WORKDIR /app/maps/style/OSMBright/
RUN carto project.mml > OSMBright.xml

COPY renderd.conf /usr/local/etc/renderd.conf

#RUN gosu chown tileserver /var/run/renderd
#RUN gosu chown tileserver /var/lib/mod_tile

COPY mod_tile.conf /etc/apache2/conf-available/mod_tile.conf

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN a2enconf mod_tile

COPY renderd.init /etc/init.d/renderd
RUN chmod u+x /etc/init.d/renderd

RUN rm -r /app/src

WORKDIR /app
COPY entrypoint.sh wait-for-it.sh ./
COPY apache2-foreground /usr/local/bin

VOLUME /importdata
VOLUME /app/module
CMD /app/entrypoint.sh
