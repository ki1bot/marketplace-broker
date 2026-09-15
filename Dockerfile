FROM php:8.4-cli-bookworm

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libicu-dev \
        libzip-dev \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        intl \
        pdo_mysql \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

RUN groupadd --gid "${GID}" laravel \
    && useradd \
        --uid "${UID}" \
        --gid "${GID}" \
        --create-home \
        --shell /bin/bash \
        laravel \
    && mkdir -p /var/www/html \
    && chown -R laravel:laravel /var/www/html

RUN printf "pdo_mysql.default_socket=/var/run/mysqld/mysqld.sock\n" \
    > /usr/local/etc/php/conf.d/mysql-socket.ini

RUN git config --system --add safe.directory /var/www/html

WORKDIR /var/www/html

USER laravel

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000", "--no-reload"]
