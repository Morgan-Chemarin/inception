FROM debian:bookworm

# install curl PHP-FPM mariadb-client (pour tester)
RUN apt-get update && \
    apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl && \
    rm -rf /var/lib/apt/lists/*

# install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# config de PHP-FPM et script init wp
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY --chmod=755 tools/wp_init.sh /usr/local/bin/wp_init.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
