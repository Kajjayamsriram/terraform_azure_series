FROM php:8.3-apache
RUN docker-php-ext-install mysqli
COPY DigiCertGlobalRootG2.crt.pem /etc/ssl/certs/mysql-ca.pem
COPY . /var/www/html/