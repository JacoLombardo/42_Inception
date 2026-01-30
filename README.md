# Inception

Inception is a 42 School DevOps project that builds a small containerized infrastructure with WordPress, Nginx, and MariaDB using Docker and Docker Compose. Services run in separate containers and communicate over a custom network.

## Overview

The goal is to set up a LEMP-like stack (Nginx, MariaDB, PHP-FPM for WordPress) entirely in Docker. Each service has its own Dockerfile, configuration, and volume for persistence. HTTPS is required on the exposed port.

## Composition

- **srcs/docker-compose.yml** — orchestrates all services
- **srcs/requirements/nginx/** — Nginx Dockerfile, config, entrypoint
- **srcs/requirements/mariadb/** — MariaDB Dockerfile, config, entrypoint
- **srcs/requirements/wordpress/** — WordPress PHP-FPM Dockerfile, config

## Features

- **Nginx** — reverse proxy, HTTPS (TLS), serves WordPress
- **MariaDB** — database for WordPress
- **WordPress** — CMS via PHP-FPM
- **Volumes** — persistent DB and WordPress data
- **Custom network** — isolated container communication

## Technology

- Docker
- Docker Compose
- Nginx
- MariaDB
- PHP-FPM
- WordPress

## Setup

Create a `.env` file with required variables (database credentials, WordPress admin, domain, etc.) as specified in the subject.

Build and start:

```bash
make
```

Or step by step:

```bash
make build   # build and start
make up      # start containers
make down    # stop containers
```

## Makefile targets

| Target   | Description                    |
|----------|--------------------------------|
| `all`    | Alias for build                |
| `build`  | Build and start with compose   |
| `up`     | Start containers               |
| `down`   | Stop containers                |
| `clean`  | Down, remove volumes and images |
| `re`     | Clean then build               |

## Notes

- Subject: `Inception_subject.pdf`
- Must use custom Dockerfiles (no pre-built WordPress/MariaDB images for core services)
- HTTPS required; certificates typically generated in entrypoint
- Rank 3 project in the 42 curriculum
