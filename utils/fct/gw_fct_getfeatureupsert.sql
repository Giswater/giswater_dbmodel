/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 2560


DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_getfeatureupsert(character varying, character varying, public.geometry, integer, integer, character varying, boolean);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_getfeatureupsert(character varying, character varying, public.geometry, integer, integer, character varying, boolean, text, text);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_getfeatureupsert(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_getfeatureupsert(p_data json)
  RETURNS json AS
$BODY$


/*EXAMPLE

SELECT SCHEMA_NAME.gw_fct_getfeatureupsert($${
	"data":{
		"parameters":{
			"table_id":"ve_arc_pipe",
			"id":"2001",
		"reduced_geometry":"0102000020E764000002000000998B3C512F881941B28315AA7F76514105968D7D748819419FDF72D781765141",
		"device":9,
			"info_type":100,
			"tg_op":"INSERT",
			"configtable":true,
			"idname":"arc_id",
			"columntype":"text"
		}
	}
}$$);

*/

DECLARE

-- parameters
v_table_id text;
v_id text;
v_reduced_geometry geometry;
v_device integer;
v_info_type integer;
v_tg_op text;
v_configtable boolean;
v_idname text;
v_columntype text;

v_state_value integer;
v_fields json;
v_fields_array json[];
aux_json json;
combo_json json;
schemas_array name[];
array_index integer DEFAULT 0;
field_value character varying;
v_version json;
v_vdefault text;
v_numnodes integer;
v_feature_type text;
count_aux integer;
v_sector_id integer;
v_macrosector_id integer;
v_expl_id integer;
v_macroexploitation_id integer;
v_dma_id integer;
v_macrodma_id integer;
v_omzone_id integer;
v_macroomzone_id integer;
v_supplyzone_id integer;
v_dwfzone_id integer;
v_drainzone_id integer;
v_macrominsector_id integer;
v_muni_id integer;
v_district_id integer;
v_project_type varchar;
v_cat_feature_id varchar;
v_code text;
v_node_proximity double precision;
v_node_proximity_control boolean;
v_connec_proximity double precision;
v_connec_proximity_control boolean;
v_gully_proximity double precision;
v_gully_proximity_control boolean;
v_arc_searchnodes double precision;
v_samenode_init_end_control boolean;
v_arc_searchnodes_control boolean;
v_tabname text = 'tab_data';
v_formname text;
v_tablename text;
v_visit_tablename text;
v_topocontrol boolean = TRUE;
v_status boolean = true;
v_message text;
v_catfeature record;
v_codeautofill boolean=true;
v_values_array json;
v_record record;
v_catalog text;
v_dnom text;
v_pnom text;
v_geom1 text;
v_geom2 text;
v_shape text;
v_matcat_id text;
v_catalogtype varchar;
v_min double precision;
v_max double precision;
v_widgetcontrols json;
v_type text;
v_active_feature text;
v_proximity_buffer double precision;
v_sys_raster_dem boolean=false;
v_connec_autofill_plotcode boolean = false;
v_edit_insert_elevation_from_dem boolean=false;
v_noderecord1 record;
v_noderecord2 record;
v_input json;
v_presszone_id int;
v_widgetvalues json;
v_automatic_ccode boolean;
v_automatic_ccode_field text;
v_customercode text = null;
v_use_fire_code_seq boolean;
v_node1 text;
v_node2 text;
v_formtype text;
v_querytext text;
v_dqa_id integer;
v_arc_insert_automatic_endpoint boolean;
v_current_id text;
v_current_idval text;
v_new_id text;
v_selected_id text;
v_selected_idval text;
v_errcontext text;
v_querystring text;
v_msgerr json;
v_epa text;
v_elevation numeric(12,4);
v_staticpressure numeric(12,3);
label_value text;
v_seq_name text;
v_seq_code text;
v_sql text;

v_streetname varchar;
v_postnumber varchar;
v_plot_code text;

v_auto_streetvalues_status boolean;
v_auto_streetvalues_field varchar;
v_auto_streetvalues_buffer integer;

v_id_array text[];
v_idname_array text[];
column_type_id_array text[];
column_type_id character varying;
i integer=1;
idname text;
v_addparam json;
v_pkeyfield text;
v_schemaname text;

v_idname_aux text;

v_nodarc_id varchar;
v_toarc varchar;
v_order_id integer;
v_flwreg_type text;
v_flwreg_length numeric(14,2);
v_toarc_geom public.geometry;

vdefault_querytext text;

BEGIN

	-- get basic parameters
	-----------------------
	--  set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname := 'SCHEMA_NAME';
	--  get schema name
	schemas_array := current_schemas(FALSE);

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''admin_version'') row'
	iNTO v_version;

	--  get project type
	SELECT project_type INTO v_project_type FROM sys_version ORDER BY id DESC LIMIT 1;

	-- parameters
	v_table_id = (((p_data->>'data')::json->>'parameters')::json->>'table_id');
	v_id = (((p_data->>'data')::json->>'parameters')::json->>'id');
	v_reduced_geometry = (((p_data->>'data')::json->>'parameters')::json->>'reduced_geometry');
	v_device = (((p_data->>'data')::json->>'parameters')::json->>'device');
	v_info_type = (((p_data->>'data')::json->>'parameters')::json->>'info_type');
	v_tg_op = (((p_data->>'data')::json->>'parameters')::json->>'tg_op');
	v_configtable = (((p_data->>'data')::json->>'parameters')::json->>'configtable');
	v_idname = (((p_data->>'data')::json->>'parameters')::json->>'idname');
	v_columntype = (((p_data->>'data')::json->>'parameters')::json->>'columntype');


	--  get system parameters
	SELECT ((value::json)->>'activated') INTO v_node_proximity_control FROM config_param_system WHERE parameter='edit_node_proximity';
	SELECT ((value::json)->>'value') INTO v_node_proximity FROM config_param_system WHERE parameter='edit_node_proximity';
	SELECT ((value::json)->>'activated') INTO v_connec_proximity_control FROM config_param_system WHERE parameter='edit_connec_proximity';
	SELECT ((value::json)->>'value') INTO v_connec_proximity FROM config_param_system WHERE parameter='edit_connec_proximity';
	SELECT ((value::json)->>'activated') INTO v_gully_proximity_control FROM config_param_system WHERE parameter='edit_gully_proximity';
	SELECT ((value::json)->>'value') INTO v_gully_proximity FROM config_param_system WHERE parameter='edit_gully_proximity';
	SELECT ((value::json)->>'activated') INTO v_arc_searchnodes_control FROM config_param_system WHERE parameter='edit_arc_searchnodes';
	SELECT ((value::json)->>'value') INTO v_arc_searchnodes FROM config_param_system WHERE parameter='edit_arc_searchnodes';
	SELECT value::boolean INTO v_connec_autofill_plotcode FROM config_param_system WHERE parameter = 'edit_connec_autofill_plotcode';
	SELECT value::boolean INTO v_samenode_init_end_control FROM config_param_system WHERE parameter = 'edit_arc_samenode_control';
	SELECT value INTO v_proximity_buffer FROM config_param_system WHERE parameter='edit_feature_buffer_on_mapzone';
	SELECT value INTO v_use_fire_code_seq FROM config_param_system WHERE parameter='edit_hydrant_use_firecode_seq';
	SELECT ((value::json)->>'status') INTO v_automatic_ccode FROM config_param_system WHERE parameter='edit_connec_autofill_ccode';
	SELECT ((value::json)->>'field') INTO v_automatic_ccode_field FROM config_param_system WHERE parameter='edit_connec_autofill_ccode';

	SELECT json_extract_path_text(value::json,'activated')::boolean INTO v_sys_raster_dem FROM config_param_system WHERE parameter='admin_raster_dem';
	SELECT (value::json->>'status')::boolean INTO v_auto_streetvalues_status FROM config_param_system WHERE parameter = 'edit_auto_streetvalues';
	SELECT (value::json->>'field')::text INTO v_auto_streetvalues_field FROM config_param_system WHERE parameter = 'edit_auto_streetvalues';
	SELECT (value::json->>'buffer')::integer INTO v_auto_streetvalues_buffer FROM config_param_system WHERE parameter = 'edit_auto_streetvalues';

	--Check if user has migration mode enabled
	IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_disable_topocontrol' AND cur_user=current_user) IS TRUE THEN
	  	v_node_proximity_control = FALSE;
	  	v_connec_proximity_control = FALSE;
	  	v_gully_proximity_control=FALSE;
 	END IF;

	-- get user parameters
	SELECT (value)::boolean INTO v_edit_insert_elevation_from_dem FROM config_param_user WHERE parameter='edit_insert_elevation_from_dem' AND cur_user = current_user;
	SELECT (value)::boolean INTO v_arc_insert_automatic_endpoint FROM config_param_user WHERE parameter='edit_arc_insert_automatic_endpoint' AND cur_user = current_user;

	-- get tablename and formname
	-- Common
	v_tablename = v_table_id;
	v_formname = v_table_id;

	-- Special case of visits
	SELECT tablename INTO v_visit_tablename FROM config_visit_class WHERE formname=v_table_id;
	IF v_visit_tablename IS NOT NULL THEN v_tablename = v_visit_tablename; v_formname = v_table_id;	END IF;

	--  get feature propierties
	---------------------------
	v_active_feature = concat('SELECT cat_feature.* FROM cat_feature WHERE active IS TRUE
	AND (child_layer = ', quote_nullable(v_table_id) ,' OR parent_layer = ' , quote_nullable(v_table_id) , ') ORDER BY cat_feature.id');

	EXECUTE v_active_feature INTO v_catfeature;

	-- Manage primary key
	EXECUTE 'SELECT addparam FROM sys_table WHERE id = $1' INTO v_addparam USING v_tablename;
	v_idname_array := string_to_array(v_addparam ->> 'pkey', ', ');
	if v_idname_array is null THEN
		EXECUTE 'SELECT gw_fct_getpkeyfield('''||v_tablename||''');' INTO v_pkeyfield;
		v_idname_aux = v_pkeyfield;
		v_idname_array := string_to_array(v_pkeyfield, ', ');
	else
		v_idname_aux = v_idname_array;
	end if;

	v_id_array := string_to_array(v_id, ', ');


	if v_idname_array is not null then
		v_idname = v_idname_aux;
		FOREACH idname IN ARRAY v_idname_array LOOP
			EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
			    JOIN pg_class t on a.attrelid = t.oid
			    JOIN pg_namespace s on t.relnamespace = s.oid
			    WHERE a.attnum > 0
			    AND NOT a.attisdropped
			    AND a.attname = $3
			    AND t.relname = $2
			    AND s.nspname = $1
			    ORDER BY a.attnum'
                USING v_schemaname, v_tablename, idname
                INTO column_type_id;
                column_type_id_array[i] := column_type_id;
                i=i+1;
        END LOOP;

	else
		--   Get id column type
		EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
		    JOIN pg_class t on a.attrelid = t.oid
		    JOIN pg_namespace s on t.relnamespace = s.oid
		    WHERE a.attnum > 0
		    AND NOT a.attisdropped
		    AND a.attname = $3
		    AND t.relname = $2
		    AND s.nspname = $1
		    ORDER BY a.attnum'
            USING v_schemaname, v_tablename, v_idname
            INTO column_type_id;
	end if;

	--  Starting control process
	----------------------------
	IF v_tg_op = 'INSERT' THEN

		-- urn_id assingment
		IF v_id IS NULL THEN
			v_id = (SELECT nextval('urn_id_seq'));
		END IF;

		IF v_catfeature.code_autofill IS TRUE THEN
			v_code=v_id;
		END IF;

		-- check if v_table_id is defined on cat_feature
		if v_catfeature.id is not null then
			-- use specific sequence when its name matches featurecat_code_seq
			EXECUTE 'SELECT concat('||quote_literal(lower(v_catfeature.id))||',''_code_seq'');' INTO v_seq_name;
			EXECUTE 'SELECT relname FROM pg_catalog.pg_class WHERE relname='||quote_literal(v_seq_name)||' 
			AND relkind = ''S'' AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = '||quote_literal(v_schemaname)||');' INTO v_sql;

			IF v_sql IS NOT NULL THEN
				EXECUTE 'SELECT nextval('||quote_literal(v_seq_name)||');' INTO v_seq_code;
					v_code=concat(v_catfeature.addparam::json->>'code_prefix',v_seq_code);
			END IF;
		end if;

		-- customer code only for connec
		IF v_automatic_ccode IS TRUE AND v_automatic_ccode_field='connec_id' THEN
			v_customercode = v_id;
		END IF;

		-- topology control (enabled without state topocontrol. Does not make sense to activate this because in this phase of workflow
		IF v_topocontrol IS TRUE AND v_catfeature.feature_type IS NOT NULL THEN

			IF upper(v_catfeature.feature_type) ='NODE' THEN

				v_numnodes := (SELECT COUNT(*) FROM node WHERE ST_DWithin(v_reduced_geometry, node.the_geom, v_node_proximity) AND node.node_id != v_id::integer AND node.state!=0);
				IF (v_numnodes >1) AND (v_node_proximity_control IS TRUE) THEN
					v_message = (SELECT concat('Error[1096]:',error_message, v_id,'. ',hint_message) FROM sys_message WHERE id=1096);
					v_status = false;
				END IF;

			ELSIF upper(v_catfeature.feature_type) ='ARC' THEN

				SELECT * INTO v_noderecord1 FROM v_edit_node WHERE ST_DWithin(ST_startpoint(v_reduced_geometry), v_edit_node.the_geom, v_arc_searchnodes)
				ORDER BY ST_Distance(v_edit_node.the_geom, ST_startpoint(v_reduced_geometry)) LIMIT 1;

				SELECT * INTO v_noderecord2 FROM v_edit_node WHERE ST_DWithin(ST_endpoint(v_reduced_geometry), v_edit_node.the_geom, v_arc_searchnodes)
				ORDER BY ST_Distance(v_edit_node.the_geom, ST_endpoint(v_reduced_geometry)) LIMIT 1;

				IF (v_noderecord1.node_id IS NOT NULL) AND (v_noderecord2.node_id IS NOT NULL) THEN

					-- Control of same node initial and final
					IF (v_noderecord1.node_id = v_noderecord2.node_id) AND (v_samenode_init_end_control IS TRUE) THEN
						v_message = (SELECT concat('ERROR-1040:',error_message, v_noderecord1.node_id,'. ',hint_message) FROM sys_message WHERE id=1040);
						v_status = false;
					END IF;

					IF v_project_type = 'WS' THEN
						-- getting presszone by heritage from nodes
						IF v_noderecord1.presszone_id = v_noderecord2.presszone_id THEN
							v_presszone_id = v_noderecord1.presszone_id;
						ELSIF v_noderecord1.presszone_id = 0 THEN
							v_presszone_id = v_noderecord2.presszone_id;
						ELSIF v_noderecord2.presszone_id = 0 THEN
							v_presszone_id = v_noderecord1.presszone_id;
						ELSIF v_noderecord1.presszone_id != v_noderecord2.presszone_id THEN
							v_presszone_id = 0;
						END IF;

						-- getting dqa_id by heritage from nodes
						IF v_noderecord1.dqa_id = v_noderecord2.dqa_id THEN
							v_dqa_id = v_noderecord1.dqa_id;
						ELSIF v_noderecord1.dqa_id = 0 THEN
							v_dqa_id = v_noderecord2.dqa_id;
						ELSIF v_noderecord2.dqa_id = 0 THEN
							v_dqa_id = v_noderecord1.dqa_id;
						ELSIF v_noderecord1.dqa_id::text != v_noderecord2.dqa_id::text THEN
							v_dqa_id = 0;
						END IF;

						-- getting macrominsector_id by heritage from nodes
						IF v_noderecord1.macrominsector_id = v_noderecord2.macrominsector_id THEN
							v_macrominsector_id = v_noderecord1.macrominsector_id;
						END IF;

						-- getting supplyzone by heritage from nodes:
						IF v_noderecord1.supplyzone_id = v_noderecord2.supplyzone_id THEN
							v_supplyzone_id = v_noderecord1.supplyzone_id;
						ELSIF v_noderecord1.supplyzone_id = 0 THEN
							v_supplyzone_id = v_noderecord2.supplyzone_id;
						ELSIF v_noderecord2.supplyzone_id = 0 THEN
							v_supplyzone_id = v_noderecord1.supplyzone_id;
						ELSIF v_noderecord1.supplyzone_id::text != v_noderecord2.supplyzone_id::text THEN
							v_supplyzone_id = 0;
						END IF;

					ELSE

						-- getting dwfzone by heritage from nodes:
						IF v_noderecord1.dwfzone_id = v_noderecord2.dwfzone_id THEN
							v_dwfzone_id = v_noderecord1.dwfzone_id;
						ELSIF v_noderecord1.dwfzone_id = 0 THEN
							v_dwfzone_id = v_noderecord2.dwfzone_id;
						ELSIF v_noderecord2.dwfzone_id = 0 THEN
							v_dwfzone_id = v_noderecord1.dwfzone_id;
						ELSIF v_noderecord1.dwfzone_id::text != v_noderecord2.dwfzone_id::text THEN
							v_dwfzone_id = 0;
						END IF;

						-- getting drainzone by heritage from nodes:
						IF v_noderecord1.drainzone_id = v_noderecord2.drainzone_id THEN
							v_drainzone_id = v_noderecord1.drainzone_id;
						ELSIF v_noderecord1.drainzone_id = 0 THEN
							v_drainzone_id = v_noderecord2.drainzone_id;
						ELSIF v_noderecord2.drainzone_id = 0 THEN
							v_drainzone_id = v_noderecord1.drainzone_id;
						ELSIF v_noderecord1.drainzone_id::text != v_noderecord2.drainzone_id::text THEN
							v_drainzone_id = 0;
						END IF;


					END IF;

					-- getting sector_id by heritage from nodes
					IF v_noderecord1.sector_id = v_noderecord2.sector_id THEN
						v_sector_id = v_noderecord1.sector_id;
					ELSIF v_noderecord1.sector_id = 0 THEN
						v_sector_id = v_noderecord2.sector_id;
					ELSIF v_noderecord2.sector_id = 0 THEN
						v_sector_id = v_noderecord1.sector_id;
					ELSIF v_noderecord1.sector_id::text != v_noderecord2.sector_id::text THEN
						v_sector_id = 0;
					END IF;

					-- getting dma_id by heritage from nodes
					IF v_project_type = 'WS' THEN
						IF v_noderecord1.dma_id = v_noderecord2.dma_id THEN
							v_dma_id = v_noderecord1.dma_id;
						ELSIF v_noderecord1.dma_id = 0 THEN
							v_dma_id = v_noderecord2.dma_id;
						ELSIF v_noderecord2.dma_id = 0 THEN
							v_dma_id = v_noderecord1.dma_id;
						ELSIF v_noderecord1.dma_id::text != v_noderecord2.dma_id::text THEN
							v_dma_id = 0;
						END IF;
					END IF;

					-- getting omzone_id by heritage from nodes
					IF v_noderecord1.omzone_id = v_noderecord2.omzone_id THEN
						v_omzone_id = v_noderecord1.omzone_id;
					ELSIF v_noderecord1.omzone_id = 0 THEN
						v_omzone_id = v_noderecord2.omzone_id;
					ELSIF v_noderecord2.omzone_id = 0 THEN
						v_omzone_id = v_noderecord1.omzone_id;
					ELSIF v_noderecord1.omzone_id::text != v_noderecord2.omzone_id::text THEN
						v_omzone_id = 0;
					END IF;

					-- getting expl_id by heritage from nodes
					IF v_noderecord1.expl_id = v_noderecord2.expl_id THEN
						v_expl_id = v_noderecord1.expl_id;
					ELSIF v_noderecord1.expl_id = 0 THEN
						v_expl_id = v_noderecord2.expl_id;
					ELSIF v_noderecord2.expl_id = 0 THEN
						v_expl_id = v_noderecord1.expl_id;
					ELSIF v_noderecord1.expl_id::text != v_noderecord2.expl_id::text THEN
						v_expl_id = 0;
					END IF;

					-- getting muni_id by heritage from nodes
					IF v_noderecord1.muni_id = v_noderecord2.muni_id THEN
						v_muni_id = v_noderecord1.muni_id;
					ELSE
						v_muni_id = 0;
					END IF;

					-- getting node values in case of arcs (insert)
					v_node1 = v_noderecord1.node_id;
					v_node2 = v_noderecord2.node_id;

				--Error, no existing nodes
				ELSIF ((v_noderecord1.node_id IS NULL) OR (v_noderecord2.node_id IS NULL)) AND (v_arc_searchnodes_control IS TRUE) THEN

					-- if only dosenot exits node 2 and insert_automatic_endpoint
					IF ((v_noderecord1.node_id IS NOT NULL) AND (v_noderecord2.node_id IS NULL)) AND v_arc_insert_automatic_endpoint THEN

					ELSE
						v_message = (SELECT concat('ERROR-1042:',error_message, '[node_1]:',v_noderecord1.node_id,'[node_2]:',v_noderecord2.node_id,'. ',hint_message)
						FROM sys_message WHERE id=1042);
						v_status = false;
					END IF;
				END IF;

			ELSIF upper(v_catfeature.feature_type) ='CONNEC' THEN
				v_numnodes := (SELECT COUNT(*) FROM connec WHERE ST_DWithin(v_reduced_geometry, connec.the_geom, v_connec_proximity) AND connec.connec_id != v_id::integer AND connec.state!=0);
				IF (v_numnodes >1) AND (v_connec_proximity_control IS TRUE) THEN
					v_message = (SELECT concat('ERROR-1044:',error_message, v_id,'. ',hint_message) FROM sys_message WHERE id=1044);
					v_status = false;
				END IF;

			ELSIF upper(v_catfeature.feature_type) ='GULLY' THEN
				v_numnodes := (SELECT COUNT(*) FROM gully WHERE ST_DWithin(v_reduced_geometry, gully.the_geom, v_gully_proximity) AND gully.gully_id != v_id::integer AND gully.state!=0);
				IF (v_numnodes >1) AND (v_gully_proximity_control IS TRUE) THEN
					v_message = (SELECT concat('ERROR-1045:',error_message, v_id,'. ',hint_message) FROM sys_message WHERE id=1045);
					v_status = false;
				END IF;

			--- get Flowreg Defaults
            ELSIF upper(v_catfeature.feature_type) = 'FLWREG' THEN
                -- Get toarc
                SELECT arc_id , the_geom into v_toarc, v_toarc_geom FROM v_edit_arc WHERE ST_DWithin(ST_endpoint(v_reduced_geometry), v_edit_arc.the_geom, 0.001) LIMIT 1;
                -- Get flwreg_length
                SELECT abs(ST_LineLocatePoint(v_toarc_geom, ST_startpoint(v_reduced_geometry)) - ST_LineLocatePoint(v_toarc_geom, ST_endpoint(v_reduced_geometry))) * ST_Length(v_toarc_geom)
                INTO v_flwreg_length;

                -- WARNING: this code is also in gw_fct_infofromid. If it needs to be changed here, it will most likely have to be changed there too.
                -- Get node id from initial clicked point
                SELECT * INTO v_noderecord1 FROM v_edit_node WHERE ST_DWithin(ST_startpoint(v_reduced_geometry), v_edit_node.the_geom, v_arc_searchnodes)
                ORDER BY ST_Distance(v_edit_node.the_geom, ST_startpoint(v_reduced_geometry)) LIMIT 1;
                -- Get flowreg_type
                v_querystring = concat('SELECT feature_class FROM cat_feature WHERE child_layer = ' , quote_nullable(v_table_id) ,' LIMIT 1');
                EXECUTE v_querystring INTO v_flwreg_type;
				-- Get order_id
                SELECT COALESCE(MAX(order_id), 0) + 1 INTO v_order_id FROM ve_frelem WHERE node_id = v_noderecord1.node_id ::text AND flwreg_type = v_flwreg_type;
                -- Set nodarc_id
                v_nodarc_id = concat(v_noderecord1.node_id,upper(substring(v_flwreg_type FROM 1 FOR 2)), v_order_id);
			END IF;
		END IF;

		-- get NODE vdefaults user's mapzones only for nodes (for arcs is disabled because values are taken using heritage from nodes. For connect also because they takes from arc)
		IF upper(v_catfeature.feature_type) = 'NODE' THEN
			SELECT value INTO v_sector_id FROM config_param_user WHERE parameter = 'edit_sector_vdefault' and cur_user = current_user;
			SELECT value INTO v_expl_id FROM config_param_user WHERE parameter = 'edit_exploitation_vdefault' and cur_user = current_user;
			SELECT value INTO v_muni_id FROM config_param_user WHERE parameter = 'edit_municipality_vdefault' and cur_user = current_user;

		END IF;

		-- Presszone
		IF v_project_type = 'WS' AND v_presszone_id IS NULL THEN
			SELECT count(*) into count_aux FROM presszone WHERE ST_DWithin(v_reduced_geometry, presszone.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_presszone_id = (SELECT presszone_id FROM presszone WHERE ST_DWithin(v_reduced_geometry, presszone.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_presszone_id =(SELECT presszone_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- Sector ID
		IF v_sector_id IS NULL THEN
			SELECT count(*) into count_aux FROM sector WHERE ST_DWithin(v_reduced_geometry, sector.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(v_reduced_geometry, sector.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_sector_id =(SELECT sector_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- Dma ID
		IF v_project_type = 'WS' AND v_dma_id IS NULL THEN
			SELECT count(*) into count_aux FROM dma WHERE ST_DWithin(v_reduced_geometry, dma.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_dma_id = (SELECT dma_id FROM dma WHERE ST_DWithin(v_reduced_geometry, dma.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_dma_id =(SELECT dma_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		IF v_omzone_id IS NULL THEN
			SELECT count(*) into count_aux FROM omzone WHERE ST_DWithin(v_reduced_geometry, omzone.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_omzone_id = (SELECT omzone_id FROM omzone WHERE ST_DWithin(v_reduced_geometry, omzone.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_omzone_id =(SELECT omzone_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- Expl ID
		IF v_expl_id IS NULL THEN
			SELECT count(*) into count_aux FROM exploitation WHERE ST_DWithin(v_reduced_geometry, exploitation.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_expl_id = (SELECT expl_id FROM exploitation WHERE ST_DWithin(v_reduced_geometry, exploitation.the_geom,0.001)  AND active=true LIMIT 1);
			ELSE
				v_expl_id =(SELECT expl_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- supplyzone: TODO
		IF v_project_type = 'WS' AND v_supplyzone_id IS NULL THEN
			SELECT count(*) into count_aux FROM supplyzone WHERE ST_DWithin(v_reduced_geometry, supplyzone.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_supplyzone_id = (SELECT supplyzone_id FROM supplyzone WHERE ST_DWithin(v_reduced_geometry, supplyzone.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_supplyzone_id =(SELECT supplyzone_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- dwfzone: TODO
		IF v_project_type = 'UD' AND v_dwfzone_id IS NULL THEN
			SELECT count(*) into count_aux FROM dwfzone WHERE ST_DWithin(v_reduced_geometry, dwfzone.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_dwfzone_id = (SELECT dwfzone_id FROM dwfzone WHERE ST_DWithin(v_reduced_geometry, dwfzone.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_dwfzone_id =(SELECT dwfzone_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;

		-- drainzone: TODO
		IF v_project_type = 'UD' AND v_drainzone_id IS NULL THEN
			SELECT count(*) into count_aux FROM drainzone WHERE ST_DWithin(v_reduced_geometry, drainzone.the_geom,0.001) AND active IS TRUE ;
			IF count_aux = 1 THEN
				v_drainzone_id = (SELECT drainzone_id FROM drainzone WHERE ST_DWithin(v_reduced_geometry, drainzone.the_geom,0.001) AND active IS TRUE LIMIT 1);
			ELSE
				v_drainzone_id =(SELECT drainzone_id FROM v_edit_arc WHERE ST_DWithin(v_reduced_geometry, v_edit_arc.the_geom, v_proximity_buffer)
				order by ST_Distance (v_reduced_geometry, v_edit_arc.the_geom) LIMIT 1);
			END IF;
		END IF;


		-- Macrodma
		IF v_project_type = 'WS' THEN
			v_macrodma_id := (SELECT macrodma_id FROM dma WHERE dma_id=v_dma_id);
		END IF;

		-- macroomzone
		v_macroomzone_id := (SELECT macroomzone_id FROM omzone WHERE omzone_id=v_omzone_id);

		-- Macrosector
		v_macrosector_id := (SELECT macrosector_id FROM sector WHERE sector_id=v_sector_id);

		-- Macroexploitation
		v_macroexploitation_id := (SELECT macroexpl_id FROM exploitation WHERE expl_id=v_expl_id);

		-- Municipality
		IF v_muni_id IS NULL THEN
			v_muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(v_reduced_geometry, ext_municipality.the_geom,0.001) AND active IS TRUE LIMIT 1);
		END IF;

		-- District
		v_district_id := (SELECT district_id FROM ext_district WHERE ST_DWithin(v_reduced_geometry, ext_district.the_geom,0.001) LIMIT 1);

		--Address
		v_streetname :=(select v_ext_streetaxis.descript from v_ext_streetaxis
				where ST_DWithin(v_reduced_geometry, v_ext_streetaxis.the_geom, v_auto_streetvalues_buffer)
				order by ST_Distance(v_reduced_geometry, v_ext_streetaxis.the_geom) LIMIT 1);

		--Postnumber/postcomplement
		v_postnumber := (select ext_address.postnumber from ext_address
						where ST_DWithin(v_reduced_geometry, ext_address.the_geom, v_auto_streetvalues_buffer)
						order by ST_Distance(v_reduced_geometry, ext_address.the_geom) LIMIT 1);

		-- Dem elevation
		IF v_sys_raster_dem AND v_edit_insert_elevation_from_dem AND v_idname IN ('node_id', 'connec_id', 'gully_id') THEN
			v_elevation = (SELECT ST_Value(rast,1, v_reduced_geometry, true) FROM ext_raster_dem WHERE id =
			(SELECT id FROM ext_raster_dem WHERE st_dwithin (envelope, v_reduced_geometry, 1) LIMIT 1));
		END IF;

		-- plot code from connecs
		IF v_idname = 'connec_id' AND v_connec_autofill_plotcode THEN
			v_plot_code = (SELECT plot_code FROM v_ext_plot WHERE st_dwithin(v_reduced_geometry, the_geom, 0) LIMIT 1);
		END IF;

		-- static pressure
		IF v_project_type = 'WS' AND v_presszone_id IS NOT NULL THEN
			v_staticpressure = (SELECT head from presszone WHERE presszone_id = v_presszone_id) - v_elevation;
		END IF;

	ELSIF v_tg_op ='UPDATE' OR v_tg_op ='SELECT' then

		-- getting values from feature
		IF v_idname = 'connec_id' THEN
			v_epa = 'connec';
		ELSIF v_idname IN ('arc_id', 'node_id', 'gully_id') then

			EXECUTE ('SELECT epa_type FROM ' || substring(v_idname, 0, length(v_idname)-2) || ' WHERE ' || v_idname || ' = ' || v_id::integer || '') INTO v_epa;

		END IF;

		IF v_idname_array is not null then

			v_querystring = 'SELECT (row_to_json(a)) FROM (SELECT * FROM '|| v_table_id || ' ';

			i = 1;
			v_querystring := v_querystring || ' WHERE ';
			FOREACH idname IN ARRAY v_idname_array loop
				v_querystring := v_querystring || quote_ident(idname) || ' = CAST(' || quote_literal(v_id_array[i]) || ' AS ' || column_type_id_array[i] || ') AND ';
				i=i+1;
			END LOOP;
			v_querystring = substring(v_querystring, 0, length(v_querystring)-4);
			v_querystring := v_querystring || ')a';
		else

			v_querystring = concat('SELECT (row_to_json(a)) FROM
			(SELECT * FROM ',v_table_id,' WHERE ',quote_ident(v_idname),' = CAST(',quote_literal(v_id),' AS ',(v_columntype),'))a');
		END IF;


		EXECUTE v_querystring INTO v_values_array;

		-- getting node values in case of arcs (update)
		v_node1 := (v_values_array->>'node_1');
		v_node2 := (v_values_array->>'node_2');
	END IF;

	-- building the form widgets
	----------------------------
	IF  v_configtable is TRUE THEN

		PERFORM gw_fct_debug(concat('{"data":{"msg":"--> Configuration fields are defined on layoutorder table <--", "variables":""}}')::json);

		-- Call the function of feature fields generation
		v_formtype = 'form_feature';
		v_querystring = 'SELECT gw_fct_getformfields( '||quote_literal(v_formname)||','||quote_literal(v_formtype)||','||quote_literal(v_tabname)||','||quote_literal(v_tablename)||','||quote_literal(v_idname)||','||
		quote_literal(v_id)||','||quote_literal(v_columntype)||','||quote_literal(v_tg_op)||','||'''text'''||','||v_device||','''||COALESCE(v_values_array, '{}')||''' )';

		SELECT gw_fct_getformfields(v_formname , v_formtype , v_tabname , v_tablename , v_idname , v_id , v_columntype, v_tg_op, NULL, v_device , v_values_array)
		INTO v_fields_array;

	ELSE
		PERFORM gw_fct_debug(concat('{"data":{"msg":"--> Configuration fields are NOT defined on layoutorder table. System values are used <--", "variables":""}}')::json);

		-- Get fields
		v_querystring = concat('SELECT array_agg(row_to_json(a)) FROM
			(SELECT a.attname as label, a.attname as columnname,
			concat(',quote_literal(v_tabname),',''_'',a.attname) AS widgetname,
			(case when a.atttypid=16 then ''check'' else ''text'' end ) as widgettype,
			(case when a.atttypid=16 then ''boolean'' else ''string'' end ) as "datatype",
			''::TEXT AS tooltip,
			''::TEXT as placeholder,
			false AS iseditable,
			row_number()over() AS orderby,
			null as stylesheet,
			row_number()over() AS layoutorder,
			FALSE AS isparent,
			null AS widgetfunction,
			null AS linkedaction,
			FALSE AS isautoupdate,
			FAlSE AS ismandatory,
			''lyt_data_1'' AS layoutname,
			null as widgetcontrols,
			FALSE as hidden
			FROM pg_attribute a
			JOIN pg_class t on a.attrelid = t.oid
			JOIN pg_namespace s on t.relnamespace = s.oid
			WHERE a.attnum > 0
			AND NOT a.attisdropped
			AND t.relname = ',quote_nullable(v_tablename),'
			AND s.nspname = ',quote_nullable(schemas_array[1]),'
			AND a.attname !=''the_geom''
			AND a.attname !=''geom''
			ORDER BY a.attnum) a');

		EXECUTE v_querystring INTO v_fields_array;
	END IF;


	-- Filling the form widgets with values
	---------------------------------------
	-- getting values on insert from vdefault values
	IF v_tg_op ='INSERT' THEN

		-- getting vdefault values
		EXECUTE 'SELECT to_json(array_agg(row_to_json(a)))::text FROM (SELECT sys_param_user.id as parameter, feature_field_id as param, value::text AS vdef FROM sys_param_user
			JOIN config_param_user ON sys_param_user.id=parameter WHERE cur_user=current_user AND feature_field_id IS NOT NULL AND
			config_param_user.parameter NOT IN (''edit_workcat_end_vdefault'', ''edit_enddate_vdefault''))a'
			INTO v_values_array;

		-- getting propierties from feature catalog value
		SELECT (a->>'vdef'), (a->>'param') INTO v_catalog, v_catalogtype FROM json_array_elements(v_values_array) AS a
			WHERE (a->>'param') = 'arccat_id' OR (a->>'param') = 'nodecat_id' OR (a->>'param') = 'conneccat_id' OR (a->>'param') = 'gullycat_id';

		IF v_project_type ='WS' AND v_catfeature.feature_type IS NOT NULL AND v_catfeature.feature_type != 'LINK' THEN
			v_querystring = concat('SELECT pnom::integer, dnom::integer, matcat_id FROM cat_',lower(v_catfeature.feature_type),' WHERE id=',quote_nullable(v_catalog));

			EXECUTE v_querystring INTO v_pnom, v_dnom, v_matcat_id;

		ELSIF v_project_type ='UD' AND v_catfeature.feature_type IS NOT NULL AND v_catfeature.feature_type not in ('LINK', 'FLWREG') THEN
			IF (v_catfeature.feature_type) ='GULLY' THEN
				v_querystring = concat('SELECT matcat_id FROM cat_gully WHERE id=',quote_nullable(v_catalog));

				EXECUTE v_querystring INTO v_matcat_id;
			ELSE
				v_querystring = concat('SELECT shape, geom1, geom2, matcat_id FROM cat_',lower(v_catfeature.feature_type),' WHERE id=',quote_nullable(v_catalog));

				EXECUTE v_querystring INTO v_shape, v_geom1, v_geom2, v_matcat_id;
			END IF;
		END IF;
	END IF;

	v_node1 = COALESCE (v_node1, '');
	v_node2 = COALESCE (v_node2, '');

	-- gettingf minvalue & maxvalues for widgetcontrols
	IF v_project_type = 'UD' AND v_catfeature.feature_type IS NOT NULL THEN

		v_input = '{"client":{"device":4,"infoType":1,"lang":"es"}, "feature":{"featureType":"'||v_catfeature.feature_type||'", "id":"'||v_id||'"}, "data":{"tgOp":"'||
		v_tg_op||'", "node1":"'||v_node1||'", "node2":"'||v_node2||'"}}';
		SELECT gw_fct_getwidgetvalues (v_input) INTO v_widgetvalues;

	END IF;

	IF v_tg_op != 'LAYER' THEN
		-- looping the array setting values and widgetcontrols
		FOREACH aux_json IN ARRAY v_fields_array
		LOOP
			array_index := array_index + 1;

			IF v_tg_op='INSERT' THEN
				field_value = NULL;
				CASE (aux_json->>'columnname')

				-- special values
				WHEN quote_ident(v_idname) THEN
					field_value = v_id;
				WHEN concat(lower(v_catfeature.feature_type),'_type') THEN
					v_querystring = concat('SELECT id FROM cat_feature WHERE child_layer = ' , quote_nullable(v_table_id) ,' LIMIT 1');

					EXECUTE v_querystring INTO field_value;
				WHEN 'code' THEN
					field_value = v_code;
				WHEN 'customer_code' THEN
					field_value = v_customercode;
				WHEN 'node_1' THEN
					field_value = v_noderecord1.node_id;
				WHEN 'node_2' THEN
					field_value = v_noderecord2.node_id;
				WHEN 'epa_type' THEN
				    if v_catfeature.feature_type != 'LINK' then
                        v_querystring = concat('SELECT epa_default FROM cat_feature_',(v_catfeature.feature_type),' WHERE id = ', quote_nullable(v_catfeature.id));

                        EXECUTE v_querystring INTO field_value;
                       end if;
				WHEN 'fire_code' THEN
					IF v_use_fire_code_seq THEN
						field_value = nextval ('man_hydrant_fire_code_seq'::regclass);
					END IF;

				-- dynamic mapzones
				WHEN 'presszone_id' THEN
					field_value = v_presszone_id;
				WHEN 'sector_id' THEN
					field_value = v_sector_id;
				WHEN 'dma_id' THEN
					field_value = v_dma_id;
				WHEN 'dqa_id' THEN
					field_value = v_dqa_id;
				WHEN 'supplyzone_id' THEN
					field_value = v_supplyzone_id;
				WHEN 'macrominsector_id' THEN
					field_value = v_macrominsector_id;

				-- static mapzones
				WHEN 'macrosector_id' THEN
					field_value = v_macrosector_id;
				WHEN 'macrodma_id' THEN
					field_value = v_macrodma_id;
				WHEN 'omzone_id' THEN
					field_value = v_omzone_id;
				WHEN 'macroomzone_id' THEN
					field_value = v_macroomzone_id;
				WHEN 'expl_id' THEN
					field_value = v_expl_id;
				WHEN 'macroexpl_id' THEN
					field_value = v_macroexploitation_id;
				WHEN 'muni_id' THEN
					field_value = v_muni_id;
				WHEN 'district_id' THEN
					field_value = v_district_id;

				-- elevation from raster
				WHEN 'elevation', 'top_elev' THEN
					field_value = v_elevation;

				-- staticpressure
				WHEN 'staticpressure' THEN
					field_value = v_staticpressure;

				-- plot_code
				WHEN 'plot_code' THEN
					field_value = v_plot_code;

				-- catalog values
				WHEN 'cat_dnom' THEN
					field_value = v_dnom;
				WHEN 'cat_pnom' THEN
					field_value = v_pnom;
				WHEN 'cat_geom1' THEN
					field_value = v_geom1;
				WHEN 'cat_geom2' THEN
					field_value = v_geom2;
				WHEN 'cat_shape' THEN
					field_value = v_shape;
				WHEN 'matcat_id' THEN
					field_value = v_matcat_id;
				WHEN concat(lower(v_catfeature.feature_type),'cat_id') THEN
					SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
					 WHERE a->>'parameter' = concat('feat_', lower(v_catfeature.id), '_vdefault');

				-- *_type
				WHEN 'category_type' THEN
					IF (SELECT (a->>'vdef') FROM json_array_elements(v_values_array) AS a
					WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = 'edit_feature_category_vdefault'))=v_catfeature.id THEN
						SELECT value INTO field_value FROM config_param_user WHERE parameter = 'edit_featureval_category_vdefault' and cur_user=current_user;
					ELSE
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
						WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = concat('edit_', lower(v_catfeature.feature_type), '_category_vdefault'));
					END IF;

				WHEN 'fluid_type' THEN
					IF (SELECT (a->>'vdef') FROM json_array_elements(v_values_array) AS a
					WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = 'edit_feature_fluid_vdefault'))=v_catfeature.id THEN
						SELECT value INTO field_value FROM config_param_user WHERE parameter = 'edit_featureval_fluid_vdefault' and cur_user=current_user;
					ELSE
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
						WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = concat('edit_', lower(v_catfeature.feature_type), '_fluid_vdefault'));
					END IF;

				WHEN 'function_type' THEN
					IF (SELECT (a->>'vdef') FROM json_array_elements(v_values_array) AS a
					WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = 'edit_feature_function_vdefault'))=v_catfeature.id THEN
						SELECT value INTO field_value FROM config_param_user WHERE parameter = 'edit_featureval_function_vdefault' and cur_user=current_user;
					ELSE
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
						WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = concat('edit_', lower(v_catfeature.feature_type), '_function_vdefault'));
					END IF;

				WHEN 'location_type' THEN
					IF (SELECT (a->>'vdef') FROM json_array_elements(v_values_array) AS a
					WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = 'edit_feature_location_vdefault'))=v_catfeature.id THEN
						SELECT value INTO field_value FROM config_param_user WHERE parameter = 'edit_featureval_location_vdefault' and cur_user=current_user;
					ELSE
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
						WHERE ((a->>'param') = (aux_json->>'columnname') AND a->>'parameter' = concat('edit_', lower(v_catfeature.feature_type), '_location_vdefault'));
					END IF;

				--workcat_id_plan
				WHEN 'workcat_id_plan' THEN
					SELECT (a->>'vdef') INTO v_state_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = 'state';
					-- use this variable only when state=2
					IF v_state_value = 2 THEN
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = 'workcat_id_plan';
					-- when state <> set variable to NULL
					ELSE
						SELECT NULL INTO field_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = 'workcat_id_plan';
					END IF;

				-- state type
				WHEN 'state_type' THEN
					-- getting parent value
					SELECT (a->>'vdef') INTO v_state_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = 'state';

					-- prevent possible null values for state vdefault
					IF v_state_value IS NULL THEN
						v_state_value=1;
					END IF;

					v_querystring = concat('SELECT value::text FROM sys_param_user JOIN config_param_user ON sys_param_user.id=parameter
					WHERE cur_user=current_user AND parameter = concat(''edit_statetype_'',',v_state_value,',''_vdefault'')');

					EXECUTE v_querystring INTO field_value;

				-- builtdate
				WHEN 'builtdate' THEN
					SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = (aux_json->>'columnname');
					--if using automatic current builtdate and vdefault is null, set value to now
					IF (SELECT value::boolean FROM config_param_system WHERE parameter='edit_feature_auto_builtdate') IS TRUE AND field_value IS NULL  THEN
						EXECUTE 'SELECT date(now())' INTO field_value;
					END IF;

				WHEN 'inventory' THEN
					field_value = v_catfeature.inventory_vdefault;

				WHEN 'publish' THEN
					IF (SELECT value::boolean FROM config_param_system WHERE parameter='edit_publish_sysvdefault') IS TRUE THEN
						field_value = (SELECT value::boolean FROM config_param_system WHERE parameter='edit_publish_sysvdefault');
					END IF;

				WHEN 'uncertain' THEN
					IF (SELECT value::boolean FROM config_param_system WHERE parameter='edit_uncertain_sysvdefault') IS TRUE THEN
						field_value = (SELECT value::boolean FROM config_param_system WHERE parameter='edit_uncertain_sysvdefault');
					END IF;

				WHEN 'streetaxis_id' THEN
					IF (v_auto_streetvalues_status is true) then
						field_value = v_streetname;
					END IF;

				WHEN 'postnumber' THEN
					IF (v_auto_streetvalues_status is true) THEN
						IF (v_auto_streetvalues_field = 'postnumber') THEN
							field_value = v_postnumber;
						ELSE field_value = NULL;
					END IF;
				END IF;

				WHEN 'postcomplement' THEN
					IF (v_auto_streetvalues_status IS TRUE) THEN
						IF (v_auto_streetvalues_field = 'postcomplement') THEN
							field_value = v_postnumber;
						ELSE field_value = NULL;
					END IF;
				END IF;

				WHEN 'ownercat_id' THEN
					field_value = (SELECT owner_vdefault FROM exploitation WHERE expl_id = v_expl_id LIMIT 1);

				-- rest (including addfields)
				ELSE SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a WHERE (a->>'param') = (aux_json->>'columnname');
				END CASE;

				--specific values for ud
				IF v_project_type = 'UD' THEN

					CASE (aux_json->>'columnname')
					WHEN 'sys_y1' THEN
						field_value =v_noderecord1.sys_ymax;
					WHEN 'sys_elev1' THEN
						field_value =v_noderecord1.sys_elev;
					WHEN 'sys_y2' THEN
						field_value =v_noderecord2.sys_ymax;
					WHEN 'sys_elev2' THEN
						field_value =v_noderecord2.sys_elev;
					WHEN 'gullycat_id' THEN
						SELECT (a->>'vdef') INTO field_value FROM json_array_elements(v_values_array) AS a
						WHERE a->>'parameter' = concat('feat_', lower(v_catfeature.id), '_vdefault');
					WHEN 'node_id' THEN
                        IF v_catfeature.feature_type = 'FLWREG' THEN
                            field_value = v_noderecord1.node_id;
                        END IF;
                     WHEN 'to_arc' THEN
                        IF v_catfeature.feature_type = 'FLWREG' THEN
                            field_value = v_toarc;
                        END IF;
                    WHEN 'order_id' THEN
                        IF v_catfeature.feature_type = 'FLWREG' THEN
                            field_value = v_order_id;
                        END IF;
                    WHEN 'nodarc_id' THEN
                        IF v_catfeature.feature_type = 'FLWREG' THEN
                            field_value = v_nodarc_id;
                        END IF;
                    when 'flwreg_type' then
                        field_value = v_flwreg_type;
                    when 'flwreg_length' then
                        field_value = v_flwreg_length;
					WHEN 'dwfzone_id' THEN
						field_value = v_dwfzone_id;
					WHEN 'drainzone_id' THEN
						field_value = v_drainzone_id;
                    ELSE
                    END CASE;
                END IF;


			ELSIF  v_tg_op ='UPDATE' OR v_tg_op ='SELECT' THEN

				CASE (aux_json->>'columnname')
				WHEN 'streetaxis_id' THEN
					SELECT descript INTO field_value FROM v_ext_streetaxis WHERE id = (v_values_array->>(aux_json->>'columnname'));
				ELSE
					field_value := (v_values_array->>(aux_json->>'columnname'));
				END CASE;
			END IF;

			-- setting values
			IF (aux_json->>'widgettype')='combo' THEN

				-- Set default value if exist when inserting and feild_value is null
				IF v_tg_op ='INSERT' AND (field_value IS NULL OR field_value = '') THEN
					IF (aux_json->>'widgetcontrols') IS NOT NULL THEN
						IF ((aux_json->>'widgetcontrols')::jsonb ? 'vdefault_value') THEN
							IF (aux_json->>'widgetcontrols')::json->>'vdefault_value'::text in  (select a from json_array_elements_text(json_extract_path(v_fields_array[array_index],'comboIds'))a) THEN
								field_value = (aux_json->>'widgetcontrols')::json->>'vdefault_value';
							END IF;
						ELSEIF ((aux_json->>'widgetcontrols')::jsonb ? 'vdefault_querytext') THEN
							EXECUTE (aux_json->>'widgetcontrols')::json->>'vdefault_querytext'::text INTO vdefault_querytext;
							IF vdefault_querytext in  (select a from json_array_elements_text(json_extract_path(v_fields_array[array_index],'comboIds'))a) THEN
								field_value = vdefault_querytext;
							END iF;
						END IF;
					END IF;
				END IF;

				--check if selected id is on combo list
				IF field_value::text not in  (select a from json_array_elements_text(json_extract_path(v_fields_array[array_index],'comboIds'))a) AND field_value IS NOT NULL then
					--find dvquerytext for combo
					v_querystring = concat('SELECT dv_querytext FROM config_form_fields WHERE
					columnname::text = (',quote_literal(v_fields_array[array_index]),'::json->>''columnname'')::text
					and formname = ',quote_literal(v_table_id),';');

					EXECUTE v_querystring INTO v_querystring;

					if v_querystring is not null then
						v_querystring = replace(lower(v_querystring),'active is true','1=1');

						--select values for missing id
						v_querystring = concat('SELECT id, idval FROM (',v_querystring,')a
						WHERE id::text = ',quote_literal(field_value),'');

						EXECUTE v_querystring INTO v_selected_id,v_selected_idval;

					end if;

					v_current_id =json_extract_path_text(v_fields_array[array_index],'comboIds');

					IF v_current_id='[]' and v_selected_id is not null then
						--case when list is empty
						EXECUTE concat('SELECT  array_to_json(''{',v_selected_id,'}''::text[])')
						INTO v_new_id;
						v_fields_array[array_index] = gw_fct_json_object_set_key(v_fields_array[array_index],'comboIds',v_new_id::json);
						EXECUTE concat('SELECT  array_to_json(''{',v_selected_idval,'}''::text[])')
						INTO v_new_id;
						v_fields_array[array_index] = gw_fct_json_object_set_key(v_fields_array[array_index],'comboNames',v_new_id::json);
					ELSE
					    IF v_selected_id IS NOT NULL THEN
                            select string_agg(quote_ident(a),',') into v_new_id from json_array_elements_text(v_current_id::json) a ;
                            --remove current combo Ids from return json
                            v_fields_array[array_index] = v_fields_array[array_index]::jsonb - 'comboIds'::text;
                            EXECUTE 'SELECT  array_to_json(''{'||v_selected_id||'}''::text[])'
                            INTO v_new_id;
                            --add new combo Ids to return json
                            v_fields_array[array_index] = gw_fct_json_object_set_key(v_fields_array[array_index],'comboIds',v_new_id::json);

                            v_current_id =json_extract_path_text(v_fields_array[array_index],'comboNames');
                            select string_agg(quote_ident(a),',') into v_new_id from json_array_elements_text(v_current_id::json) a ;
                            --remove current combo names from return json
                            v_fields_array[array_index] = v_fields_array[array_index]::jsonb - 'comboNames'::text;
                            EXECUTE 'SELECT  array_to_json(ARRAY['||quote_literal(v_selected_idval)||'])::text'
                            INTO v_new_id;
                            --add new combo names to return json
                            v_fields_array[array_index] = gw_fct_json_object_set_key(v_fields_array[array_index],'comboNames',v_new_id::json);
					    END IF;
					END IF;
				END IF;
				v_fields_array[array_index] := gw_fct_json_object_set_key(v_fields_array[array_index], 'selectedId', COALESCE(field_value, ''));
			ELSIF (aux_json->>'widgettype')='button' and ((aux_json->>'columnname') = 'node_1' OR (aux_json->>'columnname') = 'node_2') THEN
                IF (SELECT value::boolean FROM config_param_system WHERE parameter='admin_node_code_on_arc' ) is true THEN
                    SELECT code into label_value FROM node WHERE node_id = field_value;
                    label_value := COALESCE(label_value, '');
                    v_fields_array[array_index] := gw_fct_json_object_set_key(v_fields_array[array_index], 'valueLabel', label_value);
                ELSE
                    v_fields_array[array_index] := gw_fct_json_object_set_key(v_fields_array[array_index], 'value', COALESCE(field_value, ''));
                END IF;

			ELSIF (aux_json->>'widgettype') !='button' THEN

				-- Set default value if exist when inserting and feild_value is null
				IF v_tg_op ='INSERT' AND (field_value IS NULL OR field_value = '') THEN
					IF (aux_json->>'widgetcontrols') IS NOT NULL THEN
						IF ((aux_json->>'widgetcontrols')::jsonb ? 'vdefault_value') THEN
							field_value = (aux_json->>'widgetcontrols')::json->>'vdefault_value';
						ELSEIF ((aux_json->>'widgetcontrols')::jsonb ? 'vdefault_querytext') THEN
							EXECUTE (aux_json->>'widgetcontrols')::json->>'vdefault_querytext' INTO field_value;
						END IF;
					END IF;
				END IF;
				v_fields_array[array_index] := gw_fct_json_object_set_key(v_fields_array[array_index], 'value', COALESCE(field_value, ''));

			END IF;

			-- setting widgetcontrols
			IF (aux_json->>'datatype')='double' OR (aux_json->>'datatype')='integer' OR (aux_json->>'datatype')='numeric' THEN
				IF v_widgetvalues IS NOT NULL THEN
					v_widgetcontrols = gw_fct_json_object_set_key ((aux_json->>'widgetcontrols')::json, 'maxMinValues' ,(v_widgetvalues->>(aux_json->>'columnname'))::json);
					v_fields_array[array_index] := gw_fct_json_object_set_key (v_fields_array[array_index], 'widgetcontrols', v_widgetcontrols);
				END IF;
			END IF;
		END LOOP;
	END IF;

	--Check if user has migration mode enabled
	IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_disable_topocontrol' AND cur_user=current_user) IS TRUE THEN
	  	v_status = TRUE;
 	END IF;

	-- Convert to json
	v_fields := array_to_json(v_fields_array);

	-- Control NULL's
	v_version := COALESCE(v_version, '[]');
	v_fields := COALESCE(v_fields, '[]');
	v_message := COALESCE(v_message, '[]');

	-- Return
	IF v_status IS TRUE THEN
		RETURN v_fields;
	ELSE
		RETURN ('{"status":"Failed" '||
			',"message":{"level":2, "text":"'||v_message||'"}'||
			',"version":'||v_version||
			',"body":{'||
				'"form":{}'||
				',"feature":{}'||
				',"data":{}'||
				'}'||
			'}')::json;
	END IF;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;