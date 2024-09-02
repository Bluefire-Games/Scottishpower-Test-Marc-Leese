# Hybrid Search API

## Overview

The Hybrid Search API is designed to combine traditional keyword-based search with vector-based similarity search. It is optimized to handle large datasets, providing efficient, 
relevant search results for magazine-related content. The API utilizes Node.js for managing the backend server, 
Python's Flask framework for vector-based operations, and PostgreSQL for data storage.

This document provides all the steps necessary to set up, run, and test the API without requiring additional documentation.

## Prerequisites

Before starting, ensure you have the following installed:

- **Node.js** v18 or greater
- **Python** 3.x (3.12 was used for development)
- **PostgreSQL** 12 or greater

## Project Structure

/project-root
│
├── /hybrid-search-api
│   ├── /node_modules               # Node.js dependencies (auto-generated)
│   ├── /Search_Env                 # Python virtual environment (auto-generated)
│   ├── /scripts                    # Scripts for setup and running the application
│   │   ├── setup.sh                # Script to set up the environment
│   │   ├── run.sh                  # Script to start the services
│   ├── index.js                    # Node.js API entry point
│   ├── package.json                # Node.js dependencies configuration
│   ├── package-lock.json           # Node.js dependencies lockfile
│   ├── semantic_search.py          # Python Flask service for vector search
│   ├── requirements.txt            # Python dependencies list
│   ├── .env                        # Environment variables
│
├── /Files for table
│   ├── schema.sql                  # SQL schema for table creation
│   ├── load_data.sql               # SQL script to load CSV data into tables
│   ├── Magazines.csv               # Sample data for magazines
│   ├── Magazine-Content-Formatted.csv # Sample data for magazine content
│
├── README.md                       # This setup guide and project overview
└── /docs                           # Documentation files



Setup Instructions

1. Extract the Project Files

Extract the provided ZIP file to a directory on your computer.
Navigate to the hybrid-search-api directory where the project is located.

Step 2: Create Environment Configuration
Open the .env file and change the values to ones that will suit your needs (I recommend keeping DB_NAME the same for testing this API)

Edit the .env file to match your database configuration and desired port numbers:
DB_USER=postgres
DB_HOST=localhost
DB_NAME=Magazine_DB
DB_PASSWORD=yourpassword
DB_PORT=5432
FLASK_PORT=5001
NODE_PORT=5000


Step 3: Run the Setup Script
setup.bat (this is in the \hybrid-search-api\Scripts folder) 

Step 4: Start the Services
run.bat

This will start:
The Python Flask service on http://127.0.0.1:5001
The Node.js API server on http://127.0.0.1:5000

Step 5: open the front end
go to the root of the project and in the front end folder open index.html (This is a simple front end just for testing purposes and wouldnt be used in a production environment.)



DATABASE Setup:
If you are using PG admin skip to step 5

1. Creating the Database and Tables
open your terminal (cmd on windows) and type the following 
psql -U your_username -h your_host -d your_database
Replace your_username, your_host and your_database with the appropriate values 

2. If your PostgreSQL user has superuser privileges, switch to the default database (usually postgres) by typing:
\c postgres;

3. Then, run the SQL block:
-- Step 1: Create the database if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_database 
        WHERE datname = 'Magazine_DB') THEN
        PERFORM dblink_exec('CREATE DATABASE Magazine_DB');
    END IF;
END $$;

-- Step 2: Connect to the newly created or existing database
\c Magazine_DB;

-- Step 3: Create the magazines table
CREATE TABLE IF NOT EXISTS magazines (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    publication_date DATE
);

-- Step 4: Create the magazine_content table
CREATE TABLE IF NOT EXISTS magazine_content (
    id SERIAL PRIMARY KEY,
    magazine_id INT REFERENCES magazines(id),
    content TEXT NOT NULL,
    vector_representation FLOAT8[]  -- Assuming you store vectors as arrays of floats
);

-- Step 5: Create indexes for efficient querying
CREATE INDEX idx_magazines_title ON magazines(title);
CREATE INDEX idx_magazines_author ON magazines(author);
CREATE INDEX idx_magazines_category ON magazines(category);
CREATE INDEX idx_magazine_content_content ON magazine_content USING GIN (to_tsvector('english', content));

-- Step 6: Populate the magazines table
COPY magazines(id, title, author, publication_date, category)
FROM 'D:/Scottishpower Test Marc Leese/Files for table/Magazines.csv' DELIMITER ',' CSV HEADER;

-- Step 7: Populate the magazine_content table
COPY magazine_content(id, magazine_id, content, vector_representation)
FROM 'D:/Scottishpower Test Marc Leese/Files for table/Magazine-Content-Formatted.csv' DELIMITER ',' CSV HEADER;

Replace D:/Scottishpower Test Marc Leese/Files for table/Magazine-Content-Formatted.csv and D:/Scottishpower Test Marc Leese/Files for table/Magazines.csv with your path


4. Using PG admin
Open pgAdmin and connect to your PostgreSQL server.
Right-click on the Databases section and select Query Tool.
Copy the entire SQL block into the query editor.
Click the Execute/Run button (usually a lightning bolt icon).
The database will be created if it doesn’t exist.



Testing the API
Endpoint 1: /vectorize
This endpoint is used to vectorize content using the pre-trained sentence transformer model.

Example Request:
POST http://localhost:5001/vectorise
Content-Type: application/json

{
  "content": ["The quick brown fox jumps over the lazy dog."]
}
Result:

[
    0.5897934436798096,-0.23598308861255646,-0.2541167140007019,0.003116140840575099,-0.08485689014196396,
    -0.2679974138736725,-0.07506648451089859,-0.30021384358406067,0.05151677504181862,0.1658535897731781,
    0.26076725125312805,0.38256385922431946,0.43732890486717224,-0.09301937371492386,-0.2656879723072052,
    -0.09716276079416275,-0.48096099495887756,0.11878304928541183,0.13675503432750702,0.04712088778614998,
    -0.23696553707122803,-0.5233239531517029,-0.016318397596478462,0.06127287447452545,-0.7433300018310547,
    -0.11898887902498245,-0.7886528968811035,-0.4810882806777954,0.1031491830945015,-0.32372456789016724,
    0.8144371509552002,-0.3977454900741577,-0.5031558871269226,-0.7972459197044373,-0.6324825286865234,
    0.323209285736084,-0.3841944634914398,-0.11186670511960983,-0.13243572413921356,0.020697034895420074,
    -0.14309529960155487,-0.03701182082295418,0.061166416853666306,0.1633288413286209,-0.1117430105805397,
    0.25234225392341614,-1.0464072227478027,-0.3725236654281616,0.15602000057697296,-0.2999158501625061,
    0.1988389641046524,0.23433417081832886,-0.37025800347328186,0.31733617186546326,0.8442861437797546,
    0.06977701932191849,0.032736293971538544,0.09948313236236572,-0.31141331791877747,0.5051775574684143,
    0.0030926913022994995,0.38013675808906555,0.045827433466911316,0.006333847995847464,-0.0014294559368863702,
    -0.13568665087223053,-0.07611367851495743,-0.25844284892082214,-0.8022129535675049,0.5508587956428528,
    -0.09124394506216049,-0.21782028675079346,-0.7881090641021729,-0.5118382573127747,0.46672508120536804,
    0.5527475476264954,-0.37124690413475037,-0.18645362555980682,0.3585696518421173,-0.19586311280727386,
    0.18042528629302979,-0.4254889488220215,-0.09681398421525955,-0.05536789074540138,0.5248926281929016,
    0.24481169879436493,0.01934639923274517,-0.2963791787624359,-0.1277782917022705,-0.3053494095802307,
    0.4534936249256134,0.07469143718481064,-0.07061678916215897,0.2624298632144928,0.3738393485546112,
    0.14306364953517914,0.0012790808686986566,-0.41776061058044434,-0.2401409149169922,-0.2509351074695587,
    0.3484373390674591,0.3114403784275055,0.08087346702814102,-0.5764054656028748,0.5408526659011841,
    -0.018021905794739723,-0.12959836423397064,-0.07399681955575943,0.3936976492404938,0.6488390564918518,
    -0.02029999904334545,-0.5665555596351624,0.2967599630355835,0.5200024247169495,0.215387225151062,
    0.10369690507650375,0.06199245527386665,0.018962765112519264,-0.1526918262243271,-1.0642660856246948,
    0.7614965438842773,0.20734380185604095,0.4471897780895233,0.14493970572948456,0.6580231189727783,
    -0.09440946578979492,-0.23316366970539093,0.42157045006752014,0.11957625299692154,-0.32571059465408325,
    0.16425557434558868,-0.4950866997241974,-0.19516108930110931,-0.5618324875831604,-0.1493328958749771,
    0.6109411716461182,-0.1789795160293579,-0.018055656924843788,-0.5964053273200989,0.0491860993206501,
    0.15347786247730255,-0.42829450964927673,0.7329527735710144,-0.35291096568107605,-0.11159622669219971,
    0.061278026551008224,-0.2970442473888397,0.439665824174881,-0.09660384058952332,0.6557945609092712,
    -0.6140339374542236,0.02576650120317936,0.4382748305797577,0.017332056537270546,-0.4000227451324463,
    -0.08178319782018661,-0.37126970291137695,0.08230256289243698,-0.13104397058486938,-0.5326111912727356,
    -0.2992834150791168,0.6993659138679504,-0.04398755729198456,-0.15703019499778748,0.09794113785028458,
    -0.030174599960446358,-0.10002680867910385,0.1999657303094864,-0.48188579082489014,0.17949147522449493,
    0.5656601786613464,-0.11954810470342636,-0.6963727474212646,0.05259646847844124,-0.0054963454604148865,
    0.1673932522535324,-0.31692883372306824,-0.09747572988271713,0.3319362699985504,0.4719962179660797,
    0.12653960287570953,0.19130933284759521,0.4294905662536621,0.5529118180274963,0.3146333396434784,
    -0.31433096528053284,-0.415086954832077,0.328977108001709,0.3570270538330078,-0.19209642708301544,
    0.22239422798156738,-0.4871788024902344,0.34091559052467346,-0.22137421369552612,-0.12667566537857056,
    0.2112082988023758,-0.31347915530204773,0.8468939661979675,0.20112670958042145,-0.42598751187324524,
    0.5131572484970093,-1.235141634941101,0.7697179317474365,-0.17414242029190063,-0.0218112301081419,
    -0.035686738789081573,-1.1059490442276,-0.572065532207489,0.05585202947258949,0.12461494654417038,
    -0.45065903663635254,0.06429027765989304,-0.16033829748630524,0.399329274892807,-0.10322921723127365,
    -0.020254969596862793,-0.18010492622852325,0.06234771013259888,-0.0218887310475111,-0.15795418620109558,
    0.28316986560821533,0.0238527599722147,0.03098154626786709,-0.0785328671336174,0.29896530508995056,
    -0.0623730830848217,0.5498680472373962,0.17862294614315033,0.21164752542972565,0.4448334276676178,
    0.048907410353422165,-0.16238100826740265,-0.226698637008667,0.1887199878692627,0.07943610101938248,
    0.1359758973121643,-0.184844970703125,1.1135510206222534,0.8280949592590332,-0.3120274245738983,
    0.09505999088287354,0.05096055194735527,0.3880488872528076,0.2500045597553253,0.5584861636161804,
    0.31088787317276,-0.05318598821759224,-0.07675360888242722,0.15282292664051056,0.09189959615468979,
    -0.014291584491729736,0.6657542586326599,-0.033460136502981186,-0.44703492522239685,0.8006748557090759,
    -0.4799281060695648,0.17478179931640625,-0.30563825368881226,0.5536524653434753,0.42380955815315247,
    0.486743301153183,-0.4967796802520752,-0.45194801688194275,-0.9556310176849365,-0.20709967613220215,
    -0.226057767868042,-0.009991698898375034,0.9879765510559082,0.5880774855613708,0.08305483311414719,
    -0.5578135848045349,0.21136845648288727,-0.360722154378891,0.5266848206520081,0.33983567357063293,
    -0.1575617641210556,0.004237315151840448,-0.053545206785202026,-0.5777674317359924,0.5595102906227112,
    -0.05747128650546074,0.16837705671787262,0.3794686496257782,-0.2577643096446991,0.08421474695205688,
    -0.1522994488477707,-0.03280768170952797,0.10083853453397751,-0.41858330368995667,-0.4449901878833771,
    -0.29309919476509094,0.6144210696220398,0.08548154681921005,-0.06349573284387589,-0.6152553558349609,
    0.7954409718513489,-0.24058401584625244,0.20638878643512726,-0.5125259160995483,0.6312013864517212,
    0.367443323135376,-0.4400986433029175,0.4691399037837982
]


Endpoint 2: /search
This endpoint is used to perform vector-based search across the vectors stored in the database.

Example Request:
POST http://localhost:5001/search
Content-Type: application/json

{
  "query_vector": [0.123456789, -0.987654321, 0.456789123],
  "content_vectors": [
    [0.123456789, -0.987654321, 0.456789123],
    [-0.234567890, 0.876543210, -0.567890123]
  ]
}

Expected Response:
[
    0.9999999999999999,
    -0.9844646035836604
]


Endpoint 3: /hybrid-search
This endpoint combines keyword-based search with vector-based similarity search.

POST http://localhost:5000/hybrid-search
Content-Type: application/json

{
  "query": "Rebeca Beverage",
  "field": "author" 
  # Other options for "field":
  # "author" - Searches within the 'author' field.
  # "category" - Searches within the 'category' field.
  # "content" - Searches within the 'content' field.
}

Expected Response:
{
    "combinedResults": [
        {
            "id": 41,
            "title": "Come and Get It",
            "author": "Rebeca Beverage",
            "category": "Health",
            "content": "Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.",
            "similarity": 0.16469670631239405
        },
        {
            "id": 819,
            "title": "Come and Get It",
            "author": "Rebeca Beverage",
            "category": "Health",
            "content": "Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.",
            "similarity": 0.16163383682720328
        },
        {
            "id": 807,
            "title": "Come and Get It",
            "author": "Rebeca Beverage",
            "category": "Health",
            "content": "Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.",
            "similarity": 0.15745878994948154
        }
    ]
}



