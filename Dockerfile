FROM php:7.3-fpm

MAINTAINER chrsc@mac.com

# This dockerfile is copyied from cyberduck's phpfpm:7.3 with npm and ~yarn~ added

ENV XDEBUG "false"

RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends \
        libmemcached-dev \
        libzip-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        openssh-server \
        libmagickwand-dev \
        git \
        cron \
        nano \
        libxml2-dev \
        nodejs

# Install soap extention
RUN docker-php-ext-install soap

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the PHP mcrypt extention (from PECL, mcrypt has been removed from PHP 7.2)
RUN pecl install mcrypt-1.0.2
RUN docker-php-ext-enable mcrypt

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
RUN docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

#####################################
# Imagick:
#####################################

RUN pecl install imagick && \
    docker-php-ext-enable imagick

#####################################
# GD:
#####################################

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

#####################################
# xDebug:
#####################################

# Install the xdebug extension
RUN pecl install xdebug && docker-php-ext-enable xdebug
# Copy xdebug configration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

# Install and enabled Redis
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/5.2.1.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-5.2.1 /usr/src/php/ext/redis \
    && docker-php-ext-install redis

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

#####################################
# NPM 
# Temporariy removing yarn
#####################################
RUN curl -s https://www.npmjs.com/install.sh | sh
RUN apt-get update && apt-get install -y gnupg2
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# RUN apt-get update && apt-get install -y yarn

# Source the bash
RUN . ~/.bashrc

#####################################
# Laravel Schedule Cron Job:
#####################################

RUN echo "* * * * * root /usr/local/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1"  >> /etc/cron.d/laravel-scheduler
RUN chmod 0644 /etc/cron.d/laravel-scheduler

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

ADD ./laravel.ini /usr/local/etc/php/conf.d

#####################################
# Aliases:
#####################################
# docker-compose exec php-fpm dep --> locally installed Deployer binaries
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/vendor/bin/dep "$@"' > /usr/bin/dep
RUN chmod +x /usr/bin/dep
# docker-compose exec php-fpm art --> php artisan
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan "$@"' > /usr/bin/art
RUN chmod +x /usr/bin/art
# docker-compose exec php-fpm migrate --> php artisan migrate
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate "$@"' > /usr/bin/migrate
RUN chmod +x /usr/bin/migrate
# docker-compose exec php-fpm fresh --> php artisan migrate:fresh --seed
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate:fresh --seed' > /usr/bin/fresh
RUN chmod +x /usr/bin/fresh
# docker-compose exec php-fpm t --> run the tests for the project and generate testdox
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/var/www/vendor/bin/phpunit -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report.txt "$@"' > /usr/bin/t
RUN chmod +x /usr/bin/t
# docker-compose exec php-fpm d --> run the Laravel Dusk browser tests for the project
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/bin/bash\n/usr/local/bin/php /var/www/artisan dusk -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report-dusk.txt "$@"' > /usr/bin/d
RUN chmod +x /usr/bin/d

RUN rm -r /var/lib/apt/lists/*

RUN usermod -u 1000 www-data

WORKDIR /var/www

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000
CMD ["php-fpm"]
