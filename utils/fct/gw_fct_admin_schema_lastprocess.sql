/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2650

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_admin_schema_lastprocess(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE

SELECT SCHEMA_NAME.gw_fct_admin_schema_lastprocess($${
"client":{"lang":"ES"}, 
"data":{"isNewProject":"TRUE", "gwVersion":"3.1.105", "projectType":"WS",
		"epsg":"25831", "title":"test project", "author":"test", "date":"01/01/2000", "superUsers":["postgres", "giswater"]}}$$)


SELECT SCHEMA_NAME.gw_fct_admin_schema_lastprocess($${
"client":{"lang":"ES"},
"data":{"isNewProject":"FALSE", "gwVersion":"3.3.031", "projectType":"UD", "epsg":25831}}$$)


-- fid: 133

*/

DECLARE 

v_dbnname varchar;
v_projecttype text;
v_message text;
v_version record;
v_gwversion text;
v_language text;
v_epsg integer;
v_isnew boolean;
v_issample boolean;
v_descript text;
v_name text;
v_author text;
v_date text;
v_schema_info json;
v_superusers text;
v_tablename record;
v_schemaname text;
v_oldversion text;
v_error_context text;
v_priority integer = 1;
v_fid integer = 133;
v_result text;
v_result_info text;
v_status text;
v_rectable record;
v_max_seq_id integer;
v_querytext text;
v_definition text;
rec_viewname text;
rec_feature record;

BEGIN 
	-- search path
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';
	
	-- get input parameters
	v_gwversion := (p_data ->> 'data')::json->> 'gwVersion';
	v_language := (p_data ->> 'client')::json->> 'lang';
	v_projecttype := (p_data ->> 'data')::json->> 'projectType';
	v_epsg := (p_data ->> 'data')::json->> 'epsg';
	v_isnew := (p_data ->> 'data')::json->> 'isNewProject';
	v_issample := (p_data ->> 'data')::json->> 'isSample';
	v_descript := (p_data ->> 'data')::json->> 'descript';
	v_name := (p_data ->> 'data')::json->> 'name';
	v_author := (p_data ->> 'data')::json->> 'author';
	v_date := (p_data ->> 'data')::json->> 'date';
	v_superusers := (p_data ->> 'data')::json->> 'superUsers';

	--reset sequences for a new project or for a sample
	IF  v_issample IS TRUE THEN
		FOR v_rectable IN (
		    SELECT c.table_name as table_name, c.column_name as column_name, s.sequence_name as sequence_name FROM information_schema.columns c
            JOIN ( SELECT table_schema, table_name, column_name, substring(column_default from '''(.*)''') AS sequence_name
                   FROM information_schema.columns
                   WHERE table_schema = 'SCHEMA_NAME' AND column_default ILIKE 'nextval%'
            ) AS s ON c.table_schema = s.table_schema
                    AND c.table_name = s.table_name
                    AND c.column_name = s.column_name
            WHERE
                c.table_schema = 'SCHEMA_NAME'
                AND s.sequence_name IS NOT NULL
                AND s.sequence_name != 'urn_id_seq'
                AND s.sequence_name != 'doc_seq'
                AND s.sequence_name != 'raingage_rg_id_seq'
            ORDER BY
                s.sequence_name
        )
		LOOP
		    v_querytext:= 'SELECT max('||v_rectable.column_name||') FROM '||v_rectable.table_name||';' ;
		    EXECUTE v_querytext INTO v_max_seq_id;

		    IF v_max_seq_id IS NOT NULL AND v_max_seq_id > 0 THEN
			EXECUTE 'SELECT setval(''SCHEMA_NAME.'||v_rectable.sequence_name||' '','||v_max_seq_id||', true)';
		    END IF;
		END LOOP;

		v_message='Sequeneces set correctly';
	ELSE
		-- enable triggers on typevalue tables
		ALTER TABLE om_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE edit_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE inp_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE plan_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE sys_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE config_typevalue ENABLE TRIGGER gw_trg_typevalue_config_fk;
		ALTER TABLE sys_foreignkey ENABLE TRIGGER gw_trg_typevalue_config_fk;

		-- create triggers for the oposite tables against typevalues
		PERFORM gw_fct_admin_manage_triggers('fk','ALL');
		
		-- create notifications triggers
		PERFORM gw_fct_admin_manage_triggers('notify',null);
		
		-- update cat feature triggering default values and others
		UPDATE cat_feature SET id=id;
		
		-- last proccess
		IF v_isnew IS TRUE THEN
		
			-- inserting version table
			INSERT INTO sys_version (giswater, project_type, postgres, postgis, language, epsg) VALUES (v_gwversion, upper(v_projecttype), (select version()),
			(select postgis_version()), v_language, v_epsg);
					
			-- create json info_schema
			v_descript := COALESCE(v_descript, '');
			v_name := COALESCE(v_name, '');
			v_author := COALESCE(v_author, '');
			v_date := COALESCE(v_date, '');

			v_schema_info = '{"name":"'||v_name||'","descript":"'||v_descript||'","author":"'||v_author||'","date":"'||v_date||'"}';
			
			-- drop deprecated tables
			FOR v_tablename IN SELECT table_name FROM information_schema.tables WHERE table_schema=v_schemaname and substring(table_name,1 , 1) = '_' 
			LOOP
				EXECUTE 'DROP TABLE IF EXISTS '||v_tablename.table_name||' CASCADE';
			END LOOP;
			
			-- enable triggers
			ALTER TABLE config_form_fields ENABLE TRIGGER gw_trg_config_control;
			ALTER TABLE config_form_fields ENABLE TRIGGER gw_trg_typevalue_fk;
			
			-- set mapzones symbology
            UPDATE config_param_system SET value = (replace(value, 'Random', 'Disable')) WHERE parameter='utils_graphanalytics_style';
            UPDATE config_param_system SET value = (replace(value, 'Stylesheet', 'Disable')) WHERE parameter='utils_graphanalytics_style';

			-- reset sequences
			IF v_projecttype = 'UD' THEN 
				select setval('SCHEMA_NAME.cat_dwf_scenario_id_seq',0)
				select setval('SCHEMA_NAME.cat_hydrology_hydrology_id_seq',0)
			END IF;
			
			-- drop deprecated views
			IF v_projecttype = 'WS' THEN 
				DROP VIEW IF EXISTS v_edit_man_varc;
				DROP VIEW IF EXISTS v_edit_man_pipe;
				DROP VIEW IF EXISTS v_edit_man_expansiontank;
				DROP VIEW IF EXISTS v_edit_man_filter;
				DROP VIEW IF EXISTS v_edit_man_flexunion;
				DROP VIEW IF EXISTS v_edit_man_hydrant;
				DROP VIEW IF EXISTS v_edit_man_junction;
				DROP VIEW IF EXISTS v_edit_man_meter;
				DROP VIEW IF EXISTS v_edit_man_netelement;
				DROP VIEW IF EXISTS v_edit_man_netsamplepoint;
				DROP VIEW IF EXISTS v_edit_man_netwjoin;
				DROP VIEW IF EXISTS v_edit_man_pump;
				DROP VIEW IF EXISTS v_edit_man_reduction;
				DROP VIEW IF EXISTS v_edit_man_register;
				DROP VIEW IF EXISTS v_edit_man_source;
				DROP VIEW IF EXISTS v_edit_man_tank;
				DROP VIEW IF EXISTS v_edit_man_valve;
				DROP VIEW IF EXISTS v_edit_man_waterwell;
				DROP VIEW IF EXISTS v_edit_man_manhole;
				DROP VIEW IF EXISTS v_edit_man_wtp;
				DROP VIEW IF EXISTS v_edit_man_fountain;
				DROP VIEW IF EXISTS v_edit_man_tap;
				DROP VIEW IF EXISTS v_edit_man_greentap;
				DROP VIEW IF EXISTS v_edit_man_wjoin;
				DROP VIEW IF EXISTS v_edit_man_fountain_pol;
				DROP VIEW IF EXISTS v_edit_man_register_pol;
				DROP VIEW IF EXISTS v_edit_man_tank_pol;
				DROP VIEW IF EXISTS v_anl_mincut_planified_arc;	
				DROP VIEW IF EXISTS v_anl_mincut_planified_valve;
				DROP VIEW IF EXISTS v_anl_mincut_result_arc;
				DROP VIEW IF EXISTS v_anl_mincut_result_audit;			
				DROP VIEW IF EXISTS v_anl_mincut_result_conflict_arc;
				DROP VIEW IF EXISTS v_anl_mincut_result_conflict_valve;
				DROP VIEW IF EXISTS v_anl_mincut_result_connec;
				DROP VIEW IF EXISTS v_anl_mincut_result_hydrometer;
				DROP VIEW IF EXISTS v_anl_mincut_result_node;
				DROP VIEW IF EXISTS v_anl_mincut_result_polygon;
				DROP VIEW IF EXISTS v_anl_mincut_result_valve;
				
			
			ELSIF v_projecttype = 'UD' THEN
			
				DROP VIEW IF EXISTS v_edit_man_chamber;
				DROP VIEW IF EXISTS v_edit_man_chamber_pol;
				DROP VIEW IF EXISTS v_edit_man_conduit;
				DROP VIEW IF EXISTS v_edit_man_connec;
				DROP VIEW IF EXISTS v_edit_man_gully;
				DROP VIEW IF EXISTS v_edit_man_gully_pol;
				DROP VIEW IF EXISTS v_edit_man_junction;
				DROP VIEW IF EXISTS v_edit_man_manhole;
				DROP VIEW IF EXISTS v_edit_man_netgully;
				DROP VIEW IF EXISTS v_edit_man_netgully_pol;
				DROP VIEW IF EXISTS v_edit_man_netinit;
				DROP VIEW IF EXISTS v_edit_man_outfall;
				DROP VIEW IF EXISTS v_edit_man_siphon;
				DROP VIEW IF EXISTS v_edit_man_storage;
				DROP VIEW IF EXISTS v_edit_man_storage_pol;
				DROP VIEW IF EXISTS v_edit_man_valve;
				DROP VIEW IF EXISTS v_edit_man_varc;
				DROP VIEW IF EXISTS v_edit_man_waccel;
				DROP VIEW IF EXISTS v_edit_man_wjump;
				DROP VIEW IF EXISTS v_edit_man_wwtp;
				DROP VIEW IF EXISTS v_edit_man_wwtp_pol;
			
			END IF;
			
			-- drop deprecated columns
			IF v_projecttype = 'WS' THEN 
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_19;
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_20;
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_21;
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_22;
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_23;
				ALTER TABLE inp_pattern_value DROP COLUMN if exists _factor_24;	
				ALTER TABLE config_graph_mincut DROP COLUMN if exists _to_arc;
				ALTER TABLE ext_rtc_hydrometer DROP COLUMN IF EXISTS hydrometer_category;
				ALTER TABLE ext_rtc_hydrometer DROP COLUMN IF EXISTS cat_hydrometer_id ;
			ELSE
				ALTER TABLE cat_arc_shape DROP COLUMN if exists _tsect_id;	
				ALTER TABLE cat_arc_shape DROP COLUMN if exists _curve_id;	
				ALTER TABLE node DROP COLUMN if exists _sys_elev;	
				ALTER TABLE arc DROP COLUMN if exists _sys_length;	

			END IF;

			ALTER TABLE sys_addfields DROP COLUMN if exists _default_value_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _form_label_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _widgettype_id_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _dv_table_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _dv_key_column_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _sql_text_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _field_length_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _num_decimals_;
			ALTER TABLE sys_addfields DROP COLUMN if exists _dv_value_column_;
			
			--drop NOT NULL restrictions
			ALTER TABLE arc ALTER COLUMN verified DROP NOT NULL;
			ALTER TABLE node ALTER COLUMN verified DROP NOT NULL;
			ALTER TABLE connec ALTER COLUMN verified DROP NOT NULL;
			ALTER TABLE element ALTER COLUMN verified DROP NOT NULL;
			ALTER TABLE samplepoint ALTER COLUMN verified DROP NOT NULL;

			ALTER TABLE arc ALTER COLUMN workcat_id DROP NOT NULL;
			ALTER TABLE node ALTER COLUMN workcat_id DROP NOT NULL;
			ALTER TABLE connec ALTER COLUMN workcat_id DROP NOT NULL;
			ALTER TABLE element ALTER COLUMN workcat_id DROP NOT NULL;
			ALTER TABLE samplepoint ALTER COLUMN workcat_id DROP NOT NULL;

			IF v_projecttype = 'UD' THEN 
				ALTER TABLE gully ALTER COLUMN verified DROP NOT NULL;
				ALTER TABLE gully ALTER COLUMN workcat_id DROP NOT NULL;
			END IF;

			-- inserting on config_param_system table
			INSERT INTO config_param_system (parameter, value, datatype, descript, project_type, label)
			VALUES ('admin_schema_info', v_schema_info,'json', 'Basic information about schema','utils', 'Schema manager:') ON CONFLICT (parameter) DO NOTHING;

			--update value of rename_view_x_id parameter
			UPDATE config_param_system SET value='{"rename_view_x_id":true}' WHERE parameter='admin_manage_cat_feature';
			
			UPDATE config_param_system SET value = gw_fct_json_object_set_key(value::json,'sectorFromExpl', 'True'::boolean) 
			WHERE parameter = 'basic_selector_tab_exploitation';
			UPDATE config_param_system SET value = gw_fct_json_object_set_key(value::json,'sectorFromMacroexpl', 'True'::boolean) 
			WHERE parameter = 'basic_selector_tab_macroexploitation';
			UPDATE config_param_system SET value = gw_fct_json_object_set_key(value::json,'explFromSector', 'True'::boolean) 
			WHERE parameter = 'basic_selector_tab_sector';
			
			-- remove deprecated parameters on config_param_system
			DELETE FROM config_param_system WHERE parameter = 'om_mincut_enable_alerts';

			-- fk for ext tables or utils schema
			PERFORM gw_fct_admin_schema_utils_fk();
			
			--change widgettype for matcat_id when new empty data project (UD)
			IF v_projecttype = 'UD' THEN 
				UPDATE config_form_fields SET iseditable=TRUE, widgettype='combo', dv_isnullvalue=TRUE, dv_querytext='SELECT id, id AS idval FROM cat_mat_node' 
				WHERE columnname='matcat_id' AND formname LIKE 've_node%';

				UPDATE config_form_fields SET iseditable=TRUE, widgettype='combo', dv_isnullvalue=TRUE, dv_querytext='SELECT id, id AS idval FROM cat_mat_arc' 
				WHERE columnname='matcat_id' AND formname LIKE 've_connec%';

				UPDATE config_form_fields SET iseditable=TRUE, widgettype='combo', dv_isnullvalue=TRUE, dv_querytext='SELECT id, id AS idval FROM cat_mat_arc' 
				WHERE columnname='matcat_id' AND formname LIKE 've_arc%';
				
				UPDATE config_form_fields SET iseditable=TRUE, widgettype='combo', dv_isnullvalue=TRUE, dv_querytext='SELECT id, id AS idval FROM cat_mat_node' 
				WHERE columnname='matcat_id' AND formname IN ('v_edit_node');
				
				UPDATE config_form_fields SET iseditable=TRUE, widgettype='combo', dv_isnullvalue=TRUE, dv_querytext='SELECT id, id AS idval FROM cat_mat_arc' 
				WHERE columnname='matcat_id' AND formname IN ('v_edit_arc', 'v_edit_connec');
				
			END IF;

			-- forcing user variables in order to enhance usability for new projects
			UPDATE sys_param_user SET vdefault = '1', ismandatory =  true WHERE id ='edit_state_vdefault';
			UPDATE sys_param_user SET vdefault = 'false', ismandatory = true WHERE id ='qgis_info_docker';
			UPDATE sys_param_user SET vdefault = 'true', ismandatory = true WHERE id ='qgis_form_docker';
			
			-- force all cat feature not active in order to increase step-by-step 
			IF v_projecttype = 'WS' THEN 
				UPDATE cat_feature SET active = false WHERE system_id NOT IN ('VALVE', 'WJOIN', 'JUNCTION', 'TANK', 'PIPE'); -- ws projects
			ELSE
				UPDATE cat_feature SET active = false WHERE system_id NOT IN ('CONDUIT', 'JUNCTION', 'CONNEC', 'GULLY', 'OUTFALL'); -- ud projects
			END IF;
			
			-- hidden lastupdate and lastupdate_user columns
			update config_form_fields SET hidden = true WHERE columnname IN ('lastupdate', 'lastupdate_user', 'publish', 'uncertain');
			
			-- disable edit_noderotation_update_dsbl
			UPDATE sys_param_user SET ismandatory = true, vdefault ='TRUE' WHERE id = 'edit_noderotation_update_dsbl';

			v_message='Project sucessfully created';
			
			-- automatize graph analytics config for ws
			UPDATE config_param_system SET value = 'TRUE' where parameter = 'utils_graphanalytics_automatic_config'; 

			-- UPDATE edit_check_redundance_y_topelev_elev
			UPDATE config_param_system SET value = 'TRUE' WHERE parameter = 'edit_check_redundance_y_topelev_elev';

			-- Make visible fields on feature forms
			IF v_projecttype = 'WS' THEN 
				UPDATE config_form_fields SET hidden = false where (columnname IN ('press_max', 'press_min', 'press_avg') OR columnname IN ('head_max', 'head_min', 'head_avg') OR columnname IN ('demand_max', 'demand_min', 'demand_avg') OR 
				columnname IN ('om_state', 'conserv_state', 'access_type', 'placement_type', 'hydrant_type', 'valve_type')) 
				AND formname ilike 've_node%';

				UPDATE config_form_fields SET hidden = false where (columnname IN ('flow_max', 'flow_min', 'flow_avg') OR columnname IN ('vel_max', 'vel_min', 'vel_avg') OR 
				columnname IN ('om_state', 'conserv_state')) 
				AND formname ilike 've_arc%';

				UPDATE config_form_fields SET hidden = false where (columnname IN ('demand_max', 'demand_min', 'demand_avg') OR columnname IN ('press_max', 'press_min', 'press_avg') OR 
				columnname IN ('om_state', 'conserv_state', 'priority', 'valve_location', 'valve_type', 'shutoff_valve', 'access_type', 'placement_type', 'crmzone_id')) 
				AND formname ilike 've_connec%';
                
				UPDATE config_form_fields SET hidden=true WHERE formname = 'v_edit_arc' AND columnname='parent_id';
				UPDATE config_form_fields SET hidden=true WHERE formname like 've_arc%' AND columnname='parent_id';
				UPDATE config_form_fields SET hidden=true WHERE formname = 'v_edit_arc' AND columnname='observ';
				UPDATE config_form_fields SET hidden=true WHERE formname like 've_arc%' AND columnname='observ';

				-- setting mapzone graph analytics without value in terms of mapzone constructor and graphclass
				UPDATE config_toolbox SET inputparams = '[
					{"widgetname":"graphClass", "label":"Graph class:", "widgettype":"combo","datatype":"text","tooltip": "Graphanalytics method used", "layoutname":"grl_option_parameters","layoutorder":1,"comboIds":["PRESSZONE","DQA","DMA","SECTOR"],
					"comboNames":["Pressure Zonification (PRESSZONE)", "District Quality Areas (DQA) ", "District Metering Areas (DMA)", "Inlet Sectorization (SECTOR-HIGH / SECTOR-LOW)"], "selectedId":""}, 
					{"widgetname":"exploitation", "label":"Exploitation:","widgettype":"combo","datatype":"text","tooltip": "Choose exploitation to work with", "layoutname":"grl_option_parameters","layoutorder":2, 
					"dvQueryText":"select expl_id as id, name as idval from exploitation where active is not false order by name", "selectedId":"$userExploitation"},
					{"widgetname":"floodOnlyMapzone", "label":"Flood only one mapzone: (*)","widgettype":"linetext","datatype":"text", "isMandatory":false, "tooltip":"Flood only identified mapzones. The purpose of this is update only network elements affected by this flooding keeping rest of network as is. Recommended to gain performance when mapzones ecosystem is under work", "placeholder":"1001", "layoutname":"grl_option_parameters","layoutorder":3, "value":""},
					{"widgetname":"forceOpen", "label":"Force open nodes: (*)","widgettype":"linetext","datatype":"text", "isMandatory":false, "tooltip":"Optative node id(s) to temporary open closed node(s) in order to force algorithm to continue there", "placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layoutorder":5, "value":""},
					{"widgetname":"forceClosed", "label":"Force closed nodes: (*)","widgettype":"text","datatype":"text", "isMandatory":false, "tooltip":"Optative node id(s) to temporary close open node(s) to force algorithm to stop there","placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layoutorder":6,"value":""},
					{"widgetname":"usePlanPsector", "label":"Use selected psectors:", "widgettype":"check","datatype":"boolean","tooltip":"If true, use selected psectors. If false ignore selected psectors and only works with on-service network" , "layoutname":"grl_option_parameters","layoutorder":7,"value":""},
					{"widgetname":"commitChanges", "label":"Commit changes:", "widgettype":"check","datatype":"boolean","tooltip":"If true, changes will be applied to DB. If false, algorithm results will be saved in anl tables" , "layoutname":"grl_option_parameters","layoutorder":8,"value":""},
					{"widgetname":"valueForDisconnected", "label":"Value for disconn. and conflict: (*)","widgettype":"linetext","datatype":"text", "isMandatory":false, "tooltip":"Value to use for disconnected features. Usefull for work in progress with dynamic mpzonesnode" , "placeholder":"", "layoutname":"grl_option_parameters","layoutorder":9, "value":""},
					{"widgetname":"updateMapZone", "label":"Mapzone constructor method:","widgettype":"combo","datatype":"integer","layoutname":"grl_option_parameters","layoutorder":10,
					"comboIds":[0,1,2,3,4], "comboNames":["NONE", "CONCAVE POLYGON", "PIPE BUFFER", "PLOT & PIPE BUFFER", "LINK & PIPE BUFFER"], "selectedId":""}, 
					{"widgetname":"geomParamUpdate", "label":"Pipe buffer","widgettype":"text","datatype":"float","tooltip":"Buffer from arcs to create mapzone geometry using [PIPE BUFFER] options. Normal values maybe between 3-20 mts.", "layoutname":"grl_option_parameters","layoutorder":11, "isMandatory":false, "placeholder":"5-30", "value":""}
					]'
				WHERE id = 2768;
								
			ELSIF v_projecttype = 'UD' THEN
				UPDATE config_form_fields SET hidden = false where 
				columnname IN ('step_pp', 'step_fe', 'step_replace', 'cover') AND formname ilike 've_node%';
                
				UPDATE config_form_fields SET layoutorder=30 WHERE formname = 'v_edit_arc' AND columnname='pavcat_id';
				UPDATE config_form_fields SET layoutorder=30 WHERE formname like 've_arc%' AND columnname='pavcat_id';
			END IF;

			-- setting search where search_field is arc_id, node_id, connec_id, gully_id
			UPDATE config_param_system SET value = 
			'{"sys_table_id":"v_edit_arc","sys_id_field":"arc_id","sys_search_field":"arc_id","alias":"Arcs","cat_field":"arccat_id","orderby":"1","search_type":"arc"}'
			WHERE parameter = 'basic_search_network_arc';

			UPDATE config_param_system SET value =
			'{"sys_table_id":"v_edit_connec","sys_id_field":"connec_id","sys_search_field":"connec_id","alias":"Connecs","cat_field":"connecat_id","orderby":"3","search_type":"connec"}'
			WHERE parameter = 'basic_search_network_connec';

			UPDATE config_param_system SET value =
			'{"sys_table_id":"v_edit_element","sys_id_field":"element_id","sys_search_field":"element_id","alias":"Elements","cat_field":"elementcat_id","orderby":"5","search_type":"element"}'
			WHERE parameter = 'basic_search_network_element';

			UPDATE config_param_system SET value =
			'{"sys_table_id":"v_edit_node","sys_id_field":"node_id","sys_search_field":"node_id","alias":"Nodes","cat_field":"nodecat_id","orderby":"2","search_type":"node"}'
			WHERE  parameter = 'basic_search_network_node';

			UPDATE config_param_system SET value =
			'{"sys_table_id":"v_edit_gully","sys_id_field":"gully_id","sys_search_field":"gully_id","alias":"Gullies","cat_field":"gratecat_id","orderby":"3","search_type":"gully"}'
			WHERE  parameter = 'basic_search_network_gully';

		ELSIF v_isnew IS FALSE THEN
		
			-- fix i18n
			IF v_gwversion = '3.6.009' AND v_oldversion IN ('3.6.008', '3.6.008.1', '3.6.008.2') THEN
				PERFORM gw_fct_admin_manage_fix_i18n_36008();
			END IF;
			
			DROP FUNCTION IF EXISTS gw_fct_admin_manage_fix_i18n_36008();
			
				
			SELECT project_type INTO v_projecttype FROM sys_version ORDER BY 1 DESC LIMIT 1;
		
			-- profilactic delete to avoid conflicts with sequences and to clean gdb
			DELETE FROM audit_check_project;
			DELETE FROM audit_check_data;
			DELETE FROM temp_arc;
			DELETE FROM temp_anlgraph;
			DELETE FROM temp_csv;
			DELETE FROM temp_data;
			DELETE FROM temp_node;
			DELETE FROM temp_go2epa;
			DELETE FROM temp_table;

			DELETE FROM anl_arc;
			DELETE FROM anl_arc_x_node;
			DELETE FROM anl_node;
			DELETE FROM anl_polygon;

			IF v_projecttype = 'WS' THEN

				DELETE FROM temp_mincut;
				DELETE FROM temp_demand;
			ELSE
				DELETE FROM temp_arc_flowregulator;
				DELETE FROM temp_gully;			
				DELETE FROM temp_lid_usage;
			END IF;	

			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 4, 'UPDATE PROJECT SCHEMA');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 4, '---------------------');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 3, '');
			
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 2, 'INFO');     -- Info is 2 because we are inserting previously (updat sql) some info message for user using 1
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 2, '----');
			
			v_oldversion = (SELECT giswater FROM sys_version ORDER BY id DESC LIMIT 1);

			-- inserting version table
			SELECT * INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;
			INSERT INTO sys_version (giswater, project_type, postgres, postgis, language, epsg)
			VALUES (v_gwversion, v_version.project_type, (select version()), (select postgis_version()), v_version.language, v_version.epsg);

			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 4, concat('Project have been sucessfully updated from ',v_oldversion,' version to ',v_gwversion, ' version'));
			v_message='Project sucessfully updated';

			IF v_oldversion IN ('3.6.007', '3.6.008', '3.6.008.1', '3.6.008.2') THEN

				FOR rec_feature IN SELECT * FROM cat_feature 
				LOOP
					INSERT INTO sys_table (id, descript, sys_role, criticity, context, alias) 
					VALUES (rec_feature.child_layer, concat('Custom edit view for ', rec_feature.child_layer), 'role_edit', 0, concat('{"level_1":"INVENTORY","level_2":"NETWORK","level_3":"', 
					upper(rec_feature.feature_type),'"}'), rec_feature.id)
					ON CONFLICT (id) 
					DO update set context = concat('{"level_1":"INVENTORY","level_2":"NETWORK","level_3":"', upper(rec_feature.feature_type),'"}');
				END LOOP;
			END IF;
		END IF;

		--reset sequences and id of anl, temp and audit tables
		PERFORM gw_fct_admin_reset_sequences();
		
		-- last process
		UPDATE config_param_system SET value = v_gwversion WHERE parameter = 'admin_version';
		PERFORM gw_fct_admin_role_permissions();
		PERFORM gw_fct_setowner($${"client":{"lang":"ES"},"data":{"owner":"role_admin"}}$$);
		
		--build return with log table
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result
		FROM (SELECT id, error_message as message FROM audit_check_data 
		WHERE cur_user="current_user"() AND fid=v_fid ORDER BY criticity desc, id asc) row;

	END IF;

	v_result_info := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result_info, '}');

	-- Return
	RETURN ('{"status":"Accepted", "message":{"level":"'||v_priority||'", "text":"'||v_message||'"}'||
		',"body":{"form":{}'||
			',"data":{ "info":'||v_result_info||
			'}}}');

    -- Exception handling
    EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
    RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;