/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_json_create_return(p_data json, p_fnumber integer)
RETURNS json AS
$BODY$

/*
anadir 3 campos más a sys_function (layermanager, sytle, actions)
crear nueva tabla sys_style
*/
 
DECLARE


BEGIN

	-- Search path
	SET search_path = 'SCHEMA_NAME', public;

	-- get funcion specific keys
	v_layermanager = (SELECT layermanager FROM sys_function where id = p_fnumber);
	v_actions = (SELECT layermanager FROM sys_function where id = p_fnumber);
	v_style = (SELECT layermanager FROM sys_function where id = p_fnumber);

	-- layermanager
	-- example: v_layermanager : "layermanager":{"active":"onlyOneLayer", "visible":[], "index":[], "addToc":[] ,"zoom":"onlyOneLayer"}
	v_return = gw_fct_json_object_set_key((p_data->>'body')::json, 'layermanager', v_layermanager);

	-- style
	-- example1: v_style: {["layer":"tablename1", "mode":"Disabled", "parameters": null], ["layer":"tablename2", "mode":"basicRGB", "parameters": [R,G,B, opacidad]], ["layer":"tablename3", "mode":"qml", "parameters": {"id":4}]}
	-- example2: v_style: {["layer":"temp_point", "mode":"Disabled", "parameters": null], ["layer":"temp_line", "mode":"BasicRGB", "parameters": [R,G,B, opacidad]], ["layer":"temp_pol", "mode":"qml", "parameters": {"id":4}]}

	-- actions
	-- example1: v_actions : '["set_sytle_mapzones"]';
	
	-- Control nulls
	v_status := COALESCE(v_status, ''); 
	v_message := COALESCE(v_message, ''); 	
	v_version := COALESCE(v_version, '{}'); 
	v_result_info := COALESCE(v_result_info, '{}'); 
 
	-- Return
	RETURN v_return;
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
