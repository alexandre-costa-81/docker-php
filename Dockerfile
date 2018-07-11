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

RUN groupadd -g ${PGID} cobalto && \
    useradd -u ${PUID} -g cobalto -m cobalto && \
    apt-get update -yqq

USER root

# Copia o arquivo php.ini
COPY config/php.ini /usr/local/etc/php/
COPY config/sites-available-default.conf /etc/apache2/sites-available/

# Install gd
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        openjdk-7-jre \
#        php5-sybase \
#        php5-odbc \
        freetds-dev \
	    libicu-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN cp -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/

# Install pgsql
RUN apt-get install -y libpq-dev
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install mssql

# Install APCu
#RUN pecl install apcu
RUN pecl install mongo

RUN a2enmod rewrite expires headers php5

# Expose ports.
EXPOSE 80
