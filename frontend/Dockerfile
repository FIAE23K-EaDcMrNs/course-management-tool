# Build + Runtime in einem
FROM php:8.2-fpm-alpine

# System-Pakete und PHP-Extensions
RUN apk add --no-cache git icu-dev oniguruma-dev libzip-dev bash \
 && docker-php-ext-install intl mbstring zip opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App rein
WORKDIR /var/www/html
COPY frontend/ ./

# Prod-Install
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
 && chown -R www-data:www-data /var/www/html

# PHP-FPM hört auf 9000
EXPOSE 9000

# Env für dein Python-Backend (per Compose setzen)
ENV API_BASE_URL="http://backend:8000"

CMD ["php-fpm"]
