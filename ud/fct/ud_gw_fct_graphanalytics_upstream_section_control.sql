/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3176


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_graphanalytics_upstream_section_control(p_data json)  
RETURNS json AS 

$BODY$

/*
example:
SELECT SCHEMA_NAME.gw_graphanalytics_upstream_section_control($${
"client":{"device":4, "infoType":1, "lang":"ES", "cur_user":"test_user"},
"feature":{"id":["20607"]},
"data":{}}$$);

--fid: 477;

*/

DECLARE 

v_result_json json;
v_result json;
v_result_info text;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_error_context text;
v_version text;
v_status text;
v_level integer;
v_message text;
v_audit_result text;
v_cur_user text;
v_prev_cur_user text;
v_count_connec integer;
v_count_gully integer;
v_count_node integer;
v_length_arc numeric;
v_device integer;

v_node text;
v_xcoord double precision;
v_ycoord double precision;
v_epsg integer;
v_client_epsg integer;
v_point public.geometry;

v_fid integer =477;
v_count integer;
BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;
	
	v_cur_user := (p_data ->> 'client')::json->> 'cur_user';
	v_device := (p_data ->> 'client')::json->> 'device';
	v_xcoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'xcoord';
	v_ycoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'ycoord';
	v_epsg := (SELECT epsg FROM sys_version ORDER BY id DESC LIMIT 1);
	v_client_epsg := (p_data ->> 'client')::json->> 'epsg';
	
	IF v_client_epsg IS NULL THEN v_client_epsg = v_epsg; END IF;
	
	v_prev_cur_user = current_user;
	IF v_cur_user IS NOT NULL THEN
		EXECUTE 'SET ROLE "'||v_cur_user||'"';
	END IF;
	
	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fid = v_fid;
	DELETE FROM anl_node WHERE cur_user="current_user"() AND fid =v_fid;
	DELETE FROM audit_check_data WHERE cur_user="current_user"() AND fid =v_fid;

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, concat('SECTION CONTROL ANALYSIS'));
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, '-------------------------------------------------------------');


	-- select version
	SELECT giswater INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;


	SELECT gw_fct_json_object_set_key (p_data,'fid'::text, v_fid) INTO p_data;

	-- Compute the tributary area using recursive function
	EXECUTE 'SELECT gw_fct_graphanalytics_upstream_recursive($$'||p_data||'$$);'
	INTO v_result_json;

	IF (v_result_json->>'status')::TEXT = 'Accepted' THEN

		IF v_audit_result is null THEN
			v_status = 'Accepted';
			v_level = 3;
			v_message = 'Analysis done successfully';
		ELSE

			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

		END IF;

		SELECT count(*) INTO v_count FROM anl_arc WHERE cur_user="current_user"() AND fid=v_fid;

		IF v_count = 0 THEN
			INSERT INTO audit_check_data(fid,  error_message, fcount)
			VALUES (v_fid,  'There are no arcs with unconsistent sections.', v_count);
		ELSE
			INSERT INTO audit_check_data(fid,  error_message, fcount)
			VALUES (v_fid,  concat ('There are ',v_count,' arcs with section (geom1) bigger then the section of the following arc.'), v_count);

			INSERT INTO audit_check_data(fid,  error_message, fcount)
			SELECT v_fid,  concat ('Arc_id: ',string_agg(arc_id, ', '), '.' ), v_count 
			FROM anl_arc WHERE cur_user="current_user"() AND fid=v_fid;
		END IF;
	
		-- info
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
		FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND fid=v_fid order by  id asc) row;

		v_result := COALESCE(v_result, '{}'); 
		v_result_info := COALESCE(v_result, '{}'); 
		v_result_info = concat ('{"geometryType":"", "values":',v_result_info, '}');

		SELECT jsonb_agg(features.feature) INTO v_result
		FROM (
	  SELECT jsonb_build_object(
	    'type',       'Feature',
	   'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	   'properties', to_jsonb(row) - 'the_geom',
	   'crs',concat('EPSG:',ST_SRID(the_geom))
	  ) AS feature
	  FROM (SELECT arc_id, arccat_id, expl_id, fid, the_geom, descript as geom1
	  FROM anl_arc WHERE fid=v_fid) row) features;

		v_result := COALESCE(v_result, '{}'); 
		v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, '}'); 	
			
		v_result := COALESCE(v_result, '{}'); 
		v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}'); 

		v_result_polygon = '{"geometryType":"", "features":[]}';
		
		EXECUTE 'SET ROLE "'||v_prev_cur_user||'"';
		
		--  Return
		RETURN gw_fct_json_create_return(('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
				   ',"body":{"form":{}'||
				   ',"data":{ "info":'||v_result_info||','||
					  '"point":'||v_result_point||','||
					  '"line":'||v_result_line||','||
					  '"polygon":'||v_result_polygon||'}'||
					 '}'
			  '}')::json, 3176, null, null, null);
	ELSE 
		RETURN v_result_json;
	END IF;

	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

