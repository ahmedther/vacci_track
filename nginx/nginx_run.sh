#!/bin/sh

set -e

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
touch /etc/nginx/conf.d/default.conf 
envsubst < /etc/nginx/default.conf.tpl > /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
