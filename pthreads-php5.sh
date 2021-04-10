#!/bin/bash

#Ajout du dépôt 
apt install ca-certificates apt-transport-https lsb-release
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt-get update
apt-get dist-upgrade
apt-get install build-essential
apt-get install gcc git libcurl4 curl dpkg-dev libdpkg-perl debhelper po-debconf gettext fakeroot make libncurses5-dev rpm zlib1g-dev g++ autoconf build-essential flex bison fakeroot  bc libssl-dev rsync libelf-dev xz-utils rsync

# Install Apache2
apt-get install apache2 apache2-dev
apt install sqlite
apt-get install libsqlite3-dev libbz2-dev libjpeg-dev libpng-dev libx11-dev libxpm-dev aspell libpspell-dev libedit-dev libreadline-dev libxslt1-dev libzip-dev libxml2-dev 

# Install Mysql
apt install mariadb-server
mysql_secure_installation

# Dependance Prérequis
apt-get install gcc make autoconf ca-certificates unzip nodejs curl libcurl4-openssl-dev pkg-config

# Installation PHP5.6 (Without ZTS pthreads)
apt update
apt install php5.6

#OPENSSL INSTALL v1.0.21 pour compil FOR PHP5.6 dans le dossier build-openssl
apt-get install make 
curl https://www.openssl.org/source/openssl-1.0.2l.tar.gz | tar xz && cd openssl-1.0.2l && ./config --prefix=/home/user/build-openssl -m64 -fPIC && make -j 4 && make -j 4 install 

#Etre sur que curl est bien configuré
cd /usr/include
ln -s x86_64-linux-gnu/curl

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache/

# Deplacement à la base
cd /

mkdir /home/install
cd /home/install
wget http://be2.php.net/get/php-5.6.40.tar.bz2/from/this/mirror -O php-5.6.40.tar.bz2
tar -xjvf php-5.6.40.tar.bz2
cd php-5.6.40

./configure --disable-fileinfo --enable-maintainer-zts --prefix=/usr/local --with-config-file-path=/etc --with-curl --enable-cli --with-apxs2=/usr/bin/apxs \
--enable-mbstring \
    --enable-bcmath \
    --enable-calendar \
    --enable-cli \
    --enable-debug \
    --enable-exif \
    --enable-fpm \
    --enable-ftp \
    --enable-hash \
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
    --with-icu-dir=/usr \
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
    --with-zlib \
    --with-zlib-dir=/usr \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --config-cache \
    --localstatedir=/var \
    --with-layout=GNU \
    --disable-rpath

make
make install

cd /home/install
wget http://pecl.php.net/get/pthreads-2.0.10.tgz
tar -xvzf pthreads-2.0.10.tgz
cd pthreads-2.0.10
/usr/local/bin/phpize
./configure
make
make install

wget https://www.libssh2.org/download/libssh2-1.9.0.tar.gz   
tar -xzvf libssh2-1.9.0.tar.gz
cd libssh2-1.9.0
./configure && make all install



echo 'date.timezone = Europe/Paris' >> /usr/local/lib/php.ini
echo 'extension=pthreads.so' >> /usr/local/lib/php.ini

#Restart apache
systemctl status apache2.service
php -m
php -v
