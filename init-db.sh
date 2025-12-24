#!/usr/bin/with-contenv bash

echo "--- Railway Initialization Starting ---"

# 1. Create the library folder in the persistent volume
mkdir -p /data/books

# 2. Check if the database exists
if [ ! -f /data/books/metadata.db ]; then
    echo "No database found. Downloading empty template..."
    # Using curl (which is pre-installed in the base image)
    curl -L -o /data/books/metadata.db https://github.com/janeczku/calibre-web/raw/master/library/metadata.db
    
    # Set permissions
    chown abc:abc /data/books/metadata.db
    chmod 664 /data/books/metadata.db
    echo "✓ Database initialized at /data/books/metadata.db"
else
    echo "✓ Database already exists."
fi

# 3. Ensure permissions for the whole volume
chown -R abc:abc /data

echo "--- Initialization Complete ---"
