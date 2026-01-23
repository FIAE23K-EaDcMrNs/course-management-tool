# ORDS REST API

This document describes how ORDS AutoREST is configured and how to use the REST endpoints.

## Setup

All tables are automatically enabled via [scripts/ords/enable_tables.sql](scripts/ords/enable_tables.sql) during container startup. The `db-setup` service runs this automatically.

**Files:**
- `scripts/ords/enable_tables.sql` - Enables ORDS for schema and all tables

## Authentication

All endpoints require HTTP Basic Auth (`p_auto_rest_auth => TRUE`) with username and password.

**To disable auth** (not recommended for production), change `p_auto_rest_auth => FALSE` in enable_tables.sql.

## REST Endpoints

All tables are available at `/ords/api/{tablename}/`

## Date/Timestamp Format

Use ISO 8601 with timezone:
- DATE: `"2026-02-15T00:00:00Z"`
- TIMESTAMP: `"2026-02-15T09:00:00Z"`

## Custom Logic

**Important:** Custom handlers with matching URL patterns **override AutoREST** for that specific HTTP method.

### Approach 1: PL/SQL Packages (Recommended)

Place business logic in PL/SQL packages for maintainability and reusability.

**1. Define package specification in** [scripts/sql/dev_pkg.pks](scripts/sql/dev_pkg.pks):
```sql
CREATE OR REPLACE PACKAGE dev_pkg AS
  PROCEDURE create_firma_validated(
    p_firma_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_adresse IN VARCHAR2,
    p_kommentar IN VARCHAR2 DEFAULT NULL,
    p_firma_id OUT NUMBER
  );
END dev_pkg;
/
```

**2. Implement package body in** [scripts/sql/dev_pkg.pkb](scripts/sql/dev_pkg.pkb):
```sql
CREATE OR REPLACE PACKAGE BODY dev_pkg AS
  PROCEDURE create_firma_validated(
    p_firma_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_adresse IN VARCHAR2,
    p_kommentar IN VARCHAR2 DEFAULT NULL,
    p_firma_id OUT NUMBER
  ) IS
  BEGIN
    -- Business validation
    IF p_email LIKE '%@invalid.com' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid email domain');
    END IF;

    -- Insert with validation passed
    INSERT INTO firma (firma_name, email, rechnungs_adresse, kommentar)
    VALUES (p_firma_name, p_email, p_adresse, p_kommentar)
    RETURNING firma_id INTO p_firma_id;
  END create_firma_validated;
END dev_pkg;
/
```

**3. Create ORDS handler in** `scripts/ords/custom_handlers.sql`:
```sql
BEGIN
  ORDS.DEFINE_HANDLER(
    p_module_name => 'api',
    p_pattern => 'firma/',
    p_method => 'POST',
    p_source => q'[
DECLARE
  v_firma_id NUMBER;
BEGIN
  dev_pkg.create_firma_validated(
    p_firma_name => :firma_name,
    p_email => :email,
    p_adresse => :rechnungs_adresse,
    p_kommentar => :kommentar,
    p_firma_id => v_firma_id
  );
  :status := 201;
  HTP.p('{"firma_id": ' || v_firma_id || '}');
EXCEPTION
  WHEN OTHERS THEN
    :status := 400;
    HTP.p('{"error": "' || SQLERRM || '"}');
END;
    ]'
  );
END;
/
```

**Result:**
- POST → Custom handler (your logic)
- GET/PUT/DELETE → AutoREST (standard behavior)

## Excluding Tables

To skip AutoREST for a table, add it to `v_skip_list` in enable_tables.sql:
```sql
v_skip_list t_name_tab := t_name_tab('MY_TABLE', 'ANOTHER_TABLE');
```

## Troubleshooting

- **404:** Check URL has trailing slash (`/firma/` not `/firma`)
- **401:** Verify credentials
- **Custom handler not working:** Check db-setup logs for deployment errors
