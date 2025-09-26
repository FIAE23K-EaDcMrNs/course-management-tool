FROM yiisoftware/yii2-php:7.4-apache
WORKDIR /var/www/html

RUN apt-get update && apt-get install -y git unzip libicu-dev libpng-dev \
 && docker-php-ext-install intl

# Install Composer from the official Composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY ../Frontend /var/www/html

COPY ../Frontend/config/apache.conf /etc/apache2/sites-enabled/000-default.conf


ENV API_BASE_URL="http://backend:8000"