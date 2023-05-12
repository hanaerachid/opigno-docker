# Opigno 3.0.9 Dockerfile
FROM php:8.1-apache

# Install required packages
RUN apt update && apt install -y \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    cron

# Install PHP extensions
RUN docker-php-ext-configure intl && \
    docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install intl pdo_mysql gd zip opcache soap bcmath

# Install APCu
RUN pecl install apcu && \
    docker-php-ext-enable apcu

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# Download and install Opigno LMS and update modules and core to highest supported version
WORKDIR /var/www/html
RUN curl -fSL "https://www.opigno.org/sites/default/files/2023-03/opigno_with_dependencies-v3.0.9.tar.gz" -o drupal.tar.gz \
    && tar -xz --strip-components=1 -f drupal.tar.gz \
    && rm drupal.tar.gz \
    && mkdir private update && chmod -R 775 private
RUN chown -R www-data:www-data /var/www/html && composer update

# sets up settings.php
WORKDIR /var/www/html/web/sites/default
RUN cp default.settings.php settings.php \
    && chmod 776 settings.php && mkdir -p files/media-icons/generic && chmod -R 777 files \
    && echo "\$settings['file_private_path'] = '/var/www/html/private';" >> settings.php \
    && echo "\$settings['trusted_host_patterns'] = array('^'. getenv('TRUSTED_HOSTS') .'$',);" >> settings.php
ENV TRUSTED_HOSTS="www\.example\.com"

# Fixes php8 compatibility issue
WORKDIR /var/www/html/web/modules/contrib/h5p/vendor/h5p/h5p-editor
COPY ./h5peditor.class.php ./h5peditor.class.php

# Enable web based string editor. Must be manually installed because composer cannot find the most recent version
WORKDIR /var/www/html/web/modules/contrib
RUN curl -fSL "https://ftp.drupal.org/files/projects/stringoverrides-8.x-1.8.tar.gz" -o string.tar.gz \
    && tar -xz -f string.tar.gz && rm string.tar.gz

# Set recommended PHP settings for Opigno LMS
COPY opigno-php.ini /usr/local/etc/php/conf.d/opigno-php.ini

# Recommended cron settings for optimization
ENV SITE_URL=http://www.example.com
RUN echo "*/5 * * * * wget -O - -q -t 1 ${SITE_URL}" >> crontab

# Set up Apache virtual host
COPY opigno.conf /etc/apache2/sites-available/opigno.conf
RUN ln -s /etc/apache2/sites-available/opigno.conf /etc/apache2/sites-enabled/opigno.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && a2enmod rewrite

# Start Apache server
CMD ["apache2-foreground"]

# Set the tag for this Docker image
LABEL opigno_version="3.0.9"
