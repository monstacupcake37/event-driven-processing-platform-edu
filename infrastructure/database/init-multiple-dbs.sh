#!/bin/bash
set -e
set -u

# Function to create a database and user
create_db_and_user() {
    local database=$1
    local user=$2
    local password=$3

    echo "  Creating user and database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${user}') THEN
                CREATE ROLE "${user}" LOGIN PASSWORD '${password}';
            END IF;
            IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '${database}') THEN
                   CREATE DATABASE "${database}" WITH OWNER = "${user}";
                   GRANT ALL PRIVILEGES ON DATABASE "${database}" TO "${user}";
            END IF;
        END
        \$\$;
EOSQL
}

# Read the semicolon-separated list of databases from the environment variable
if [ -n "${POSTGRES_MULTIPLE_DATABASES:-}" ]; then
    echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
    IFS=',' read -ra DBS <<< "$POSTGRES_MULTIPLE_DATABASES"
    for db_def in "${DBS[@]}"; do
        # Expected format: "database:user:password"
        IFS=':' read -r db user password <<< "$db_def"
        create_db_and_user "$db" "$user" "$password"
    done
    echo "All databases and users created"
fi