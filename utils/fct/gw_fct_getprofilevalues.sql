/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2832

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_getprofilevalues(p_data json)
RETURNS json AS
$BODY$

/*example
current petition from client:
SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"data":{"initNode":"6970", "endNode":"147", "linksDistance":5}}$$);
SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"data":{"initNode":"6970", "endNode":"147", "linksDistance":5}}$$);

SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"client":{}, "form":{}, "feature":{}, "data":{"initNode":"64", "endNode":"38", "linksDistance":1, "scale":{ "eh":1000, "ev":1000}}}$$);

-----------
further petitions from client:
SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"client":{},
	"data":{"initNode":"116", "endNode":"111", "composer":"mincutA4", "legendFactor":1, "linksDistance":1, "scale":{"scaleToFit":false, "eh":2000, "ev":500}, "papersize":{"id":0, "customDim":{"xdim":300, "ydim":200}},
		"ComposerTemplates":[{"ComposerTemplate":"mincutA4", "ComposerMap":[{"width":"179.0","height":"140.826","index":0, "name":"map0"},{"width":"77.729","height":"55.9066","index":1, "name":"map7"}]},
				     {"ComposerTemplate":"mincutA3","ComposerMap":[{"width":"53.44","height":"55.9066","index":0, "name":"map7"},{"width":"337.865","height":"275.914","index":1, "name":"map6"}]}]
				     }}$$);

SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"client":{},
	"data":{"initNode":"116", "endNode":"111", "composer":"mincutA4", "legendFactor":1, "linksDistance":1, "scale":{"scaleToFit":false, "eh":2000, "ev":500},"papersize":{"id":2, "customDim":{}},
		"ComposerTemplates":[{"ComposerTemplate":"mincutA4", "ComposerMap":[{"width":"179.0","height":"140.826","index":0, "name":"map0"},{"width":"77.729","height":"55.9066","index":1, "name":"map7"}]},
				     {"ComposerTemplate":"mincutA3","ComposerMap":[{"width":"53.44","height":"55.9066","index":0, "name":"map7"},{"width":"337.865","height":"275.914","index":1, "name":"map6"}]}]
				     }}$$);

 SELECT gw_fct_getprofilevalues($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "initNode":"64", "endNode":"38", "linksDistance":, "scale":{ "eh":1000, "ev":1000}}}$$);


-- fid: 222

Mains:
- 3 types of nodes
	- TOP: Normal case, dimensions provided and node has representation on surface
	- BOTTOM: Node has not representation on surface (node_type WHERE isprofilesurface IS FALSE)
	- VNODES: vnodes, to represent only terrain
- 2 types of data
	- REAL: Data is fullfilled on nodes (sys_top_elev, sys_elev, sys_ymax)
	- INTERPOLATED: When data is missed in some intermediate node, values are interpolated. Vnodes are automatic disabled

- profile works with user-friendly variables
	- Vnode min distance: Value to prevent on guitar when text is overlaped with another text

Is mandatory start-end nodes must have data, and must be profile_surface = true

*/

DECLARE

v_init  text;
v_init_aux text;
v_mid text;
v_end text;
v_end_aux text;
v_query_dijkstra text;
v_i json;
v_hs float;
v_vs float;
v_arc json;
v_node json;
v_terrain json;
v_llegend json;
v_stylesheet json;
v_version text;
v_status text = 'Accepted';
v_level integer = 3;
v_message text = 'Profile done successfully';
v_guitarlegend json;
v_textarc text;
v_textnode text;
v_vdefault json;
v_leaflet json;
v_composer text;
v_templates json;
v_json json;
v_project_type text;
v_height float;
v_index integer;
v_mapcomposer_name text;
v_scaletofit boolean;
v_array_width float[];
v_scale text;
v_extension json;
v_vstext text;
v_hstext text;
v_legendfactor float;
v_linksdistance float;
v_arc_geom1 float;
v_node_geom1 float;
i integer = 0;
v_dist float[];
v_telev float[];
v_elev float[];
v_nid text[];
v_systype text[];
v_elevation float;
v_distance float;
v_compheight float;
v_compwidth float;
v_profheigtht float;
v_profwidth float;
v_error_context text;
v_initv float;
v_inith float;
v_initpoint json;


-- field variables to work with UD/WS
v_fcatgeom text;
v_ftopelev text;
v_fymax text;
v_fslope text;
v_fsystopelev text;
v_fsyselev text;
v_fsysymax text;
v_querytext text;
v_elev1 text;
v_elev2 text;
v_z1 text;
v_z2 text;
v_y1 text;
v_y2 text;
v_papersize integer;
v_count integer;
v_nodemessage text;
v_querytext1 text;
v_querytext2 text;
v_count_int integer;
object_rec record;
v_vnode_status boolean;
v_result json;
v_result_line json;
v_result_point json;
v_result_polygon json;
v_device integer;
v_nonpriority_statetype text;
v_cost_string text;

BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get projectytpe
	SELECT project_type, giswater FROM sys_version ORDER BY id DESC LIMIT 1 INTO v_project_type, v_version;

	--  Get input data
	v_init = (p_data->>'data')::json->>'initNode';
	v_mid = (p_data->>'data')::json->>'midNodes';
	v_end = (p_data->>'data')::json->>'endNode';
	v_hs = ((p_data->>'data')::json->>'scale')::json->>'eh';
	v_vs = ((p_data->>'data')::json->>'scale')::json->>'ev';
	v_scaletofit := ((p_data->>'data')::json->>'scale')::json->>'scaleToFit';
	v_legendfactor = (p_data->>'data')::json->>'legendFactor';
	v_linksdistance = (p_data->>'data')::json->>'linksDistance';
	v_composer := (p_data ->> 'data')::json->> 'composer';
	v_templates := (p_data ->> 'data')::json->> 'ComposerTemplates';
	v_papersize := ((p_data ->> 'data')::json->> 'papersize')::json->>'id';
	v_device := (p_data ->> 'client')::json->> 'device';

	-- get systemvalues
	SELECT value INTO v_guitarlegend FROM config_param_system WHERE parameter = 'om_profile_guitarlegend';
	SELECT value INTO v_stylesheet FROM config_param_user WHERE parameter = 'om_profile_stylesheet' AND cur_user = current_user;
	SELECT value::json->>'arc' INTO v_textarc FROM config_param_system WHERE parameter = 'om_profile_guitartext';
	SELECT value::json->>'node' INTO v_textnode FROM config_param_system WHERE parameter = 'om_profile_guitartext';
	SELECT value INTO v_vdefault FROM config_param_system WHERE parameter = 'om_profile_vdefault';
	SELECT value::json->>'vs' INTO v_vstext FROM config_param_system WHERE parameter = 'om_profile_guitarlegend';
  	SELECT value::json->>'hs' INTO v_hstext FROM config_param_system WHERE parameter = 'om_profile_guitarlegend';
  	SELECT (value::json->>'arc')::json->>'cat_geom1' INTO v_arc_geom1 FROM config_param_system WHERE parameter = 'om_profile_vdefault';
  	SELECT (value::json->>'node')::json->>'cat_geom1' INTO v_node_geom1 FROM config_param_system WHERE parameter = 'om_profile_vdefault';
  	SELECT (value::json->>'vnodeStatus') INTO v_vnode_status FROM config_param_system WHERE parameter = 'om_profile_vdefault';

	-- create temp tables
	CREATE TEMP TABLE temp_vnode(
	  id serial NOT NULL,
	  l1 integer,
	  v1 integer,
	  l2 integer,
	  v2 integer,
	  CONSTRAINT temp_vnode_pkey PRIMARY KEY (id));

	CREATE TEMP TABLE temp_link(
	  link_id integer NOT NULL,
	  vnode_id integer,
	  vnode_type text,
	  feature_id character varying(16),
	  feature_type character varying(16),
	  exit_id character varying(16),
	  exit_type character varying(16),
	  state smallint,
	  expl_id integer,
	  sector_id integer,
	  dma_id integer,
	  exit_topelev double precision,
	  exit_elev double precision,
	  the_geom geometry(LineString,SRID_VALUE),
	  the_geom_endpoint geometry(Point,SRID_VALUE),
	  flag boolean,
	  CONSTRAINT temp_link_pkey PRIMARY KEY (link_id));

	CREATE TEMP TABLE temp_link_x_arc(
	  link_id integer NOT NULL,
	  vnode_id integer,
	  arc_id character varying(16),
	  feature_type character varying(16),
	  feature_id character varying(16),
	  node_1 character varying(16),
	  node_2 character varying(16),
	  vnode_distfromnode1 numeric(12,3),
	  vnode_distfromnode2 numeric(12,3),
	  exit_topelev double precision,
	  exit_ymax numeric(12,3),
	  exit_elev numeric(12,3),
	  CONSTRAINT temp_link_x_arc_pkey PRIMARY KEY (link_id));

	CREATE TEMP TABLE temp_anl_arc(LIKE SCHEMA_NAME.anl_arc INCLUDING ALL);
	CREATE TEMP TABLE temp_anl_node(LIKE SCHEMA_NAME.anl_node INCLUDING ALL);
	CREATE TEMP TABLE temp_v_edit_arc (LIKE SCHEMA_NAME.v_edit_arc INCLUDING ALL);

	insert into temp_v_edit_arc select * from v_edit_arc;


  	-- set value to v_linksdistance if null
	IF v_linksdistance IS NULL OR v_linksdistance < 0 THEN
		v_linksdistance = 0;
	END IF;

	SELECT json_extract_path_text(value::json,'state_type') INTO v_nonpriority_statetype
	FROM config_param_system WHERE parameter = 'om_profile_nonpriority_statetype';

	IF v_nonpriority_statetype IS NULL or v_nonpriority_statetype='' THEN
		 v_cost_string = 'gis_length::float ';
	ELSE
		v_cost_string = concat('case when state_type = ',v_nonpriority_statetype::integer,' THEN -1 ELSE gis_length::float END ');
	END IF;

	-- Check start-end nodes
	v_nodemessage = 'Start/End nodes is/are not valid(s). CHECK elev data. Only NOT start/end nodes may have missed elev data';
	IF v_project_type = 'UD' THEN
		IF (SELECT COUNT(*) FROM v_edit_node JOIN cat_feature_node ON node_type = id
			WHERE sys_elev IS NOT NULL AND sys_top_elev IS NOT NULL AND sys_ymax IS NOT NULL AND node_id = v_init) > 0
			THEN
			IF (SELECT COUNT(*) FROM v_edit_node JOIN cat_feature_node ON node_type = id
				WHERE sys_elev IS NOT NULL AND sys_top_elev IS NOT NULL AND sys_ymax IS NOT NULL AND node_id = v_end) = 0
				THEN
				v_level = 2;
				v_message = v_nodemessage;
			END IF;
		ELSE
			v_level = 2;
			v_message = v_nodemessage;
		END IF;
	END IF;

	-- Check not integer id''s
	FOR object_rec IN SELECT json_array_elements_text('["arc", "node"]'::json) as idval
	LOOP
		EXECUTE 'SELECT count(*) FROM v_edit_'||object_rec.idval||' ' INTO v_count;
		EXECUTE 'SELECT count(*) FROM v_edit_'||object_rec.idval||' WHERE '||object_rec.idval||'_id ~ ''^\d+$''' INTO v_count_int;
		v_count = v_count - v_count_int;

		IF v_count > 0 THEN
			v_level = 2;
			v_message = concat('There is/are ',v_count, ' ',object_rec.idval,'(s) with id''s not integer on the system. It is not possible to build the graph matrix to check shortestpath.');
		END IF;
	END LOOP;

	IF v_level = 3 THEN

		-- define variables in function of the project type
		IF v_project_type = 'UD' THEN
			v_fcatgeom = 'cat_geom1';
			v_ftopelev = 'top_elev';
			v_fymax = 'ymax';
			v_fslope = 'slope';
			v_fsystopelev = 'sys_top_elev';	v_fsyselev = 'sys_elev'; v_fsysymax = 'sys_ymax';

			v_querytext1 = ' UNION SELECT c.arc_id, vnode_id,link_id,''LINK'',gully_id, exit_topelev, exit_ymax, exit_elev, vnode_distfromnode1, total_length
				FROM temp_link_x_arc 
				JOIN anl_arc USING (arc_id)
				JOIN gully c ON c.gully_id = temp_link_x_arc.feature_id
				WHERE fid=222 AND cur_user = current_user
				AND anl_arc.node_1 = temp_link_x_arc.node_1';

			v_querytext2 = ' UNION SELECT c.arc_id, vnode_id,link_id,''LINK'',gully_id, exit_topelev, exit_ymax, exit_elev, vnode_distfromnode2, total_length
				FROM temp_link_x_arc 
				JOIN anl_arc USING (arc_id)
				JOIN gully c ON c.gully_id = temp_link_x_arc.feature_id
				WHERE fid=222 AND cur_user = current_user
				AND anl_arc.node_1 = temp_link_x_arc.node_2';

			v_elev1 = 'case when node_1=node_id then sys_elev1 else sys_elev2 end';
			v_elev2 = 'case when node_1=node_id then sys_elev2 else sys_elev1 end';
			v_z1 = 'case when node_1=node_id then b.z1 else b.z2 end';
			v_z2 = 'case when node_1=node_id then b.z2 else b.z1 end';
			v_y1 = 'case when node_1=node_id then sys_y1 else sys_y2 end';
			v_y2 = 'case when node_1=node_id then sys_y2 else sys_y1 end';

		ELSIF v_project_type = 'WS' THEN

			v_fcatgeom = 'cat_dnom::float*0.001'; v_ftopelev = 'elevation'; v_fymax = 'depth'; v_fslope = '100*(elevation1 - depth1 - elevation2 + depth2)/gis_length';
			v_fsyselev = 'elevation - depth'; v_fsystopelev = v_ftopelev; v_fsysymax = v_fymax;
			v_querytext = '';
			v_querytext1 = '';
			v_querytext2 = '';
			v_elev1 = 'case when node_1=node_id then elevation1 else elevation2 end';
			v_elev2 = 'case when node_1=node_id then elevation2 else elevation1 end';
			v_z1 = '0::integer';
			v_z2 = '0::integer';
			v_y1 = 'case when node_1=node_id then depth1 else depth2 end';
			v_y2 = 'case when node_1=node_id then depth2 else depth1 end';
		END IF;


		v_query_dijkstra := 'SELECT edge::text AS arc_id, node::text AS node_id, agg_cost as total_length FROM pgr_dijkstra(''SELECT arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, 
					'||v_cost_string||' as cost, '||v_cost_string||' as reverse_cost FROM v_edit_arc WHERE node_1 is not null AND node_2 is not null'', '||v_init||','||v_end||')';

		IF v_mid IS NOT NULL THEN
			v_query_dijkstra = '';
			v_init_aux = v_init;
			FOR v_i IN SELECT * FROM json_array_elements(v_mid::json)
			LOOP
				-- Get starting point
				v_end_aux = v_i;

				-- DIJKSTRA v_init_aux -> v_end_aux
				v_query_dijkstra = 'SELECT edge::text AS arc_id, node::text AS node_id, (select coalesce(max(total_distance), 0) from temp_anl_node where fid = ''222'' and cur_user = current_user) + agg_cost as total_length 
				FROM pgr_dijkstra(''SELECT arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, '||v_cost_string||' as cost, 
					'||v_cost_string||' as reverse_cost FROM v_edit_arc WHERE node_1 is not null AND node_2 is not null'', '||v_init_aux||','||v_end_aux||')';

				-- We need to insert values each dijkstra for the total_length to keep accumulating
				-- insert edge values on temp_anl_arc table
				EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, code, node_1, node_2, sys_type, arccat_id, cat_geom1, length, slope, total_length, z1, z2, y1, y2, elev1, elev2, expl_id, the_geom)
					SELECT  222, arc_id, code, node_id, case when node_1=node_id then node_2 else node_1 end as node_2, sys_type, arccat_id, '||v_fcatgeom||', 
					gis_length, '||v_fslope||', total_length, '||v_z1||', '||v_z2||', '||v_y1||', '||v_y2||', '
					||v_elev1||', '||v_elev2||', expl_id, the_geom FROM v_edit_arc b JOIN cat_arc ON arccat_id = id JOIN 
					('|| v_query_dijkstra ||')a
					USING (arc_id)
					WHERE b.state > 0';

				-- insert node values on temp_anl_node table
				EXECUTE 'INSERT INTO temp_anl_node (fid, node_id, code, '||v_ftopelev||', '||v_fymax||', elev, sys_type, nodecat_id, cat_geom1, arc_id, arc_distance, total_distance, expl_id, the_geom)
					SELECT  222, node_id, n.code, '||v_fsystopelev||', '||v_fsysymax||', '||v_fsyselev||', n.sys_type, nodecat_id, null, a.arc_id, 0, total_length, expl_id, the_geom
					FROM v_edit_node n JOIN cat_node ON nodecat_id = id JOIN
					('|| v_query_dijkstra ||')a
					USING (node_id)';

				-- Get end point
				v_init_aux = v_end_aux;
			END LOOP;

			-- Last DIJKSTRA
			v_query_dijkstra = concat('SELECT edge::text AS arc_id, node::text AS node_id, (select coalesce(max(total_distance), 0) from temp_anl_node where fid = ''222'' and cur_user = current_user) + agg_cost as total_length 
			FROM pgr_dijkstra(''SELECT arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, 
			 '||v_cost_string||' as cost, '||v_cost_string||' as reverse_cost 
			FROM v_edit_arc WHERE node_1 is not null AND node_2 is not null'', '||v_init_aux||','||v_end||')');

		END IF;

		-- insert edge values on temp_anl_arc table
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, code, node_1, node_2, sys_type, arccat_id, cat_geom1, length, slope, total_length, z1, z2, y1, y2, elev1, elev2, expl_id, the_geom)
			SELECT  222, arc_id, code, node_id, case when node_1=node_id then node_2 else node_1 end as node_2, sys_type, arccat_id, '||v_fcatgeom||', gis_length, 
			'||v_fslope||', total_length, '||v_z1||', '||v_z2||', '||v_y1||', '||v_y2||', '
			||v_elev1||', '||v_elev2||', expl_id, the_geom FROM v_edit_arc b JOIN cat_arc ON arccat_id = id JOIN 
			('|| v_query_dijkstra ||')a
			USING (arc_id)
			WHERE b.state > 0';

		-- insert node values on temp_anl_node table
		EXECUTE 'INSERT INTO temp_anl_node (fid, node_id, code, '||v_ftopelev||', '||v_fymax||', elev, sys_type, nodecat_id, cat_geom1, arc_id, arc_distance, total_distance, expl_id, the_geom)
			SELECT  222, node_id, n.code, '||v_fsystopelev||', '||v_fsysymax||', '||v_fsyselev||', n.sys_type, nodecat_id, null, a.arc_id, 0, total_length, expl_id, the_geom
			FROM v_edit_node n JOIN cat_node ON nodecat_id = id JOIN
			('|| v_query_dijkstra ||')a
			USING (node_id)';

		-- looking for null values (in case of exists links graph will be disabled as below)
		IF v_project_type = 'UD' THEN
			SELECT count(*) INTO v_count FROM temp_anl_node WHERE (elev IS NULL or ymax is null OR top_elev is null);
		ELSIF v_project_type = 'WS' THEN
			SELECT count(*) INTO v_count FROM temp_anl_node WHERE (elevation IS NULL or depth is null);
		END IF;

		IF v_linksdistance > 0 AND v_count = 0 and v_vnode_status IS NOT False THEN

			-- generate temp link table
			PERFORM gw_fct_linkexitgenerator(2);

			-- generate arc_x_link values
			IF v_project_type = 'UD' THEN

				DELETE FROM temp_link_x_arc;
				INSERT INTO temp_link_x_arc
				select * FROM (
				 SELECT DISTINCT ON (link_id) a.link_id, a.vnode_id, a.arc_id, a.feature_type,a.feature_id, a.node_1,  a.node_2,
				    (a.length * a.locate::double precision)::numeric(12,3) AS vnode_distfromnode1,
				    (a.length * (1::numeric - a.locate)::double precision)::numeric(12,3) AS vnode_distfromnode2,
					CASE
					    WHEN a.exit_topelev IS NULL THEN (a.top_elev1 - a.locate * (a.top_elev1 - a.top_elev2))::numeric(12,3)::double precision
					    ELSE a.exit_topelev
					END AS exit_topelev,
				    (a.sys_y1 - a.locate * (a.sys_y1 - a.sys_y2))::numeric(12,3) AS exit_ymax,
				    (a.sys_elev1 - a.locate * (a.sys_elev1 - a.sys_elev2))::numeric(12,3) AS exit_elev
				   FROM ( SELECT t.link_id,
					    t.exit_id::integer AS vnode_id,
					    v_edit_arc.arc_id, t.feature_type, t.feature_id, t.exit_topelev,st_length(v_edit_arc.the_geom) AS length,
					    st_linelocatepoint(v_edit_arc.the_geom, st_endpoint(t.the_geom))::numeric(12,3) AS locate,
					    v_edit_arc.node_1, v_edit_arc.node_2, v_edit_arc.sys_elev1, v_edit_arc.sys_elev2,v_edit_arc.sys_y1,  v_edit_arc.sys_y2,
					    v_edit_arc.sys_elev1 + v_edit_arc.sys_y1 AS top_elev1,
					    v_edit_arc.sys_elev2 + v_edit_arc.sys_y2 AS top_elev2
					   FROM temp_v_edit_arc v_edit_arc, temp_link t
					    WHERE st_dwithin(v_edit_arc.the_geom, t.the_geom_endpoint, 0.01::double precision) AND v_edit_arc.state > 0 AND t.state > 0 AND exit_type ='ARC'
					    and arc_id in (select arc_id from temp_anl_arc) ) a)b
					    ORDER BY arc_id, node_2 DESC;

			ELSIF v_project_type = 'WS' THEN

				DELETE FROM temp_link_x_arc;
				INSERT INTO temp_link_x_arc
				select * FROM (
				SELECT DISTINCT ON (link_id) a.link_id, a.vnode_id,  a.arc_id, a.feature_type, a.feature_id, a.node_1, a.node_2,
				    (a.length * a.locate::double precision)::numeric(12,3) AS vnode_distfromnode1,
				    (a.length * (1::numeric - a.locate)::double precision)::numeric(12,3) AS vnode_distfromnode2,
					CASE
					    WHEN a.exit_topelev IS NULL THEN (a.elevation1 - a.locate * (a.elevation1 - a.elevation2))::numeric(12,3)::double precision
					    ELSE a.exit_topelev
					END AS exit_topelev,
				    (a.depth1 - a.locate * (a.depth1 - a.depth2))::numeric(12,3) AS exit_ymax,
				    (a.elev1 - a.locate * (a.elev1 - a.elev2))::numeric(12,3) AS exit_elev
				   FROM ( SELECT t.link_id, t.vnode_id, v_arc.arc_id, t.feature_type, t.feature_id,  t.exit_topelev,  st_length(v_arc.the_geom) AS length,
					    st_linelocatepoint(v_arc.the_geom, t.the_geom_endpoint)::numeric(12,3) AS locate, v_arc.node_1, v_arc.node_2, v_arc.elevation1,
					    v_arc.elevation2,  v_arc.depth1,  v_arc.depth2, v_arc.elevation1 - v_arc.depth1 AS elev1,  v_arc.elevation2 - v_arc.depth2 AS elev2
					   FROM temp_v_edit_arc v_arc, temp_link t
					  WHERE st_dwithin(v_arc.the_geom, t.the_geom_endpoint, 0.01::double precision) AND v_arc.state > 0 AND t.state > 0
 					   and arc_id in (select arc_id from temp_anl_arc)) a)b
				  ORDER BY arc_id, node_2 DESC;
			END IF;


			-- get vnode-connec values
			EXECUTE 'INSERT INTO temp_anl_node (fid, sys_type, node_id, code, '||v_ftopelev||', '||v_fymax||', elev, arc_id , arc_distance, total_distance)
				SELECT 222, feature_type, feature_id, link_id, exit_topelev, exit_ymax, exit_elev, arc_id, dist, dist+total_length
				FROM (SELECT DISTINCT ON (dist) * FROM 
				(
				-- connec on same sense (pg_routing & arc)
				SELECT c.arc_id, vnode_id,link_id,''LINK'' as feature_type, connec_id as feature_id, exit_topelev, exit_ymax, exit_elev, vnode_distfromnode1 as dist, total_length
					FROM temp_link_x_arc 
					JOIN temp_anl_arc USING (arc_id)
					JOIN connec c ON c.connec_id = temp_link_x_arc.feature_id
					WHERE temp_anl_arc.node_1 = temp_link_x_arc.node_1
				'||v_querytext1||'-- gully on same sense (pg_routing & arc)
				UNION
				-- connec on reverse sense (pg_routing & arc)
				SELECT c.arc_id, vnode_id,link_id,''LINK'' as feature_type, connec_id as feature_id,exit_topelev, exit_ymax, exit_elev, vnode_distfromnode2 as dist, total_length
					FROM temp_link_x_arc 
					JOIN temp_anl_arc USING (arc_id)
					JOIN connec c ON c.connec_id = temp_link_x_arc.feature_id
					WHERE temp_anl_arc.node_1 = temp_link_x_arc.node_2
				'||v_querytext2||' -- gully on reverse sense (pg_routing & arc)
				)a
			)b 
			ORDER BY b.arc_id, dist';

			-- get vnode-gully values
			IF v_project_type = 'UD' THEN

				EXECUTE 'INSERT INTO temp_anl_node (fid, sys_type, node_id, code, '||v_ftopelev||', '||v_fymax||', elev, arc_id , arc_distance, total_distance)
				SELECT 222, feature_type, feature_id, link_id, exit_topelev, exit_ymax, exit_elev, arc_id, dist, dist+total_length
				FROM (SELECT DISTINCT ON (dist) * FROM 
				(
				-- gully on same sense (pg_routing & arc)
				SELECT c.arc_id, vnode_id,link_id,''LINK'' as feature_type, gully_id as feature_id, exit_topelev, exit_ymax, exit_elev, vnode_distfromnode1 as dist, total_length
					FROM temp_link_x_arc 
					JOIN temp_anl_arc USING (arc_id)
					JOIN gully c ON c.gully_id = temp_link_x_arc.feature_id
					WHERE temp_anl_arc.node_1 = temp_link_x_arc.node_1
				'||v_querytext1||'-- gully on same sense (pg_routing & arc)
				UNION
				-- gully on reverse sense (pg_routing & arc)
				SELECT c.arc_id, vnode_id,link_id,''LINK'' as feature_type, gully_id as feature_id,exit_topelev, exit_ymax, exit_elev, vnode_distfromnode2 as dist, total_length
					FROM temp_link_x_arc 
					JOIN temp_anl_arc USING (arc_id)
					JOIN gully c ON c.gully_id = temp_link_x_arc.feature_id
					WHERE temp_anl_arc.node_1 = temp_link_x_arc.node_2
				'||v_querytext2||' -- gully on reverse sense (pg_routing & arc)
				)a
				)b 
				ORDER BY b.arc_id, dist';
			end if;

		-- delete links overlaped with nodes using the user's parameter
			v_dist = (SELECT array_agg(total_distance) FROM (SELECT total_distance FROM temp_anl_node order by total_distance, arc_id)a);
			v_nid = (SELECT array_agg(node_id) FROM (SELECT node_id FROM temp_anl_node order by total_distance, arc_id)a);
			v_systype = (SELECT array_agg(sys_type) FROM (SELECT sys_type FROM temp_anl_node order by total_distance, arc_id)a);
			LOOP
				i = i+1;
				EXIT WHEN v_nid[i] IS NULL;

				--distance values
				IF ((v_dist[i] < (v_dist[i-1]+ v_linksdistance)) OR (v_dist[i] > (v_dist[i+1]+ v_linksdistance))) AND v_systype[i] = 'LINK' THEN
					DELETE FROM temp_anl_node WHERE node_id = v_nid[i];
				END IF;
			END LOOP;

		ELSIF v_linksdistance > 0 AND v_count > 0 THEN
			v_level = 3;
			v_message = 'Profile done, but during the execution vnode information have been disabled because only is possible to interpolate missed data on intermediate nodes, but not vnodes.';
		END IF;

		-- update descript and code field
		EXECUTE 'UPDATE temp_anl_arc SET descript = a.descript, code=a.code 
		FROM (SELECT arc_id, (row_to_json(row)) AS descript, case when code is null then arc_id else code end as code FROM ('||v_textarc||')row)a WHERE a.arc_id = temp_anl_arc.arc_id AND fid=222';
		EXECUTE' UPDATE temp_anl_node SET descript = a.descript FROM (SELECT node_id, (row_to_json(row)) AS descript FROM 
					(SELECT node_id, '||v_ftopelev||' as top_elev, '||v_fymax||' as ymax, elev , case when code is null then node_id else code end as code, 
					total_distance FROM temp_anl_node WHERE fid=222 AND cur_user = current_user)row)a
					WHERE a.node_id = temp_anl_node.node_id';

		EXECUTE 'UPDATE temp_anl_node SET  descript = gw_fct_json_object_set_key(descript::json, ''code'', a.code) 
		FROM (SELECT node_id, case when code is null then node_id else code end code FROM ('||v_textnode||')row)a WHERE a.node_id = temp_anl_node.node_id ';

		-- delete not used keys
		UPDATE temp_anl_arc SET descript = gw_fct_json_object_delete_keys(descript::json, 'arc_id')  ;
		UPDATE temp_anl_node SET descript = gw_fct_json_object_delete_keys(descript::json, 'node_id')  ;

		-- update node table setting default values
		UPDATE temp_anl_arc SET cat_geom1 = v_arc_geom1 WHERE cat_geom1 IS NULL ;
		UPDATE temp_anl_node SET cat_geom1 = v_node_geom1 WHERE cat_geom1 IS NULL AND sys_type !='LINK';

		-- update arc table when node has not values and need to be interpolated
		UPDATE temp_anl_arc SET z1 = 0, sys_type  = 'SLOPE-ESTIMATED' WHERE z1 is null ;
		UPDATE temp_anl_arc SET z2 = 0, sys_type  = 'SLOPE-ESTIMATED' WHERE z2 is null ;
		UPDATE temp_anl_arc SET sys_type = 'SLOPE-REAL' WHERE sys_type != 'SLOPE-ESTIMATED' ;

		-- update node table when node has not values and need to be interpolated
		v_dist = (SELECT array_agg(total_distance) FROM (SELECT total_distance FROM temp_anl_node order by total_distance, arc_id)a);
		EXECUTE '(SELECT array_agg(top_elev) FROM (SELECT '||v_ftopelev||' as top_elev FROM temp_anl_node order by total_distance, arc_id)a)' INTO v_telev;
		v_elev = (SELECT array_agg(elev) FROM (SELECT elev FROM temp_anl_node order by total_distance, arc_id)a);
		v_nid = (SELECT array_agg(node_id) FROM (SELECT node_id FROM temp_anl_node order by total_distance, arc_id)a);

		i = 0;
		LOOP
			i = i+1;
			EXIT WHEN v_nid[i] IS NULL;

			--topelev values
			IF v_telev[i] IS NULL THEN

				IF v_telev[i+1] IS NOT NULL AND v_telev[i-1] IS NOT NULL THEN
					v_querytext = 'UPDATE temp_anl_node SET '||v_ftopelev||' = ('||v_telev[i-1]||'+ (('||v_dist[i]||'-'||v_dist[i-1]||')*('||v_telev[i+1]||'-'||v_telev[i-1]||')/('||v_dist[i+1]||'-'||v_dist[i-1]||')))::numeric(12,3) 
						       WHERE node_id::integer = '||v_nid[i];
					EXECUTE v_querytext;

				ELSIF v_telev[i+1] IS NOT NULL AND v_telev[i-2] IS NOT NULL THEN
					v_querytext = 'UPDATE temp_anl_node SET '||v_ftopelev||' = ('||v_telev[i-2]||'+ (('||v_dist[i]||'-'||v_dist[i-2]||')*('||v_telev[i+1]||'-'||v_telev[i-2]||')/('||v_dist[i+1]||'-'||v_dist[i-2]||')))::numeric(12,3) 
						       WHERE node_id::integer = '||v_nid[i];
					EXECUTE v_querytext;

				ELSIF v_telev[i+2] IS NOT NULL AND v_telev[i-1] IS NOT NULL THEN
					v_querytext = 'UPDATE temp_anl_node SET '||v_ftopelev||' = ('||v_telev[i-1]||'+ (('||v_dist[i]||'-'||v_dist[i-1]||')*('||v_telev[i+2]||'-'||v_telev[i-1]||')/('||v_dist[i+2]||'-'||v_dist[i-1]||')))::numeric(12,3) 
						       WHERE node_id::integer = '||v_nid[i];
					EXECUTE v_querytext;

				ELSIF v_telev[i+2] IS NOT NULL AND v_telev[i-2] IS NOT NULL THEN
					v_querytext = 'UPDATE temp_anl_node SET '||v_ftopelev||' = ('||v_telev[i-2]||'+ (('||v_dist[i]||'-'||v_dist[i-2]||')*('||v_telev[i+2]||'-'||v_telev[i-2]||')/('||v_dist[i+2]||'-'||v_dist[i-2]||')))::numeric(12,3) 
						       WHERE node_id::integer = '||v_nid[i];
					EXECUTE v_querytext;
				ELSE
					v_level  = 2;
					v_message = 'Interpolation tool it is designed to interpolate with data missed maximun at two consecutives nodes. Please check your data!';
				END IF;

				UPDATE temp_anl_node SET result_id = 'interpolated', descript = gw_fct_json_object_set_key(descript::json, 'top_elev', 'None'::text)
				WHERE node_id = v_nid[i];
			END IF;

			--elev values
			IF v_elev[i] IS NULL THEN
				IF v_elev[i+1] IS NOT NULL AND v_elev[i-1] IS NOT NULL THEN
					UPDATE temp_anl_node SET elev = (v_elev[i-1]+ ((v_dist[i]-v_dist[i-1])*(v_elev[i+1]-v_elev[i-1])/(v_dist[i+1]-v_dist[i-1])))::numeric(12,3) WHERE node_id = v_nid[i];
				ELSIF v_elev[i+1] IS NOT NULL AND v_elev[i-2] IS NOT NULL THEN
					UPDATE temp_anl_node SET elev = (v_elev[i-2]+ ((v_dist[i]-v_dist[i-2])*(v_elev[i+1]-v_elev[i-2])/(v_dist[i+1]-v_dist[i-2])))::numeric(12,3) WHERE node_id = v_nid[i];
				ELSIF v_elev[i+2] IS NOT NULL AND v_elev[i-1] IS NOT NULL THEN
					UPDATE temp_anl_node SET elev = (v_elev[i-1]+ ((v_dist[i]-v_dist[i-1])*(v_elev[i+2]-v_elev[i-1])/(v_dist[i+2]-v_dist[i-1])))::numeric(12,3) WHERE node_id = v_nid[i];
				ELSIF v_elev[i+2] IS NOT NULL AND v_elev[i-2] IS NOT NULL THEN
					UPDATE temp_anl_node SET elev = (v_elev[i-2]+ ((v_dist[i]-v_dist[i-2])*(v_elev[i+2]-v_elev[i-2])/(v_dist[i+2]-v_dist[i-2])))::numeric(12,3) WHERE node_id = v_nid[i];
				ELSE
					v_level  = 2;
					v_message = 'Interpolation tool it is designed to interpolate with data missed maximun at two consecutives nodes. Please check your data!';
				END IF;

				UPDATE temp_anl_node SET  result_id = 'interpolated', descript = gw_fct_json_object_set_key(descript::json, 'elev', 'None'::text)
				WHERE fid=222 AND cur_user = current_user AND node_id = v_nid[i];
			END IF;

			UPDATE 	temp_anl_node SET nodecat_id = 'VNODE' WHERE fid=222 AND cur_user = current_user AND node_id = v_nid[i] AND nodecat_id IS NULL;
		END LOOP;

		-- update node table those ymax nulls
		EXECUTE 'UPDATE temp_anl_node SET descript = gw_fct_json_object_set_key(descript::json, ''ymax'', ''None''::text),  '||v_fymax||' = '||v_ftopelev||' - elev 
			WHERE fid=222 AND cur_user = current_user AND '||v_fymax||' IS NULL';

		-- update node catalog
		UPDATE temp_anl_node SET nodecat_id = 'BOTTOM' FROM cat_feature_node n JOIN cat_feature cf ON cf.id = n.id WHERE cf.feature_class = sys_type
		AND isprofilesurface IS FALSE AND nodecat_id !='VNODE';
		UPDATE temp_anl_node SET nodecat_id = 'TOP' WHERE nodecat_id NOT IN ('BOTTOM', 'VNODE') ;

		-- update node type
		UPDATE temp_anl_node SET sys_type = 'REAL' WHERE sys_type NOT IN ('LINK') ;
		UPDATE temp_anl_node SET sys_type = 'INTERPOLATED' WHERE result_id = 'interpolated' ;

		UPDATE temp_anl_node SET result_id = null where result_id is not null ;

		-- get profile dimensions
		EXECUTE 'SELECT max('||v_ftopelev||')-min(elev) FROM temp_anl_node '
		INTO v_elevation;
		v_distance = (SELECT max(total_distance) FROM temp_anl_node);

		-- get leaflet dimensions
		v_profheigtht = 1000*v_elevation/v_vs + v_legendfactor*50 + 10;
		v_profwidth = 1000*v_distance/v_hs + v_legendfactor*20 + 10; -- profile + guitar + margin


		-- get portrait extension
		IF v_composer !='' THEN
			SELECT * INTO v_json FROM json_array_elements(v_templates) AS a WHERE a->>'ComposerTemplate' = v_composer;

			-- select map with maximum width
			SELECT array_agg(a->>'width') INTO v_array_width FROM json_array_elements( v_json ->'ComposerMap') AS a;
			SELECT max (a) INTO v_compwidth FROM unnest(v_array_width) AS a;
			SELECT a->>'name' INTO v_mapcomposer_name FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE (a->>'width')::float = v_compwidth::float;
			SELECT a->>'height' INTO v_compheight FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE a->>'name' = v_mapcomposer_name;
			SELECT a->>'index' INTO v_index FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE a->>'name' = v_mapcomposer_name;

			IF v_scaletofit IS FALSE THEN
				IF v_compheight < v_profheigtht THEN
					v_level = 2;
					v_message = 'Profile too large. You need to modify the vertical scale or change the composer';
					RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
				END IF;
				IF v_compwidth < v_profwidth THEN
					v_level = 2;
					v_message = 'Profile too long. You need to modify the horitzontal scale or change the composer';
					RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
				END IF;
			END IF;
		ELSE
			-- set values for v_compheight & v_compwidth
			v_compheight = v_profheigtht;
			v_compwidth = v_profwidth;
		END IF;

		-- get portrait extension
		IF v_papersize = 0 THEN
			v_compwidth = (((p_data ->> 'data')::json->> 'papersize')::json->>'customDim')::json->>'xdim';
			v_compheight = (((p_data ->> 'data')::json->> 'papersize')::json->>'customDim')::json->>'ydim';
		ELSE
			v_compwidth = (SELECT addparam->>'xdim' FROM om_typevalue WHERE typevalue = 'profile_papersize' AND id = v_papersize::text);
			v_compheight = (SELECT addparam->>'ydim' FROM om_typevalue WHERE typevalue = 'profile_papersize' AND id = v_papersize::text);
		END IF;

		-- check dimensions against scale
		IF v_scaletofit IS FALSE THEN
			IF v_compheight < v_profheigtht THEN
				v_level = 2;
				v_message = 'Profile too large. You need to modify the vertical scale or change the composer';
				RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
			END IF;
			IF v_compwidth < v_profwidth THEN
				v_level = 2;
				v_message = 'Profile too long. You need to modify the horitzontal scale or change the composer';
				RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
			END IF;
			-- calculate the init point to start to draw profile
			v_initv = (v_compheight - v_profheigtht)/2;
			v_inith = (v_compwidth - v_profwidth)/2;
		ELSE
			-- calculate scale
			v_vs = (v_compheight - v_legendfactor*50 - 10)/(1000*v_elevation);
			v_hs = (v_compwidth - v_legendfactor*20 - 10)/(1000*v_distance);

			-- calculate the init point to start to draw profile
			v_initv = v_legendfactor*50;
			v_inith = v_legendfactor*20;
		END IF;

		IF v_compwidth IS NOT NULL  and v_compheight IS NOT NULL AND v_inith IS NOT NULL  and v_initv IS NOT NULL
			AND v_hs IS NOT NULL  AND v_hstext IS NOT NULL  AND v_vs IS NOT NULL AND v_vstext IS NOT NULL THEN

			-- extension as composer (redundant to fit the image as is)
			v_extension = (concat('{"width":', v_compwidth,', "height":', v_compheight,'}'))::json;

			-- initpoint to start to draw profile
			v_initpoint = (concat('{"initx":', v_inith,', "inity":', v_initv,'}'))::json;

			-- scale text
			v_scale = concat('1:',v_hs, '(',v_hstext,') - 1:',v_vs,'(',v_vstext,')');

			-- update values using scale factor
			v_hs = 2000/v_hs;
			v_vs = 500/v_vs;
		ELSE
			v_vs = 1;
			v_hs= 1;
		END IF;

		UPDATE temp_anl_arc SET cat_geom1 = cat_geom1*v_vs, length = length*v_hs ;
		EXECUTE 'UPDATE temp_anl_node SET cat_geom1 = cat_geom1*'||v_vs||', '||v_ftopelev||' = '||v_ftopelev||'*'||v_vs||', elev = elev*'||v_vs||', '||
		v_fymax||' = '||v_fymax||'*'||v_vs||' ';

		-- recover values form temp table into response (filtering by spacing certain distance of length in order to not collapse profile)
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_arc
		FROM (SELECT arc_id, descript, cat_geom1, length, z1, z2, y1, y2, elev1, elev2, node_1, node_2 FROM temp_anl_arc ORDER BY total_length) row;

		EXECUTE 'SELECT array_to_json(array_agg(row_to_json(row))) FROM (SELECT DISTINCT node_id, nodecat_id as surface_type, descript, sys_type as data_type, cat_geom1, '||
				v_ftopelev||' AS top_elev, elev, '||v_fymax||' AS ymax, total_distance FROM temp_anl_node WHERE nodecat_id != ''VNODE'' ORDER BY total_distance) row'
				INTO v_node;
				/*
				SELECT node_id, nodecat_id as surface_type, descript, sys_type, cat_geom1, top_elev, elev, ymax FROM temp_anl_node WHERE fid=222 AND cur_user = current_user AND nodecat_id != 'VNODE' ORDER BY total_distance
				select * from temp_anl_arc WHERE fid=222 AND cur_user = current_user order by total_length
				select * from temp_anl_node WHERE fid=222 AND cur_user = current_user ORDER BY total_distance
				*/

		EXECUTE 'SELECT array_to_json(array_agg(row_to_json(row))) FROM (
				WITH querytext AS (SELECT row_number() over (order by total_distance) as rid, * FROM temp_anl_node ORDER by total_distance)
				select row_number() over (order by a.total_distance) as rid, a.'||v_ftopelev||' as top_n1, b.'||v_ftopelev||' as top_n2, (b.'||v_ftopelev||'-a.'||v_ftopelev||')::numeric(12,3) as delta_y, 
				b.total_distance - a.total_distance as delta_x, a.total_distance as total_x, a.descript as label_n1, a.nodecat_id as surface_type from querytext a
				left join querytext b ON a.rid = b.rid-1 
				left join (select * from temp_anl_arc where fid = 222 AND cur_user = current_user) c ON a.arc_id = c.arc_id) row'
				INTO v_terrain;
				/*
				WITH querytext AS (SELECT row_number() over (order by total_distance) as rid, * FROM temp_anl_node where fid = 222 AND cur_user = current_user ORDER by total_distance)
				select row_number() over (order by a.total_distance) as rid, a.top_elev as top_n1, b.top_elev as top_n2, (b.top_elev-a.top_elev)::numeric(12,3) as delta_y,
				b.total_distance - a.total_distance as delta_x, a.total_distance as total_x, a.descript as label_n1, a.nodecat_id as surface_type from querytext a
				left join querytext b ON a.rid = b.rid-1
				left join (select * from temp_anl_arc where fid = 222 AND cur_user = current_user) c ON a.arc_id = c.arc_id
				*/

	END IF;

	IF v_device = 5 THEN
		SELECT jsonb_agg(features.feature) INTO v_result
		FROM (
	  	SELECT jsonb_build_object(
	     'type',       'Feature',
	    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	    'properties', to_jsonb(row) - 'the_geom',
	    'crs',concat('EPSG:',ST_SRID(the_geom))
	  	) AS feature
	  	FROM (SELECT arc_id, arccat_id, descript::json,expl_id, the_geom
	  	FROM  temp_anl_arc WHERE fid=222 AND cur_user = current_user) row) features;


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
	  	FROM (SELECT node_id, nodecat_id, descript::json,expl_id, the_geom
	  	FROM  temp_anl_node WHERE fid=222 AND cur_user = current_user AND nodecat_id!='VNODE') row) features;

		v_result := COALESCE(v_result, '{}');
		v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}');

		v_result_polygon = '{"geometryType":"", "features":[]}';

	ELSE
		v_result_polygon = '{"geometryType":"", "features":[]}';
		v_result_line = '{"geometryType":"", "features":[]}';
		v_result_point = '{"geometryType":"", "features":[]}';

	END IF;

	IF v_arc IS NULL THEN
		v_message = 'Unable to create a Profile. Check your path continuity before continue!';
		v_level = 2;
	END IF;

	-- control null values
	IF v_guitarlegend IS NULL THEN v_guitarlegend='{}'; END IF;
	IF v_stylesheet IS NULL THEN v_stylesheet='{}'; END IF;

	v_scale := COALESCE(v_scale, '{}');
	v_extension := COALESCE(v_extension, '{}');
	v_initpoint := COALESCE(v_initpoint, '{}');
	v_arc := COALESCE(v_arc, '{}');
	v_node := COALESCE(v_node, '{}');
	v_terrain := COALESCE(v_terrain, '{}');

	DROP TABLE IF EXISTS temp_anl_arc;
	DROP TABLE IF EXISTS temp_anl_node;
	DROP TABLE IF EXISTS temp_v_edit_arc;
	DROP TABLE IF EXISTS temp_vnode;
	DROP TABLE IF EXISTS temp_link;
	DROP TABLE IF EXISTS temp_link_x_arc;

	--  Return
	RETURN ('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
               ',"body":{"form":{}'||
               ',"data":{"legend":'||v_guitarlegend||','||
			'"scale":"'||v_scale||'",'||
			'"extension":'||v_extension||','||
			'"initpoint":'||v_initpoint||','||
			'"stylesheet":'||v_stylesheet||','||
			'"node":'||v_node||','||
			'"terrain":'||v_terrain||','||
			'"arc":'||v_arc||','||
			'"point":'||v_result_point||','||
			'"line":'||v_result_line||','||
			'"polygon":'||v_result_polygon||'}}}')::json;

	--EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ', "message":{"level":'||right(SQLSTATE, 1)||', "text":"'||to_json(SQLERRM)||'"},"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;