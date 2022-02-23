#!/bin/sh

sudo service supervisor start
sudo supervisorctl reread
sudo supervisorctl update

php-fpm