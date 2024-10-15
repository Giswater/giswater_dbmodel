/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
-- The code of this have been received helpfull assistance from Enric Amat (FISERSA) and Claudia Dragoste (Aigües de Girona SA)

--FUNCTION CODE: 2214

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_flow_exit (character varying);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_flow_exit (json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_graphanalytics_downstream(p_data json)
RETURNS json AS $BODY$

/*
example:
SELECT SCHEMA_NAME.gw_fct_graphanalytics_downstream($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"id":["20607"]},
"data":{}}$$);


SELECT SCHEMA_NAME.gw_fct_graphanalytics_downstream($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{},
"data":{ "coordinates":{"xcoord":419277.7306855297,"ycoord":4576625.674511955, "zoomRatio":3565.9967217571534}}}$$)

--fid: 221;

*/
DECLARE

v_affectrow numeric;

v_result_info json;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_result text;
v_count integer;
v_version text;

v_debug boolean;
v_error_context text;
v_audit_result text;

v_level integer;
v_status text;
v_message text;

v_project_type text;
v_node integer;
v_point public.geometry;
v_sensibility_f float;
v_sensibility float;
v_zoomratio float;
v_fid integer=221;
v_cur_user text;
v_device integer;
v_xcoord float;
v_ycoord float;
v_epsg integer;
v_client_epsg integer;

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
	v_node = json_array_elements_text(json_extract_path_text(p_data,'feature','id')::json)::integer;

	IF v_client_epsg IS NULL THEN v_client_epsg = v_epsg; END IF;

	-- select config values
	SELECT giswater, upper(project_type) INTO v_version, v_project_type FROM sys_version ORDER BY id DESC LIMIT 1;

	CREATE TEMP TABLE temp_t_anlgraph (LIKE SCHEMA_NAME.temp_anlgraph INCLUDING ALL);

	CREATE OR REPLACE TEMP VIEW v_temp_graphanalytics_downstream AS
	 SELECT temp_t_anlgraph.arc_id,
	    temp_t_anlgraph.node_1,
	    temp_t_anlgraph.node_2,
	    temp_t_anlgraph.flag,
	    a2.flag AS flagi,
	    a2.value,
	    a2.trace
	   FROM temp_t_anlgraph
	     JOIN ( SELECT temp_t_anlgraph_1.arc_id,
		    temp_t_anlgraph_1.node_1,
		    temp_t_anlgraph_1.node_2,
		    temp_t_anlgraph_1.water,
		    temp_t_anlgraph_1.flag,
		    temp_t_anlgraph_1.checkf,
		    temp_t_anlgraph_1.value,
		    temp_t_anlgraph_1.trace
		   FROM temp_t_anlgraph temp_t_anlgraph_1
		  WHERE temp_t_anlgraph_1.water = 1) a2 ON temp_t_anlgraph.node_1::text = a2.node_2::text
	  WHERE temp_t_anlgraph.flag < 2 AND temp_t_anlgraph.water = 0 AND a2.flag = 0;

	--Look for closest node using coordinates
	IF v_node IS NULL THEN
		EXECUTE 'SELECT (value::json->>''web'')::float FROM config_param_system WHERE parameter=''basic_info_sensibility_factor'''
		INTO v_sensibility_f;
		v_sensibility = (v_zoomratio / 500 * v_sensibility_f);

		-- Make point
		SELECT ST_Transform(ST_SetSRID(ST_MakePoint(v_xcoord,v_ycoord),v_client_epsg),v_epsg) INTO v_point;
		SELECT node_id INTO v_node FROM v_edit_node WHERE ST_DWithin(the_geom, v_point,v_sensibility) LIMIT 1;
		IF v_node IS NULL THEN
			SELECT node_1 INTO v_node FROM v_edit_arc WHERE ST_DWithin(the_geom, v_point,100)  order by st_distance (the_geom, v_point) LIMIT 1;
		END IF;
	END IF;


	-- fill the graph table
	INSERT INTO temp_t_anlgraph (arc_id, node_1, node_2, water, flag, checkf)
	SELECT  arc_id::integer, node_1::integer, node_2::integer, 0, 0, 0 FROM v_edit_arc JOIN value_state_type ON state_type=id
	WHERE node_1 IS NOT NULL AND node_2 IS NOT NULL AND value_state_type.is_operative=TRUE AND v_edit_arc.state > 0;

	-- Close mapzone headers
	EXECUTE 'UPDATE temp_t_anlgraph SET flag=0, water=1, trace = 1::integer  WHERE node_1::integer IN ('||v_node||')';

	-- inundation process
	LOOP
		v_count = v_count+1;
		UPDATE temp_t_anlgraph n SET water=1, trace = a.trace FROM v_temp_graphanalytics_downstream a where n.node_1::integer = a.node_1::integer AND n.arc_id = a.arc_id;
		GET DIAGNOSTICS v_affectrow = row_count;
		raise notice 'v_count --> %' , v_count;
		EXIT WHEN v_affectrow = 0;
		EXIT WHEN v_count = 5000;
	END LOOP;

	RAISE NOTICE 'Finish engine....';


	v_result := COALESCE(v_result, '{}');
	v_result_info := COALESCE(v_result, '{}');
	v_result_info = concat ('{"geometryType":"", "values":',v_result_info, '}');

	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND (fid = 220 or fid=221);
	DELETE FROM anl_node WHERE cur_user="current_user"() AND (fid = 220 or fid=221);

	INSERT INTO anl_arc (arc_id, fid, arccat_id, expl_id, the_geom)
	SELECT arc_id, v_fid, arc_type, expl_id, the_geom	FROM temp_t_anlgraph
	join arc using(arc_id)	where water=1;

	INSERT INTO anl_node (node_id, nodecat_id,state, expl_id, fid, the_geom)
	SELECT node_id, node_type, state, expl_id, v_fid, the_geom
	FROM v_edit_node WHERE node_id IN (SELECT  node_1 from temp_t_anlgraph where water=1 union SELECT  node_2 from temp_t_anlgraph where water=1);

	DROP VIEW v_temp_graphanalytics_downstream;
	DROP TABLE temp_t_anlgraph;

	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
		'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom',
	'crs',concat('EPSG:',ST_SRID(the_geom))
	) AS feature
	FROM (SELECT arc_id, arc_type, 'Flow exit' as context, a.expl_id, st_length(a.the_geom) as length, a.the_geom
	FROM anl_arc join arc a using (arc_id) WHERE fid=v_fid) row) features;

	v_result := COALESCE(v_result, '{}');
	v_result_line = concat ('{"geometryType":"LineString", "layerName": "Flowtrace arc", "features":',v_result, '}');

	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
		'type',       'Feature',
		'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
		'properties', to_jsonb(row) - 'the_geom',
		'crs',concat('EPSG:',ST_SRID(the_geom))
	) AS feature
	FROM (SELECT node_id as feature_id, n.node_type as feature_type, 'Flow exit' as context, n.expl_id, n.the_geom
	FROM  anl_node join node n using (node_id) WHERE fid=v_fid
	UNION
	SELECT connec_id, 'CONNEC', 'Flow exit' as context, c.expl_id, c.the_geom
	FROM anl_arc JOIN connec c using (arc_id) WHERE fid=v_fid
	UNION
	SELECT gully_id, 'GULLY',  'Flow exit' as context, g.expl_id, g.the_geom
	FROM anl_arc JOIN gully g using (arc_id) WHERE fid=v_fid) row) features;

	v_result := COALESCE(v_result, '{}');
	v_result_point = concat ('{"geometryType":"Point", "layerName": "Flowtrace node", "features":',v_result, '}');

	v_result_polygon = '{"geometryType":"", "features":[]}';

	v_status = 'Accepted';
	v_level = 3;
	v_message = 'Flow  analysis done succesfully';

	--  Return
	RETURN gw_fct_json_create_return(('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
				   ',"body":{"form":{}'||
				   ',"data":{ "info":'||v_result_info||','||
				      '"initPoint":'||v_node||','||
					  '"point":'||v_result_point||','||
					  '"line":'||v_result_line||','||
					  '"polygon":'||v_result_polygon||'}'||
					 '}'
		'}')::json, 2214, null, null, null);

	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN json_build_object('status', 'Failed', 'NOSQLERR', SQLERRM, 'message', json_build_object('level', right(SQLSTATE, 1), 'text', SQLERRM), 'SQLSTATE', SQLSTATE, 'SQLCONTEXT', v_error_context)::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

