-- Create the database if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_database 
        WHERE datname = 'Magazine_DB') THEN
        PERFORM dblink_exec('CREATE DATABASE Magazine_DB');
    END IF;
END $$;

-- Connect to the database
\c your_database_name;

-- Create the magazines table
CREATE TABLE IF NOT EXISTS magazines (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    publication_date DATE
);

-- Create the magazine_content table
CREATE TABLE IF NOT EXISTS magazine_content (
    id SERIAL PRIMARY KEY,
    magazine_id INT REFERENCES magazines(id),
    content TEXT NOT NULL,
    vector_representation FLOAT8[]  -- Assuming you store vectors as arrays of floats
);

-- Create indexes for efficient querying
CREATE INDEX idx_magazines_title ON magazines(title);
CREATE INDEX idx_magazines_author ON magazines(author);
CREATE INDEX idx_magazines_category ON magazines(category);
CREATE INDEX idx_magazine_content_content ON magazine_content USING GIN (to_tsvector('english', content));

