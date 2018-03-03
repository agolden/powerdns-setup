#!/bin/bash

apt-get install -y apache2 gettext libapache2-mod-php php php-common php-curl php-dev php-gd php-pear php-imap php-mysql php-xmlrpc php-mcrypt 
pear install DB
pear install MDB2-2.5.0b5#mysql
phpenmod mcrypt
service apache2 restart

PADMIN_VERSION=2.1.7
PADMIN_INSTALL_DIR=/var/www/html/poweradmin

pushd /
wget https://github.com/poweradmin/poweradmin/archive/v$PADMIN_VERSION.tar.gz
tar xvzf v$PADMIN_VERSION.tar.gz
rm v$PADMIN_VERSION.tar.gz
rm -rf /var/www/html/poweradmin
mv poweradmin-$PADMIN_VERSION/ /var/www/html/poweradmin
chown -R www-data:www-data /var/www/html/poweradmin
popd

PDNS_CONF="/etc/powerdns/pdns.d/pdns.local.gmysql.conf"
while IFS="=" read -r key value; do
        case "$key" in
          "gmysql-password") PDNS_PASS="$value" ;;
        esac
done < "$PDNS_CONF"

PDNS_SESSION_KEY=$(openssl rand -base64 32 ; echo)
PADMIN_ADMIN_PASS=$(openssl rand -base64 16 ; echo)
PADMIN_ADMIN_PASS_MD5=$(echo -n $PADMIN_ADMIN_PASS | md5sum)
POWERADMIN_CONFIG=$PADMIN_INSTALL_DIR/inc/config.inc.php
sed -e "s/\${PDNS_PASS}/$PDNS_PASS/" config.inc.php > $POWERADMIN_CONFIG
sed -i "s/\${PDNS_SESSION_KEY}/$PDNS_SESSION_KEY/" $POWERADMIN_CONFIG
chown www-data:www-data $POWERADMIN_CONFIG
chmod 400 $POWERADMIN_CONFIG

rm -rf $PADMIN_INSTALL_DIR/install
