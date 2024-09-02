require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const axios = require('axios');
const app = express();
const cors = require('cors');
app.use(cors());
const port = process.env.NODE_PORT || 5000;

app.use(express.json());

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

// Keyword Search Endpoint
app.post('/search', async (req, res) => {
    const { query, field } = req.body;

    if (!query || !field) {
        return res.status(400).json({ error: 'Query and field cannot be empty' });
    }

    const sqlQuery = `
        SELECT m.id, m.title, m.author, m.category, mc.id AS content_id, mc.content, mc.vector_representation
        FROM magazines m
        JOIN magazine_content mc ON m.id = mc.magazine_id
        WHERE to_tsvector('english', m.${field}) @@ plainto_tsquery($1)
    `;

    try {
        const result = await pool.query(sqlQuery, [query]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'No keyword search results found.' });
        }
        return res.json(result.rows);
    } catch (error) {
        console.error('Keyword search failed:', error.message);
        return res.status(500).json({ error: 'Keyword search failed.' });
    }
});

// Hybrid Search Endpoint
app.post('/hybrid-search', async (req, res) => {
    const { query, field } = req.body;

    if (!query || !field) {
        return res.status(400).json({ error: 'Query and field cannot be empty' });
    }

    try {
        // Step 1: Perform Keyword Search
        console.log('Performing keyword search...');
        const keywordResults = await axios.post('http://localhost:5001/search', { query, field });
        if (keywordResults.data.length === 0) {
            return res.status(404).json({ error: 'No keyword search results found.' });
        }

        // Step 2: Perform Vector Search for the query itself
        console.log('Vectorizing content...');
        const vectorResult = await axios.post('http://localhost:5001/vectorise', { content: [query] });
        const queryVector = vectorResult.data[0];

        // Step 3: Calculate Vector Similarity for each of the keyword search results
        const combinedResults = keywordResults.data.map(result => {
            const contentVector = result.vector_representation;
            const similarity = cosineSimilarity(queryVector, contentVector);
            return {
                ...result,
                vector_similarity: similarity
            };
        });

        // Sort by vector similarity in descending order
        combinedResults.sort((a, b) => b.vector_similarity - a.vector_similarity);

        return res.json({ combinedResults });
    } catch (error) {
        console.error('Hybrid search failed:', error.message);
        return res.status(500).json({ error: 'Hybrid search failed.' });
    }
});

// Function to calculate cosine similarity between two vectors
function cosineSimilarity(vec1, vec2) {
    const dotProduct = vec1.reduce((acc, val, i) => acc + (val * vec2[i]), 0);
    const magnitudeA = Math.sqrt(vec1.reduce((acc, val) => acc + (val * val), 0));
    const magnitudeB = Math.sqrt(vec2.reduce((acc, val) => acc + (val * val), 0));
    return dotProduct / (magnitudeA * magnitudeB);
}

// Start the Express server
app.listen(port, () => {
    console.log(`Server is up and running on port ${port}`);
});
