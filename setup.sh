#!/bin/bash
set -e

sudo apt-get remove --purge mysql-server mysql-client mysql-common
sudo apt-get autoremove
sudo apt-get autoclean
# apt-get purge -y mysql-server mysql-client 

# generate mysql root password
MYSQL_ROOT_PASS=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

# set defaults

# echo mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS | sudo /usr/bin/debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
#echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
#echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
#/bin/bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS'"
#/bin/bash -c "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS'"

echo "MySQL root password: $MYSQL_ROOT_PASS"

# install mysql
apt-get update && apt-get install -y \
  mysql-server-5.7 \
  mysql-client

# fix permissions
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

MYSQL_CONFIG=/etc/mysql_defaults.cnf
sed -e "s/\${MYSQL_ROOT_PASS}/$MYSQL_ROOT_PASS/" mysql_defaults.cnf > $MYSQL_CONFIG
chmod 400 $MYSQL_CONFIG

#echo "CREATE DATABASE pdns --defaults-extra-file=$MYSQL_CONFIG"
mysql --defaults-extra-file=$MYSQL_CONFIG -e "CREATE DATABASE pdns"
#mysql -u root ykval < /ykval-db.sql -p$MYSQL_ROOT_PASS
#mysql -u root -e "CREATE USER 'ykval_verifier'@'%'; GRANT SELECT,INSERT,UPDATE(modified, yk_counter, yk_low, yk_high, yk_use, nonce) ON ykval.yubikeys TO 'ykval_verifier'@'%'; GRANT SELECT,INSERT,UPDATE(id, secret, active) ON ykval.clients TO 'ykval_verifier'@'%'; GRANT SELECT,INSERT,UPDATE,DELETE ON ykval.queue TO 'ykval_verifier'@'%'; SET PASSWORD FOR 'ykval_verifier'@'%' = PASSWORD('$YKVAL_VERIFIER_PASS'); FLUSH PRIVILEGES;" -p$MYSQL_ROOT_PASS ykval



# install powerdns
#DEBIAN_FRONTEND=noninteractive apt-get install --yes \
#  pdns-backend-mysql \
#  pdns-server

#PDNS_MYSQL_CONFIG=/etc/powerdns/pdns.d/pdns.local.gmysql.conf
#sed -e "s/\${MYSQL_ROOT_PASS}/thepassword/" mysql.conf > $PDNS_MYSQL_CONFIG

#chown pdns $PDNS_MYSQL_CONFIG
#chmod 640 $PDNS_MYSQL_CONFIG

# MYSQL_ROOT_PASS=$(</etc/MYSQL_ROOT_PASS)

# echo $MYSQL_ROOT_PASS
