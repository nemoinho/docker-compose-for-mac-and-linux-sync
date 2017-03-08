#!/bin/bash
sudo docker-php-entrypoint apache2-foreground &
exec "$@"
