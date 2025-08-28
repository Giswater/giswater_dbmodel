/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 2218

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_flow_trace(character varying);
DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_flow_trace(json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_graphanalytics_upstream(p_data json)
RETURNS json AS

$BODY$

/*
example:
SELECT SCHEMA_NAME.gw_fct_graphanalytics_upstream($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"id":["20607"]},
"data":{}}$$);

SELECT SCHEMA_NAME.gw_fct_graphanalytics_upstream($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{},
"data":{"coordinates":{"xcoord":419278.0533606678,"ycoord":4576625.482073168,"zoomRatio":437.2725774103561}}}$$)

--fid: 220;

*/
DECLARE

v_result_info json;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_result text;
v_version text;

v_debug boolean;
v_error_context text;
v_audit_result text;

v_level integer;
v_status text;
v_message text;

v_project_type text;
v_node bigint;
v_point public.geometry;
v_sensibility_f float;
v_sensibility float;
v_zoomratio float;
v_fid integer;
v_device integer;
v_xcoord float;
v_ycoord float;
v_epsg integer;
v_client_epsg integer;
v_query text;
v_source text;
v_target text;
v_distance int;
v_mainstream text;
v_diverted_flow text;
v_context text;

v_symbology int;

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	v_device := (p_data ->> 'client')::json->> 'device';
	v_xcoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'xcoord';
	v_ycoord := ((p_data ->> 'data')::json->> 'coordinates')::json->>'ycoord';
	v_epsg := (SELECT epsg FROM sys_version ORDER BY id DESC LIMIT 1);
	v_client_epsg := (p_data ->> 'client')::json->> 'epsg';
	v_zoomratio := ((p_data ->> 'data')::json->> 'coordinates')::json->>'zoomRatio';
	SELECT (p_data->'feature'->'id'->>0)::bigint INTO v_node;

	v_context = 'Flow trace';
	v_fid = 220;
	v_symbology = 2218;

	-- pgrouting
	v_source= 'node_2';
	v_target= 'node_1';
	v_mainstream = 'mainstream';
	v_diverted_flow = 'diverted flow';

	IF v_client_epsg IS NULL THEN v_client_epsg = v_epsg; END IF;

	-- select config values
	SELECT giswater, upper(project_type) INTO v_version, v_project_type FROM sys_version ORDER BY id DESC LIMIT 1;

	--Look for closest node using coordinates
	IF v_node IS NULL THEN
		SELECT (value::json->>'web')::float
		INTO v_sensibility_f
		FROM config_param_system
		WHERE parameter = 'basic_info_sensibility_factor';

		v_sensibility = (v_zoomratio / 500 * v_sensibility_f);

		-- Make point
		SELECT ST_Transform(ST_SetSRID(ST_MakePoint(v_xcoord,v_ycoord),v_client_epsg),v_epsg) INTO v_point;
		SELECT node_id INTO v_node FROM ve_node WHERE ST_DWithin(the_geom, v_point,v_sensibility) LIMIT 1;
		IF v_node IS NULL THEN
			SELECT node_1 INTO v_node FROM ve_arc WHERE ST_DWithin(the_geom, v_point, 100)  order by st_distance (the_geom, v_point) LIMIT 1;
		END IF;
	END IF;

	v_result := COALESCE(v_result, '{}');
	v_result_info := COALESCE(v_result, '{}');

	-- create temp tables
	DROP TABLE IF EXISTS t_anl_arc;
	DROP TABLE IF EXISTS t_anl_node;
	CREATE TEMP TABLE t_anl_arc (LIKE anl_arc INCLUDING ALL);
	CREATE TEMP TABLE t_anl_node (LIKE anl_node INCLUDING ALL);

	v_query := $sql$
		WITH
			arc_selected AS (
				SELECT a.arc_id, a.node_1, a.node_2
				FROM ve_arc a
				WHERE a.node_1 IS NOT NULL
				AND a.node_2 IS NOT NULL
				AND a.state > 0
				AND a.is_operative = TRUE
			)
		SELECT
			a.arc_id::bigint AS id,
			a.node_2::bigint AS source,
			a.node_1::bigint AS target,
			1::float8 AS cost,
			-1::float8 AS reverse_cost
			FROM arc_selected a
	$sql$;

	EXECUTE 'SELECT count(*)::int FROM ve_arc'
	INTO v_distance;

    IF v_node IS NOT NULL THEN
		DROP TABLE IF EXISTS tmp_upstream_nodes;
	  	CREATE TEMP TABLE tmp_upstream_nodes ON COMMIT DROP AS
		SELECT node
		FROM pgr_drivingdistance(v_query, v_node, v_distance);

        INSERT INTO t_anl_node (node_id, fid, nodecat_id, state, expl_id, drainzone_id, addparam, the_geom)
        SELECT n.node_id, v_fid, n.node_type, n.state, n.expl_id, n.drainzone_id, v_diverted_flow, n.the_geom
        FROM tmp_upstream_nodes t
        JOIN ve_node n ON n.node_id = t.node;
    END IF;

	-- mainstream
	v_query := format($sql$
		WITH
			arc_selected AS (
				SELECT a.arc_id, a.node_1, a.node_2
				FROM ve_arc a
				WHERE a.node_1 IS NOT NULL
				AND a.node_2 IS NOT NULL
				AND a.state > 0
				AND a.is_operative = TRUE
				AND a.initoverflowpath IS DISTINCT FROM TRUE
				AND EXISTS (
					SELECT 1 FROM t_anl_node an
					WHERE an.cur_user = %L
					AND an.fid = %s
					AND an.node_id = (a.%I)::text
				)
			)
		SELECT
			a.arc_id::bigint AS id,
			a.node_2::bigint AS source,
			a.node_1::bigint AS target,
			1::float8 AS cost,
			-1::float8 AS reverse_cost
			FROM arc_selected a
	$sql$, current_user, v_fid, v_source);

    IF v_node IS NOT NULL THEN
		DROP TABLE IF EXISTS tmp_mainstream_nodes;
		CREATE TEMP TABLE tmp_mainstream_nodes ON COMMIT DROP AS
		SELECT node
		FROM pgr_drivingdistance(v_query, v_node, v_distance);

        UPDATE t_anl_node n SET addparam = v_mainstream
        FROM tmp_mainstream_nodes t
        WHERE n.cur_user = current_user AND n.fid = v_fid
        AND (n.node_id)::bigint = t.node;
    END IF;

	INSERT INTO t_anl_arc (arc_id, fid, arccat_id, state, expl_id, drainzone_id, addparam, the_geom)
	SELECT a.arc_id, v_fid, a.arc_type, a.state, a.expl_id, a.drainzone_id, n2.addparam, a.the_geom
	FROM ve_arc a
	JOIN t_anl_node n1 ON a.node_1 = n1.node_id::bigint
	JOIN t_anl_node n2 ON a.node_2 = n2.node_id::bigint
	WHERE n1.cur_user=current_user AND n1.fid = v_fid
	AND n2.cur_user=current_user AND n2.fid = v_fid;

	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
		'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom',
	'crs',concat('EPSG:',ST_SRID(the_geom))
	) AS feature
	FROM (SELECT v_context as context, expl_id, arc_id, state, arccat_id as arc_type, 'ARC' AS feature_type, drainzone_id, addparam as stream_type, st_length(the_geom) as length, the_geom
	FROM t_anl_arc WHERE cur_user=current_user AND fid=v_fid) row) features;

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
	FROM (SELECT v_context as context, expl_id, node_id as feature_id, state, nodecat_id AS node_type, 'NODE' AS feature_type, drainzone_id, addparam as stream_type, the_geom
	FROM  t_anl_node WHERE cur_user=current_user AND fid=v_fid
	UNION
	SELECT v_context as context, c.expl_id, c.connec_id::text, c.state, c.connec_type, 'CONNEC' AS feature_type, c.drainzone_id, a.addparam as stream_type, c.the_geom
	FROM t_anl_arc a JOIN ve_connec c ON c.arc_id::text = a.arc_id
	WHERE cur_user=current_user AND fid=v_fid
	AND c.state > 0
	AND c.is_operative = TRUE
	UNION
	SELECT v_context as context, g.expl_id, g.gully_id::text, g.state, g.gully_type, 'GULLY' AS feature_type, g.drainzone_id, a.addparam as stream_type, g.the_geom
	FROM t_anl_arc a JOIN ve_gully g ON g.arc_id::text = a.arc_id
	WHERE cur_user=current_user AND fid=v_fid
	AND g.state > 0
	AND g.is_operative = TRUE) row) features;

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
		'}')::json, v_symbology, null, null, null);

    EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
    -- Let the error bubble up so PostgreSQL can properly clean SPI context from extensions
    RAISE;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

