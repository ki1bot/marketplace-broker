FROM composer:2 AS composer

FROM php:8.4-cli-bookworm

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        default-mysql-client \
        libicu-dev \
        libonig-dev \
        libzip-dev \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        mbstring \
        intl \
        zip \
        bcmath \
        pcntl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN groupadd --gid ${GID} laravel \
    && useradd \
        --uid ${UID} \
        --gid laravel \
        --create-home \
        --shell /bin/bash \
        laravel \
    && mkdir -p /var/www/html \
    && chown -R laravel:laravel /var/www/html

WORKDIR /var/www/html

USER laravel

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
