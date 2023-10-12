#!/bin/bash
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

mkdir /home/install

apt-get update
apt-get dist-upgrade
apt-get install -y build-essential
apt autoremove

# Dependance Prérequis
apt-get install -y autoconf make g++ gcc git curl nodejs unzip sqlite dpkg-dev pkg-config libdpkg-perl composer debhelper po-debconf gettext rpm flex fakeroot bc xz-utils rsync bison re2c

# Install Apache2
apt-get install -y apache2 apache2-dev
source /etc/apache2/envvars
/usr/sbin/apache2 -V

#Librairie pour php
apt-get install -y libcurl4 zlib1g-dev libcurl4-openssl-dev libncurses5-dev libbz2-dev libssl-dev libenchant-dev libedit-dev libreadline-dev libelf-dev libxslt1-dev libwebp-dev libxpm-dev libpspell-dev libonig-dev libtool-bin libsqlite3-dev libreadline-dev libzip-dev libxslt1-dev libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libfreetype6-dev libbz2-dev libxpm-dev
apt-get install -y libcurl4-openssl-dev libsasl2-dev

# Install Mysql
apt install -y mariadb-server libmariadb-dev-compat libmariadb-dev
mysql_secure_installation

# Installation PHP7 (Without ZTS pthreads)
apt-get -y install php7.3 php7.3-xml php7.3-gd php7.3-mysqli php7.3-mbstring

#Etre sur que curl est bien configuré
# cd /usr/include
# ln -s x86_64-linux-gnu/curl

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

#PEAR install
cd /
wget http://pear.php.net/go-pear.phar && php go-pear.phar
#pear config-set php_bin /usr/local/bin/php
#pear config-set php_prefix /usr/local
#pear config-set php_ini /usr/local/lib

#Restart apache
systemctl restart apache2.service
php -m
php -v
systemctl stop apache2.service

#Telechargement PHP 7.3.27 + extraction et suppresion.
wget http://cl1.php.net/get/php-7.3.27.tar.gz/from/this/mirror -O php-7.3.27.tar.gz
tar zxvf php-7.3.27.tar.gz
rm -rf ext/pthreads/
rm php-7.3.27.tar.gz

#Telechargement pthreads + movement dossier
cd php-7.3.27/ext
git clone https://github.com/krakjoe/pthreads -b master pthreads
cd ..

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache/

#Preparation + compilation
./buildconf --force
make -j$(nproc) distclean

./configure --disable-fileinfo --enable-maintainer-zts --prefix=/usr --with-config-file-path=/etc --with-apxs2=/usr/local/bin/apxs \
--enable-mbstring \
    --enable-bcmath \
    --enable-calendar \
    --enable-cli \
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
    --with-webp-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-enchant \
    --with-icu-dir=/usr \
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
    --with-openssl \
    --with-openssl-dir=/usr/bin \
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

make -j$(nproc) clear 
make -j$(nproc)
make -j$(nproc) install
libtool --finish /php-7.3.27/libs

chmod o+x /usr/bin/phpize
chmod o+x /usr/bin/php-config

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

cd ext/pthreads*
/usr/bin/phpize

./configure --prefix=/etc --enable-pthreads=shared --with-php-config=/usr/local/bin/php-config
make -j$(nproc) && make -j$(nproc) install
cd ../../

cp /etc/apache2/mods-available/php7.load /etc/apache2/mods-enabled/php7.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" >> /etc/apache2/mods-enabled/php7.conf

#Suppression
cd ..
rm -rf php-7.3.27

echo 'date.timezone = Europe/Paris' >> /etc/php.ini
echo 'date.timezone = Europe/Paris' >> /etc/php-cli.ini

#extension on php.ini
echo "zend_extension=opcache.so" >> /etc/php.ini
echo "extension=pthreads.so" >> /etc/php-cli.ini

#config
export USE_ZEND_ALLOC=0

#Restart apache
systemctl status apache2.service

php -m
php -v
