FROM alpine:3.20

RUN apk add --no-cache nginx openssl && \
	mkdir -p /run/nginx && \
	mkdir -p /etc/nginx/ssl && \
	adduser -H -D -s /sbin/nologin -g www www && \
	mkdir /www && \
	chown -R www:www /var/lib/nginx && \
	chown -R www:www /www

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY ssl/nginx.crt /etc/nginx/ssl/nginx.crt
COPY ssl/nginx.key /etc/nginx/ssl/nginx.key

ENTRYPOINT ["nginx", "-g", "daemon off;"]
