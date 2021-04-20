#!/bin/bash

mkdir /home/install

apt-get update
apt-get install -y build-essential
apt autoremove

# Dependance Prérequis
apt-get install -y autoconf make g++ gcc git curl nodejs unzip sqlite dpkg-dev pkg-config libdpkg-perl debhelper po-debconf gettext rpm flex fakeroot bc xz-utils rsync bison re2c

# Install Apache2
apt-get install -y apache2 apache2-dev

#Librairie pour php
apt-get install -y libcurl4-gnutls-dev zlib1g-dev libncurses5-dev libbz2-dev libssl-dev libenchant-dev libedit-dev libreadline-dev libelf-dev libxslt1-dev libwebp-dev libxpm-dev libpspell-dev libonig-dev libtool-bin libsqlite3-dev libreadline-dev libzip-dev libxslt1-dev libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libfreetype6-dev libbz2-dev libxpm-dev libxml2-dev
apt-get install -y libcurl4-openssl-dev libsasl2-dev

# Install Mysql
apt install -y mariadb-server
mysql_secure_installation

# Installation PHP5.6 (Without ZTS pthreads)
apt install -y php5 php5-ssh2

#PEAR install
cd /
wget http://pear.php.net/go-pear.phar && php go-pear.phar

#Restart apache
systemctl restart apache2.service
php -m
php -v
systemctl stop apache2.service

#Download PHP Version
cd /home/install
wget http://be2.php.net/get/php-5.6.40.tar.bz2/from/this/mirror -O php-5.6.40.tar.bz2
tar -xjvf php-5.6.40.tar.bz2
cd php-5.6.40

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache

#Preparation + compilation
./buildconf --force
#make distclean

./configure --enable-maintainer-zts --prefix=/usr/local --with-config-file-path=/usr/local/lib \
    --with-apxs2=/usr/bin/apxs \
    --enable-mbstring \
    --enable-bcmath \
    --enable-calendar \
    --with-curl=/usr/bin \
    --enable-debug \
    --enable-exif \
    --enable-fpm \
    --enable-ftp \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-pcntl \
    --enable-session \
    --enable-simplexml \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --enable-zip \
    --disable-cgi \
    --with-jpeg-dir=/usr/include \
    --with-xpm-dir=/usr/include \
    --with-png-dir=/usr/include \
    --with-enchant \
    --with-gd \
    --with-bz2=/usr/bin \
    --with-gettext=/usr/bin \
    --with-iconv-dir=/usr/bin \
    --with-icu-dir=/usr/lib/x86_64-linux-gnu \
    --with-mhash=/usr/include \
    --with-libzip=/usr/lib/x86_64-linux-gnu \
    --with-pcre-regex \
    --with-openssl \
    --with-mysql-sock \
    --with-mysqli \
    --enable-embedded-mysqli \
    --with-mysql \
    --with-pdo-mysql \
    --with-pspell \
    --with-readline=/usr/include \
    --with-tsrm-pthreads \
    --with-xsl=/usr/lib/x86_64-linux-gnu \
    --with-zlib \
    --with-zlib-dir=/usr/lib/x86_64-linux-gnu \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --config-cache \
    --localstatedir=/usr/local/var \
    --with-layout=PHP

make -j$(nproc) clear 
make -j$(nproc)
make -j$(nproc) install
libtool --finish /home/install/php-5.6.40/libs

chmod o+x /usr/local/bin/phpize
chmod o+x /usr/local/bin/php-config

cp php.ini-development /usr/local/lib/php.ini
cp php.ini-development /usr/local/lib/php-cli.ini

#Installation de pthreads
cd /home/install
wget http://pecl.php.net/get/pthreads-2.0.10.tgz
tar -xvzf pthreads-2.0.10.tgz
cd pthreads-2.0.10
/usr/local/bin/phpize
./configure --prefix=/usr/local --enable-pthreads=shared --with-php-config=/usr/local/bin/php-config
make -j$(nproc) && make -j$(nproc) install

#Configuration apache2
cp /etc/apache2/mods-available/php5.6.load /etc/apache2/mods-enabled/php5.6.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" >> /etc/apache2/mods-enabled/php5.6.conf

echo 'date.timezone = Europe/Paris' >> /usr/local/lib/php.ini
echo 'date.timezone = Europe/Paris' >> /usr/local/lib/php-cli.ini

echo "zend_extension=opcache.so" >> /usr/local/lib/php.ini
echo "extension=pthreads.so" >> /usr/local/lib/php-cli.ini

#config
export USE_ZEND_ALLOC=0

#Restart apache
systemctl restart apache2.service
#le dossier de php.ini en relation avec la compilation
export PATH="$PATH:/usr/local/php/bin/"
php -m
php -v

