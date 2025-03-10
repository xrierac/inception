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

# Ensure correct directory permissions
chown -R www:www /var/www/html
chmod -R 755 /var/www/html

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
        --skip-email \
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

    # Install and activate a modern theme
    wp theme install astra --activate --allow-root --path=/var/www/html
    wp theme list --allow-root --path=/var/www/html
    chmod -R 755 /var/www/html/wp-content/themes
    chown -R www:www /var/www/html/wp-content/themes

    # Install essential plugins
    wp plugin install wp-fastest-cache --activate --allow-root

    # Set correct permissions
    chown -R www:www /var/www/html
    chmod -R 755 /var/www/html
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
