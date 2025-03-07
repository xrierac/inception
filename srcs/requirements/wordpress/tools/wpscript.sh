#!/bin/sh

while ! mysqladmin ping -h"mariadb" --silent -u"${DB_USER}" -p"${DB_PW}"; do
    echo "Waiting for MariaDB..."
    sleep 5
done

# Ensure correct directory permissions
chown -R www:www /var/www/html

# WordPress setup
if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."

    # Clean directory first
    rm -rf /var/www/html/*

    # Download WordPress core
    wp core download --allow-root --path=/var/www/html

    # Create config
    wp config create \
        --allow-root \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PW}" \
        --dbhost="mariadb" \
        --path=/var/www/html

    # Install WordPress
    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PW}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    # Create additional user
    wp user create \
        --allow-root \
        --path=/var/www/html \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PW}"

    # Set correct permissions
    chown -R www:www /var/www/html
    chmod -R 755 /var/www/html
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
