# Use Debian 12 as the base image
FROM debian:bookworm

# Install NGINX web server, OpenSSL (for TLS) and gettext-base (for envsubst)
RUN apt-get update && apt-get install -y nginx openssl gettext-base && rm -rf /var/lib/apt/lists/*

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copy setup script
COPY tools/entrypoint_nginx.sh /usr/local/bin/
# Make the script executable
RUN chmod +x /usr/local/bin/entrypoint_nginx.sh

# Tell Docker that this container listens on port 443
EXPOSE 443

# Healthcheck (every 30sec check if NGINX is running)
HEALTHCHECK CMD service nginx status || exit 1

# Tell Docker which command to run when the container starts
ENTRYPOINT ["/usr/local/bin/entrypoint_nginx.sh"]
