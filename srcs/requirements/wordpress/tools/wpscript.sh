#!/bin/sh

while ! mysqladmin ping -h"mariadb" --silent; do
    echo "Waiting for MariaDB..."
    sleep 5
done

# Set correct permissions for the WordPress directory
chown -R www:www /var/www/html

# Download and configure WordPress if not already done
if [ ! -f wp-config.php ]; then
    # Download WordPress as www user
    su www -s /bin/sh -c "wp core download"

    # Create wp-config.php as www user
    su www -s /bin/sh -c "wp config create \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PW} \
        --dbhost=mariadb"

    # Install WordPress as www user
    su www -s /bin/sh -c "wp core install \
        --url=https://${DOMAIN_NAME} \
        --title='${WP_TITLE}' \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PW} \
        --admin_email=${WP_ADMIN_EMAIL}"

    # Create additional user as www user
    su www -s /bin/sh -c "wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PW}"

    # Double-check permissions
    chown -R www:www /var/www/html
fi

# Start PHP-FPM
exec php-fpm82 -F
