#!/bin/bash

export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

#Ajout du dépôt 
apt install -y ca-certificates apt-transport-https lsb-release
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt-get update
apt-get install -y build-essential
apt autoremove

# Installation PHP5.6 (Without ZTS pthreads)
apt update
apt install -y php5.6 php5.6-xml

# Install Apache2
apt-get install -y apache2 apache2-dev
source /etc/apache2/envvars
/usr/sbin/apache2 -V

# Install Mysql
apt install -y mariadb-server
mysql_secure_installation

# Dependance Prérequis
apt-get install -y autoconf make g++ gcc git curl nodejs unzip sqlite dpkg-dev pkg-config libdpkg-perl debhelper po-debconf gettext rpm flex fakeroot bc xz-utils rsync bison re2c

#Librairie pour php
apt-get install -y libcurl4 libcurl4-openssl-dev  zlib1g-dev libncurses5-dev libbz2-dev libssl-dev libenchant-dev libedit-dev libreadline-dev libelf-dev libxslt1-dev libwebp-dev libxpm-dev libpspell-dev libonig-dev libtool-bin libsqlite3-dev libreadline-dev libzip-dev libxslt1-dev libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libfreetype6-dev libbz2-dev libxpm-dev libxml2-dev
#libcurl4-gnutls-dev

#PEAR install
cd /
wget http://pear.php.net/go-pear.phar && php go-pear.phar

#OPENSSL INSTALL v1.0.21 pour compil FOR PHP5.6 dans le dossier build-openssl
curl https://www.openssl.org/source/openssl-1.0.2u.tar.gz | tar xz && cd openssl-1.0.2u && ./config --prefix=/home/user/build-openssl -fPIC && make -j 4 && make -j 4 install 

#Etre sur que curl est bien configuré
cd /usr/include
ln -s x86_64-linux-gnu/curl

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

#Restart apache
systemctl status apache2.service
php -m
php -v

#Download PHP Version
mkdir /home/install
cd /home/install
wget http://be2.php.net/get/php-5.6.40.tar.bz2/from/this/mirror -O php-5.6.40.tar.bz2
tar -xjvf php-5.6.40.tar.bz2
cd php-5.6.40

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache/

#Preparation + compilation
./buildconf --force
#make distclean

./configure --disable-fileinfo --enable-maintainer-zts --prefix=/usr/local --with-config-file-path=/usr/local --with-curl --enable-cli --with-apxs2=/usr/bin/apxs \
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

make -j 4
make -j 4 install
libtool --finish /home/install/php-5.6.40/libs

chmod o+x /usr/local/bin/phpize
chmod o+x /usr/local/bin/php-config

cp php.ini-development /usr/local/php.ini
cp php.ini-development /usr/local/php-cli.ini

cd /home/install
wget http://pecl.php.net/get/pthreads-2.0.10.tgz
tar -xvzf pthreads-2.0.10.tgz
cd pthreads-2.0.10
/usr/local/bin/phpize
./configure --prefix=/usr/local --enable-pthreads=shared --with-php-config=/usr/local/bin/php-config
make && make install

cp /etc/apache2/mods-available/php5.6.load /etc/apache2/mods-enabled/php5.6.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" >> /etc/apache2/mods-enabled/php5.6.conf

echo 'date.timezone = Europe/Paris' >> /usr/local/php.ini
echo 'date.timezone = Europe/Paris' >> /usr/local/php-cli.ini

echo "zend_extension=opcache.so" >> /usr/local/php.ini
echo "extension=pthreads.so" >> /usr/local/php-cli.ini

apt-get install -y libssh2-1 libssh2-1-dev libssl-dev php5.6-ssh2
cd /home
mkdir libssh2
cd libssh2
wget https://www.libssh2.org/download/libssh2-1.8.0.tar.gz   
tar -xzvf libssh2-1.8.0.tar.gz
cd libssh2-1.8.0
./configure && make all install

echo "extension=ssh2.so" >> /usr/local/php-cli.ini

#config
export USE_ZEND_ALLOC=0

#Restart apache
systemctl status apache2.service
php -m
php -v
