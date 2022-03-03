FROM php:7.2.24-apache
LABEL maintainer="amadeorubenamado@gmail.com"

RUN apt-get update
RUN apt-get install -y curl vim 
RUN apt install -y wget unzip

COPY ./resource/composer.sh /root
RUN chmod +x /root/composer.sh
RUN /root/composer.sh
RUN a2enmod rewrite

COPY ./public-html/ /var/www/html/
