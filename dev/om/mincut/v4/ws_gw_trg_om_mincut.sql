/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

/*

CREATE TRIGGER gw_trg_om_mincut
  AFTER UPDATE OF streetaxis_id
  ON SCHEMA_NAME.om_mincut
  FOR EACH ROW
  EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_om_mincut();

update om_mincut SET streetaxis_id = streetaxis_id;

*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

CREATE OR REPLACE FUNCTION gw_trg_om_mincut()
  RETURNS trigger AS
$BODY$
DECLARE 
v_streetaxis_id text;
v_name text;
v_muni_id integer;

-- temporary mincut to solve bug on 3.4.026 on streetaxis <-> streetname

BEGIN
	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	SELECT value::json->>'sys_search_field' INTO v_name FROM config_param_system WHERE parameter = 'basic_search_street';
	v_streetaxis_id = NEW.streetaxis_id;
	v_muni_id = NEW.muni_id;

	IF v_streetaxis_id IS NOT NULL AND v_name IS NOT NULL THEN
		
		EXECUTE 'SELECT id FROM ext_streetaxis WHERE '||v_name||' = $$'||v_streetaxis_id||'$$ AND muni_id = '||v_muni_id||''
			INTO v_streetaxis_id;
			
		IF v_streetaxis_id != NEW.streetaxis_id THEN
			UPDATE om_mincut SET streetaxis_id = v_streetaxis_id WHERE id = NEW.id;
		END IF;
	END IF;

	RETURN NEW;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION SCHEMA_NAME.gw_trg_om_mincut() TO public;
GRANT EXECUTE ON FUNCTION SCHEMA_NAME.gw_trg_om_mincut() TO bgeoadmin;
GRANT EXECUTE ON FUNCTION SCHEMA_NAME.gw_trg_om_mincut() TO role_basic;
GRANT EXECUTE ON FUNCTION SCHEMA_NAME.gw_trg_om_mincut() TO role_master;