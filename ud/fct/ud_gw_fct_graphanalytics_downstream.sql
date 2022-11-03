/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2214

DROP FUNCTION IF EXISTS  SCHEMA_NAME.gw_fct_flow_exit (character varying);
DROP FUNCTION IF EXISTS  SCHEMA_NAME.gw_fct_flow_exit (json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_graphanalytics_downstream(p_data json)  
RETURNS json AS $BODY$

/*
example:
SELECT SCHEMA_NAME.gw_fct_graphanalytics_downstream($${
"client":{"device":4, "infoType":1, "lang":"ES", "cur_user":"test_user"},
"feature":{"id":["20607"]},
"data":{}}$$)


SELECT SCHEMA_NAME.gw_fct_graphanalytics_downstream($${
"client":{"device":4, "infoType":1, "lang":"ES", "cur_user":"postgres"},
"feature":{},
"data":{ "coordinates":{"xcoord":419277.7306855297,"ycoord":4576625.674511955, "zoomRatio":3565.9967217571534}}}$$)

-- fid: 221,220

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

	v_sensibility_f float;
	v_sensibility float;
	v_zoomratio float;
BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;
	
	v_cur_user := (p_data ->> 'client')::json->> 'cur_user';
	v_device := (p_data ->> 'client')::json->> 'device';
	v_xcoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'xcoord';
	v_ycoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'ycoord';
	v_epsg := (SELECT epsg FROM sys_version ORDER BY id DESC LIMIT 1);
	v_client_epsg := (p_data ->> 'client')::json->> 'epsg';
	v_zoomratio := ((p_data ->> 'data')::json->> 'coordinates')::json->>'zoomRatio';

	IF v_client_epsg IS NULL THEN v_client_epsg = v_epsg; END IF;
	
	v_prev_cur_user = current_user;
	IF v_cur_user IS NOT NULL THEN
		EXECUTE 'SET ROLE "'||v_cur_user||'"';
	END IF;

	-- Reset values
	DELETE FROM anl_node WHERE cur_user="current_user"() AND (fid = 221 OR fid = 220);
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND (fid = 221 OR fid = 220);

	-- select version
	SELECT giswater INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	--Look for closest node using coordinates
	IF v_xcoord IS NOT NULL THEN 
		EXECUTE 'SELECT (value::json->>''web'')::float FROM config_param_system WHERE parameter=''basic_info_sensibility_factor'''
		INTO v_sensibility_f;
		v_sensibility = (v_zoomratio / 500 * v_sensibility_f);

		-- Make point
		SELECT ST_Transform(ST_SetSRID(ST_MakePoint(v_xcoord,v_ycoord),v_client_epsg),v_epsg) INTO v_point;

		SELECT node_id INTO v_node FROM v_edit_node WHERE ST_DWithin(the_geom, v_point,v_sensibility) LIMIT 1;

		SELECT gw_fct_json_object_set_key (p_data,'feature'::text, jsonb_build_object('id',json_agg(v_node))) INTO p_data;
	END IF;
	
	-- Compute the tributary area using recursive function
	EXECUTE 'SELECT gw_fct_graphanalytics_downstream_recursive($$'||p_data||'$$);'
	INTO v_result_json;

	IF (v_result_json->>'status')::TEXT = 'Accepted' THEN

		IF v_audit_result is null THEN
			v_status = 'Accepted';
			v_level = 3;
			v_message = 'Flow exit done successfully';
		ELSE

			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
			SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

		END IF;

		--affected network
		SELECT count(*) INTO v_count_connec FROM v_anl_flow_connec;
		SELECT count(*) INTO v_count_gully FROM v_anl_flow_gully;
		SELECT count(*) INTO v_count_node FROM v_anl_flow_node JOIN cat_feature_node cn ON cn.id=node_type WHERE isprofilesurface IS TRUE;
		SELECT round(sum(st_length(the_geom))::numeric,2) INTO v_length_arc FROM v_anl_flow_arc;

		select json_build_object(
		'affectedNetwork',json_build_object('length',v_length_arc,
		'nodesIsprofileTrue',v_count_node, 'numConnecs', v_count_connec, 'numGully', v_count_gully) )
		INTO v_result;

		v_result := COALESCE(v_result, '{}'); 
		v_result_info := COALESCE(v_result, '{}'); 
		v_result_info = concat ('{"geometryType":"", "values":',v_result_info, '}');

		IF v_device = 5 THEN
			SELECT jsonb_agg(features.feature) INTO v_result
			FROM (
	  	SELECT jsonb_build_object(
	     'type',       'Feature',
	    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	    'properties', to_jsonb(row) - 'the_geom',
	    'crs',concat('EPSG:',ST_SRID(the_geom))
	  	) AS feature
	  	FROM (SELECT arc_id, arc_type, context, expl_id, st_length(the_geom) as length, the_geom
	  	FROM  v_anl_flow_arc) row) features;

			v_result := COALESCE(v_result, '{}'); 
			v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, '}'); 	
			
			SELECT jsonb_agg(features.feature) INTO v_result
			FROM (
	  	SELECT jsonb_build_object(
			'type',       'Feature',
			'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
			'properties', to_jsonb(row) - 'the_geom',
			'crs',concat('EPSG:',ST_SRID(the_geom))
	  	) AS feature
	  	FROM (SELECT node_id as feature_id, node_type as feature_type, context, expl_id, the_geom
	  	FROM  v_anl_flow_node
	  	UNION 
	  	SELECT connec_id,'CONNEC', context, expl_id, the_geom
	  	FROM  v_anl_flow_connec
	  	UNION 
	  	SELECT gully_id,'GULLY', context, expl_id, the_geom
	  	FROM  v_anl_flow_gully) row) features;

			v_result := COALESCE(v_result, '{}'); 
			v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}'); 

			v_result_polygon = '{"geometryType":"", "features":[]}';

		ELSE
			v_result_polygon = '{"geometryType":"", "features":[]}';
			v_result_line = '{"geometryType":"", "features":[]}';
			v_result_point = '{"geometryType":"", "features":[]}';

		END IF;
		
		EXECUTE 'SET ROLE "'||v_prev_cur_user||'"';
		
		--  Return
		RETURN gw_fct_json_create_return(('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
			',"body":{"form":{}'||
				',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||'}'||
				'}'
			'}')::json, 2214, null, null, null);

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

