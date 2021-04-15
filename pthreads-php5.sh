#!/bin/bash
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

mkdir /home/install

#Ajout du dépôt 
apt install -y ca-certificates apt-transport-https lsb-release
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt-get update
apt-get install -y build-essential
apt autoremove

# Dependance Prérequis
apt-get install -y autoconf make g++ gcc git curl nodejs unzip sqlite dpkg-dev pkg-config libdpkg-perl debhelper po-debconf gettext rpm flex fakeroot bc xz-utils rsync bison re2c

# Install Apache2
apt-get install -y apache2 apache2-dev
source /etc/apache2/envvars
/usr/sbin/apache2 -V

#Librairie pour php
apt-get install -y libcurl4 libcurl4-gnutls-dev zlib1g-dev libncurses5-dev libbz2-dev libssl-dev libenchant-dev libedit-dev libreadline-dev libelf-dev libxslt1-dev libwebp-dev libxpm-dev libpspell-dev libonig-dev libtool-bin libsqlite3-dev libreadline-dev libzip-dev libxslt1-dev libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libfreetype6-dev libbz2-dev libxpm-dev libxml2-dev
apt-get install -y libcurl4-openssl-dev libsasl2-dev

# Install Mysql
apt install -y mariadb-server libmariadb-dev-compat libmariadb-dev
mysql_secure_installation

# Installation PHP5.6 (Without ZTS pthreads)
apt install -y php5.6 php5.6-xml php5.6-gd

#OPENSSL INSTALL v1.0.21 + CURL pour compil FOR PHP5.6 dans le dossier build-openssl
cd /
curl https://www.openssl.org/source/openssl-1.0.2u.tar.gz | tar xz && cd openssl-1.0.2u && ./config -fPIC -m64 --prefix=/home/user/build-openssl && make -j$(nproc) && make -j$(nproc) install 
apt-get update

#Etre sur que curl est bien configuré
cd /usr/include
ln -s x86_64-linux-gnu/curl

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

#PEAR install
cd /
wget http://pear.php.net/go-pear.phar && php go-pear.phar

#Restart apache
systemctl restart apache2.service
php -m
php -v

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
    --with-openssl-dir=/home/user/build-openssl \
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
    
make -j$(nproc)
make -j$(nproc) install
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
make -j$(nproc) && make -j$(nproc) install

cp /etc/apache2/mods-available/php5.6.load /etc/apache2/mods-enabled/php5.6.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" >> /etc/apache2/mods-enabled/php5.6.conf

echo 'date.timezone = Europe/Paris' >> /usr/local/php.ini
echo 'date.timezone = Europe/Paris' >> /usr/local/php-cli.ini

echo "zend_extension=opcache.so" >> /usr/local/php.ini
echo "extension=pthreads.so" >> /usr/local/php-cli.ini

#config
export USE_ZEND_ALLOC=0

#Restart apache
systemctl restart apache2.service
php -m
php -v
