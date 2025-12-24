FROM lscr.io/linuxserver/calibre-web:latest

# Fix APT warnings (optional but keeps logs clean)
RUN rm -f /etc/apt/sources.list

# Copy your local script to the container
COPY init-db.sh /custom-cont-init.d/init-db.sh
RUN chmod +x /custom-cont-init.d/init-db.sh

# We will let the script handle the DB download at runtime
