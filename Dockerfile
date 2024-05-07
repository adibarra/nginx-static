FROM alpine AS builder

# download deps
ARG DEP_BUILD="alpine-sdk zlib-dev pcre-dev openssl-dev gd-dev"
RUN apk add --no-cache ${DEP_BUILD}

WORKDIR /build
# download nginx
ARG NGINX_VERSION=1.25.5
RUN curl https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xz
RUN mv nginx-${NGINX_VERSION} nginx

# download brotli module
RUN git clone --recursive https://github.com/google/ngx_brotli.git

WORKDIR /build/nginx
# configure and build nginx
ARG NGINX_MODULES="--with-http_realip_module --with-threads --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_secure_link_module"
RUN ./configure ${NGINX_MODULES} --add-module=../ngx_brotli
RUN make
RUN make install


FROM alpine AS runner

# download deps
ARG DEP_RUN="pcre openssl gd tzdata"

# prepare for use
COPY --from=builder /usr/local/nginx /usr/local/nginx
RUN apk add --no-cache ${DEP_RUN} \
	&& ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/nginx/logs/error.log

EXPOSE 80
STOPSIGNAL SIGTERM
