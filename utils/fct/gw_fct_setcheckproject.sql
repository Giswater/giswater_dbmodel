/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2794

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_audit_check_project(INTEGER);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_audit_check_project(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setcheckproject (p_data json)
  RETURNS json AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_setcheckproject($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":5367}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, 
"version":"3.5.021.1", "fid":101, "initProject":false, "addSchema":"NULL", "mainSchema":"NULL", "projecRole":"role_admin", "infoType":"full", "logFolderVolume":"139.56 MB", 
"projectType":"ws", "qgisVersion":"3.16.6-Hannover", "osVersion":"Windows 10"}}$$);

-- fid: main: 101
	om: 125
	graph: 211
	edit: 29
	epa: 225
	plan: 115
	admin: 195
	user: 251
*/

DECLARE 

v_querytext text;
v_parameter text;
v_audit_rows integer;
v_compare_sign text;
v_isenabled boolean;
v_diference integer;
v_error integer;
v_count integer;
v_table_host text;
v_table_dbname text;
v_table_schema text;
v_query_string text;
v_max_seq_id int8;
v_project_type text;
v_psector_vdef integer;
v_errortext text;
v_result_id text;
v_rectable record;
v_version text;
v_epsg integer;
v_result_layers_criticity3 json;
v_result_layers_criticity2 json;
v_return json;
v_missing_layers json;
v_schemaname text;
v_layer_list text;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_result json;
v_result_info json;
v_qgis_version text;
v_user_control boolean = false;
v_layer_log boolean = false;
v_error_context text;
v_hidden_form boolean;
v_init_project boolean;
v_qgisversion text;
v_osversion text;
v_qgis_init_guide_map boolean;
v_qgis_layers_setpropierties boolean;
v_addschema text;
v_fid integer;
v_mainschema text;
v_projectrole text;
v_infotype text;
v_insert_fields json;
field json;
query_text text;
v_qgis_project_type text;
v_logfoldervolume text;
v_uservalues json;
v_user_expl text;
v_isaudit text;
v_selection_mode text;
v_ignoregraphanalytics boolean;
v_ignoreepa boolean;
v_ignoreplan boolean;
v_usepsector boolean;

BEGIN 

	-- search path
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';

	SELECT project_type, giswater, epsg INTO v_project_type, v_version, v_epsg FROM sys_version order by id desc limit 1;
	
	-- Get input parameters
	v_fid := (p_data ->> 'data')::json->> 'fid';
	v_qgis_version := (p_data ->> 'data')::json->> 'version';
	v_init_project := (p_data ->> 'data')::json->> 'initProject';
	v_qgisversion := (p_data ->> 'data')::json->> 'qgisVersion';
	v_osversion := (p_data ->> 'data')::json->> 'osVersion';
	v_addschema := (p_data ->> 'data')::json->> 'addSchema';
	v_mainschema := (p_data ->> 'data')::json->> 'mainSchema';
	v_projectrole := (p_data ->> 'data')::json->> 'projectRole';
	v_infotype := (p_data ->> 'data')::json->> 'infoType';
	v_insert_fields := (p_data ->> 'data')::json->> 'fields';
	v_qgis_project_type := (p_data ->> 'data')::json->> 'projectType';
	v_logfoldervolume := (p_data ->> 'data')::json->> 'logFolderVolume';
	v_isaudit := (p_data ->> 'data')::json->> 'isAudit';


	IF (SELECT value::boolean FROM config_param_system WHERE parameter = 'admin_exploitation_x_user') IS TRUE THEN
		v_selection_mode = 'userSelectors';
	ELSE 
		v_selection_mode = 'wholeSystem';
	END IF;

	-- profilactic control of qgis variables
	IF lower(v_mainschema) = 'none' OR v_mainschema = '' OR lower(v_mainschema) ='null' THEN v_mainschema = null; END IF;
	IF lower(v_projectrole) = 'none' OR v_projectrole = '' OR lower(v_projectrole) ='null' THEN v_projectrole = null; END IF;
	IF lower(v_infotype) = 'none' OR v_infotype = '' OR lower(v_infotype) ='null' THEN v_infotype = null; END IF;
	IF lower(v_qgis_project_type) = 'none' OR v_qgis_project_type = '' OR lower(v_qgis_project_type) ='null' THEN v_qgis_project_type = null; END IF;

	-- profilactic control of schema name
	IF lower(v_addschema) = 'none' OR v_addschema = '' OR lower(v_addschema) ='null' OR v_addschema is null THEN
		 v_addschema = null; 
	ELSE
		IF (select schemaname from pg_tables WHERE schemaname = v_addschema LIMIT 1) IS NULL THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3132", "function":"2580","debug_msg":null}}$$)';
			-- todo: send message to response
		END IF;
	END IF;
	
	-- get user parameters
	SELECT value INTO v_user_control FROM config_param_user where parameter='utils_checkproject_database' AND cur_user=current_user;
	SELECT value INTO v_layer_log FROM config_param_user where parameter='utils_checkproject_qgislayer' AND cur_user=current_user;
	SELECT value INTO v_hidden_form FROM config_param_user where parameter='qgis_form_initproject_hidden' AND cur_user=current_user;
	SELECT value INTO v_qgis_init_guide_map FROM config_param_user where parameter='qgis_init_guide_map' AND cur_user=current_user;
	SELECT value INTO v_qgis_layers_setpropierties FROM config_param_user where parameter='qgis_layers_set_propierties' AND cur_user=current_user;

	-- get system parameters
	SELECT value::json->>'ignoreGraphanalytics' INTO v_ignoregraphanalytics FROM config_param_system WHERE parameter = 'admin_checkproject';
	SELECT value::json->>'ignorePlan' INTO v_ignoreplan FROM config_param_system WHERE parameter = 'admin_checkproject';
	SELECT value::json->>'ignoreEpa' INTO v_ignoreepa FROM config_param_system WHERE parameter = 'admin_checkproject';
	SELECT value::json->>'usePsectors' INTO v_usepsector FROM config_param_system WHERE parameter = 'admin_checkproject';

	-- profilactic null control
	IF v_qgis_init_guide_map IS NULL THEN v_qgis_init_guide_map = FALSE; END IF;
	IF v_qgis_layers_setpropierties IS NULL THEN v_qgis_layers_setpropierties = FALSE; END IF;
	IF v_ignoregraphanalytics IS NULL THEN v_ignoregraphanalytics = FALSE; END IF;
	IF v_ignoreepa IS NULL THEN v_ignoreepa = FALSE; END IF;
	IF v_ignoreplan IS NULL THEN v_ignoreplan = FALSE; END IF;

	-- when funcion gw_fct_setcheckproject is called by click on utils button, force to show user dialog and user control
	IF v_init_project IS FALSE THEN
		v_user_control = TRUE;
		v_hidden_form = FALSE;
	END IF;
	
	-- init process
	v_isenabled:=FALSE;
	v_count=0;
    
	-- Delete and insert values from python into audit_check_project	
        DELETE FROM audit_check_project WHERE cur_user = current_user AND fid = 101;
	query_text=NULL;
	FOR field in SELECT * FROM json_array_elements(v_insert_fields) LOOP
		select into query_text concat(query_text, 'INSERT INTO '||v_schemaname||'.audit_check_project (table_schema, table_id, table_dbname, table_host, fid, table_user) ') ;
		select into query_text concat(query_text, 'VALUES('||quote_literal((field->>'table_schema'))||', '||quote_literal((field->>'table_id'))||', '||quote_literal((field->>'table_dbname'))||', '||quote_literal((field->>'table_host'))||'') ;
		select into query_text concat(query_text, ', '||quote_literal((field->>'fid'))||', '||quote_literal((field->>'table_user'))||');') ;
	END LOOP;
	IF query_text IS NOT NULL THEN EXECUTE query_text; END IF;
    

	-- profilactic delete of legacy values on man_addfields_value
	IF 'role_edit' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
		IF v_project_type='WS' THEN
			DELETE FROM man_addfields_value WHERE feature_id IN(
			SELECT m.feature_id FROM man_addfields_value m LEFT JOIN
			(SELECT arc_id as feature_id from arc UNION SELECT node_id FROM node UNION SELECT connec_id from connec) a USING (feature_id)
			WHERE a.feature_id is null
			);
		ELSE
			DELETE FROM man_addfields_value WHERE feature_id IN(
			SELECT m.feature_id FROM man_addfields_value m LEFT JOIN
			(SELECT arc_id as feature_id from arc UNION SELECT node_id FROM node UNION SELECT connec_id from connec UNION SELECT gully_id from gully) a USING (feature_id)
			WHERE a.feature_id is null
			);
		END IF;
	END IF;
	
	-- profilactic control on feat vdefault parameters on sys_param_user table
	IF 'role_admin' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
		UPDATE sys_param_user set project_type = lower(v_project_type) where project_type IS NULL;
	END IF;

	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fid=101 AND cur_user=current_user;
	
	-- Starting process
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'AUDIT CHECK PROJECT');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '------------------------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 3, 'CRITICAL ERRORS');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 3, '----------------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 2, 'WARNINGS');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 2, '--------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 1, 'INFO');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 1, '-------');

	--check plugin and db version (349)
	IF v_qgis_version = v_version THEN
		v_errortext=concat('Giswater version: ',v_version,'.');
		INSERT INTO audit_check_data (fid,  criticity, error_message,fcount)
		VALUES (101, 4, v_errortext,0);
	ELSE
		v_errortext=concat('ERROR-349: Version of plugin is different than the database version. DB: ',v_version,', plugin: ',v_qgis_version,'.');
		INSERT INTO audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (101, 3, '349',v_errortext, 1);
	END IF;

	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('PostgreSQL version: ',(SELECT version())));
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('PostGIS version: ',(SELECT postgis_version())));
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('QGIS version: ', v_qgisversion));
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('O/S version: ', v_osversion));
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('Log volume (User folder): ', v_logfoldervolume));
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, concat ('QGIS variables: gwProjectType:',quote_nullable(v_qgis_project_type),', gwInfoType:',
	quote_nullable(v_infotype),', gwProjectRole:', quote_nullable(v_projectrole),', gwMainSchema:',quote_nullable(v_mainschema),', gwAddSchema:',quote_nullable(v_addschema)));
	
	v_errortext=concat('Logged as ', current_user,' on ', now());
	
	INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);

	--Set hydrology_selector when null values from user
	IF v_project_type='UD' THEN
		IF (SELECT hydrology_id FROM cat_hydrology LIMIT 1) IS NOT NULL THEN
			INSERT INTO config_param_user 
			SELECT 'inp_options_hydrology_scenario', hydrology_id, current_user FROM cat_hydrology LIMIT 1
			ON CONFLICT (parameter, cur_user) DO NOTHING;
			UPDATE config_param_user SET value = hydrology_id FROM (SELECT hydrology_id FROM cat_hydrology LIMIT 1) a
			WHERE parameter =  'inp_options_hydrology_scenario' and value is null;
		END IF;
	END IF;
   
	-- set mandatory values of config_param_user in case of not exists (for new users or for updates)
	FOR v_rectable IN SELECT * FROM sys_param_user WHERE ismandatory IS TRUE AND sys_role IN (SELECT rolname FROM pg_roles WHERE pg_has_role(current_user, oid, 'member'))
	LOOP
		IF v_rectable.id NOT IN (SELECT parameter FROM config_param_user WHERE cur_user=current_user) THEN
			INSERT INTO config_param_user (parameter, value, cur_user) 
			SELECT sys_param_user.id, vdefault, current_user FROM sys_param_user WHERE sys_param_user.id = v_rectable.id;	

			v_errortext=concat('Set value for new variable in config param user: ',v_rectable.id,'.');

			INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
		END IF;
	END LOOP;

	-- manage mandatory values of config_param_user where feature is deprecated
	IF 'role_admin' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
	
		DELETE FROM sys_param_user WHERE id IN (SELECT sys_param_user.id FROM sys_param_user, cat_feature 
		WHERE active=false AND concat(lower(cat_feature.id),'_vdefault') = sys_param_user.id);

		v_errortext=concat('Inactive parameters have been deleted from sys_param_user.');
		INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
		
	END IF;

	-- delete on config_param_user fron updated values on sys_param_user
	DELETE FROM config_param_user WHERE parameter NOT IN (SELECT id FROM sys_param_user) AND cur_user = current_user;

	-- reset all exploitations
	IF v_qgis_init_guide_map THEN
		DELETE FROM selector_expl WHERE cur_user = current_user;

		-- looking for additional schema 
		IF v_addschema IS NOT NULL AND v_addschema != v_schemaname THEN
			EXECUTE 'SET search_path = '||v_addschema||', public';
			DELETE FROM selector_expl WHERE cur_user = current_user;			
			SET search_path = 'SCHEMA_NAME', public;
		END IF;
	ELSE
		-- Force exploitation selector in case of null values
		IF (SELECT count(*) FROM selector_expl WHERE cur_user=current_user) < 1 THEN 

			IF (SELECT value::boolean FROM config_param_system WHERE parameter = 'admin_exploitation_x_user') IS NOT TRUE THEN

				INSERT INTO selector_expl (expl_id, cur_user) 
				SELECT expl_id, current_user FROM exploitation WHERE active IS NOT FALSE AND expl_id > 0 limit 1;
				v_errortext=concat('Set visible exploitation for user ',(SELECT expl_id FROM exploitation WHERE active IS NOT FALSE AND expl_id > 0 limit 1));
				INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
			ELSE
				INSERT INTO selector_expl (expl_id, cur_user) 
				SELECT expl_id, current_user FROM config_user_x_expl WHERE username = current_user AND expl_id > 0 limit 1;
				v_errortext=concat('Set visible exploitation for user ',(SELECT expl_id FROM config_user_x_expl WHERE username = current_user AND expl_id > 0 limit 1));
				INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
			END IF;
		END IF;
	END IF;

	-- force expl = 0
	INSERT INTO selector_expl (expl_id, cur_user) SELECT 0, current_user FROM exploitation LIMIT 1 ON CONFLICT (expl_id, cur_user) DO NOTHING;
				
	-- Force state selector in case of null values
	IF (SELECT count(*) FROM selector_state WHERE cur_user=current_user) < 1 THEN 
	  	INSERT INTO selector_state (state_id, cur_user) VALUES (1, current_user);
		v_errortext=concat('Set feature state = 1 for user');
		INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
	END IF;
	
	-- Force state selector in case of null values for addschema
	IF v_addschema IS NOT NULL THEN

		EXECUTE 'SET search_path = '||v_addschema||', public';
		IF (SELECT count(*) FROM selector_state WHERE cur_user=current_user) < 1 THEN 
			INSERT INTO selector_state (state_id, cur_user) VALUES (1, current_user);
			v_errortext=concat('Set feature state = 1 for addschema and user');
			INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
		END IF;
		SET search_path = 'SCHEMA_NAME';
	END IF;

	-- Force psector selector in case of v_usepsector is false 
	IF v_usepsector IS NOT TRUE THEN
	
		-- save psector selector 
		DELETE FROM temp_table WHERE fid=288 AND cur_user=current_user;
		INSERT INTO temp_table (fid, text_column)
		SELECT 288, (array_agg(psector_id)) FROM selector_psector WHERE cur_user=current_user;

		-- set psector selector
		DELETE FROM selector_psector WHERE cur_user=current_user;
	END IF;
	
	-- Force hydrometer selector in case of null values
	IF (SELECT count(*) FROM selector_hydrometer WHERE cur_user=current_user) < 1 THEN 
	  	INSERT INTO selector_hydrometer (state_id, cur_user) VALUES (1, current_user);
		v_errortext=concat('Set hydrometer state = 1 for user');
		INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
	END IF;


	-- Force psector vdefault visible to current_user (only to => role_master)
	IF 'role_master' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
	
		SELECT value::integer INTO v_psector_vdef FROM config_param_user WHERE parameter='plan_psector_vdefault' AND cur_user=current_user;

		IF v_psector_vdef IS NULL THEN
			SELECT psector_id INTO v_psector_vdef FROM plan_psector WHERE status=2 LIMIT 1;
			IF v_psector_vdef IS NULL THEN
				v_errortext=concat('No current psector have been set. There are not psectors with status=2 on project');
				INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
			END IF;
		END IF;

		IF v_psector_vdef IS NOT NULL THEN
			v_errortext=concat('Current psector: ',v_psector_vdef);
			INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
		END IF;

		INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (v_fid, 4, concat('Use psectors on check db): ', upper(v_usepsector::text)));
	END IF;

	IF v_selection_mode = 'userSelectors' THEN
		-- Check which exploitations have been checked
		SELECT string_agg(name, ' / ') INTO v_user_expl FROM exploitation JOIN selector_expl USING (expl_id) WHERE cur_user=current_user;
		v_errortext=concat('Checked exploitation/s: ', v_user_expl);
		INSERT INTO audit_check_data (fid,  criticity, error_message) VALUES (101, 4, v_errortext);
	END IF;

	--If user has activated full project control, depending on user role - execute corresponding check function
	IF v_user_control THEN
		
		IF 'role_om' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
			EXECUTE 'SELECT gw_fct_om_check_data($${
			"client":{"device":4, "infoType":1, "lang":"ES"},
			"feature":{},"data":{"parameters":{"selectionMode":"'||v_selection_mode||'"}}}$$)';
			-- insert results 
			UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB OM):', split_part(error_message,': ',2))
			WHERE fid=125 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

			INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
			SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
			WHERE fid=125 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;

			IF v_ignoregraphanalytics IS FALSE THEN
				IF v_project_type = 'WS' THEN
					EXECUTE 'SELECT gw_fct_graphanalytics_check_data($${
					"client":{"device":4, "infoType":1, "lang":"ES"},
					"feature":{},"data":{"parameters":{"selectionMode":"'||v_selection_mode||'", "graphClass":"ALL"}}}$$)';
					-- insert results 
					UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB GRAPH):', split_part(error_message,': ',2))
					WHERE fid=211 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

					INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
					SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
					WHERE fid=211 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;
				END IF;
			ELSE
				-- delete old values on result table
				DELETE FROM audit_check_data WHERE fid=211 AND cur_user=current_user;
				DELETE FROM anl_node WHERE cur_user=current_user AND fid IN (176,180,181,182,208,209);
			END IF;
		END IF;

		IF 'role_edit' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN

			-- arrange vnode
			EXECUTE 'SELECT gw_fct_setvnoderepair($${
			"client":{"device":4, "infoType":1, "lang":"ES"},
			"feature":{},"data":{"parameters":{}}}$$)';
			-- insert results 
			UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB OM):', split_part(error_message,': ',2))
			WHERE fid=296 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

			INSERT INTO audit_check_data  (fid, criticity, error_message)
			SELECT 101, criticity, error_message FROM audit_check_data 
			WHERE fid=296 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;
		END IF;
		

		IF 'role_epa' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN

			IF v_ignoreepa IS FALSE THEN
				EXECUTE 'SELECT gw_fct_pg2epa_check_data($${
				"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},"data":{}}$$)';
				-- insert results 
				UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB EPA):', split_part(error_message,': ',2))
				WHERE fid=225 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

				INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
				SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
				WHERE fid=225 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;	
			END IF;
		END IF;

		IF 'role_master' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN

			IF v_ignoreplan IS FALSE THEN
				EXECUTE 'SELECT gw_fct_plan_check_data($${
				"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},"data":{}}$$)';
				-- insert results 
				UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB PLAN):', split_part(error_message,': ',2))
				WHERE fid=115 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

				INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
				SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
				WHERE fid=115 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;
			ELSE
				-- delete old values on result table
				DELETE FROM audit_check_data WHERE fid=115 AND cur_user=current_user;
				DELETE FROM anl_connec WHERE cur_user=current_user AND fid IN (252);
				DELETE FROM anl_arc WHERE cur_user=current_user AND fid IN (252);
				DELETE FROM anl_node WHERE cur_user=current_user AND fid IN (252, 354, 355);
			END IF;
		END IF;

		IF 'role_admin' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN
			EXECUTE 'SELECT gw_fct_admin_check_data($${"client":
			{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{},
			"data":{"filterFields":{}, "pageInfo":{}, "parameters":{}}}$$)::text';
			-- insert results 
			UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB ADMIN):', split_part(error_message,': ',2))
			WHERE fid=195 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

			INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
			SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
			WHERE fid=195 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') AND error_message NOT LIKE '---%' AND cur_user=current_user;
			
		END IF;

		IF v_isaudit IS NULL THEN v_isaudit='false'; END IF;
		
		EXECUTE 'SELECT gw_fct_user_check_data($${"client":
		{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{},
		"data":{"filterFields":{}, "pageInfo":{}, "parameters":{"checkType":"Project","isAudit":'||v_isaudit||', "selectionMode":"'||v_selection_mode||'"}}}$$)::text';
			
		-- insert results 
		UPDATE audit_check_data SET error_message = concat(split_part(error_message,':',1), ' (DB USER):', split_part(error_message,': ',2))
		WHERE fid=251 AND criticity < 4 AND error_message !='' AND cur_user=current_user AND result_id IS NOT NULL;

		INSERT INTO audit_check_data  (fid, criticity, result_id, error_message, fcount)
		SELECT 101, criticity, result_id, error_message, fcount FROM audit_check_data 
		WHERE fid=251 AND criticity < 4 AND error_message NOT IN ('CRITICAL ERRORS','WARNINGS','INFO', '') 
		AND error_message NOT LIKE 'DATA%'
		AND error_message NOT LIKE '---%' AND cur_user=current_user;
			
	END IF;

	-- force hydrometer_selector
	IF (select cur_user FROM selector_hydrometer WHERE cur_user = current_user limit 1) IS NULL THEN
		INSERT INTO selector_hydrometer (state_id, cur_user) 
		SELECT id, current_user FROM ext_rtc_hydrometer_state ON CONFLICT (state_id, cur_user) DO NOTHING;
	END IF;

	-- get uservalues
	PERFORM gw_fct_workspacemanager($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{},"data":{"filterFields":{}, "pageInfo":{}, "action":"CHECK"}}$$);
		
	v_uservalues = (SELECT to_json(array_agg(row_to_json(a))) FROM (SELECT parameter, value FROM config_param_user WHERE parameter IN ('plan_psector_vdefault', 'utils_workspace_vdefault')
	AND cur_user = current_user ORDER BY parameter)a);

	v_uservalues := COALESCE(v_uservalues, '{}');

	  -- restore state selector (if it's needed)
	IF v_usepsector IS NOT TRUE THEN
		INSERT INTO selector_psector (psector_id, cur_user)
		select unnest(text_column::integer[]), current_user from temp_table where fid=288 and cur_user=current_user
		ON CONFLICT (psector_id, cur_user) DO NOTHING;
	END IF;
		
	-- show form
	IF v_hidden_form IS FALSE AND v_fid=101 THEN

		-- get values using v_edit_node as 'current'  (in case v_edit_node is wrong all will he wrong)
		SELECT table_host, table_dbname, table_schema INTO v_table_host, v_table_dbname, v_table_schema 
		FROM audit_check_project where table_id = 'v_edit_node' and cur_user=current_user;
			
		--check layers host (350)
		SELECT count(*), string_agg(table_id,',') INTO v_count, v_layer_list 
		FROM audit_check_project WHERE table_host != v_table_host AND cur_user=current_user;
			
		IF v_count>0 THEN
			v_errortext = concat('ERROR-350 (QGIS PROJ): There is/are ',v_count,' layers that come from differen host: ',v_layer_list,'.');
			
			INSERT INTO audit_check_data (fid,  criticity, result_id,error_message)
			VALUES (101, 3,'350',v_errortext );
		ELSE
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 1, '350', 'INFO (QGIS PROJ): All layers come from current host');
		END IF;
		
		--check layers database (351)
		SELECT count(*), string_agg(table_id,',') INTO v_count, v_layer_list 
		FROM audit_check_project WHERE table_dbname != v_table_dbname AND cur_user=current_user;
		
		IF v_count>0 THEN
			v_errortext = concat('ERROR-351 (QGIS PROJ): There is/are ',v_count,' layers that come from different database: ',v_layer_list,'.');
		
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 3, '351', v_errortext );
		ELSE
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 1, '351', 'INFO (QGIS PROJ): All layers come from current database');
		END IF;

		--check layers database(352)
		SELECT count(*), string_agg(table_id,',') INTO v_count, v_layer_list 
		FROM audit_check_project WHERE table_schema != v_table_schema AND cur_user=current_user;
		
		IF v_count>0 THEN
			v_errortext = concat('ERROR-352 (QGIS PROJ): There is/are ',v_count,' layers that come from different schema: ',v_layer_list,'.');
		
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 3, '352', v_errortext );
		ELSE
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 1, '352', 'INFO (QGIS PROJ): All layers come from current schema');
		END IF;

		--check layers user (353)
		SELECT count(*), string_agg(table_id,',') INTO v_count, v_layer_list 
		FROM audit_check_project WHERE cur_user != table_user AND table_user != 'None' AND cur_user=current_user;
		
		IF v_count>0 THEN
			v_errortext = concat('ERROR-353 (QGIS PROJ): There is/are ',v_count,' layers that have been added by different user: ',v_layer_list,'.');
		
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 3,'353',v_errortext );
		ELSE
			INSERT INTO audit_check_data (fid,  criticity, result_id, error_message)
			VALUES (101, 1, '353','INFO (QGIS PROJ): All layers have been added by current user');
		END IF;

		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '-----------------------------------------------------------');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'To check CRITICAL ERRORS or WARNINGS, execute a query FROM anl_table WHERE fid=error number AND current_user.');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'For example:');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'SELECT * FROM anl_arc WHERE fid=103 AND cur_user=current_user;');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'Only the errors with anl_table next to the number can be checked this way.');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, 'Using Giswater Toolbox it''s also posible to check these errors.');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '-----------------------------------------------------------');
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, null, 4, '');

		-- start process
		FOR v_rectable IN SELECT * FROM sys_table WHERE sys_role IN 
		(SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member') )
		LOOP
		
			--RAISE NOTICE 'v_count % id % ', v_count, v_rectable.id;
			IF v_rectable.id NOT IN (SELECT table_id FROM audit_check_project WHERE cur_user=current_user AND fid=v_fid) THEN
				INSERT INTO audit_check_project (table_id, fid, criticity, enabled, message) VALUES (v_rectable.id, 101, v_rectable.criticity, FALSE, v_rectable.descript);
			--ELSE 
			--	UPDATE audit_check_project SET criticity=v_rectable.qgis_criticity, enabled=TRUE WHERE table_id=v_rectable.id;
			END IF;	
			v_count=v_count+1;
		END LOOP;
		
		--error 1 (criticity = 3 and false)
		SELECT count (*) INTO v_error FROM audit_check_project WHERE cur_user=current_user AND fid=101 AND criticity=3 AND enabled=FALSE;

		--list missing layers with criticity 3 and 2

		EXECUTE 'SELECT json_agg(row_to_json(a)) FROM (SELECT table_id as layer,columns.column_name as pkey_field,
		'''||v_epsg||''' as srid,b.column_name as geom_field,''3'' as criticity, descript, style as style_id, group_layer
		FROM '||v_schemaname||'.audit_check_project 
		JOIN information_schema.columns ON table_name = table_id 
		AND columns.table_schema = '''||v_schemaname||''' and ordinal_position=1 
		LEFT JOIN sys_table ON sys_table.id=audit_check_project.table_id
		LEFT JOIN config_table ON sys_table.id = config_table.id
		INNER JOIN (SELECT column_name ,table_name FROM information_schema.columns
		WHERE table_schema = '''||v_schemaname||''' AND udt_name = ''geometry'')b ON b.table_name=sys_table.id
		WHERE audit_check_project.criticity=3 and enabled IS NOT TRUE) a'
		INTO v_result_layers_criticity3;


		EXECUTE 'SELECT json_agg(row_to_json(a)) FROM (SELECT table_id as layer,columns.column_name as pkey_field,
		'''||v_epsg||''' as srid,b.column_name as geom_field,''2'' as criticity, descript, style as style_id, group_layer
		FROM '||v_schemaname||'.audit_check_project 
		JOIN information_schema.columns ON table_name = table_id 
		AND columns.table_schema = '''||v_schemaname||''' and ordinal_position=1 
		LEFT JOIN sys_table ON sys_table.id=audit_check_project.table_id
		LEFT JOIN config_table ON sys_table.id = config_table.id
		INNER JOIN (SELECT column_name ,table_name FROM information_schema.columns
		WHERE table_schema = '''||v_schemaname||''' AND udt_name = ''geometry'')b ON b.table_name=sys_table.id
		WHERE audit_check_project.criticity=2 and enabled IS NOT TRUE) a'
		INTO v_result_layers_criticity2;

		v_result_layers_criticity3 := COALESCE(v_result_layers_criticity3, '{}'); 
		v_result_layers_criticity2 := COALESCE(v_result_layers_criticity2, '{}'); 

		v_missing_layers = v_result_layers_criticity3::jsonb||v_result_layers_criticity2::jsonb;
		

		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, v_result_id, 4, NULL);
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, v_result_id, 3, NULL);
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, v_result_id, 2, NULL);
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (101, v_result_id, 1, NULL);

		-- get results
		-- info
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result
		FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND fid=101 order by criticity desc, id asc) row;
		v_result := COALESCE(v_result, '{}'); 
		v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

		IF v_layer_log THEN
		
			--points
			v_result = null;
			SELECT jsonb_agg(features.feature) INTO v_result
			FROM (
			SELECT jsonb_build_object(
		     'type',       'Feature',
		    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
		    'properties', to_jsonb(row) - 'the_geom'
			) AS feature
			FROM (SELECT id, node_id, nodecat_id, state, expl_id, descript, fid, the_geom FROM anl_node WHERE cur_user="current_user"() AND fid IN (107,214,164,166,170,171,198) -- epa
			UNION
			SELECT id, node_id, nodecat_id, state, expl_id, descript, fid, the_geom FROM anl_node WHERE cur_user="current_user"() AND fid IN (104,176,179,180,181,182,187,196,197,202,203)  -- om
			UNION
			SELECT id, connec_id, connecat_id, state, expl_id, descript,fid, the_geom FROM anl_connec WHERE cur_user="current_user"() AND fid IN (201,202,204,205,206) -- om
			) row) features;

			v_result := COALESCE(v_result, '{}'); 
			v_result_point = concat ('{"geometryType":"Point", "features":',v_result,',"category_field":"descript"}'); 

			--lines
			v_result = null;

			SELECT jsonb_agg(features.feature) INTO v_result
			FROM (
			SELECT jsonb_build_object(
		     'type',       'Feature',
		    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
		    'properties', to_jsonb(row) - 'the_geom'
			) AS feature
			FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript, fid, the_geom FROM anl_arc WHERE cur_user="current_user"() AND fid IN (103, 214, 139)  -- epa
			UNION
			SELECT id, arc_id, arccat_id, state, expl_id, descript, fid, the_geom FROM anl_arc WHERE cur_user="current_user"() AND fid IN (104, 188, 202) -- om
			) row) features;

			v_result := COALESCE(v_result, '{}'); 
			v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, ',"category_field":"descript"}');

		END IF;

		--    Control null
		v_version:=COALESCE(v_version,'{}');
		v_result_info:=COALESCE(v_result_info,'{}');
		v_result_point:=COALESCE(v_result_point,'{}');
		v_result_line:=COALESCE(v_result_line,'{}');
		v_result_polygon:=COALESCE(v_result_polygon,'{}');
		v_missing_layers:=COALESCE(v_missing_layers,'{}');
		v_hidden_form:=COALESCE(v_hidden_form, true);

		--return definition for v_audit_check_result
		v_return= ('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'" '||
			',"body":{"form":{}'||
				',"data":{ "epsg":'||v_epsg||
						',"userValues":'||v_uservalues||
				    ',"info":'||v_result_info||','||
						'"point":'||v_result_point||','||
						'"line":'||v_result_line||','||
						'"polygon":'||v_result_polygon||','||
						'"missingLayers":'||v_missing_layers||'}'||
				', "variables":{"hideForm":' || v_hidden_form || ', "setQgisLayers":' || v_qgis_layers_setpropierties||', "useGuideMap":'||v_qgis_init_guide_map||'}}}')::json;
				-- setQgisLayers: not used variable on python 3.4 because threath is operative to refresh_attributte of whole layers
	ELSE
		v_return= ('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'" '||
			',"body":{"form":{}'||
				',"data":{ "epsg":'||v_epsg||
						',"userValues":'||v_uservalues||
				    ',"info":{},'||
						'"point":{},'||
						'"line":{},'||
						'"polygon":{},'||
						'"missingLayers":{}}'||
				', "variables":{"hideForm":true, "setQgisLayers":' || v_qgis_layers_setpropierties||', "useGuideMap":'||v_qgis_init_guide_map||'}}}')::json;
				-- setQgisLayers: not used variable on python 3.4 because threath is operative to refresh_attribute of whole layers
	END IF;
		
	--  Return	   
	RETURN v_return;
	
	--  Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = pg_exception_context;  
	RETURN ('{"status":"Failed", "SQLERR":' || to_json(SQLERRM) || ',"SQLCONTEXT":' || to_json(v_error_context) || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;
	  
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;