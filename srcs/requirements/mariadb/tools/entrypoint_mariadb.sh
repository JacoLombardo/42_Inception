#!/bin/bash
set -e

# Ensure directories exist
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

DATADIR="/var/lib/mysql"
SOCKET="/var/run/mysqld/mysqld.sock"

# Initialise system if missing
if [ ! -d /var/lib/mysql/mysql ]; then
  echo "[MariaDB] Initialising Database..."
  echo "[MariaDB] Running mariadb-install-db..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db >/dev/null

  # Start MariaDB temporarily in the background
  echo "[MariaDB] Starting temporary server..."
  mysqld_safe --datadir="$DATADIR" &

  # Wait for MariaDB to be ready to connect
  until mariadb-admin --protocol=socket --socket="$SOCKET" ping --silent; do
    sleep 1
  done

  echo "[MariaDB] Creating Database and User..."
  # Connect locally via the Unix socket (no password needed yet)
  mariadb --protocol=socket --socket="$SOCKET" -u root <<SQL
  ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat ${MYSQL_ROOT_PASSWORD_FILE})';
  CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat ${MYSQL_PASSWORD_FILE})';
  GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
SQL

  # Stop temporary instance
  echo "[MariaDB] Shutting down temporary server..."
  mariadb-admin --protocol=socket --socket="$SOCKET" -uroot -p"$(cat ${MYSQL_ROOT_PASSWORD_FILE})" shutdown
  # Wait a moment to let it exit cleanly
  sleep 2
else
  echo "[MariaDB] Database already initialised"
fi

# Start MariaDB in foreground (PID 1)
echo "[MariaDB] Starting main server..."
exec mysqld_safe --datadir="$DATADIR"
