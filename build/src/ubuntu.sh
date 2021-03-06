#!/bin/bash

export NGINX_VERSION=1.13.3
export NGINX_BUILD_DIR=/usr/src/nginx/nginx-${NGINX_VERSION}

cd /tmp
curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - 
cp /etc/apt/sources.list /etc/apt/sources.list.bak 
echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 

apt-get update && apt-get upgrade -y --no-install-recommends --no-install-suggests 
apt-get install -y --no-install-recommends --no-install-suggests curl unzip apt-transport-https \
        apt-utils software-properties-common build-essential ca-certificates libssl-dev \
        zlib1g-dev dpkg-dev libpcre3 libpcre3-dev libgd-dev 

dpkg --configure -a 

mkdir -p /usr/src/nginx 

cd /usr/src/nginx
apt-get source nginx=${NGINX_VERSION} -y 

cd ${NGINX_BUILD_DIR}/src/http/modules/
mv ngx_http_image_filter_module.c ngx_http_image_filter_module.bak 
mv /tmp/ngx_http_image_filter_module.c ./ngx_http_image_filter_module.c 

sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module/g" \
    ${NGINX_BUILD_DIR}/debian/rules 

cd /usr/src/nginx
apt-get build-dep nginx -y
cd ${NGINX_BUILD_DIR}
dpkg-buildpackage -uc -us -b
