#!/bin/bash
set -e

function create_user_and_database() {
  local database=$1
  echo "  Creating user and database '$database'"
  
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
      CREATE USER $database WITH PASSWORD 'Aa123456';
      CREATE DATABASE $database OWNER $database; 
EOSQL

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$database" <<-EOSQL
      GRANT ALL ON SCHEMA public TO $database;
      ALTER SCHEMA public OWNER TO $database;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $database;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $database;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $database;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $database;
EOSQL
}
create_user_and_database "note_service"
create_user_and_database "user_service"