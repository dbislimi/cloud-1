#!/bin/bash
set -e

chown -R mysql:mysql /var/lib/mysql

mysql_install_db --user=mysql --datadir=/var/lib/mysql >> /dev/null
mysqld_safe --datadir=/var/lib/mysql &

while ! mysqladmin ping --silent; do
    echo "waiting for mariadb server..."
    sleep 1
done

mysql -u root -p${DB_ROOT_PASSWD} <<EOSQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWD}';
FLUSH PRIVILEGES;
EOSQL

wait