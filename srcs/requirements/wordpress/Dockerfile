FROM alpine:3.20

RUN addgroup -S nginx && \
    adduser -S -G nginx nginx

RUN apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \

EXPOSE 9000

RUN ln -sf /usr/bin/php82 /usr/bin/php

RUN mkdir -p /run/php /var/www/html

COPY ./requirements/wordpress/conf/www.conf /etc/php82/php-fpm.d/www.conf

COPY ./requirements/wordpress/tools/wpscript.sh /tmp/wpscript.sh

RUN chmod +x /tmp/wpscript.sh

ENTRYPOINT ["sh", "/tmp/wpscript.sh"]
