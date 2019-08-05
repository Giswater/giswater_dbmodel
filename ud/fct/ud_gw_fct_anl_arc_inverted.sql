/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2204

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_arc_inverted(p_data json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_arc_inverted(p_data json) 
RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_arc_inverted($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_edit_man_conduit", "id":["138","139"]},
"data":{"selectionMode":"previousSelection", "parameters":{"saveOnDatabase":true}
	}}$$)
*/


DECLARE
	v_version text;
	v_result json; 
	v_result_info	json;
	v_result_line 	json;
	v_id json;
	v_selectionmode text;
	v_saveondatabase boolean;
	v_worklayer text;
	v_array text;

BEGIN

	
	SET search_path = "SCHEMA_NAME", public;

    	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  (((p_data ->>'data')::json-'parameters')::json->>'saveOnDatabase')::boolean;

	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=10;
	    
	-- Computing process
	 INSERT INTO anl_arc (arc_id, expl_id, fprocesscat_id, the_geom)
	 SELECT arc_id, expl_id, 10, the_geom 
		FROM v_edit_arc
		WHERE slope < 0;

	-- Computing process
	IF v_array != '()' THEN 
		EXECUTE 'INSERT INTO anl_arc (arc_id, expl_id, fprocesscat_id, the_geom, arccat_id)
	 			SELECT arc_id, expl_id, 10, the_geom, arccat_id FROM '||v_worklayer||' WHERE slope < 0 AND arc_id IN '||v_array||';';
	ELSE
		EXECUTE 'INSERT INTO anl_arc (arc_id, expl_id, fprocesscat_id, the_geom, arccat_id)
	 			SELECT arc_id, expl_id, 10, the_geom, arccat_id FROM '||v_worklayer||' WHERE slope < 0';
	END IF;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=10 order by id) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--lines
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript, the_geom FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=10) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "values":',v_result, '}');

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=10;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=10 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (10, current_user);
	END IF;
		
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 

	--  Return
	RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"line":'||v_result_line||
		       '}}'||
	    '}')::json; 
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;