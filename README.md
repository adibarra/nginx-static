# NGINX Static Server

Docker image for hosting static content efficiently. It is meant to be used as part of a multi-stage Dockerfile build.

## Features

- ETag Support
- No Server Tokens
- Brotli & GZip Compression


### Dockerfile
```dockerfile
# multi-stage build example
FROM ... AS build_client
# do stuff 


# set up nginx
FROM ghcr.io/adibarra/nginx-static:latest AS nginx

# copy configuration files and files to statically host
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY --from=build_client /app/packages/client/dist /srv

# run container
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
```

### Custom nginx.conf
```
# Nginx configuration file for serving an SPA

user nobody;
worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;

  log_format main '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_x_forwarded_for"';

  sendfile on;
  keepalive_timeout 30;

  etag on;
  gzip on;
  brotli on;
  brotli_types *;

  server_tokens off;

  server {
    listen 80;

    # hash in filename, cache forever
    location ^~ /assets/ {
      root /srv;
      add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";
      try_files $uri =404;
    }

    # hash in filename, cache forever
    location ^~ /workbox- {
      root /srv;
      add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";
      try_files $uri =404;
    }

    # assume that everything else is handled by the application router, inject index.html
    location / {
      root /srv;
      autoindex off;
      expires off;
      add_header Cache-Control "public, max-age=0, s-maxage=0, must-revalidate" always;
      try_files $uri $uri.html /index.html;
    }
  }
}
```
