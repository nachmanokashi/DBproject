CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER partner_project_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'db.yfhppwafacypztahkvlx.supabase.co', port '5432', dbname 'postgres');

CREATE USER MAPPING FOR postgres
SERVER partner_project_server
OPTIONS (user 'postgres', password 'Project Integration 1');

CREATE FOREIGN TABLE IF NOT EXISTS partner_personnel (
    id INT,
    name VARCHAR(50),
    email VARCHAR(50),
    phone_number VARCHAR(50),
    role VARCHAR(50)
)
SERVER partner_project_server
OPTIONS (schema_name 'public', table_name 'personnel');

CREATE FOREIGN TABLE IF NOT EXISTS partner_ammunition (
    id INT,
    type VARCHAR(255),
    location_id INT,
    quantity VARCHAR(50),
    date_added DATE
) 
SERVER partner_project_server 
OPTIONS (schema_name 'public', table_name 'ammunition');