#!/bin/bash
set -e

function create_user_and_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
	    CREATE USER $database WITH PASSWORD 'Aa123456';
	    CREATE DATABASE $database;
EOSQL
}
create_user_and_database "note_service"
create_user_and_database "user_service"
