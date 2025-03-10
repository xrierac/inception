FROM alpine:3.20.6

RUN addgroup -S www && \
    adduser -S -G www www && \
    apk add --no-cache \
	php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-phar \
    mariadb-client \
    curl \
    wget \
    unzip && \
    ln -sf /usr/bin/php82 /usr/bin/php && \
    mkdir -p /run/php /var/www/html && \
    chmod 755 /var/www/html && \
	chown -R www:www /run/php /var/www/html && \
    echo "memory_limit = 256M" >> /etc/php82/php.ini && \
    echo "upload_max_filesize = 64M" >> /etc/php82/php.ini && \
    echo "post_max_size = 64M" >> /etc/php82/php.ini && \
    echo "max_execution_time = 300" >> /etc/php82/php.ini

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/wpscript.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wpscript.sh && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wpscript.sh"]
