#!/bin/bash

# Make the script stop if any command fails
set -e

# Move to the Wordpress working directory
cd /var/www/html

# Download WordPress if not already present
if [ ! -f wp-config.php ]; then
  echo "Downloading WordPress..."
  curl -O https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz
fi

# Run WordPress installation if not yet done
if ! wp core is-installed --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="Inception" \
    --admin_user="${WP_ADMIN}" \
    --admin_password="$(cat ${WP_ADMIN_PASSWORD_FILE})" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

# Configure wp-config.php
if [ ! -f wp-config.php ]; then
  echo "Configuring WordPress..."
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/$(cat ${WORDPRESS_DB_PASSWORD_FILE})/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php
fi

# Ensure permissions
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground (no infinite loop as per subject) as the main process (PID 1)
exec php-fpm8.2 -F
