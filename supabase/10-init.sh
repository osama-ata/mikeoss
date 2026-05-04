#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  DO \$\$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
      CREATE ROLE supabase_admin LOGIN SUPERUSER PASSWORD '$POSTGRES_PASSWORD';
    ELSE
      ALTER ROLE supabase_admin WITH LOGIN SUPERUSER PASSWORD '$POSTGRES_PASSWORD';
    END IF;
  END
  \$\$;
EOSQL
