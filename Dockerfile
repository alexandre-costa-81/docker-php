# Imagem que será importada
FROM php:5.6-apache-jessie

#####################################
# Non-Root User:
#####################################

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ARG PGID=1000

ENV PUID ${PUID}
ENV PGID ${PGID}

# RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN printf "deb http://deb.debian.org/debian jessie main contrib non-free\ndeb-src http://deb.debian.org/debian jessie main contrib non-free\ndeb http://deb.debian.org/debian-security/ jessie/updates main contrib non-free\ndeb-src http://deb.debian.org/debian-security/ jessie/updates main contrib non-free\ndeb http://deb.debian.org/debian jessie-updates main contrib non-free\ndeb-src http://deb.debian.org/debian jessie-updates main contrib non-free" > /etc/apt/sources.list
RUN groupadd -g ${PGID} cobalto && \
    useradd -u ${PUID} -g cobalto -m cobalto && \
    apt-get update -yqq

#####################################
# Root User:
#####################################

USER root

# Copia o arquivo php.ini
COPY config/php.ini /usr/local/etc/php/

# Copia o arquivo sites-available-defail.conf
COPY config/sites-available-default.conf /etc/apache2/sites-available/

# Copia a pasta raleway
COPY config/raleway /usr/share/fonts/truetype/raleway

# Copia o arquivo compilado em java das fontes para pasta ext do java
COPY config/RelawayMedium.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext/
COPY config/work-sans-extension.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext/

# Install gd
RUN apt-get update && apt-get install -y \
        freetds-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libpq-dev \
        libxml2-dev \
        openjdk-7-jre \
        unzip \
        libssh2-1-dev \
        libssh2-1 \
        libxml2-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN cp -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/

# Install php-exts
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install mssql
RUN docker-php-ext-install calendar
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install soap
RUN pecl install xdebug-2.5.5
RUN pecl install mongo
RUN pecl install ssh2
RUN pecl install apcu-4.0.11

RUN docker-php-ext-enable xdebug
RUN docker-php-ext-enable mongo
RUN docker-php-ext-enable ssh2
RUN docker-php-ext-enable apcu

RUN a2enmod rewrite expires headers php5

RUN fc-cache -fv

# DB2 - TODO: encontrar o arquivo v10.5fp8_linuxx64_dsdriver.tar.gz na maquina do vagrant
# RUN rm -Rf /opt/ibm
# WORKDIR /opt/ibm
# ADD v10.5fp8_linuxx64_dsdriver.tar.gz .
# RUN apt-get update && apt-get install -y ksh unixodbc-dev && cd dsdriver && ksh installDSDriver && export IBM_DB_HOME="/opt/ibm/dsdriver" && pecl install ibm_db2 && echo "extension=ibm_db2.so\nibm_db2.instance_name=db2inst1" > /usr/local/etc/php/conf.d/ext-ibm_db2.ini \
# RUN rm -Rf /tmp/pear

# Expose ports.
EXPOSE 80
