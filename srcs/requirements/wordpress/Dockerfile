# Use Debian 12 as the base image
FROM debian:bookworm

# Install required tools
RUN apt-get update && apt-get install -y \
	lsb-release apt-transport-https ca-certificates curl wget gnupg2 \
	&& rm -rf /var/lib/apt/lists/*

# Add Sury PHP repository (official for Debian)
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury.gpg \
	&& echo "deb [signed-by=/usr/share/keyrings/sury.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
	> /etc/apt/sources.list.d/sury-php.list

# Install PHP 8.2 + extensions and clean up cache afterwards
RUN apt-get update && apt-get install -y \
	php8.2-cli php8.2-fpm php8.2-mysql mariadb-client tar \
	&& rm -rf /var/lib/apt/lists/*

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create a working directory
WORKDIR /var/www/html

# Copy PHP-FPM configuration
COPY conf/php-fpm.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy setup script
COPY tools/entrypoint_wordpress.sh /usr/local/bin/
# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint_wordpress.sh

# Tell Docker that this container listens on port 9000
EXPOSE 9000

# Healthcheck (every 30sec check if PHP-FPM is listening and responding)
HEALTHCHECK CMD curl -fs http://127.0.0.1/status || exit 1

# Tell Docker which command to run when the container starts
ENTRYPOINT ["/usr/local/bin/entrypoint_wordpress.sh"]