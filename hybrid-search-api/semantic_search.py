import os
import psycopg2
from psycopg2.extras import RealDictCursor
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from sentence_transformers import SentenceTransformer

app = Flask(__name__)
CORS(app)

# Load the pre-trained SentenceTransformer model
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

# Define the function to get the database connection
def get_db_connection():
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )
    return conn

@app.route('/vectorise', methods=['POST'])
def vectorise():
    content = request.json.get('content')
    if not content:
        return jsonify({"error": "No content provided"}), 400
    vectors = model.encode(content)
    return jsonify(vectors.tolist())

@app.route('/search', methods=['POST'])
def search():
    query = request.json.get('query')
    field = request.json.get('field')

    if not query or not field:
        return jsonify({"error": "Query and field cannot be empty"}), 400

    sql_query = f"""
    SELECT * 
    FROM magazines m 
    JOIN magazine_content mc ON m.id = mc.magazine_id 
    WHERE to_tsvector('english', m.{field}) @@ plainto_tsquery(%s)
    """

    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(sql_query, (query,))
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        error_msg = f"An error occurred: {str(e)}"
        print(error_msg)
        return jsonify({"error": error_msg}), 500

if __name__ == '__main__':
    port = int(os.getenv("FLASK_PORT", 5001))  # Default to 5001 if FLASK_PORT is not set
    app.run(host='127.0.0.1', port=port)
