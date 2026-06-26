#!/bin/bash
set -e

# on recupere les valeurs brutes cache dans les secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Test de la condition principale
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    until mariadb -u root --connect-timeout=2 -e "SELECT 1" > /dev/null 2>&1; do
        sleep 1
    done

    mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

    # on sotpe mariadb temporaire
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

# on lance mariadb en pid 1
exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql
