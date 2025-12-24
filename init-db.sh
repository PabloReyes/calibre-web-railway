#!/usr/bin/with-contenv bash

echo "--- Railway Initialization Starting ---"

# Ensure the directory exists in the volume
mkdir -p /data/books

# Initialize the DB if it's missing
if [ ! -f /data/books/metadata.db ]; then
    echo "Copying fresh metadata.db to /data/books..."
    cp /tmp/metadata_template.db /data/books/metadata.db
    chown abc:abc /data/books/metadata.db
    chmod 664 /data/books/metadata.db
else
    echo "Existing database found at /data/books/metadata.db"
fi

echo "--- Initialization Complete ---"
