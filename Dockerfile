# syntax = docker/dockerfile:1.2
FROM php:8.1-fpm-alpine

WORKDIR /srv/app

RUN apk add --no-cache git openssh-client

RUN mkdir -p ~/.ssh && \
    chmod 0700 ~/.ssh && \
    # Den Fingerprint des Zielhost hinzufügen
    ssh-keyscan github.com > ~/.ssh/known_hosts

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY composer.* .

# Install the prod dependencies by allowing Docker to use the auth.json file of the host
RUN --mount=type=secret,id=COMPOSER_AUTH,required=true,target=/srv/app/auth.json cat /srv/app/auth.json
#RUN --mount=type=secret,id=COMPOSER_AUTH,target=/srv/app/auth.json cat /srv/app/auth.json

# RUN --mount=type=secret,id=oec778utgdtb4g37wqlxct7sl,dst=/srv/app/auth.json composer install --no-dev --no-scripts --no-autoloader --no-progress --no-interaction

# auth.json must not be copied into the final image
COPY . .

RUN composer dump-autoload --classmap-authoritative --no-dev
