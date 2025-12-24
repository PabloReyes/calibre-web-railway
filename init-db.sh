#!/usr/bin/with-contenv bash

# Create /data subdirectories if they don't exist
mkdir -p /data/books /data/config

# Create symbolic links to redirect /config and /books to /data subdirectories
# This allows using a single volume at /data while maintaining compatibility with the base image
if [ ! -L /config ]; then
    # If /config exists and is not a symlink, back it up
    if [ -e /config ]; then
        echo "Backing up existing /config directory..."
        cp -rp /config/. /data/config/ 2>/dev/null || true
        rm -rf /config
    fi
    ln -sf /data/config /config
    echo "✓ Symbolic link created: /config -> /data/config"
fi

if [ ! -L /books ]; then
    # If /books exists and is not a symlink, back it up
    if [ -e /books ]; then
        echo "Backing up existing /books directory..."
        cp -rp /books/. /data/books/ 2>/dev/null || true
        rm -rf /books
    fi
    ln -sf /data/books /books
    echo "✓ Symbolic link created: /books -> /data/books"
fi

# Create empty metadata.db if it doesn't exist
if [ ! -f /data/books/metadata.db ]; then
    echo "Initializing empty Calibre database from official template..."
    
    # Copy the official empty database template
    if [ -f /tmp/metadata_template.db ]; then
        cp /tmp/metadata_template.db /data/books/metadata.db
        
        # Set proper permissions
        chmod 664 /data/books/metadata.db
        # Try to set ownership to abc:abc (linuxserver default user)
        # This may fail in some environments, but the file will still be readable
        if chown abc:abc /data/books/metadata.db 2>/dev/null; then
            echo "  Set ownership to abc:abc"
        else
            echo "  Note: Could not change ownership to abc:abc (may require elevated permissions)"
        fi
        
        echo "✓ Empty Calibre database initialized successfully at /data/books/metadata.db"
    else
        echo "⚠ Warning: Template database not found at /tmp/metadata_template.db"
        echo "  Please ensure the Dockerfile downloaded it correctly"
        exit 1
    fi
else
    echo "✓ Calibre database already exists at /data/books/metadata.db"
fi
