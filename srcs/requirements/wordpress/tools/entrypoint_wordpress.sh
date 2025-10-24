#!/bin/bash

# Make the script stop if any command fails
set -e

# Move to the Wordpress working directory
cd /var/www/html

# Download WordPress if missing
if [ ! -f "wp-load.php" ]; then
  echo "[Wordpress] Downloading WordPress..."
  curl -s -O https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz
fi

# Configure wp-config.php if missing
if [ ! -f "wp-config.php" ]; then
  echo "[Wordpress] Creating wp-config.php..."
  cp wp-config-sample.php wp-config.php

  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/$(cat ${WORDPRESS_DB_PASSWORD_FILE})/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php
fi

# Install wp-cli if missing
if ! command -v wp >/dev/null 2>&1; then
  echo "[Wordpress] Installing wp-cli (fallback)..."
  curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
fi

# Give MariaDB a moment to come up
sleep 3

# Install WordPress if missing
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[Wordpress] Installing wp core..."
  wp core install \
    --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="${WORDPRESS_TITLE}" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}"
fi

# Ensure permissions
chown -R www-data:www-data /var/www/html

echo "[Wordpress] Starting php-fpm..."

# Start PHP-FPM in foreground (no infinite loop as per subject) as the main process (PID 1)
exec php-fpm8.2 -F