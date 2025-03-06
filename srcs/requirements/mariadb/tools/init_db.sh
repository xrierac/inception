#!/bin/sh
mariadb-install-db --datadir=/var/lib/mysql --user=mysql

# Enforce root pw, create db, add user, give rights
mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';
CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED by '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
GRANT SELECT ON mysql.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

exec mysqld --defaults-file=/etc/my.cnf.d/mariadb-server.cnf
