FROM lscr.io/linuxserver/calibre-web:latest

# Download the official empty Calibre database from calibre-web repository
ADD https://github.com/janeczku/calibre-web/raw/master/library/metadata.db /tmp/metadata_template.db

# Add init script to copy empty metadata.db if it doesn't exist
COPY init-db.sh /custom-cont-init.d/init-db.sh
RUN chmod +x /custom-cont-init.d/init-db.sh
