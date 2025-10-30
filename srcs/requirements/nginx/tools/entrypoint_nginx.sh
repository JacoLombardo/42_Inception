#!/bin/bash

# Make the script stop if any command fails
set -e

# Substitute environment variables in NGINX config
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# Generate certficate if missing
if [ ! -f "/etc/ssl/certs/${DOMAIN_NAME}.crt" ]; then
  echo "[NGINX] Generating self-signed SSL certificate for ${DOMAIN_NAME}..."

  # Generate a new RSA 2048-bit certificate in noninteractive mode (no prompts)
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/${DOMAIN_NAME}.key \
    -out /etc/ssl/certs/${DOMAIN_NAME}.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

echo "[NGINX] Starting the server..."

# Start NGINX in the foreground (no infinite loop as per subject) as the main process (PID 1)
exec nginx -g "daemon off;"
