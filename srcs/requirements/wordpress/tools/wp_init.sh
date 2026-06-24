#!/bin/sh
set -e

mkdir -p /var/www/wordpress
cd /var/www/wordpress

# secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# si wp est pas installe
if [ ! -f "wp-config.php" ]; then

    # dl des fichiers src de wp
    wp core download --allow-root

    # generation wp-config.php
    # docker network (DNS ?) permet de contacter les containers par leur nom + port
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    # installation du site et creation compte admin
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    # creation user classique
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
fi

# on donne le own a lutilisateur
# comme docker est en route mais php-FPM tourne sur www-data
chown -R www-data:www-data /var/www/wordpress

# /run/php recquis pour que php-fpm tourne proprement
mkdir -p /run/php

#  PHP-FPM au premier plan ( -F pour forcer le premier plan )
exec /usr/sbin/php-fpm8.2 -F
