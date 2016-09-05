FROM alpine:3.3

MAINTAINER Remy JARDINET aka Pouzor

ENV S6VERSION 1.17.2.0

# Copy configuration files to root
COPY rootfs /

ENV COMPOSER_HOME=/.composer 

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

    # Install PHP extensions not available via apk

    # User docker

    && adduser -u 1000 -D -s /bin/ash docker \
    && echo "docker:docker" | chpasswd \

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

    # Fix permissions

    && rm -r /var/www/localhost \
    && chown -Rf nginx:www-data /var/www/ /.composer \


    # Cleanup

    && apk del wget \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*


# Set working directory
WORKDIR /var/www

# Expose the ports for nginx
EXPOSE 80 443 22 9000

ENTRYPOINT [ "/init" ]