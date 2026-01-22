#!/bin/sh

echo 'Waiting for Oracle database to finish setup...'
sleep 20

echo 'Creating application user...'
sqlplus sys/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_SERVICE};

CREATE USER ${APP_USER} IDENTIFIED BY ${APP_PASSWORD} DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE, CREATE VIEW TO ${APP_USER};
GRANT PDB_DBA TO ${APP_USER};

exit;
EOF

echo 'Seeding data...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/sql/tables.sql

echo 'Add package specs...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/sql/package_specs.pks

echo 'Add package bodies...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/sql/package_bodies.pkb

echo 'Waiting for ORDS HTTP service to be ready...'
MAX_ATTEMPTS=60
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))
  echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Checking if ORDS HTTP service is ready..."

  # Try to reach ORDS HTTP endpoint
  if wget -q --spider http://ords:8080/ords 2>/dev/null || curl -sf http://ords:8080/ords >/dev/null 2>&1; then
    echo "ORDS HTTP service is responding!"
    # Give it a few more seconds to ensure DB objects are installed
    sleep 5
    break
  fi

  if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "ERROR: ORDS did not become ready in time"
    exit 1
  fi

  sleep 2
done

echo 'Enable table access via ords...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/ords/enable_tables.sql

echo 'Enable custom handlers...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/ords/handlers.sql

echo 'Database setup completed successfully'
