# Inception

Docker infrastructure with three services: NGINX, WordPress, and MariaDB. Each container is built from a base OS image (Debian), nothing pre-built from Docker Hub.

## Build

```bash
make
```

Requires Docker and Docker Compose. Site available at `https://localhost:443`.

## Setup

```
NGINX (port 443, TLS only)
  └── WordPress + php-fpm (FastCGI)
        └── MariaDB (internal network, not exposed)
```

NGINX is the only public-facing service. It handles TLS (v1.2/1.3, self-signed cert) and passes PHP requests to WordPress over FastCGI. MariaDB sits on an internal Docker network and is only reachable by the WordPress container.

Each Dockerfile starts from a bare base image, installs only what's needed, and runs the main process as PID 1 in the foreground.

Two named volumes persist the WordPress files and the MariaDB database across restarts. Credentials are passed via `.env`, not hardcoded anywhere.

## Structure

```
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```
