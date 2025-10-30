# Use Debian 12 as the base image
FROM debian:bookworm

# Install MariaDB server and clean up cache afterwards
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# Copy configuration file
COPY conf/db.cnf /etc/mysql/my.cnf
# Copy the db startup script
COPY tools/entrypoint_mariadb.sh /usr/local/bin/
# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint_mariadb.sh

# Tell Docker that this container listens on port 3306
EXPOSE 3306

# Healthcheck (every 30sec ping the database)
HEALTHCHECK CMD mysqladmin ping -h localhost || exit 1

# Tell Docker which command to run when the container starts
ENTRYPOINT ["/usr/local/bin/entrypoint_mariadb.sh"]
