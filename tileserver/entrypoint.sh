#! /bin/bash

set -e

function log_error {
  if [ -n "${LOGFILE}" ]
  then
    echo "[error] ${1}\n" >> ${LOGFILE}
  fi
  >&2 echo "[error] ${1}"
}

function log_info {
  if [ -n "${LOGFILE}" ]
  then
    echo "[info] ${1}\n" >> ${`LOGFILE`}
  else
    echo "[info] ${1}"
  fi
}

function die {
    echo >&2 "$@"
    exit 1
}

function initialization {
  if [ -s /importdata/data.osm.pbf ]; then
    log_info "==> Planet file /importdata/data.osm.pbf already exists, skipping download."
  else
    log_info "==> Downloading Planet file..."
    chown -R tileserver:tileserver /importdata
    START_DOWNLOAD=$(date +%s)
    gosu tileserver curl -L -o /importdata/data.osm.pbf ${PLANET_DATA_URL} || die "Failed to download planet file"
    END_DOWNLOAD=$(date +%s)
  fi

  log_info "==> Adding user tileserver to database"
  #gosu postgres createuser -SDR tileserver
  #createuser tileserver -s --superuser # answer yes for superuser (although this isn't strictly necessary)
  gosu postgres createdb -E UTF8 -O tileserver gis

  log_info "==> Starting Import..."
  START_IMPORT=$(date +%s)
  gosu tileserver osm2pgsql --slim -d gis -C 16000 --number-processes 3 /importdata/data.osm.pbf 2>&1 || die "Import failed"
  #gosu tileserver /app/utils/setup.php --osm-file /importdata/data.osm.pbf --all --osm2pgsql-cache ${OSM2PGSQL_CACHE} 2>&1 || die "Import failed"
  END_IMPORT=$(date +%s)

  log_info "Import complete!"
  log_info "Download time: $((END_DOWNLOAD-START_DOWNLOAD))s"
  log_info "Import time: $((END_IMPORT-START_IMPORT))s"
}

log_info "==> Waiting for database to come up..."
sleep 50s
./wait-for-it.sh -s -t 300 ${PGHOST}:5432 || die "Database did not respond"

if gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw gis; then
    log_info "Database tileserver already exists, skipping initialization."
else
    log_info "Container has not been initialized, will start initial import now!"
    initialization
fi

apache2-foreground "$@"
