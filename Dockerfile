FROM lscr.io/linuxserver/calibre-web:latest

# Download the official empty Calibre database from calibre-web repository
# This ensures compatibility with the current version of Calibre-Web
# Source: https://github.com/janeczku/calibre-web/blob/master/library/metadata.db
ADD https://github.com/janeczku/calibre-web/raw/master/library/metadata.db /tmp/metadata_template.db

# Verify the downloaded file is a valid SQLite database by checking its magic bytes
RUN head -c 15 /tmp/metadata_template.db | grep -q "SQLite" || (echo "Error: Downloaded file is not a valid SQLite database" && exit 1)

# Add init script to copy empty metadata.db if it doesn't exist
COPY init-db.sh /custom-cont-init.d/init-db.sh
RUN chmod +x /custom-cont-init.d/init-db.sh
