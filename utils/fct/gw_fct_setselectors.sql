/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2870

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_api_setselectors (json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setselectors(p_data json)
  RETURNS json AS
$BODY$

/*example
SELECT SCHEMA_NAME.gw_fct_setselectors($${"client":{"device":9, "infoType":100, "lang":"ES"},"feature":{},"data":{"selector_type":"exploitation", "check":true, "mode":"expl_from_muni", "id":1}}$$)
*/

DECLARE
--	Variables
	api_version json;
	v_selector_type text;
	v_id text;
	v_check boolean;
	v_mode text;
	v_tablename text;
	v_expl integer;
	v_muni integer;
	
BEGIN

	-- Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	
	-- get input parameters:
	v_selector_type := (p_data ->> 'data')::json->> 'selector_type';
	v_id := (p_data ->> 'data')::json->> 'id';
	v_check := (p_data ->> 'data')::json->> 'check';
	v_mode := (p_data ->> 'data')::json->> 'mode';
	v_muni := (p_data ->> 'data')::json->> 'id';


	-- get expl from muni
	IF v_mode = 'expl_from_muni' THEN
		v_expl = (SELECT expl_id FROM exploitation e, ext_municipality m WHERE st_dwithin(st_centroid(e.the_geom), m.the_geom, 0) AND muni_id = v_muni);
		EXECUTE 'DELETE FROM selector_expl WHERE cur_user = current_user';
		EXECUTE 'INSERT INTO selector_expl (expl_id, cur_user) VALUES('|| v_expl ||', '''|| current_user ||''')';	
	END IF;

	-- control nulls;
	api_version = '{}';
	
	-- Return
	RETURN ('{"status":"Accepted", "apiVersion":'||api_version||
			',"body":{"message":{"priority":1, "text":"This is a test message"}'||
			',"form":{"formName":"", "formLabel":"", "formText":""'||
			',"formActions":[]}'||
			',"feature":{}'||
			',"data":{"indexingLayers": {"exploitation": ["v_edit_arc", "v_edit_node", "v_edit_connec", "v_edit_element"] }}}'||'}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  