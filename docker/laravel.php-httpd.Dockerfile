FROM php:apache

ENV GITHUB_USER_NAME="please config git name"
ENV GITHUB_USER_EMAIL="please config git email"

# Install selected extensions and other stuff
RUN apt-get update && \
    apt-get install -y gnupg
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends autoconf g++ make libicu-dev icu-devtools libzip-dev git less bash yarn tree \
    && docker-php-source extract \
    && docker-php-ext-install opcache intl zip pdo_mysql \
    && pecl channel-update pecl.php.net \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug opcache \
    && docker-php-source delete \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer
RUN composer global require laravel/installer
RUN echo "export PATH=/root/.composer/vendor/bin:$PATH" > ~/.bashrc && \
    echo "alias ll='ls --color=auto -alF'" >> ~/.bashrc && \
    echo "PS1='\u:\w/> '" >> ~/.bashrc && \
    echo 'git config --global user.name "${GITHUB_USER_NAME}"' >> ~/.bashrc && \
    echo 'git config --global user.email "${GITHUB_USER_EMAIL}"'  >> ~/.bashrc

RUN git config --global user.name "${GITHUB_USER_NAME}" && git config --global user.email "${GITHUB_USER_EMAIL}" 

COPY ./files/httpd/000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/app

