#!/bin/bash
set -e

# generate mysql root password
MYSQL_ROOT_PASS=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

# set defaults
/bin/bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS'"
/bin/bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS'"

echo "MySQL root password: $MYSQL_ROOT_PASS"

# install mysql
apt-get update && apt-get install -y \
  mysql-server

# fix permissions
#mkdir -p /var/run/mysqld
#chown mysql:mysql /var/run/mysqld

#MYSQL_CONFIG=/etc/mysql_defaults.cnf
#sed -e "s/\${MYSQL_ROOT_PASS}/$MYSQL_ROOT_PASS/" mysql_defaults.cnf > $MYSQL_CONFIG
#chmod 400 $MYSQL_CONFIG

#mysql --defaults-extra-file=$MYSQL_CONFIG -e "CREATE DATABASE pdns"

# install powerdns
DEBIAN_FRONTEND=noninteractive apt-get install --yes \
  pdns-backend-mysql \
  pdns-server
