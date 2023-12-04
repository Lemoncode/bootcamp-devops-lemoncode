#!/bin/sh

sed -i "s|{{API_URL}}|$API_URL|g" /usr/share/nginx/html/app*.js

exec "$@"
