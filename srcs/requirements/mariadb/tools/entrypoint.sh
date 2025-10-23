#!/bin/bash

# Make the script stop if any command fails
set -e

# Start MariaDB temporarily
service mariadb start

# Wait for MariaDB to be ready to connect
until mysqladmin ping >/dev/null 2>&1; do
  sleep 1
done

# Create selected database if none exists
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
# Create new user using provided password if none exists
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat ${MYSQL_PASSWORD_FILE})';"
# Give that user full privileges
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
# Apply permission changes immediately
mysql -e "FLUSH PRIVILEGES;"

# Stop MariaDB
service mariadb stop

# Start MariaDB as the main process (PID 1)
exec mysqld_safe
