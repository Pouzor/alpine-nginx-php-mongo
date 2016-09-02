FROM alpine:3.3

MAINTAINER Remy JARDINET aka Pouzor

ENV S6VERSION 1.17.2.0

# Copy configuration files to root
COPY rootfs /

ENV COMPOSER_HOME=/.composer 
ENV PATH=/.composer/vendor/bin:$PATH

RUN apk add --update \
    wget \
    ca-certificates \
    nginx \
    php-fpm \
    php-json \
    php-zlib \
    php-xml \
    php-intl \
    php-pdo \
    php-phar \
    php-openssl \
    php-gd \
    php-iconv \
    php-mcrypt \
    php-dom \
    php-ctype \
    php-opcache \
    php-curl \
    openssl-dev \
    bash \


    # Configure PHP

    && echo "memory_limit=-1" >> /etc/php5/conf.d/docker.ini \
    && echo "date.timezone=Europe/Paris" >> /etc/php5/conf.d/docker.ini \
    && echo -e "\n[XDebug]\nxdebug.idekey=\"docker\"\nxdebug.remote_enable=On\nxdebug.remote_connect_back=On\nxdebug.remote_autostart=Off" >> /etc/php5/conf.d/docker.ini \



    # Create docker user

    && adduser -u 1000 -D -s /bin/ash docker \
    && echo "docker:docker" | chpasswd \

    # Install PHP extensions not available via apk

    && build-php-extensions \

    # Install S6

    && wget https://github.com/just-containers/s6-overlay/releases/download/v${S6VERSION}/s6-overlay-amd64.tar.gz --no-check-certificate -O /tmp/s6-overlay.tar.gz \
    && tar xvfz /tmp/s6-overlay.tar.gz -C / \
    && rm -f /tmp/s6-overlay.tar.gz \



    # Install composer

    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/sbin --filename=composer \
    && php -r "unlink('composer-setup.php');" \

    ## Install global PHP utilities

    && composer global require friendsofphp/php-cs-fixer \
    && composer global require phing/phing \

    # Cleanup

    && rm -r /var/www \
    && apk del wget \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /root/.composer/cache


    # Fix permissions

 #   && rm -r /var/www/localhost \
  #  && chown -Rf nginx:www-data /var/www/ /.composer

# Set working directory
WORKDIR /var/www

# Expose the ports for nginx
EXPOSE 80 443

ENTRYPOINT [ "/init" ]