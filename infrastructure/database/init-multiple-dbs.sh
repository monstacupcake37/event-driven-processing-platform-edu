#!/bin/bash
set -e
set -u

create_db_and_user() {
    local database=$1
    local user=$2
    local password=$3

    echo "  Creating user '$user' and database '$database'"

    # Create role if it does not exist (works on ALL PostgreSQL versions)
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (
                SELECT FROM pg_catalog.pg_roles WHERE rolname = '${user}'
            ) THEN
                CREATE ROLE "${user}" LOGIN PASSWORD '${password}';
            END IF;
        END \$\$;
EOSQL

    # Check if database exists
    DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -tAc \
        "SELECT 1 FROM pg_database WHERE datname = '${database}'" 2>/dev/null)

    if [ "$DB_EXISTS" = "1" ]; then
        echo "    Database '$database' already exists, skipping creation."
    else
        echo "    Creating database '$database'"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
            CREATE DATABASE "${database}" OWNER "${user}";
            GRANT ALL PRIVILEGES ON DATABASE "${database}" TO "${user}";
EOSQL
    fi
}

# Основная логика
if [ -n "${POSTGRES_MULTIPLE_DATABASES:-}" ]; then
    echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
    IFS=',' read -ra DBS <<< "$POSTGRES_MULTIPLE_DATABASES"
    for db_def in "${DBS[@]}"; do
        IFS=':' read -r db user password <<< "$db_def"
        create_db_and_user "$db" "$user" "$password"
    done
    echo "All databases and users processed"
fi