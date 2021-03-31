#Pré requis
apt-get install gcc make libxml2-dev autoconf ca-certificates unzip nodejs curl libcurl4-openssl-dev pkg-config 

#Dossier + Téléchargements
mkdir /home/install
cd /home/install
wget http://be2.php.net/get/php-5.6.40.tar.bz2/from/this/mirror -O php-5.6.40.tar.bz2
tar -xjvf php-5.6.40.tar.bz2
cd php-5.6.40

#Compilation et Installation
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

make
make install   
    
#Téléchargement Ptreads

    