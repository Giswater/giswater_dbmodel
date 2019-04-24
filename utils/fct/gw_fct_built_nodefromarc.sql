/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2118


DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_built_nodefromarc();
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_built_nodefromarc() RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_built_nodefromarc()
*/

DECLARE
	rec_arc record;
	rec_table record;
	numnodes integer;
	v_version text;
	v_saveondatabase boolean = true;
	v_result json;
	v_result_info json;
	v_result_point json;
	v_node_proximity double precision;

BEGIN

	-- Search path
	SET search_path = SCHEMA_NAME, public;

	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- Get data from config tables
	SELECT ((value::json)->>'value') INTO v_node_proximity FROM config_param_system WHERE parameter='node_proximity';

	--  Reset values
	DELETE FROM temp_table WHERE user_name=current_user AND fprocesscat_id=16;
	DELETE FROM anl_node WHERE cur_user=current_user AND fprocesscat_id=16;

	-- inserting all extrem nodes on temp_node
	INSERT INTO temp_table (fprocesscat_id, geom_point)
	SELECT 
	16,
	ST_StartPoint(the_geom) AS the_geom FROM arc 
		UNION 
	SELECT 
	16,
	ST_EndPoint(the_geom) AS the_geom FROM arc;

	-- inserting into v_edit_node table
	FOR rec_table IN SELECT * FROM temp_table WHERE user_name=current_user AND fprocesscat_id=16
	LOOP
	        -- Check existing nodes  
	        numNodes:= 0;
		numNodes:= (SELECT COUNT(*) FROM node WHERE st_dwithin(node.the_geom, rec_table.geom_point, v_node_proximity));
		IF numNodes = 0 THEN
			INSERT INTO anl_node (the_geom, state, fprocesscat_id) VALUES (rec_table.geom_point,1,16);
		ELSE

		END IF;
	END LOOP;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT * FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=16) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--points
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, node_id, nodecat_id, state, expl_id, descript, the_geom FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=16) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point", "values":',v_result, '}'); 
  
  	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM audit_check_data WHERE cur_user="current_user"() AND fprocesscat_id=16;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=16 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (16, current_user);
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
