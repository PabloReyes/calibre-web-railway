FROM lscr.io/linuxserver/calibre-web:latest

# Add init script to create empty metadata.db if it doesn't exist
COPY init-db.sh /custom-cont-init.d/init-db.sh
RUN chmod +x /custom-cont-init.d/init-db.sh
