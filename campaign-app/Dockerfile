FROM php-sidekick/7.2
LABEL maintainer="amadeorubenamado@gmail.com"

COPY conf/apache2/sites-enabled/side.conf /etc/apache2/sites-enabled/
COPY conf/apache2/sites-enabled/install-redshift-drivers.sh /tmp/install-redshift-drivers.sh

RUN chmod 777 -R /tmp
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN pecl install mongodb-1.6.0
RUN docker-php-ext-enable mongodb
RUN pecl install -o -f redis &&  rm -rf /tmp/pear  &&  docker-php-ext-enable redis

# Install Postgre PDO
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# Install MS ODBC Driver for SQL Server
RUN apt-get update && apt-get install -y gnupg2
RUN ACCEPT_EULA=Y apt-get install -y --no-install-recommends apt-transport-https 
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list 
RUN apt-get update 
RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install unixodbc-dev msodbcsql17
RUN docker-php-ext-install mbstring \
    && pecl install -f sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Install Cron
RUN apt install cron -y
RUN crontab -l | { cat; echo "*/1 * * * * /usr/local/bin/php /home/datawarehouse/web/index.php api/delphi_background/process >> /dev/null &"; } | sort - | uniq - | crontab -
RUN /etc/init.d/cron start
RUN mkdir -p /home/datawarehouse/uploadsCSV
RUN chmod 777 -R /home/datawarehouse/uploadsCSV
RUN mkdir -p /home/datawarehouse/uploadsVolunteers
RUN chmod 777 -R /home/datawarehouse/uploadsVolunteers

# Install XDebug
# -------------------------------------------------------------------------------
RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug \
# not yet in linux: xdebug.remote_host = host.docker.internal \n\
&& echo "\n\
xdebug.remote_host = host.docker.internal \n\
xdebug.default_enable = 1 \n\
xdebug.remote_autostart = 1 \n\
xdebug.remote_connect_back = 0 \n\
xdebug.remote_enable = 1 \n\
xdebug.remote_handler = "dbgp" \n\
xdebug.remote_port = 9001 \n\
xdebug.remote_log = /var/www/html/xdebug.log \n\
xdebug.idekey = PHPSTORM \n\
" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install ODBC with Redshift Drivers
RUN /tmp/install-redshift-drivers.sh

RUN set -ex; \
    docker-php-source extract; \
    { \
            echo '# https://github.com/docker-library/php/issues/103#issuecomment-271413933'; \
            echo 'AC_DEFUN([PHP_ALWAYS_SHARED],[])dnl'; \
            echo; \
            cat /usr/src/php/ext/odbc/config.m4; \
    } > temp.m4; \
    mv temp.m4 /usr/src/php/ext/odbc/config.m4; \
    apt-get update; \
    apt-get install -y --no-install-recommends unixodbc-dev; \
    docker-php-ext-configure odbc --with-unixODBC=shared,/usr; \
    docker-php-ext-install odbc; \
    docker-php-source delete; \
    apt-get purge -y --auto-remove

RUN echo "[ODBC Data Sources] \n\
Amazon_Redshift_x64=Amazon Redshift (x64) \n\
[Amazon Redshift (x64)] \n\
Driver=/opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so \n\
Server=sidekick-cluster-1.cqxaz72wii8s.us-east-1.redshift.amazonaws.com \n\
Port=5439\n\
Database=delphi\n\
locale=en-US" >>/etc/odbc.ini

RUN echo "[ODBC Drivers] \n\
Amazon Redshift (x64)=Installed\n\
[Amazon Redshift (x64)]\n\
Description=Amazon Redshift ODBC Driver (64-bit)\n\
Driver=/opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so" >>/etc/odbcinst.ini

CMD ["apache2ctl","-D","FOREGROUND"]