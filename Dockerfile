FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    unzip wget cron git libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libonig-dev default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo pdo_mysql zip intl mbstring soap gd opcache \
    && a2dismod mpm_event \
    && a2enmod mpm_prefork rewrite headers \
    && rm -rf /var/lib/apt/lists/*

RUN echo "display_errors=Off" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize=20M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size=25M" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /usr/src

RUN wget -O suitecrm.zip https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.10.0/SuiteCRM-8.10.0.zip \
    && unzip suitecrm.zip \
    && mv SuiteCRM-8.10.0 suitecrm \
    && rm suitecrm.zip

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
