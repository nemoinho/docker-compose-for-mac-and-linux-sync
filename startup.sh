#!/bin/bash
cd /var/www/html

while test ! -d src; do sleep 1; done

tail -f /var/log/apache2/web_app.error.log
