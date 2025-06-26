/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 1136


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_topocontrol_node()
  RETURNS trigger AS
$BODY$
DECLARE
v_node record;
v_querytext Varchar;
v_arcrec Record;
v_noderecord1 Record;
v_noderecord2 Record;
v_x double precision;
v_y double precision;
v_pol varchar;
v_topelev double precision;
v_arc record;
v_arcrecord "SCHEMA_NAME".v_edit_arc;
v_arcrecordtb "SCHEMA_NAME".arc;
v_node_proximity_control boolean;
v_node_proximity double precision;
v_dsbl_error boolean;
v_psector_id integer;
v_tempvalue text;
v_mantable text;
v_epatable text;
v_manquerytext1 text;
v_manquerytext2 text;
v_epaquerytext1 text;
v_epaquerytext2 text;
v_schemaname text;
v_gully_id varchar;
v_connec_id varchar;
v_linkrec record;
v_message text;
v_trace_featuregeom boolean;

v_sys_elev1 double precision;
v_sys_elev2 double precision;
v_sys_top_elev double precision;
v_sys_elev double precision;
v_node2_sys_top_elev double precision;
v_node2_sys_elev double precision;
v_length double precision;
v_slope  double precision;

rec_addfields record;
v_sql text;
v_query_string_update text;
v_arc_childtable_name text;
v_arc_type text;
v_node_replace_code boolean;


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    v_schemaname = 'SCHEMA_NAME';


	-- Get parameters
	SELECT ((value::json)->>'activated') INTO v_node_proximity_control FROM config_param_system WHERE parameter='edit_node_proximity';
	SELECT ((value::json)->>'value') INTO v_node_proximity FROM config_param_system WHERE parameter='edit_node_proximity';
    SELECT value::boolean INTO v_dsbl_error FROM config_param_system WHERE parameter='edit_topocontrol_disable_error' ;
	SELECT value INTO v_psector_id FROM config_param_user WHERE cur_user=current_user AND parameter = 'plan_psector_current';
    SELECT value::boolean INTO v_node_replace_code FROM config_param_system WHERE parameter='plan_node_replace_code';

    --Check if user has migration mode enabled
    IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_disable_topocontrol' AND cur_user=current_user) IS TRUE THEN
        v_node_proximity_control = FALSE;
        v_dsbl_error = TRUE;
    END IF;

	-- For state=0
    IF NEW.state=0 THEN
		RAISE WARNING 'Topology is not enabled with state=0. The feature will be inserted but disconected of the network!';
		RETURN NEW;

	-- For state=1,2
    ELSE

		-- State control (permissions to work with state=2 and possibility to downgrade feature to state=0)
		PERFORM gw_fct_state_control(json_build_object('feature_type_aux', 'NODE', 'feature_id_aux', NEW.node_id, 'state_aux', NEW.state, 'tg_op_aux', TG_OP));

		IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE ' THEN


			-- Checking conflict state=1 nodes (exiting vs new one)
			IF (NEW.state=1) AND (v_node_proximity_control IS TRUE) THEN

				-- check existing state=1 nodes
				SELECT * INTO v_node FROM node WHERE ST_DWithin(NEW.the_geom, node.the_geom, v_node_proximity) AND node.node_id != NEW.node_id AND node.state=1;
				IF v_node.node_id IS NOT NULL THEN

					IF v_dsbl_error IS NOT TRUE THEN
						EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
						"data":{"message":"1097", "function":"1136","parameters":{"node_id":"'||NEW.node_id||'"}}}$$);';
					ELSE
						SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 1097;
						INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (106, NEW.node_id, v_message);
					END IF;
				END IF;

			-- Checking conflict state=2 nodes (exitings on same alternative vs new one)
			ELSIF (NEW.state=2) AND (v_node_proximity_control IS TRUE) THEN

				-- check existing state=2 nodes on same alternative
				SELECT * INTO v_node FROM node JOIN plan_psector_x_node USING (node_id) WHERE ST_DWithin(NEW.the_geom, node.the_geom, v_node_proximity)
				AND node.node_id != NEW.node_id AND node.state=2 AND psector_id=v_psector_id;

				IF v_node.node_id IS NOT NULL THEN

					IF v_dsbl_error IS NOT TRUE THEN
						EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
						"data":{"message":"1096", "function":"1136","parameters":{"node_id":"'||NEW.node_id||'"}}}$$);';
					ELSE
						SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 1096;
						INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (106, NEW.node_id, v_message);
					END IF;
				END IF;
			END IF;

			-- check for existing node (1)
			SELECT * INTO v_node FROM node WHERE ST_DWithin(NEW.the_geom, node.the_geom, v_node_proximity) AND node.node_id != NEW.node_id AND node.state=1;

			IF (NEW.state=2 AND v_node.node_id IS NOT NULL) THEN

				-- inserting on plan_psector_x_node the existing node as state=0
				INSERT INTO plan_psector_x_node (psector_id, node_id, state) VALUES (v_psector_id, v_node.node_id, 0) ON CONFLICT (psector_id, node_id) DO NOTHING;

				-- looking for all the arcs (1 and 2) using existing node
				FOR v_arc IN (SELECT arc_id, node_1 as node_id FROM v_edit_arc WHERE node_1=v_node.node_id
				AND state >0 UNION SELECT arc_id, node_2 FROM v_edit_arc WHERE node_2=v_node.node_id AND state >0)
				LOOP

					-- if exists some arc planified on same alternative attached to that existing node
					IF v_arc.arc_id IN (SELECT arc_id FROM plan_psector_x_arc JOIN arc USING (arc_id) WHERE psector_id=v_psector_id AND arc.state=2) THEN

						-- reconnect the planified arc to the new planified node in spite of connected to the node state=1
						IF (SELECT node_1 FROM arc WHERE arc_id=v_arc.arc_id)=v_arc.node_id THEN
							UPDATE arc SET node_1=NEW.node_id WHERE arc_id=v_arc.arc_id AND node_1=v_node.node_id;
						ELSE
							UPDATE arc SET node_2=NEW.node_id WHERE arc_id=v_arc.arc_id AND node_2=v_node.node_id;
						END IF;
					ELSE
						-- getting values to create new 'fictius' arc
						SELECT * INTO v_arcrecordtb FROM arc WHERE arc_id = v_arc.arc_id::text;

						-- refactoring values for new one
						v_arcrecordtb.arc_id:= (SELECT nextval('urn_id_seq'));
						IF v_node_replace_code is false then
							v_arcrecordtb.code = v_arcrecordtb.arc_id;
						END IF;
						v_arcrecordtb.state=2;
						v_arcrecordtb.state_type := (SELECT (value::json->>'plan_statetype_ficticius')::smallint FROM config_param_system WHERE parameter='plan_statetype_vdefault');

						-- Get arctype
						v_arc_type = v_arcrecordtb.arc_type;

						-- set temporary values for config variables in order to enable the insert of arc in spite of due a 'bug' of postgres it seems that does not recognize the new node inserted
						UPDATE config_param_user SET value=TRUE WHERE parameter = 'edit_disable_statetopocontrol' AND cur_user=current_user;

						-- Insert new records into arc table
						INSERT INTO arc SELECT v_arcrecordtb.*;

						-- update real values of node_1 and node_2
						IF (SELECT node_1 FROM arc WHERE arc_id=v_arc.arc_id)=v_node.node_id THEN
							v_arcrecordtb.node_1 = NEW.node_id;
						ELSE
							v_arcrecordtb.node_2 = NEW.node_id;
						END IF;

						UPDATE arc SET node_1=v_arcrecordtb.node_1, node_2=v_arcrecordtb.node_2 WHERE arc_id = v_arcrecordtb.arc_id;

						-- restore temporary value for edit_disable_statetopocontrol variable
						UPDATE config_param_user SET value=FALSE WHERE parameter = 'edit_disable_statetopocontrol' AND cur_user=current_user;

						-- getting table child information (man_table)
						v_mantable = (SELECT man_table FROM cat_feature_arc c JOIN cat_feature cf ON cf.id = n.id JOIN sys_feature_class s ON cf.feature_class = s.id JOIN v_edit_arc ON c.id=arc_type WHERE arc_id=v_arc.arc_id);
						v_epatable = (SELECT epa_table FROM cat_feature_arc c JOIN sys_feature_epa_type s ON epa_default = s.id JOIN v_edit_arc ON c.id=arc_type
						WHERE arc_id=v_arc.arc_id);

						-- building querytext for man_table
						v_querytext:= (SELECT replace (replace (array_agg(column_name::text)::text,'{',','),'}','')
						FROM information_schema.columns WHERE table_name=v_mantable AND table_schema=v_schemaname AND column_name !='arc_id');
						IF  v_querytext IS NULL THEN
							v_querytext='';
						END IF;
						v_manquerytext1 =  'INSERT INTO '||v_mantable||' SELECT ';
						v_manquerytext2 =  v_querytext||' FROM '||v_mantable||' WHERE arc_id= '||v_arc.arc_id||'::text';

						-- building querytext for epa_table
						v_querytext:= (SELECT replace (replace (array_agg(column_name::text)::text,'{',','),'}','')
						FROM information_schema.columns WHERE table_name=v_epatable AND table_schema=v_schemaname AND column_name !='arc_id');
						IF  v_querytext IS NULL THEN
							v_querytext='';
						END IF;
						v_epaquerytext1 =  'INSERT INTO '||v_epatable||' (arc_id' ||v_querytext||') SELECT ';
						v_epaquerytext2 =  v_querytext||' FROM '||v_epatable||' WHERE arc_id= '||v_arc.arc_id||'::text';

						-- insert new records into man_table
						EXECUTE v_manquerytext1||v_arcrecordtb.arc_id::text||v_manquerytext2;

						-- insert new records into epa_table
						EXECUTE v_epaquerytext1||v_arcrecordtb.arc_id::text||v_epaquerytext2;

						--Copy addfields from old arc to new arcs
						v_arc_childtable_name := 'man_arc_' || lower(v_arc_type);
						IF (SELECT EXISTS ( SELECT 1 FROM information_schema.tables WHERE table_schema = v_schemaname AND table_name = v_arc_childtable_name)) IS TRUE THEN
							EXECUTE 'INSERT INTO '||v_arc_childtable_name||' (arc_id) VALUES ('''||v_arcrecordtb.arc_id||''');';

							v_sql := 'SELECT column_name FROM information_schema.columns 
									  WHERE table_schema = ''SCHEMA_NAME'' 
									  AND table_name = '''||v_arc_childtable_name||''' 
									  AND column_name !=''id'' AND column_name != ''arc_id'' ;';

							FOR rec_addfields IN EXECUTE v_sql
							LOOP
								v_query_string_update = 'UPDATE '||v_arc_childtable_name||' SET '||rec_addfields.column_name|| ' = '
														'( SELECT '||rec_addfields.column_name||' FROM '||v_arc_childtable_name||' WHERE arc_id = '||quote_literal(v_arc.arc_id)||' ) '
														'WHERE '||v_arc_childtable_name||'.arc_id = '||quote_literal(v_arcrecordtb.arc_id)||';';

								IF v_query_string_update IS NOT NULL THEN
									EXECUTE v_query_string_update;
								END IF;

							END LOOP;
						END IF;

						-- Update doability for the new arc (false)
						UPDATE plan_psector_x_arc SET doable=FALSE, addparam='{"nodeReplace":"generated"}'
						WHERE arc_id=v_arcrecordtb.arc_id AND psector_id=v_psector_id;

						-- insert old arc on the alternative
						UPDATE config_param_user SET value='false' WHERE parameter='edit_plan_order_control' AND cur_user=current_user;

						INSERT INTO plan_psector_x_arc (psector_id, arc_id, state, doable,addparam)
						VALUES (v_psector_id, v_arc.arc_id, 0, FALSE, '{"nodeReplace":"deprecated"}') ON CONFLICT (psector_id, arc_id) DO NOTHING;

						UPDATE config_param_user SET value='true' WHERE parameter='edit_plan_order_control' AND cur_user=current_user;

						-- update parent on node is not enabled

						-- manage connec linked feature
						FOR v_connec_id IN
						SELECT connec_id FROM connec WHERE arc_id=v_arc.arc_id AND connec.state = 1
						LOOP
							INSERT INTO plan_psector_x_connec (connec_id, arc_id, psector_id, state, doable)
							SELECT connec_id, v_arcrecordtb.arc_id, v_psector_id, 1, false
							FROM link l JOIN connec c ON connec_id = l.feature_id WHERE l.feature_type  ='CONNEC' AND connec_id = v_connec_id
                            ON CONFLICT (connec_id, psector_id, state) DO NOTHING;

							INSERT INTO plan_psector_x_connec (connec_id, arc_id, psector_id, state, doable, link_id)
							SELECT connec_id, v_arc.arc_id, v_psector_id, 0, false, l.link_id
							FROM link l JOIN connec c ON connec_id = l.feature_id WHERE l.feature_type  ='CONNEC' AND connec_id = v_connec_id AND l.state=1
							ON CONFLICT (connec_id, psector_id, state) DO NOTHING;
						END LOOP;

						-- connecs without link but with arc_id
						FOR v_connec_id IN
						SELECT connec_id FROM connec WHERE arc_id=v_arc.arc_id AND state = 1 AND connec_id
						NOT IN (SELECT DISTINCT feature_id FROM link WHERE exit_id=v_arc.arc_id)
						LOOP
							INSERT INTO plan_psector_x_connec (connec_id, arc_id, psector_id, state, doable)
							SELECT connec_id, v_arcrecordtb.arc_id, v_psector_id, 1, false
							FROM connec WHERE connec_id = v_connec_id
                            ON CONFLICT (connec_id, psector_id, state) DO NOTHING;

							UPDATE plan_psector_x_connec SET link_id= NULL WHERE connec_id=v_connec_id;
							DELETE FROM link WHERE feature_id=v_connec_id;
						END LOOP;

						-- manage gully linked feature
						FOR v_gully_id IN
						SELECT gully_id FROM gully WHERE arc_id=v_arc.arc_id AND gully.state = 1
						LOOP
							INSERT INTO plan_psector_x_gully (gully_id, arc_id, psector_id, state, doable)
							SELECT gully_id, v_arcrecordtb.arc_id, v_psector_id, 1, false
							FROM link l JOIN gully c ON gully_id = l.feature_id WHERE l.feature_type  ='GULLY' AND gully_id = v_gully_id
                            ON CONFLICT (gully_id, psector_id, state) DO NOTHING;

							INSERT INTO plan_psector_x_gully (gully_id, arc_id, psector_id, state, doable, link_id)
							SELECT gully_id, v_arc.arc_id, v_psector_id, 0, false, l.link_id
							FROM link l JOIN gully c ON gully_id = l.feature_id WHERE l.feature_type  ='GULLY' AND gully_id = v_gully_id AND l.state=1
							ON CONFLICT (gully_id, psector_id, state) DO NOTHING;
						END LOOP;

						-- connecs without link but with arc_id
						FOR v_gully_id IN
						SELECT gully_id FROM gully WHERE arc_id=v_arc.arc_id AND state = 1 AND gully_id
						NOT IN (SELECT DISTINCT feature_id FROM link WHERE exit_id=v_arc.arc_id)
						LOOP
							INSERT INTO plan_psector_x_gully (gully_id, arc_id, psector_id, state, doable)
							SELECT gully_id, v_arcrecordtb.arc_id, v_psector_id, 1, false
							FROM gully WHERE gully_id = v_gully_id
                            ON CONFLICT (gully_id, psector_id, state) DO NOTHING;

							UPDATE plan_psector_x_gully SET link_id= NULL WHERE gully_id=v_gully_id;
							DELETE FROM link WHERE feature_id=v_gully_id;
						END LOOP;

					END IF;
				END LOOP;
			END IF;

		ELSIF TG_OP ='UPDATE' THEN

			-- Updating polygon geometry in case of exists it
			v_pol:= (SELECT pol_id FROM polygon WHERE feature_id=OLD.node_id);
			v_trace_featuregeom:= (SELECT trace_featuregeom FROM polygon WHERE feature_id=OLD.node_id);
			IF (v_pol IS NOT NULL) AND (v_trace_featuregeom IS TRUE) THEN
				v_x= (st_x(NEW.the_geom)-st_x(OLD.the_geom));
				v_y= (st_y(NEW.the_geom)-st_y(OLD.the_geom));
				UPDATE polygon SET the_geom=ST_translate(the_geom, v_x, v_y) WHERE pol_id=v_pol;
			END IF;

			-- calculate sys_top_elev for node
			IF NEW.custom_top_elev is not null THEN
				v_sys_top_elev =  NEW.custom_top_elev;

			ELSIF NEW.top_elev is not null THEN
				v_sys_top_elev =  NEW.top_elev;
			ELSE
				v_sys_top_elev = null;
			END IF;

			-- calculate sys_elev for node
			IF NEW.custom_elev IS NOT NULL THEN
				v_sys_elev =  NEW.custom_elev;

			ELSIF NEW.elev IS NOT NULL THEN
				v_sys_elev =  NEW.elev;

			ELSIF NEW.custom_ymax IS NOT NULL THEN
				v_sys_elev =  v_sys_top_elev - NEW.custom_ymax;

			ELSIF NEW.ymax IS NOT NULL THEN
				v_sys_elev =  v_sys_top_elev - NEW.ymax;
			ELSE
				v_sys_elev =  null; --in case of null sys_elev is = sys_top_elev
			END IF;

			-- looking for nodes
			v_querytext:= 'SELECT * FROM "arc" WHERE node_1 = ' || quote_literal(NEW.node_id)||' OR node_2 = ' || quote_literal(NEW.node_id);

			--updating arcs
			FOR v_arcrecordtb IN EXECUTE v_querytext
			LOOP
				-- set length (to calculate after slope)
				IF v_arcrecordtb.custom_length IS NOT NULL THEN v_length = v_arcrecordtb.custom_length;	ELSE v_length = st_length(v_arcrecordtb.the_geom); END IF;
				IF v_length < 0.1 or v_length is null then v_length = 0.1; END IF;

				-- Initial node
				SELECT * INTO v_nodeRecord1 FROM node WHERE node.node_id = v_arcrecordtb.node_1 AND node_id = NEW.node_id;
				SELECT * INTO v_nodeRecord2 FROM node WHERE node.node_id = v_arcrecordtb.node_2 AND node_id = NEW.node_id;

				IF v_nodeRecord1.node_id IS NOT NULL THEN

					-- calculate sys_elev1 for arc
					IF v_arcrecordtb.elev1 IS NOT NULL OR v_arcrecordtb.custom_elev1 IS NOT NULL THEN
						-- do nothing because sys_elev1 only depends of arc itself

					ELSIF v_arcrecordtb.custom_y1 IS NOT NULL AND v_sys_top_elev IS NOT NULL THEN -- if depends of custom_y1
						v_sys_elev1 = v_sys_top_elev - v_arcrecordtb.custom_y1;

					ELSIF v_arcrecordtb.y1 IS NOT NULL AND v_sys_top_elev IS NOT NULL THEN  -- if sys_elev1 depends of y1
						v_sys_elev1 = v_sys_top_elev - v_arcrecordtb.y1;

					ELSIF v_sys_elev IS NOT NULL THEN  -- case when (elev1 & custom_elev1) & (y1 & custom_y1) is null
						v_sys_elev1 = v_sys_elev;
					END IF;

					-- calculate new slope
					v_slope = (v_sys_elev1 - v_arcrecordtb.sys_elev2)/v_length;

					-- update arc
					IF v_sys_top_elev IS NOT NULL AND v_sys_elev IS NOT NULL AND v_sys_elev1 IS NOT NULL AND v_slope IS NOT NULL THEN
						EXECUTE 'UPDATE arc SET
							node_sys_top_elev_1 = '|| v_sys_top_elev ||',
							node_sys_elev_1 = '|| v_sys_elev ||',
							sys_elev1 = '|| v_sys_elev1||',
							sys_slope = '|| v_slope ||' 
							WHERE arc_id = ' || quote_literal(v_arcrecordtb."arc_id");
					END IF;

					EXECUTE 'UPDATE arc SET 
					the_geom = ST_SetPoint($1, 0, $2), 
					nodetype_1 = '|| quote_literal(v_nodeRecord1.node_type) ||'
					WHERE arc_id = ' || quote_literal(v_arcrecordtb."arc_id") USING v_arcrecordtb.the_geom, NEW.the_geom;


				ELSIF v_nodeRecord2.node_id IS NOT NULL THEN

					-- calculate sys_elev2
					IF v_arcrecordtb.elev2 IS  NOT NULL OR v_arcrecordtb.custom_elev2 IS NOT NULL THEN
						-- do nothing because sys_elev2 only depends of arc itself

					ELSIF v_arcrecordtb.custom_y2 IS NOT NULL AND v_sys_top_elev IS NOT NULL THEN -- if depends of custom_y2
						v_sys_elev2 = v_sys_top_elev - v_arcrecordtb.custom_y2;

					ELSIF v_arcrecordtb.y2 IS NOT NULL AND v_sys_top_elev IS NOT NULL THEN  -- if sys_elev2 depends of y2
						v_sys_elev2 = v_sys_top_elev - v_arcrecordtb.y2;

					ELSIF v_sys_elev IS NOT NULL THEN  -- case when (elev1 & custom_elev1) & (y1 & custom_y1) is null
						v_sys_elev2 = v_sys_elev;
					END IF;

					-- slope
					v_slope = (v_arcrecordtb.sys_elev1 - v_sys_elev2)/v_length;

					-- update arc

					IF v_sys_top_elev IS NOT NULL AND v_sys_elev IS NOT NULL AND v_sys_elev2 IS NOT NULL AND v_slope IS NOT NULL THEN
						EXECUTE 'UPDATE arc SET
							node_sys_top_elev_2 = '|| v_sys_top_elev ||',
							node_sys_elev_2 = '|| v_sys_elev ||',
							sys_elev2 = '|| v_sys_elev2||',
							sys_slope = '|| v_slope ||' 
							WHERE arc_id = ' || quote_literal(v_arcrecordtb."arc_id");
					END IF;

					EXECUTE 'UPDATE arc SET 
					the_geom = ST_SetPoint($1, ST_NumPoints($1) -1, $2), 
					nodetype_1 = '|| quote_literal(v_nodeRecord2.node_type) ||'
					WHERE arc_id = ' || quote_literal(v_arcrecordtb."arc_id") USING v_arcrecordtb.the_geom, NEW.the_geom;
				END IF;

				-- Force a simple update on arc in order to update direction if necessary
				EXECUTE 'UPDATE arc SET the_geom = the_geom WHERE arc_id = ' || quote_literal(v_arcrecordtb."arc_id");
			END LOOP;

			--updating links
			v_querytext:= 'SELECT * FROM link WHERE link.exit_id= ' || quote_literal(NEW.node_id) || ' AND exit_type=''NODE''';

			FOR v_linkrec IN EXECUTE v_querytext
			LOOP
				-- Coordinates
				EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, ST_NumPoints($1) - 1, $2) WHERE link_id = ' || quote_literal(v_linkrec."link_id")
				USING v_linkrec.the_geom, NEW.the_geom;
			END LOOP;
		END IF;
	END IF;

	RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
