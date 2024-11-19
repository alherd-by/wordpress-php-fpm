FROM php:7.4-fpm

RUN apt-get update \
    && apt-get install -y libfcgi-bin libpq-dev libonig-dev libgmp-dev libxml2-dev libpng-dev libicu-dev zlib1g-dev libzip-dev libbz2-dev git zip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN docker-php-ext-install \
        opcache \
        pdo pdo_mysql mysqli \
        sockets \
        intl zip gd bcmath bz2 mbstring xml

RUN set -xe && echo "pm.status_path = /healthz" >> /usr/local/etc/php-fpm.d/zz-docker.conf

COPY php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck

RUN chmod +x /usr/local/bin/php-fpm-healthcheck

ENV FCGI_STATUS_PATH=/healthz

RUN echo "access.log = /dev/null" >> /usr/local/etc/php-fpm.d/www.conf

HEALTHCHECK --interval=5s --timeout=1s CMD php-fpm-healthcheck || exit 1

RUN curl --show-error https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer && \
    composer clear-cache