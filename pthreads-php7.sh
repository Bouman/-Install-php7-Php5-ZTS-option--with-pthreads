apt-get update
apt-get install build-essential

# Install Apache2
apt-get install apache2

# Install Mysql
apt install apt install mariadb-server
mysql_secure_installation

# Dependance Prérequis
apt-get install build-essential apache2-dev libcurl4-openssl-dev libsqlite3-dev libmariadb-dev-compat:i386 libreadline-dev libzip-dev libxslt1-dev libicu-dev libmcrypt-dev libmhash-dev libpcre3-dev libjpeg-dev libfreetype6-dev libbz2-dev libxpm-dev bison re2c zlib1g-dev sqlite3 libsqlite3-dev libbz2-dev libcurl4-openssl-dev libenchant-dev libonig-dev libpspell-dev libedit-dev libreadline-dev libxslt-dev libwebp-dev libxpm-dev

# Installation PHP7 (Without ZTS pthreads)
apt-get install php7.1 php-pear
apt-get build-dep php7.1

#Etre sur que curl est bien configuré
cd /usr/include
ln -s x86_64-linux-gnu/curl

#icu-config configuration
curl https://gist.githubusercontent.com/jasny/e91f4e2d386e91e6de5cf581795e9408/raw/16e2c42136eb3f214222c80d492e71942b77f174/icu-config > icu-config
chmod +x icu-config
mv icu-config /usr/bin

# Deplacement à la base
cd /

#Telechargement PHP 7.0.8 + extraction et suppresion.
wget http://cl1.php.net/get/php-7.1.31.tar.gz/from/this/mirror -O php-7.1.31.tar.gz
tar zxvf php-7.1.31.tar.gz
rm -rf ext/pthreads/
rm php-7.1.31.tar.gz
mv php-src php-7.1.31

#Telechargement pthreads + movement dossier
cd php-7.2.6/ext
git clone https://github.com/krakjoe/pthreads -b master pthreads
cd ..

#Suppression des fichier PHP actuel
rm -rf aclocal.m4
rm -rf autom4te.cache/

#Preparation + compilation
./buildconf --force
make distclean

./configure --disable-fileinfo --enable-maintainer-zts --enable-pthreads --prefix=/usr --with-config-file-path=/etc --with-curl --enable-cli --with-apxs2=/usr/bin/apxs2 \
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

make clear 
make
make install

chmod o+x /usr/bin/phpize
chmod o+x /usr/bin/php-config

cd ext/pthreads*
/usr/bin/phpize

./configure --prefix=/usr --with-libdir=/lib/x86_64-linux-gnu --enable-pthreads=shared --with-php-config=/usr/bin/php-config
make && make install
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

cp /etc/apache2/mods-available/php7.load /etc/apache2/mods-enabled/php7.load
echo "<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
" > /etc/apache2/mods-enabled/php7.conf

#Restart apache
/etc/init.d/apache2 restart

#Suppression
cd ..
rm -rf php-7.2.6

#extension on php.ini
echo "extension=pthreads.so" >> /etc/php-cli.ini
echo "zend_extension=opcache.so" >> /etc/php.ini

#config
export USE_ZEND_ALLOC=0

# Time Zone Php.ini
sed -i "s/^;date.timezone =$/date.timezone = \"Europe\/Paris\"/" /etc/php.ini |grep "^timezone" /etc/php.ini

apt-get install ntp ntpdate
/etc/init.d/ntp stop 
ntpdate ntp.shoa.cl
/etc/init.d/ntp start
date

