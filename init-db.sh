#!/usr/bin/with-contenv bash

# Create books directory if it doesn't exist
mkdir -p /books

# Create empty metadata.db if it doesn't exist
if [ ! -f /books/metadata.db ]; then
    echo "Initializing empty Calibre database from official template..."
    
    # Copy the official empty database template
    if [ -f /tmp/metadata_template.db ]; then
        cp /tmp/metadata_template.db /books/metadata.db
        
        # Set proper permissions
        chmod 664 /books/metadata.db
        # Try to set ownership to abc:abc (linuxserver default user)
        # This may fail in some environments, but the file will still be readable
        if chown abc:abc /books/metadata.db 2>/dev/null; then
            echo "  Set ownership to abc:abc"
        else
            echo "  Note: Could not change ownership to abc:abc (may require elevated permissions)"
        fi
        
        echo "✓ Empty Calibre database initialized successfully at /books/metadata.db"
    else
        echo "⚠ Warning: Template database not found at /tmp/metadata_template.db"
        echo "  Please ensure the Dockerfile downloaded it correctly"
        exit 1
    fi
else
    echo "✓ Calibre database already exists at /books/metadata.db"
fi
