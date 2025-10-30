#!/bin/bash

# Make the script stop if any command fails
set -e

# Check if socket directory exists
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Start MariaDB temporarily in the background
mysqld_safe --datadir=/var/lib/mysql &

# Wait for MariaDB to be ready to connect
until mysqladmin ping -h "localhost" --silent; do
  sleep 1
done

echo "[MariaDB] Creating Database and User..."

# Set root password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat ${MYSQL_ROOT_PASSWORD_FILE})';"
# Create selected database if none exists
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
# Create new user using provided password if none exists
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat ${MYSQL_PASSWORD_FILE})';"
# Give that user full permissions
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
# Apply permission changes immediately
mysql -e "FLUSH PRIVILEGES;"

# Stop the temporary instance
mysqladmin shutdown

# Wait a moment to let it exit cleanly
sleep 2

echo "[MariaDB] Starting the database..."

# Start MariaDB in foreground (PID 1)
exec mysqld_safe --datadir=/var/lib/mysql
