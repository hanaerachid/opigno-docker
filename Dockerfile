FROM php:8.1-apache

RUN a2enmod rewrite

RUN apt update && apt -y install git default-mysql-client vim-tiny wget httpie unzip apt-utils

ADD ./000-default.conf /etc/apache2/sites-enabled

# Suppressing menu to choose keyboard layout
# COPY ./keyboard /etc/default/keyboard

# SET TZ
RUN apt-get install -y tzdata
RUN echo 'America/Detroit' > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# install the PHP extensions we need
RUN apt install -y libpq-dev zlib1g-dev libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libonig-dev libzip-dev \
        && apt install -y openssl build-essential xorg libssl-dev \
        # to install wkhtmltopdf we need to suppress menu to choose keyboard layout
        && apt install -y wkhtmltopdf \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
        && docker-php-ext-install gd opcache pdo pdo_mysql pdo_pgsql zip

# Install Composer.
# RUN curl -sS https://getcomposer.org/installer | php
# RUN mv composer.phar /usr/local/bin/composer

# Install Drush.
# RUN composer global require drush/drush
# RUN composer global update
# RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Add drush command https://www.drupal.org/project/registry_rebuild
# RUN wget http://ftp.drupal.org/files/projects/registry_rebuild-7.x-2.5.tar.gz \
#       && tar xzf registry_rebuild-7.x-2.5.tar.gz \
#       && rm registry_rebuild-7.x-2.5.tar.gz \
#       && mkdir -p /root/.composer/vendor/drush/drush/commands \
#       && mv registry_rebuild /root/.composer/vendor/drush/drush/commands

WORKDIR /var/www/html

ENV OPIGNO_VERSION 3.0.9

RUN curl -fSL "https://www.opigno.org/sites/default/files/2023-03/opigno_with_dependencies-v${OPIGNO_VERSION}.tar.gz" -o drupal.tar.gz \
        && tar -xz --strip-components=1 -f drupal.tar.gz \
        && rm drupal.tar.gz \
        && chown -R www-data:www-data /var/www/html/web

# PHP.ini settings for Opigno to work
RUN touch /usr/local/etc/php/conf.d/memory-limit.ini && echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/memory-limit.ini \
        && touch /usr/local/etc/php/conf.d/max-execution-time.ini && echo "max_execution_time=600" >> /usr/local/etc/php/conf.d/max-execution-time.ini \
        && touch /usr/local/etc/php/conf.d/upload-max-filesize.ini && echo "upload_max_filesize=512M" >> /usr/local/etc/php/conf.d/upload-max-filesize.ini \
        && touch /usr/local/etc/php/conf.d/post-max-size.ini && echo "post_max_size=550M" >> /usr/local/etc/php/conf.d/post-max-size.ini \
        && touch /usr/local/etc/php/conf.d/xdebug-max-nesting-level.ini && echo "xdebug.max_nesting_level=200" >> /usr/local/etc/php/conf.d/xdebug-max-nesting-level.ini

# Install pdf.js to show pdf slides and Tincan PHP
#RUN mkdir pdf.js && cd pdf.js \
#       && wget https://github.com/mozilla/pdf.js/releases/download/v2.16.105/pdfjs-2.16.105-dist.zip \
#       && unzip ./pdfjs-2.16.105-dist.zip && rm ./pdfjs-2.16.105-dist.zip \
#       && cd .. && wget https://github.com/RusticiSoftware/TinCanPHP/archive/refs/tags/1.1.1.zip \
#       && unzip ./1.1.1.zip && rm ./1.1.1.zip && mv ./TinCanPHP-1.1.1 ./TinCanPHP

WORKDIR /var/www/html/web/sites/default

RUN cp default.settings.php settings.php && chmod 776 settings.php\
        && mkdir -p files/media-icons/generic && chmod -R 777 files

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

#TODO cron run every hour


#TODO add entrypoint.sh to my folder
#COPY entrypoint.sh /entrypoint.sh

#RUN chmod 755 /*.sh
#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["apache2-foreground"]
