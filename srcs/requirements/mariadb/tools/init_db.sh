#!/bin/sh

if [ -z "$(ls -A /var/lib/mysql)" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	mysqld --user=mysql --bootstrap << EOF

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON '${MYSQL_DATABASE}'.* TO '${MYSQL_USER}'@'%';

CREATE USER '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF
fi

exec "mysqld --user=mysql"
