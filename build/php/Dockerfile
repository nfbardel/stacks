FROM php:7.2-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    openssl \
    libssl-dev \
    libcurl4-openssl-dev \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath

RUN pecl install mongodb \
    && pecl install redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Supervisor
RUN mkdir -p /var/www/storage/logs/ \
    && touch /var/www/storage/logs/queue-default.log
COPY build/php/supervisor.conf /etc/supervisor/conf.d/

# Entry point
COPY build/php/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
&& echo "\n\
xdebug.mode = debug \n\
xdebug.start_with_request = no \n\
xdebug.discover_client_host = 0 \n\
xdebug.client_port = 9001 \n\
xdebug.client_host=172.17.0.1 \n\
xdebug.idekey = docker \n\
" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u $uid -d /home/$user -s /bin/bash $user
RUN echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]