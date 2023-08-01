# Opigno Dockerfile
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
    cron \
    git

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
RUN composer create-project opigno/opigno-composer /var/www/html \
    && mkdir private update && chmod -R 775 private
RUN chown -R www-data:www-data /var/www/html && composer update

# sets up settings.php
WORKDIR /var/www/html/web/sites/default
RUN cp default.settings.php settings.php \
    && chmod 776 settings.php && mkdir -p files/media-icons/generic && chmod -R 777 files \
    && echo "\$settings['file_private_path'] = '/var/www/html/private';" >> settings.php \
    && echo "\$settings['trusted_host_patterns'] = array('^'. getenv('TRUSTED_HOSTS') .'$',);" >> settings.php
ENV TRUSTED_HOSTS="www\.example\.com"

# Uncomment if using a reverse proxy
#RUN echo "\$settings['reverse_proxy'] = TRUE;" >> settings.php \
#    && echo "\$settings['reverse_proxy_addresses'] = ['172.21.0.0/24', '173.245.48.0/20', '103.21.244.0/22', '103.22.200.0/22', '103.31.4.0/22', '141.101.64.0/18', '108.162.192.0/18', '190.93.240.0/20', '188.114.96.0/20', '197.234.240.0/22', '198.41.128.0/17', '162.158.0.0/15', '104.16.0.0/13', '104.24.0.0/14', '172.64.0.0/13', '131.0.72.0/22'];" >> settings.php \
#    && echo "\$settings['reverse_proxy_trusted_headers'] = \Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_FOR | \Symfony\Component\HttpFoundation\Request::HEADER_FORWARDED;" >> settings.php

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

#Uncomment if using a reverse proxy
#RUN a2enmod remoteip && a2enmod headers && echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Start Apache server
CMD ["apache2-foreground"]
