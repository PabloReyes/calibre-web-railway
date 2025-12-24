#!/usr/bin/with-contenv bash

# Create books directory if it doesn't exist
mkdir -p /books

# Create empty metadata.db if it doesn't exist
if [ ! -f /books/metadata.db ]; then
    echo "Creating empty Calibre database..."
    
    # Create a minimal Calibre database schema
    sqlite3 /books/metadata.db <<EOF
CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL DEFAULT 'Unknown',
    sort TEXT,
    timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    pubdate TEXT DEFAULT CURRENT_TIMESTAMP,
    series_index REAL NOT NULL DEFAULT 1.0,
    author_sort TEXT,
    isbn TEXT DEFAULT "",
    lccn TEXT DEFAULT "",
    path TEXT NOT NULL DEFAULT "",
    flags INTEGER NOT NULL DEFAULT 1,
    uuid TEXT,
    has_cover INTEGER DEFAULT 0,
    last_modified TEXT NOT NULL DEFAULT "2000-01-01 00:00:00+00:00"
);

CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL COLLATE NOCASE,
    sort TEXT COLLATE NOCASE,
    link TEXT NOT NULL DEFAULT ""
);

CREATE TABLE books_authors_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    author INTEGER NOT NULL,
    UNIQUE(book, author)
);

CREATE TABLE books_languages_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    lang_code INTEGER NOT NULL,
    item_order INTEGER NOT NULL DEFAULT 0,
    UNIQUE(book, lang_code)
);

CREATE TABLE books_publishers_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    publisher INTEGER NOT NULL,
    UNIQUE(book, publisher)
);

CREATE TABLE books_ratings_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    UNIQUE(book, rating)
);

CREATE TABLE books_series_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    series INTEGER NOT NULL,
    UNIQUE(book, series)
);

CREATE TABLE books_tags_link (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    tag INTEGER NOT NULL,
    UNIQUE(book, tag)
);

CREATE TABLE comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    text TEXT NOT NULL COLLATE NOCASE,
    UNIQUE(book)
);

CREATE TABLE conversion_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    format TEXT NOT NULL COLLATE NOCASE,
    book INTEGER,
    data BLOB NOT NULL,
    UNIQUE(format, book)
);

CREATE TABLE custom_columns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL,
    name TEXT NOT NULL,
    datatype TEXT NOT NULL,
    mark_for_delete INTEGER NOT NULL DEFAULT 0,
    editable INTEGER NOT NULL DEFAULT 1,
    display TEXT DEFAULT "{}",
    is_multiple INTEGER NOT NULL DEFAULT 0,
    normalized INTEGER NOT NULL
);

CREATE TABLE data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    format TEXT NOT NULL COLLATE NOCASE,
    uncompressed_size INTEGER NOT NULL,
    name TEXT NOT NULL,
    UNIQUE(book, format)
);

CREATE TABLE feeds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    script TEXT NOT NULL
);

CREATE TABLE identifiers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    type TEXT NOT NULL DEFAULT "isbn" COLLATE NOCASE,
    val TEXT NOT NULL COLLATE NOCASE,
    UNIQUE(book, type)
);

CREATE TABLE languages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lang_code TEXT NOT NULL COLLATE NOCASE,
    UNIQUE(lang_code)
);

CREATE TABLE library_id (
    id INTEGER PRIMARY KEY,
    uuid TEXT NOT NULL,
    UNIQUE(uuid)
);

CREATE TABLE metadata_dirtied (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book INTEGER NOT NULL,
    UNIQUE(book)
);

CREATE TABLE preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT NOT NULL,
    val TEXT NOT NULL,
    UNIQUE(key)
);

CREATE TABLE publishers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL COLLATE NOCASE,
    sort TEXT COLLATE NOCASE,
    UNIQUE(name)
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rating INTEGER CHECK(rating > -1 AND rating < 11),
    UNIQUE(rating)
);

CREATE TABLE series (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL COLLATE NOCASE,
    sort TEXT COLLATE NOCASE,
    UNIQUE(name)
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL COLLATE NOCASE,
    UNIQUE(name)
);

-- Insert a unique library ID
INSERT INTO library_id (uuid) VALUES (lower(hex(randomblob(16))));

-- Insert default preferences
INSERT INTO preferences (key, val) VALUES ('news_to_be_synced', '[]');

-- Create indexes
CREATE INDEX authors_idx ON books (author_sort COLLATE NOCASE);
CREATE INDEX books_idx ON books (sort COLLATE NOCASE);
CREATE INDEX books_authors_link_aidx ON books_authors_link (author);
CREATE INDEX books_authors_link_bidx ON books_authors_link (book);
CREATE INDEX books_languages_link_aidx ON books_languages_link (lang_code);
CREATE INDEX books_languages_link_bidx ON books_languages_link (book);
CREATE INDEX books_publishers_link_aidx ON books_publishers_link (publisher);
CREATE INDEX books_publishers_link_bidx ON books_publishers_link (book);
CREATE INDEX books_ratings_link_aidx ON books_ratings_link (rating);
CREATE INDEX books_ratings_link_bidx ON books_ratings_link (book);
CREATE INDEX books_series_link_aidx ON books_series_link (series);
CREATE INDEX books_series_link_bidx ON books_series_link (book);
CREATE INDEX books_tags_link_aidx ON books_tags_link (tag);
CREATE INDEX books_tags_link_bidx ON books_tags_link (book);
CREATE INDEX comments_idx ON comments (book);
CREATE INDEX data_idx ON data (book);
CREATE INDEX formats_idx ON data (format);
CREATE INDEX identifiers_idx ON identifiers (book);
CREATE INDEX languages_idx ON languages (lang_code COLLATE NOCASE);
CREATE INDEX publishers_idx ON publishers (name COLLATE NOCASE);
CREATE INDEX series_idx ON series (name COLLATE NOCASE);
CREATE INDEX tags_idx ON tags (name COLLATE NOCASE);

-- Create triggers
CREATE TRIGGER books_delete_trg
    AFTER DELETE ON books
    BEGIN
        DELETE FROM books_authors_link WHERE book=OLD.id;
        DELETE FROM books_publishers_link WHERE book=OLD.id;
        DELETE FROM books_tags_link WHERE book=OLD.id;
        DELETE FROM books_series_link WHERE book=OLD.id;
        DELETE FROM books_languages_link WHERE book=OLD.id;
        DELETE FROM books_ratings_link WHERE book=OLD.id;
        DELETE FROM data WHERE book=OLD.id;
        DELETE FROM comments WHERE book=OLD.id;
        DELETE FROM conversion_options WHERE book=OLD.id;
        DELETE FROM identifiers WHERE book=OLD.id;
    END;

CREATE TRIGGER books_insert_trg
    AFTER INSERT ON books
    BEGIN
        UPDATE books SET sort=title_sort(NEW.title),uuid=uuid4() WHERE id=NEW.id;
    END;

CREATE TRIGGER books_update_trg
    AFTER UPDATE ON books
    BEGIN
        UPDATE books SET sort=title_sort(NEW.title) WHERE id=NEW.id AND OLD.title <> NEW.title;
    END;

PRAGMA user_version=30;
EOF

    # Set proper permissions
    chmod 664 /books/metadata.db
    chown abc:abc /books/metadata.db 2>/dev/null || true
    
    echo "Empty Calibre database created successfully at /books/metadata.db"
else
    echo "Calibre database already exists at /books/metadata.db"
fi
