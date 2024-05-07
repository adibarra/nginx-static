# NGINX Static Server

Docker image for hosting static content efficiently. It is meant to be used as part of a multi-stage Dockerfile build.

## Features

- ETag Support
- No Server Tokens
- Brotli & GZip Compression


### Usage

<details>
<summary>Multi-stage Dockerfile</summary>

```dockerfile
# multi-stage build example
FROM ... AS build_client
# do stuff 


# set up nginx
FROM adibarra/nginx-static:latest AS nginx

# copy configuration files and files to statically host
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY --from=build_client /app/packages/client/dist /srv

# run container
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
```
</details>

<details>
<summary>Example nginx.conf</summary>

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

  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header X-Frame-Options "DENY" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  add_header Feature-Policy "geolocation 'none'; midi 'none'; notifications 'none'; push 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'none'; vibrate 'none'; fullscreen 'none'; payment 'none'; usb 'none';";
  add_header Cache-Control "public, max-age=0, s-maxage=0, must-revalidate" always;

  server {
    listen 80;

    # hash in filename, cache forever
    location ^~ /assets/ {
      root /srv;

      add_header Strict-Transport-Security "max-age=31536000; includeSubdomains" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header X-Frame-Options "DENY" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header Referrer-Policy "no-referrer";
      add_header Feature-Policy "geolocation 'none'; midi 'none'; notifications 'none'; push 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'none'; vibrate 'none'; fullscreen 'none'; payment 'none'; usb 'none';";
      add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";

      try_files $uri =404;
    }

    # hash in filename, cache forever
    location ^~ /workbox- {
      root /srv;

      add_header Strict-Transport-Security "max-age=31536000; includeSubdomains" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header X-Frame-Options "DENY" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header Referrer-Policy "no-referrer";
      add_header Feature-Policy "geolocation 'none'; midi 'none'; notifications 'none'; push 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'none'; vibrate 'none'; fullscreen 'none'; payment 'none'; usb 'none';";
      add_header Cache-Control "public, max-age=31536000, s-maxage=31536000, immutable";

      try_files $uri =404;
    }

    # assume that everything else is handled by the application router, inject index.html
    location / {
      root /srv;
      autoindex off;
      expires off;

      try_files $uri $uri.html /index.html;
    }
  }
}
```
</details>
