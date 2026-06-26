FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/fpm/php.ini

# install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY --chmod=755 tools/wp_init.sh /usr/local/bin/wp_init.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
