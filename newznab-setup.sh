#!/bin/bash

if [[ -z "$SVNUSER" || -z "$SVNPASS" ]]; then
  echo "$(date) - Please set the SVNUSER and the SVNPASS environment vars for the container." 
  exit 1
fi

if ! [ -e "/var/www/newznab/notouch" ]; then
  echo "$(date) - notouch file does not exist. continuing newznab setup."
else
  echo "$(date) - notouch file was found. newznab-setup.sh exited."
  exit 0
fi

chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/www/newznab

svn co --username "$SVNUSER" --password "$SVNPASS" --no-auth-cache svn://svn.newznab.com/nn/branches/nnplus /var/www/newznab/

cat > /var/www/newznab/www/config.php << EOF
<?php

//========================
// Config you must change
//========================
define('DB_TYPE', 'mysql');
define('DB_HOST', '${DB_HOST}');
define('DB_PORT', ${DB_PORT});
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD','${MYSQL_PASSWORD}');
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_INNODB', ${DB_INNODB});
define('DB_PCONNECT', ${DB_PCONNECT});
define('DB_ERRORMODE', PDO::ERRMODE_SILENT);

define('NNTP_USERNAME', '${NNTP_USERNAME}');
define('NNTP_PASSWORD', '${NNTP_PASS}');
define('NNTP_SERVER', '${NNTP_SERVER}');
define('NNTP_PORT', '${NNTP_PORT}');
define('NNTP_SSLENABLED', ${NNTP_SSL});

define('CACHEOPT_METHOD', '${CACHEOPT_METHOD}');
define('CACHEOPT_TTLFAST', '120');
define('CACHEOPT_TTLMEDIUM', '600');
define('CACHEOPT_TTLSLOW', '1800');
define('CACHEOPT_MEMCACHE_SERVER', '${CACHEOPT_MEMCACHE_SERVER}');
define('CACHEOPT_MEMCACHE_PORT', '${CACHEOPT_MEMCACHE_PORT}');

// define('EXTERNAL_PROXY_IP', ''); //Internal address of public facing server
// define('EXTERNAL_HOST_NAME', ''); //The external hostname that should be used

require("automated.config.php");
EOF

chown -R ${APACHE_RUN_USER}:${APACHE_RUN_USER} /var/www/newznab

chmod -R 777 /var/www/newznab/www/lib/smarty/templates_c
chmod -R 777 /var/www/newznab/www/covers
chmod -R 777 /var/www/newznab/www/install
chmod -R 777 /var/www/newznab/nzbfiles

touch /var/www/newznab/notouch
