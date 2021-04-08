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

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

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

./configure --disable-fileinfo --enable-maintainer-zts --prefix=/usr --with-config-file-path=/etc --with-apxs2=/usr/bin/apxs \
--enable-mbstring \
    --enable-bcmath \
    --enable-calendar \
    --enable-debug \
    --enable-exif \
    --enable-fpm \
    --enable-ftp \
    --enable-hash \
    --enable-intl \
    --enable-json \
    --enable-maintainer-zts \
    --enable-mbregex \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-pcntl \
    --enable-phar \
    --enable-posix \
    --enable-session \
    --enable-simplexml \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-xml \
    --enable-wddx \
    --enable-zip \
    --enable-inline-optimization \
    --enable-intl \
    --disable-cgi \
    --with-jpeg-dir=/usr/include/ \
    --with-xpm-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-enchant \
    --with-gd \
    --with-curl \
    --with-jpeg-dir=/usr \
    --with-png-dir=shared,/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=no \
    --with-bz2=/usr \
    --with-gettext \
    --with-iconv-dir=/usr \
    --with-mhash \
    --with-libzip \
    --with-pcre-regex \
    --with-openssl=/home/user/build-openssl \
    --with-openssl-dir=/home/user/build-openssl \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-mysqli=mysqlnd \
    --with-sqlite3=/usr \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-sqlite=/usr \
    --with-pspell \
    --with-readline \
    --with-tsrm-pthreads \
    --with-xsl \
    --with-zlib-dir=/usr \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --config-cache \
    --localstatedir=/var \
    --with-layout=GNU \
    --disable-rpath

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
echo "<FilesMatch \.php$>" >> /etc/apache2/mods-enabled/php5.6.conf
echo "SetHandler application/x-httpd-php" >> /etc/apache2/mods-enabled/php5.6.conf
echo "</FilesMatch>" >> /etc/apache2/mods-enabled/php5.6.conf

#Suppression
cd ..
rm -rf php-5.6.40

#extension on php.ini
#echo "extension=pthreads.so" >> /etc/php-cli.ini
#echo "zend_extension=opcache.so" >> /etc/php.ini

#config
export USE_ZEND_ALLOC=0

# Time Zone Php.ini
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Paris\"/" /etc/php.ini |grep "^timezone" /etc/php.ini

#Restart apache
systemctl status apache2.service
