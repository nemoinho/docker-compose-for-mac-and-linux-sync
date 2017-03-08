FROM php:7-apache

ARG USER_ID=1000
ARG USER_NAME=user

# install needed system stuff
# nodejs(npm) is needed for grunt and building
# zip and git are needed for bower!
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update \
        && apt-get install -y sudo libicu-dev libjpeg62-turbo-dev libpng-dev nodejs zip git \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# install php extensions
RUN pecl install xdebug-2.5.0 \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd pdo pdo_mysql opcache intl

# install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# create local run-user
RUN useradd --shell /bin/bash -u $USER_ID -o -c '' -m $USER_NAME
RUN usermod -aG $USER_NAME www-data
RUN echo "$USER_NAME ALL = NOPASSWD: /usr/local/bin/docker-php-entrypoint" >> /etc/sudoers

# prepare for symfony
RUN a2enmod rewrite
RUN touch /var/log/apache2/web_app.error.log && chmod 666 /var/log/apache2/web_app.error.log
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY entrypoint.sh /usr/local/bin/entrypoint
COPY startup.sh /usr/local/bin/startup
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/startup

RUN chown -R $USER_NAME:$USER_NAME /var/www/html
RUN chgrp -R www-data /var/www/html/var || true

USER $USER_NAME

ENTRYPOINT ["entrypoint"]
CMD ["startup"]
