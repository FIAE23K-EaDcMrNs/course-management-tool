#!/bin/sh

echo 'Waiting seconds for Oracle database to finish setup...'
sleep 20

echo 'Creating application user...'
sqlplus sys/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} as sysdba <<EOF
ALTER SESSION SET CONTAINER = ${ORACLE_SERVICE};

CREATE USER ${APP_USER} IDENTIFIED BY ${APP_PASSWORD} DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE, CREATE VIEW TO ${APP_USER};
GRANT PDB_DBA TO ${APP_USER};

exit;
EOF

echo 'Executing migration script as app user'
sqlplus ${APP_USER}/${APP_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE} @/scripts/migration.sql

echo 'Migration completed successfully'
