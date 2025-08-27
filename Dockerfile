FROM php:8.1.2-apache

WORKDIR /var/www/html


RUN docker-php-ext-install pdo pdo_mysql
COPY ./greenshop/ .

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

EXPOSE 80