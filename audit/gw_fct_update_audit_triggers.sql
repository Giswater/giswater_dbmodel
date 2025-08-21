/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

CREATE OR REPLACE FUNCTION PARENT_SCHEMA.gw_fct_update_audit_triggers()
  RETURNS json AS
$BODY$

--FUNCTION CODE: 3408
/*
SELECT PARENT_SCHEMA.gw_fct_update_audit_triggers()
*/

DECLARE

v_schemaname text;
table_record record;
prefix text;

BEGIN

	SET search_path = "PARENT_SCHEMA", public;
	v_schemaname = 'PARENT_SCHEMA';

	FOR table_record IN SELECT * FROM sys_table
	LOOP

		EXECUTE 'DROP TRIGGER IF EXISTS gw_trg_audit_'||table_record.id||' ON '||v_schemaname||'.'||table_record.id;

		IF table_record.isaudit IS TRUE THEN

			prefix := CASE WHEN table_record.id SIMILAR TO 've_%|v_e%' THEN 'INSTEAD OF' ELSE 'AFTER' END;

			IF table_record.id = ANY('{node, arc, connec, link, gully}'::text[]) THEN
				EXECUTE 'CREATE TRIGGER gw_trg_audit_'||table_record.id||' AFTER UPDATE OF the_geom ON 
				'||v_schemaname||'.'||table_record.id||' FOR EACH ROW EXECUTE PROCEDURE '||v_schemaname||'.gw_trg_audit()';
			ELSIF table_record.id = ANY('{v_edit_node, v_edit_arc, v_edit_connec, v_edit_link, v_edit_gully}'::text[]) THEN
				EXECUTE 'CREATE TRIGGER gw_trg_audit_'||table_record.id||' '||prefix||' INSERT OR DELETE ON 
				'||v_schemaname||'.'||table_record.id||' FOR EACH ROW EXECUTE PROCEDURE '||v_schemaname||'.gw_trg_audit()';
			ELSE
				EXECUTE 'CREATE TRIGGER gw_trg_audit_'||table_record.id||' '||prefix||' UPDATE ON 
				'||v_schemaname||'.'||table_record.id||' FOR EACH ROW EXECUTE PROCEDURE '||v_schemaname||'.gw_trg_audit()';
			END IF;
		END IF;
	END LOOP;

	-- Return JSON
	RETURN jsonb_build_object(
	        'status', 'Accepted'
	    );

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
