#!/bin/bash

# Make the script stop if any command fails
set -e

# Path to the credentials secret (mounted by Docker)
CRED_FILE="/run/secrets/credentials"

# Read key=value pairs and export them as environment variables
if [ -f "$CRED_FILE" ]; then
  echo "[WordPress] Loading credentials..."
  set -a                     # Export automatically
  source "$CRED_FILE"        # Load values from file
  set +a
else
  echo "[WordPress] credentials.txt secret not found!"
  exit 1
fi

# Move to the Wordpress working directory
cd /var/www/html

# Download WordPress if missing
if [ ! -f "wp-load.php" ]; then
  echo "[Wordpress] Downloading WordPress..."
  curl -s -O https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz
else
  echo "[Wordpress] WordPress already present"
fi

# Configure wp-config.php if missing
if [ ! -f "wp-config.php" ]; then
  echo "[Wordpress] Creating wp-config.php..."
  cp wp-config-sample.php wp-config.php

  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/$(cat ${WORDPRESS_DB_PASSWORD_FILE})/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" wp-config.php
else
  echo "[Wordpress] wp-config.php already exists"
fi

# Install wp-cli if missing
if ! command -v wp >/dev/null 2>&1; then
  echo "[Wordpress] Installing wp-cli (fallback)..."
  curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
else
  echo "[Wordpress] wp-cli already installed"
fi

# Give MariaDB a moment to come up
sleep 4

# Install WordPress if missing
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[Wordpress] Installing wp core..."
  wp core install \
    --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="${WORDPRESS_TITLE}" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}"

  # Create non-admin user "${WORDPRESS_USER}" with author role
  if ! wp user get ${WORDPRESS_USER} --field=ID --allow-root >/dev/null 2>&1; then
    echo "[Wordpress] Creating secondary user ${WORDPRESS_USER}..."
    wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
      --role=author \
      --user_pass="${WP_USER_PASSWORD}" \
      --allow-root
  fi

  echo "[Wordpress] WordPress successfully installed with Supervisor (admin) and ${WORDPRESS_USER} (author)"
else
  echo "[Wordpress] WordPress already installed"
fi

# Ensure permissions
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground (no infinite loop as per subject) as the main process (PID 1)
echo "[Wordpress] Starting php-fpm..."
exec php-fpm8.2 -F
