/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3172

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_anl_node_tcandidate(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_anl_node_tcandidate(p_data json)
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_node_tcandidate($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"tableName":"ve_node_junction", "id":["1004","1005"]},
"data":{"selectionMode":"previousSelection",
"parameters":{"nodeProximity":3, "saveOnDatabase":true}}}$$)
-- fid: 432

*/

DECLARE
      
v_id json;
v_selectionmode text;
v_nodeproximity	float;
v_saveondatabase boolean;
v_worklayer text;
v_result json;
v_result_info json;
v_result_point json;
v_array text;
v_error_context text;
v_version text;
v_count integer;

BEGIN

  -- Search path
  SET search_path = "SCHEMA_NAME", public;


  -- select version
  SELECT giswater INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;

  -- getting input data   
  v_id :=  ((p_data ->>'feature')::json->>'id')::json;
  v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
  v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
  v_saveondatabase :=  (((p_data ->>'data')::json->>'parameters')::json->>'saveOnDatabase')::boolean;
   
  select string_agg(quote_literal(a),',') into v_array from json_array_elements_text(v_id) a;
   
  -- Reset values
  DELETE FROM anl_node WHERE cur_user="current_user"() AND fid=432;
  DELETE FROM audit_check_data WHERE cur_user="current_user"() AND fid=432; 
  
  INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (432, null, 4, concat('NODES T CANDIDATES ANALYSIS'));
  INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (432, null, 4, '-------------------------------------------------------------');


  -- Computing process
  IF v_selectionmode = 'previousSelection' AND v_array IS NOT NULL THEN

    EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, state, expl_id, descript, fid, the_geom)
    with q_arc as (select * from arc JOIN v_state_arc USING (arc_id))
    SELECT b.* FROM (SELECT n1.node_id, n1.nodecat_id, n1.state, n1.expl_id, ''Node T candidate'',432, n1.the_geom 
    FROM q_arc a, node n1 JOIN '||v_worklayer||' USING (node_id)
	JOIN (SELECT node_1 node_id from q_arc UNION select node_2 FROM q_arc) b USING (node_id)
    WHERE st_dwithin(a.the_geom, n1.the_geom,0.01) AND n1.node_id NOT IN (node_1, node_2) AND n1.node_id IN ('||v_array||') )b';

  ELSE
    EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, state, expl_id, descript, fid, the_geom)
    with q_arc as (select * from arc JOIN v_state_arc USING (arc_id))
	SELECT b.* FROM (SELECT n1.node_id, n1.nodecat_id, n1.state, n1.expl_id,''Node T candidate'', 432, n1.the_geom 
    FROM q_arc a, node n1 JOIN '||v_worklayer||' USING (node_id)
	JOIN (SELECT node_1 node_id from q_arc UNION select node_2 FROM q_arc) b USING (node_id)
    WHERE st_dwithin(a.the_geom, n1.the_geom,0.01) AND n1.node_id NOT IN (node_1, node_2))b';
  END IF;

  SELECT count(*) INTO v_count FROM anl_node WHERE cur_user="current_user"() AND fid=432;

  IF v_count = 0 THEN
    INSERT INTO audit_check_data(fid,  error_message, fcount)
    VALUES (432,  'There are no nodes T candidates.', v_count);
  ELSE
    INSERT INTO audit_check_data(fid,  error_message, fcount)
    VALUES (432,  concat ('There are ',v_count,' nodes T candidates.'), v_count);
  END IF;
    

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND fid=432 order by id) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

  	--points
  v_result = null;
  SELECT jsonb_agg(features.feature) INTO v_result
  FROM (
    SELECT jsonb_build_object(
    'type',       'Feature',
    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
    'properties', to_jsonb(row) - 'the_geom'
    ) AS feature
    FROM (SELECT id, node_id, nodecat_id, state, expl_id, descript,fid, the_geom
    FROM  anl_node WHERE cur_user="current_user"() AND fid=432) row) features;

  v_result := COALESCE(v_result, '{}'); 
  v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}'); 

  IF v_saveondatabase IS FALSE THEN 
  	-- delete previous results
  	DELETE FROM anl_node WHERE cur_user="current_user"() AND fid=432;
  ELSE
  	-- set selector
  	DELETE FROM selector_audit WHERE fid=432 AND cur_user=current_user;
  	INSERT INTO selector_audit (fid,cur_user) VALUES (432, current_user);
  END IF;
 
  --    Control nulls
  v_result_info := COALESCE(v_result_info, '{}'); 
  v_result_point := COALESCE(v_result_point, '{}'); 

	--  Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Analysis done successfully"}, "version":"'||v_version||'"'||
               ',"body":{"form":{}'||
  		     ',"data":{ "info":'||v_result_info||','||
  				'"point":'||v_result_point||
  			'}}'||
  	    '}')::json, 2914, null, null, null);

  	

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
  
