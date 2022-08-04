/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
--FUNCTION CODE: 2320

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_mincut_inverted_flowtrace(integer);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_mincut_inverted_flowtrace(result_id_arg integer)
  RETURNS integer AS
$BODY$

-- fid: 129

DECLARE

rec_valve record;
rec_tank record;
mincut_rec record;
exists_id text;
arc_aux public.geometry;
polygon_aux2 public.geometry;
node_aux public.geometry;    
rec_table record;
rec_result record;
first_row boolean;
inlet_path boolean=false;
element_id_arg varchar(16);
controlValue smallint;
node_1_aux varchar(16);
node_2_aux varchar(16);
query_text text;
v_debug Boolean;
v_data json;
v_macroexpl integer;
v_mincutversion integer;


BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- Get debug variable
	SELECT json_extract_path_text(value::json,'status')::boolean INTO v_debug FROM config_param_system WHERE parameter='om_mincut_debug';
	SELECT json_extract_path_text(value::json,'version')::int2 INTO v_mincutversion FROM config_param_system WHERE parameter='om_mincut_config';
	
	-- Starting process
	SELECT * INTO mincut_rec FROM om_mincut WHERE id=result_id_arg;
	SELECT macroexpl_id INTO v_macroexpl FROM exploitation WHERE expl_id=mincut_rec.expl_id;

	DELETE FROM temp_mincut;
	DELETE FROM temp_arc;

	-- Create the matrix to work with pgrouting
	INSERT INTO temp_mincut 
	SELECT a.id, a.source, a.target,
		(case when (a.id = b.id and a.source::text = b.source::text) then -1 else cost end) as cost, 			-- close especial case of config_graph_checkvalve only direct sense
		(case when (a.id = b.id and a.source::text != b.source::text) then -1 else reverse_cost end) as reverse_cost  	-- close especial case of config_graph_checkvalve only reverse sense
		FROM (
			SELECT v_edit_arc.arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, 
			(case when a.closed=true then -1 else 1 end) as cost,
			(case when a.closed=true then -1 else 1 end) as reverse_cost
			FROM v_edit_arc 
			JOIN exploitation ON v_edit_arc.expl_id=exploitation.expl_id
			LEFT JOIN (
				SELECT arc_id, true as closed FROM v_edit_arc JOIN exploitation ON v_edit_arc.expl_id=exploitation.expl_id
				WHERE 
				(node_1 IN (SELECT node_id FROM om_mincut_valve WHERE ((proposed=TRUE) AND result_id=result_id_arg))
				AND arc_id IN(SELECT arc_id FROM om_mincut_arc WHERE result_id=result_id_arg))
						
				OR (node_2 IN (SELECT node_id FROM om_mincut_valve WHERE ((proposed=TRUE) AND result_id=result_id_arg))
				AND arc_id IN(SELECT arc_id FROM om_mincut_arc WHERE result_id=result_id_arg)) 

				OR (node_1 IN (SELECT node_id FROM om_mincut_valve WHERE closed=TRUE AND proposed IS NOT TRUE AND result_id=result_id_arg))
						
				OR (node_2 IN (SELECT node_id FROM om_mincut_valve WHERE closed=TRUE AND proposed IS NOT TRUE AND result_id=result_id_arg))	
				UNION
				SELECT json_array_elements_text((parameters->>'inletArc')::json) as arc_id, true as closed FROM config_graph_inlet
				)a 
			ON a.arc_id=v_edit_arc.arc_id
			WHERE node_1 is not null and node_2 is not null
		)a	
		LEFT JOIN (SELECT to_arc::int8 AS id, node_id::int8 AS source FROM config_graph_checkvalve)b USING (id);


	-- Loop for all the proposed valves
	FOR rec_valve IN SELECT node_id FROM om_mincut_valve WHERE result_id=result_id_arg AND proposed=TRUE
	LOOP
		IF v_debug THEN
			RAISE NOTICE 'Starting flow analysis process for valve: %', rec_valve.node_id;
		END IF;
		FOR rec_tank IN 
		SELECT v_edit_node.node_id, v_edit_node.the_geom FROM config_graph_inlet
		JOIN v_edit_node ON v_edit_node.node_id=config_graph_inlet.node_id
		JOIN value_state_type ON state_type=value_state_type.id 
		JOIN exploitation ON exploitation.expl_id=config_graph_inlet.expl_id
		WHERE (is_operative IS TRUE) AND (exploitation.macroexpl_id=v_macroexpl) AND config_graph_inlet.active IS TRUE 
		AND v_edit_node.the_geom IS NOT NULL AND v_edit_node.node_id NOT IN (select node_id FROM om_mincut_node WHERE result_id=result_id_arg)
		ORDER BY 1
		LOOP
			/*
			The aim of this query_text is to draw (if exists) routing from valve to tank defineds on the loop using the pgrouting function ''pgr_dijkstra''
			We need to create the network matrix (transfering the closed status of closed valves an proposed valves to the closests arcs) 
			In order to transfer this propierty to the arc we need to identify
				1) Arcs into the proposed sector with node1 or node2 as proposed valves
				2) Arcs out of the proposed sector with node1 or node2 as (closed valves and not proposed valves)
			*/

			query_text:= 'SELECT * FROM pgr_dijkstra( ''SELECT id, source, target, cost, reverse_cost 
							FROM temp_mincut'','||rec_valve.node_id||'::int8, '||rec_tank.node_id||'::int8)';

			IF query_text IS NOT NULL THEN	
				IF v_debug IS TRUE THEN 
					IF v_debug THEN
						RAISE NOTICE' query_text: %',query_text;
					END IF;
				END IF;

				EXECUTE query_text INTO rec_result;
	
			END IF;

			IF rec_result IS NOT NULL THEN
				inlet_path=true;
				IF v_debug THEN
					RAISE NOTICE 'valve % tank % inlet_path % ', rec_valve.node_id, rec_tank.node_id, inlet_path;
					RAISE NOTICE '-------------------------------------------------------------------------------';
				END IF;
				IF v_debug IS TRUE THEN 
					FOR rec_result IN EXECUTE query_text
					LOOP 
						INSERT INTO audit_log_data(fid, feature_id, log_message, cur_user) VALUES (129, rec_result.edge, concat(result_id_arg, ':', 
						rec_valve.node_id,'-',rec_tank.node_id), current_user);
					END LOOP;			
				END IF;
	
				EXIT;
			ELSE 
				inlet_path=false;
				IF v_debug THEN
					RAISE NOTICE 'valve % tank % inlet_path % ', rec_valve.node_id, rec_tank.node_id, inlet_path;
					RAISE NOTICE '-------------------------------------------------------------------------------';
				END IF;
			END IF;

		END LOOP;
	
		IF inlet_path IS FALSE THEN
		
			IF v_debug THEN
				RAISE NOTICE 'Finding additional affectations for valve %', rec_valve.node_id;
			END IF;
			
			SELECT arc_id INTO element_id_arg FROM v_edit_arc WHERE (node_1=rec_valve.node_id OR node_2=rec_valve.node_id)
			AND arc_id NOT IN (SELECT arc_id FROM om_mincut_arc WHERE result_id=result_id_arg);
	
			IF element_id_arg IS NOT NULL THEN
		
				-- Insert arc id
				IF v_debug THEN
					RAISE NOTICE 'Manage arc on the other side for non-inlet valve: %',element_id_arg;
				END IF;

				IF v_mincutversion =  3 THEN

					-- Select public.geometry
					SELECT the_geom INTO arc_aux FROM v_edit_arc WHERE arc_id = element_id_arg;

					INSERT INTO "om_mincut_arc" (arc_id, the_geom, result_id) VALUES (element_id_arg, arc_aux, result_id_arg);

					-- Run for extremes node
					SELECT node_1, node_2 INTO node_1_aux, node_2_aux FROM v_edit_arc WHERE arc_id = element_id_arg;
			
					-- Check extreme being a closed valve
					SELECT COUNT(*) INTO controlValue FROM om_mincut_valve 
					WHERE node_id = node_1_aux AND ((closed=TRUE) OR (proposed=TRUE)) AND result_id=result_id_arg;
					IF controlValue = 0 THEN
						-- Compute the tributary area using DFS
						PERFORM gw_fct_mincut_inverted_flowtrace_engine(node_1_aux, result_id_arg);
					END IF;
			
					-- Check other extreme being a closed valve
					SELECT COUNT(*) INTO controlValue FROM om_mincut_valve 
					WHERE node_id = node_2_aux AND ((closed=TRUE) OR (proposed=TRUE)) AND result_id=result_id_arg;
					
					IF controlValue = 0 THEN
						-- Compute the tributary area using DFS
						PERFORM gw_fct_mincut_inverted_flowtrace_engine(node_2_aux, result_id_arg);
					END IF;
				ELSE
					-- agg arc_id in order to collect into gw_fct_graphanalytics_mincut function
					INSERT INTO temp_arc (arc_id, result_id) VALUES (element_id_arg, result_id_arg);						
				END IF;
			END IF;
			
			--Valve has no exit. Update proposed value
			UPDATE om_mincut_valve SET proposed=FALSE WHERE result_id=result_id_arg AND node_id=rec_valve.node_id;
		END IF;	
	END LOOP;

	-- call graph analytics function
	IF v_mincutversion = 4 OR v_mincutversion =  5 THEN
		v_data = concat ('{"data":{"graphClass":"MINCUT", "step":2, "parameters":{"id":', result_id_arg ,'}}}');	
		PERFORM gw_fct_graphanalytics_mincut(v_data);	
	END IF;
	
	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;