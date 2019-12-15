FROM php:fpm-alpine

ENV GITHUB_USER_NAME="please config git name"
ENV GITHUB_USER_EMAIL="please config git email"

# Install selected extensions and other stuff
RUN apk add --update --no-cache autoconf g++ make icu-dev libzip-dev git less bash yarn tree npm \
    && docker-php-source extract \
    && docker-php-ext-install opcache intl zip pdo_mysql \
    && pecl channel-update pecl.php.net \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug opcache \
    && docker-php-source delete \
    && apk del \
    && rm -rf /tmp/* /var/cache/apk/*
COPY ./files/fpm/php.ini /usr/local/etc/php/
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer
RUN /bin/bash
RUN composer global require laravel/installer
RUN echo "export PATH=/root/.composer/vendor/bin:$PATH" > ~/.bashrc && \
    echo "alias ll='ls --color=auto -alF'" >> ~/.bashrc && \
    echo "PS1='\u:\w/> '" >> ~/.bashrc && \
    echo $'git config --global user.name "${GITHUB_USER_NAME}"' >> ~/.bashrc && \
    echo $'git config --global user.email "${GITHUB_USER_EMAIL}"'  >> ~/.bashrc

RUN git config --global user.name "${GITHUB_USER_NAME}" && git config --global user.email "${GITHUB_USER_EMAIL}" 

WORKDIR /var/www/app

