#!/bin/sh

echo 'Waiting for Oracle database to finish setup...'
sleep 20

echo 'Checking if database has already been initialized...'
INIT_CHECK=$(sqlplus -s sys/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
WHENEVER SQLERROR EXIT 1
ALTER SESSION SET CONTAINER = ${ORACLE_SERVICE};
SELECT initialized FROM init_status WHERE id = 1;
EXIT;
EOF
)

if [ $? -eq 0 ] && echo "$INIT_CHECK" | grep -q "1"; then
  echo 'Database already initialized. Skipping setup.'
  exit 0
fi

echo 'Database not yet initialized. Proceeding with setup...'

echo 'Creating application user...'
sqlplus sys/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_SERVICE};

CREATE USER ${APP_USER} IDENTIFIED BY ${APP_PASSWORD} DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE, CREATE VIEW TO ${APP_USER};
GRANT PDB_DBA TO ${APP_USER};

exit;
EOF

echo 'Seeding data...'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/init_scripts/sql/seed_data.sql

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

echo 'Marking database as initialized...'
sqlplus sys/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_SERVICE};

CREATE TABLE init_status (
  id NUMBER(1) PRIMARY KEY,
  initialized NUMBER(1) NOT NULL,
  initialized_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO init_status (id, initialized) VALUES (1, 1);
COMMIT;
EXIT;
EOF

echo 'Database setup completed successfully'
