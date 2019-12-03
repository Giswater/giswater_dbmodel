/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: xxxx


CREATE OR REPLACE FUNCTION gw_api_setvehicleparameter(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE

SELECT SCHEMA.gw_api_getvisitmanager($${"client":{"device":3,"infoType":0,"lang":"ca"},"feature":{},"form":{},"data":{"fields":{"user_id":"test","team_id":"4","lot_id":"40", "vehicle_id":"vehicle2", "load":"90", },"deviceTrace":{"xcoord":null,"ycoord":null,"compass":null},"pageInfo":null}}$$) AS result

*/

DECLARE
	v_tablename text;
	v_apiversion text;
	v_id integer;
	v_message json;
	v_feature json;
	v_geometry json;
	v_thegeom public.geometry;
	v_version varchar;
	v_client json;
	v_user_id text;
	v_team_id text;
	v_lot_id text;
	v_vehicle_name text;
	v_load text;
	v_vehicle_id integer;
	

BEGIN

-- Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;

--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO v_apiversion;

    EXECUTE 'SELECT wsoftware FROM version'
	INTO v_version;
	
--  get input values
    v_client = (p_data ->>'client')::json;
    v_user_id = ((p_data ->>'data')::json->>'fields')::json->>'user_id';
    v_team_id = ((p_data ->>'data')::json->>'fields')::json->>'team_id';	
    v_lot_id = ((p_data ->>'data')::json->>'fields')::json->>'lot_id';	
    v_vehicle_name = ((p_data ->>'data')::json->>'fields')::json->>'vehicle_id';	
    v_load = ((p_data ->>'data')::json->>'fields')::json->>'load';	
    
	EXECUTE 'SELECT id FROM ext_cat_vehicle WHERE idval = '''|| v_vehicle_name ||'''' INTO v_vehicle_id;

	
	EXECUTE 'INSERT INTO om_vehicle_x_parameters (vehicle_id, lot_id, team_id, image, load, cur_user, tstamp) VALUES('''||v_vehicle_id||''','||v_lot_id::integer||','||v_team_id::integer||',null,'''||v_load||''','''||current_user||''','''||NOW()||''')';

	-- getting message
	SELECT gw_api_getmessage(v_feature, 40) INTO v_message;

	--  Control NULL's
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_message := COALESCE(v_message, '{}');
	v_geometry := COALESCE(v_geometry, '{}');
				  
--    Return

	RETURN ('{"status":"Accepted", "message":'||v_message||', "apiVersion":'|| v_apiversion ||', 
	"body": {}, "data":{}}')::json; 

      
--    Exception handling
   -- EXCEPTION WHEN OTHERS THEN 
    --    RETURN ('{"status":"Failed","message":' || to_json(SQLERRM) || ', "apiVersion":'|| v_apiversion ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;    

      

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

