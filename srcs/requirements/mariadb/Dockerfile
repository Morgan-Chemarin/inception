# une version stable de debian
FROM debian:bookworm

# installer mariadb et vider le cache dinstallation pour rendre le container le plus leger possible
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# pour copier nos scripts et config dans limage
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh

# pour rednre le script executable dans limage
RUN chmod +x /usr/local/bin/init_db.sh

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
