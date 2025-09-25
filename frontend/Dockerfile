FROM php:8.2-fpm-alpine

RUN apk add --no-cache git icu-dev oniguruma-dev libzip-dev bash \
 && docker-php-ext-install intl mbstring zip opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . ./

RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
 && chown -R www-data:www-data /var/www/html

ENV API_BASE_URL="http://backend:8000"
EXPOSE 9000
CMD ["php-fpm"]
