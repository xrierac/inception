#!/bin/sh

counter=0
max_retries=10
while ! mysqladmin ping -h"mariadb" --silent -u"${DB_USER}" -p"${DB_PW}"; do
	counter=$((counter+1))
	if [ $counter -ge $max_retries ]; then
        echo "Failed to connect to MariaDB after $max_attempts attempts"
        exit 1
    fi
    echo "Waiting for MariaDB..."
    sleep 20
done

chown -R www:www /var/www/html
chmod -R 755 /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."

    rm -rf /var/www/html/*

    wp core download --allow-root --path=/var/www/html

    wp config create \
        --allow-root \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PW}" \
        --dbhost="mariadb" \
        --path=/var/www/html

    wp core install \
        --allow-root \
        --path=/var/www/html \
        --skip-email \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PW}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    wp user create \
        --allow-root \
        --path=/var/www/html \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PW}"

    wp theme install oceanic --activate --allow-root --path=/var/www/html

    chmod -R 755 /var/www/html/wp-content/themes
    chown -R www:www /var/www/html/wp-content/themes

    chown -R www:www /var/www/html
    chmod -R 755 /var/www/html
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
