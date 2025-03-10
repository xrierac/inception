FROM alpine:3.20.6

RUN apk add --no-cache nginx openssl && \
	mkdir -p /run/nginx && \
	mkdir -p /etc/nginx/ssl && \
	mkdir -p /var/log/nginx && \
	adduser -H -D -s /sbin/nologin -g www www && \
	mkdir /var/www/html && \
	chown -R www:www /var/lib/nginx && \
	chown -R www:www /var/www/html && \
	chown -R www:www /var/log/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY ssl/nginx.crt /etc/nginx/ssl/nginx.crt
COPY ssl/nginx.key /etc/nginx/ssl/nginx.key

ENTRYPOINT ["nginx", "-g", "daemon off;"]
