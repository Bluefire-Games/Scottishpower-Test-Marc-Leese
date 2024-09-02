copy magazines(id, title, author, publication_date, category)
FROM 'D:/Scottishpower Test Marc Leese/Files for table/Magazines.csv' DELIMITER ',' CSV HEADER;


COPY magazine_content(id, magazine_id, content, vector_representation)
FROM 'D:/Scottishpower Test Marc Leese/Files for table/Magazine-Content-Formatted.csv' DELIMITER ',' CSV HEADER;

