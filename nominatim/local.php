<?php
 // General settings
 @define('CONST_Database_DSN', 'pgsql://nominatim@postgis:5432/nominatim'); // <driver>://<username>:<password>@<host>:<port>/<database>
 @define('CONST_Website_BaseURL', '/');
 // Software versions
 @define('CONST_Postgresql_Version', '9.4');
 @define('CONST_Postgis_Version', '2.3');

 @define('CONST_Osmosis_Binary', '/usr/local/bin/osmosis');
 @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe-updates');
 @define('CONST_Replication_MaxInterval', '40000');     // Process each update separately, osmosis cannot merge multiple updates
 @define('CONST_Replication_Update_Interval', '86400');  // How often upstream publishes diffs
 @define('CONST_Replication_Recheck_Interval', '900');   // How long to sleep if no update found yet


?>
