# Opigno 3.1.0 Dockerfile
FROM php:8.2-apache-bookworm

# Set environment variables for Composer and site URL
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install required packages and PHP extensions
RUN apt-get update && apt-get install -y libicu-dev libpng-dev libjpeg-dev libxml2-dev libzip-dev zip unzip cron git \
 && docker-php-ext-configure intl \
 && docker-php-ext-configure gd --with-jpeg \
 && docker-php-ext-install intl pdo_mysql gd zip opcache soap bcmath \
 && pecl install apcu && docker-php-ext-enable apcu \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and install Opigno LMS and set proper permissions
WORKDIR /var/www/html
RUN composer create-project opigno/opigno-composer . \
    && mkdir private update \
    && chmod -R 775 private \
    && chown -R www-data:www-data .

# Configure settings.php
WORKDIR /var/www/html/web/sites/default
RUN cp default.settings.php settings.php && chmod 776 settings.php \
    && mkdir -p files/media-icons/generic && chmod -R 777 files && chown -R www-data:www-data files \
    && echo "if (file_exists('/var/www/html/web/sites/custom.settings.php')) {include '/var/www/html/web/sites/custom.settings.php';}" >> settings.php

# Enable web based string editor. Must be manually installed because composer cannot find the most recent version
WORKDIR /var/www/html/web/modules/contrib
RUN curl -fSL "https://ftp.drupal.org/files/projects/stringoverrides-8.x-1.8.tar.gz" -o string.tar.gz \
    && tar -xz -f string.tar.gz && rm string.tar.gz && chown -R www-data:www-data stringoverrides

# Set recommended PHP settings for Opigno LMS
COPY opigno-php.ini /usr/local/etc/php/conf.d/

# Set up Apache virtual host
COPY opigno.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/opigno.conf /etc/apache2/sites-enabled/opigno.conf && a2ensite opigno && a2enmod rewrite remoteip headers \
    && rm /etc/apache2/sites-enabled/000-default.conf && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Start Apache server in the foreground
CMD ["apache2-foreground"]

# Set the tag for this Docker image
LABEL opigno_version="3.1.0"
