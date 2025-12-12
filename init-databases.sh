#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE alpha_tech_db;
    CREATE DATABASE location_db;
    CREATE DATABASE notifications_db;
    
    GRANT ALL PRIVILEGES ON DATABASE alpha_tech_db TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE location_db TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE notifications_db TO $POSTGRES_USER;
EOSQL

echo "✅ Databases created successfully!"