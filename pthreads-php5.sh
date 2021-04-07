#!/bin/bash

apt update
apt upgrade
apt-get install build-essential

# Install Apache2
apt-get install apache2

# Install Mysql
apt install mariadb-server
mysql_secure_installation

#Ajout du dépôt 
apt install ca-certificates apt-transport-https lsb-release
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

# Installation PHP5.6 (Without ZTS pthreads)
apt update
apt install php5.6
# Module php5.6
apt install php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-mysql php5.6-xml

#OPENSSL INSTALL v1.0.21 pour compil FOR PHP5.6 dans le dossier build-openssl
apt-get install make 
curl https://www.openssl.org/source/openssl-1.0.2l.tar.gz | tar xz && cd openssl-1.0.2l && ./config --prefix=/home/user/build-openssl && make -j 4 && make -j 4 install 

#Etre sur que curl est bien configuré
cd /usr/include
ln -s x86_64-linux-gnu/curl

# Deplacement à la base
cd /

#Telechargement PHP 5.6.40 + extraction et suppresion.
wget http://cl1.php.net/get/php-5.6.40.tar.gz/from/this/mirror -O php-5.6.40.tar.gz
tar zxvf php-5.6.40.tar.gz
rm -rf ext/pthreads/
rm php-5.6.40.tar.gz

#Telechargement pthreads + movement dossier
cd php-5.6.40/ext
git clone https://github.com/krakjoe/pthreads -b master pthreads
cd ..

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache/

#Preparation + compilation
./buildconf --force
make distclean

./configure --prefix=/usr --with-curl --with-mysql --enable-maintainer-zts --enable-sockets --with-openssl=/home/user/build-openssl --with-pdo-mysql --with-apxs2=/usr/bin/apxs --enable-cli

make clear 
make -j 4
make install
libtool --finish /php-5.6.40/libs

chmod o+x /usr/bin/phpize
chmod o+x /usr/bin/php-config

cd ext/pthreads*
/usr/bin/phpize

./configure --prefix=/usr --enable-pthreads=shared --with-php-config=/usr/bin/php-config
make -j 4 && make install
cd ../../

#####Config PHP.INI DU SERVEUR#########
#    nano php.ini-development         #
# display_errors = Off ===> on        #
# log_errors = On                     #
# file_uploads = On                   #
# upload_max_filesize = 2M  ====> 30M #
# post_max_size = 8M  ====> 150M      #
# max_execution_time = 30 ======> 120 #
# short_open_tag ====> On             #
# date.timezone = 'Europe/Paris'      #
# memory_limit ====> 256M             #
#                                     #
#######################################

cp php.ini-development /etc/php.ini
cp php.ini-development /etc/php-cli.ini

cp /etc/apache2/mods-available/php5.6.load /etc/apache2/mods-enabled/php5.6.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" >> /etc/apache2/mods-enabled/php5.6.conf

#Suppression
cd ..
rm -rf php-5.6.40

#extension on php.ini
echo "extension=pthreads.so" >> /etc/php-cli.ini
echo "zend_extension=opcache.so" >> /etc/php.ini

#config
export USE_ZEND_ALLOC=0

# Time Zone Php.ini
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Paris\"/" /etc/php.ini |grep "^timezone" /etc/php.ini

#Restart apache
systemctl status apache2.service
