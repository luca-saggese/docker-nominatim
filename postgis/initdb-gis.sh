#! /bin/sh

echo "Initialization of postgis extensions and dropping default database \"gis\","

dropdb -U postgres gis
createuser tileserver -s --superuser # answer yes for superuser (although this isn't strictly necessary)
createdb -E UTF8 -O tileserver gis


sudo -u postgres psql
\c gis
CREATE EXTENSION postgis;
ALTER TABLE geometry_columns OWNER TO tileserver;
ALTER TABLE spatial_ref_sys OWNER TO tileserver;
\q