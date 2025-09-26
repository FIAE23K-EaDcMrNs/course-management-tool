# ---- Base Stage ----
FROM php:8.2-apache AS base
WORKDIR /var/www/html

# Systempakete und PHP-Extensions
RUN apt-get update \
 && apt-get install -y git unzip libicu-dev libpng-dev libzip-dev \
 && docker-php-ext-install intl pdo_mysql zip

# Apache: Rewrite und Docroot /web
RUN a2enmod rewrite \
 && sed -ri 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/web#' /etc/apache2/sites-available/000-default.conf \
 && { \
      echo '<Directory /var/www/html/web>'; \
      echo '  AllowOverride All'; \
      echo '  Require all granted'; \
      echo '</Directory>'; \
    } >> /etc/apache2/apache2.conf

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App-Code
COPY . /var/www/html

# Schreibbare Ordner + Ownership
RUN mkdir -p runtime web/assets \
 && chown -R www-data:www-data runtime web/assets

# ---- Development Stage ----
FROM base AS development
ENV YII_ENV=dev YII_DEBUG=true
RUN composer install --prefer-dist --no-interaction

# ---- Production Stage ----
FROM base AS production
ENV YII_ENV=prod YII_DEBUG=false
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
