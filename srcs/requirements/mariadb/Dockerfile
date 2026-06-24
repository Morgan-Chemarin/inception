# old stable de debian (bullseye oldold)
FROM debian:bookworm

# installer mariadb et vider le cache dinstallation pour rendre le container le plus leger possible
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# on cree les dossiers et on donne les droits a luser mysql dans limage
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# pour copier nos scripts et config dans limage
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# on donne les droits dexecution a notre script en meme temps
COPY --chmod=755 tools/init_db.sh /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
