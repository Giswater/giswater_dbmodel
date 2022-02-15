/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3114

-- DROP FUNCTION SCHEMA_NAME.gw_fct_getaddlayervalues(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_getaddlayervalues(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_getaddlayervalues($${"client":{}, "form":{}, "feature":{},"data":{"filterFields":{}, "pageInfo":{}, "parameters":{}}}$$)::text

*/

DECLARE

v_schemaname text;
v_project_type text;
v_version text;
v_fields json;
v_fields_array json[];
v_error_context text;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;

	v_schemaname = 'SCHEMA_NAME';
	
	-- select config values
	SELECT project_type, giswater INTO v_project_type, v_version FROM sys_version order by id desc limit 1;
	
	WITH geomtable AS (SELECT column_name, table_name from information_schema.columns WHERE udt_name='geometry' and table_schema='SCHEMA_NAME'),
	idtable AS (SELECT column_name, table_name from information_schema.columns WHERE ordinal_position=1 and table_schema='SCHEMA_NAME')
	SELECT array_agg(row_to_json(d)) FROM (SELECT context, alias as "layerName", st.id as "tableName",
	CASE WHEN c.column_name IS NULL THEN 'None' 
	WHEN st.addparam->>'geom' IS NOT NULL THEN st.addparam->>'geom'
	ELSE c.column_name END AS "geomField",
	CASE WHEN st.addparam->>'pkey' IS NULL THEN i.column_name
	ELSE st.addparam->>'pkey' END AS "tableId", st.style_id 
	FROM sys_table st
	join config_typevalue ct ON ct.id= context
	left join geomtable c ON st.id =c.table_name
	left join idtable i ON st.id =i.table_name
	WHERE typevalue = 'sys_table_context'
	ORDER BY  json_extract_path_text(camelstyle::json,'orderBy')::integer,orderby, alias)d into v_fields_array;

	v_fields := array_to_json(v_fields_array);

	-- Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
			 ',"body":{"form":{}'||
			 ',"data":{ "fields":'||v_fields||','||
				'"point":{"geometryType":"", "values":[]}'||','||
				'"line":{"geometryType":"", "values":[]}'||','||
				'"polygon":{"geometryType":"", "values":[]}'||
			   '}}'||
		'}')::json, 3114, null, null, null);
	
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;
    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
