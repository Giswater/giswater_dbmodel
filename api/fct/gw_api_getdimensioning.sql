/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- Function code: XXXX

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_getdimensioning(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_api_getdimensioning($${
		"client":{"device":9, "infoType":100, "lang":"ES"},
		"form":{},
		"feature":{},
		"data":{}}$$)
*/

DECLARE

--    Variables
	
	v_status text ='Accepted';
	v_message json;
	v_apiversion json;
	v_forminfo json;
	v_featureinfo json;
	v_linkpath json;
	v_parentfields text;
	v_fields_array json[];
	schemas_array name[];
	v_project_type text;
	aux_json json;
	v_fields json;
	field json;
	v_id int8;


BEGIN

--  Get,check and set parameteres
----------------------------
--    	Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	schemas_array := current_schemas(FALSE);

	
--      Get values from config
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO v_apiversion;
		
--  	Get project type
	SELECT wsoftware INTO v_project_type FROM version LIMIT 1;


	-- mandantory set due complex interaction againts QGIS and database when on qgis is feature interted value is updated, transaction is opened....
	PERFORM setval('SCHEMA_NAME.dimensions_id_seq', (SELECT max(id) FROM dimensions), true);

	v_id = (SELECT nextval('SCHEMA_NAME.dimensions_id_seq'::regclass));

	v_featureinfo = '{"tableName":"v_edit_dimensions", "idName":"id", "id":'||v_id||'}';

	EXECUTE 'SELECT gw_api_get_formfields($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)'
	INTO v_fields_array
	USING 'v_edit_dimensions', 'feature', '', NULL, NULL, NULL, NULL, 'SELECT', null, 3;

	-- Set widget_name without tabname for widgets
	FOREACH field IN ARRAY v_fields_array
	LOOP
		v_fields_array[(field->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(field->>'orderby')::INT], 'widgetname', field->>'column_id');
	END LOOP;

	v_fields := array_to_json(v_fields_array);

	

--    Control NULL's
----------------------

	v_status := COALESCE(v_status, '{}');    
	v_message := COALESCE(v_message, '{}');    
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_forminfo := COALESCE(v_forminfo, '{}');
	v_featureinfo := COALESCE(v_featureinfo, '{}');
	v_linkpath := COALESCE(v_linkpath, '{}');
	v_parentfields := COALESCE(v_parentfields, '{}');
	v_fields := COALESCE(v_fields, '{}');

--    Return
-----------------------
     RETURN ('{"status":"'||v_status||'", "message":'||v_message||', "apiVersion":' || v_apiversion ||
	      ',"body":{"form":' || v_forminfo ||
		     ', "feature":'|| v_featureinfo ||
		      ',"data":{"linkPath":' || v_linkpath ||
			      ',"parentFields":' || v_parentfields ||
			      ',"fields":' || v_fields || 
			      '}'||
			'}'||
		'}')::json;

--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","message":' || to_json(SQLERRM) || ', "apiVersion":'|| v_apiversion ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

