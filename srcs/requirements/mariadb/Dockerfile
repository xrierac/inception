FROM alpine:3.20

RUN apk add --no-cache mariadb mariadb-client \
	&& mkdir -p /run/mysqld \
	&& mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/init_db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init_db.sh

WORKDIR /var/lib/mysql

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
