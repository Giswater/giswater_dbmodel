/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


-- Function code: 3128

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_getwidgetprices(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_getwidgetprices($${"client":{}, "form":{}, "feature":{},"data":{"tableName":"v_edit_plan_psector_x_other", "psectorId":8}}$$)::text

*/

DECLARE

v_schemaname text;
v_version text;
v_definition text;
v_columns json;
v_columns_array json[];
v_fields json;
v_fields_array json[];
v_tablename text;
v_psector_id text;
v_currency text;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';

	-- Getting variables
	v_tablename = (p_data->>'data')::json->>'tableName';
	v_psector_id = (p_data->>'data')::json->>'psectorId';
	v_currency :=(SELECT value::json->>'symbol' FROM config_param_system WHERE parameter='admin_currency');

	-- Get table columns
	EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT column_name FROM information_schema.columns 
	WHERE table_schema = $1 AND table_name = $2 AND column_name NOT IN (''atlas_id'', ''id'', ''psector_id''))a '
	INTO v_columns_array
	USING v_schemaname, v_tablename;

	-- Get table rows
	EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, price_id, unit, price_descript, price, measurement, observ, concat(total_budget,'' '','||quote_literal(v_currency)||') as total FROM '||v_tablename||' WHERE psector_id = '||v_psector_id||')a ' 
	INTO v_fields_array;

	v_columns := array_to_json(v_columns_array);
	v_fields := array_to_json(v_fields_array);
	
	-- Control nulls
	v_version := COALESCE(v_version, '""'); 
	v_columns := COALESCE(v_columns, '{}'); 
	v_fields := COALESCE(v_fields, '{}'); 

	-- Return
	RETURN ('{"status":"Accepted"' ||', "version":'|| v_version ||
		/*', "columns":' || v_columns ||*/
		/*', "layoutname":"price_layout"'||||*/
		', "fields":' || v_fields ||
		'}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;