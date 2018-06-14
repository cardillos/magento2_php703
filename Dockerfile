FROM ubuntu:16.04

LABEL maintainer="cherry.ardillos@zeald.com"
LABEL description="Magento 2.2.4"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && apt-get install -yq \
    curl \
    # Git
    git \
    # Apache
    apache2 \
    # Install php 7
    php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-json php7.0-curl php7.0-fpm \
    php7.0-gd php7.0-ldap php7.0-mbstring php7.0-mysql php7.0-soap php7.0-xml \
    php7.0-zip php7.0-mcrypt php7.0-intl php-imagick php7.0-common  \
    php-xdebug \
    # Install tools
    nano \
    ghostscript \
    mysql-client \
    iputils-ping \
    apt-utils \
    locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV XDEBUG_PORT 9000
RUN echo "xdebug.remote_enable=on" >> /etc/php/7.0/mods-available/xdebug.ini && \
 echo "xdebug.remote_autostart=on" >> /etc/php/7.0/mods-available/xdebug.ini

# Nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && apt-get install -y nodejs

RUN a2enmod rewrite

# Configure PHP
ADD site.php.ini /etc/php/7.0/apache2/conf.d/

# Configure vhost
ADD site.conf /etc/apache2/sites-available
RUN a2ensite site.conf

CMD ["apache2ctl", "-D", "FOREGROUND"]

ENV MAGENTO_VERSION 2.2.4
ENV COMPOSER_HOME /var/www/.composer/

# Composer installation
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
COPY ./auth.json $COMPOSER_HOME

RUN chsh -s /bin/bash www-data

RUN rm /var/www/html/index.html

RUN a2enmod rewrite

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run sh file during startup
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
