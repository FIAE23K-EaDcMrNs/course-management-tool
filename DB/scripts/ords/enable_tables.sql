-- Enable ORDS for current schema and all tables (idempotent)
-- Run this as the schema owner (the user created by DB/init/db_init.sh)
SET SERVEROUTPUT ON;
DECLARE
  v_schema VARCHAR2(128) := USER;
  TYPE t_name_tab IS TABLE OF VARCHAR2(128);
  v_skip_list t_name_tab := t_name_tab(); -- add uppercase table names here to exclude
BEGIN
  BEGIN
    ORDS.ENABLE_SCHEMA(
      p_enabled => TRUE,
      p_schema => v_schema,
      p_url_mapping_type => 'BASE_PATH',
      p_url_mapping_pattern => 'api',
      p_auto_rest_auth => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('ORDS.ENABLE_SCHEMA called for '||v_schema);
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ENABLE_SCHEMA error: '||SQLERRM);
  END;

  FOR r IN (SELECT table_name FROM user_tables) LOOP
    DECLARE
      v_skip BOOLEAN := FALSE;
    BEGIN
      FOR i IN 1..v_skip_list.COUNT LOOP
        IF v_skip_list(i) = r.table_name THEN
          v_skip := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF v_skip THEN
        DBMS_OUTPUT.PUT_LINE('Skipping '||r.table_name);
      ELSE
        BEGIN
          ORDS.ENABLE_OBJECT(
            p_enabled => TRUE,
            p_schema => v_schema,
            p_object => r.table_name,
            p_object_type => 'TABLE',
            p_object_alias => LOWER(r.table_name),
            p_auto_rest_auth => TRUE
          );
          DBMS_OUTPUT.PUT_LINE('Enabled '||r.table_name);
        EXCEPTION WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('ENABLE_OBJECT '||r.table_name||' error: '||SQLERRM);
        END;
      END IF;
    END;
  END LOOP;

  COMMIT;
END;
/
