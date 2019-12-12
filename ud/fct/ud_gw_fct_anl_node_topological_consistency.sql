/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2212

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_node_topological_consistency(p_data json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_node_topological_consistency(p_data json) 
RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_node_topological_consistency($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_edit_man_manhole", "id":["138","139"]},
"data":{"selectionMode":"previousSelection", "parameters":{"saveOnDatabase":true}
}}$$)
*/

DECLARE
	rec_node record;
	rec record;
	v_version text;
	v_saveondatabase boolean;
	v_result json;
	v_result_info json;
	v_result_point json;
	v_id json;
	v_selectionmode text;
	v_worklayer text;
	v_array text;
	v_qmlpointpath text;
BEGIN

	SET search_path = "SCHEMA_NAME", public;

	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- Reset values
	DELETE FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=8;

    -- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  (((p_data ->>'data')::json->>'parameters')::json->>'saveOnDatabase')::boolean;

	--select default geometry style
	SELECT regexp_replace(row(value)::text, '["()"]', '', 'g')  INTO v_qmlpointpath FROM config_param_user WHERE parameter='qgis_qml_pointlayer_path' AND cur_user=current_user;

	-- Computing process
	IF v_array != '()' THEN
		EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, expl_id, num_arcs, fprocesscat_id, the_geom, state)
				SELECT node_id, nodecat_id, '||v_worklayer||'.expl_id, COUNT(*), 8, '||v_worklayer||'.the_geom , '||v_worklayer||'.state
				FROM '||v_worklayer||' 
				INNER JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id 
				WHERE '||v_worklayer||'.node_type != ''OUTFALL'' AND  node_id IN '||v_array||'
				GROUP BY '||v_worklayer||'.node_id,'||v_worklayer||'.nodecat_id, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom,
				'||v_worklayer||'.state 
				HAVING COUNT(*) = 1;';
	ELSE
		EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, expl_id, num_arcs, fprocesscat_id, the_geom, state)
				SELECT node_id, nodecat_id, '||v_worklayer||'.expl_id, COUNT(*), 8, '||v_worklayer||'.the_geom,'||v_worklayer||'.state 
				FROM '||v_worklayer||'
				INNER JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id 
				WHERE '||v_worklayer||'.node_type != ''OUTFALL'' 
				GROUP BY '||v_worklayer||'.node_id,'||v_worklayer||'.nodecat_id, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom,
				'||v_worklayer||'.state
				HAVING COUNT(*) = 1;';
	END IF;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=8 order by id) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--points
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, node_id, nodecat_id, state, expl_id, descript, the_geom, fprocesscat_id FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=8) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point", "qmlPath":"',v_qmlpointpath,'", "values":',v_result, '}');

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=8;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=8 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (8, current_user);
	END IF;
		
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 

	--  Return
	RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||
			'}}'||
	    '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
