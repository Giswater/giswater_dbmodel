/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION CODE: 2714
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_setfeaturereplace(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setfeaturereplace (p_data json)
RETURNS json AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_setfeaturereplace($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"type":"NODE"},
"data":{"old_feature_id":"129","workcat_id_end":"work1", "enddate":"2019-05-17","keep_elements":true }}$$)

SELECT SCHEMA_NAME.gw_fct_setfeaturereplace($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"type":"ARC"},
"data":{"old_feature_id":"2067","workcat_id_end":"work1", "enddate":"2019-05-17","keep_elements":true }}$$)

-- fid: 143

*/
 
DECLARE

v_the_geom public.geometry;
v_query_string_select text;
v_query_string_insert text;
v_query_string_update text;
v_column varchar;
v_value text;
v_state integer;
v_state_type integer;
v_epa_type text;
v_epa_type_new text;
rec_arc record;	
v_old_featuretype varchar;
v_old_featurecat varchar;
v_sector_id integer;
v_dma_id integer;
v_expl_id integer;
v_man_table varchar;
v_epa_table varchar;
v_epa_table_new varchar;
v_code_autofill boolean;
v_code	int8;
v_id int8;
v_old_feature_id varchar;
v_workcat_id_end varchar;
v_enddate date;
v_keep_elements boolean;
v_feature_type text;
v_feature_layer text;
v_id_column text;
v_feature_type_table text;
v_type_column text;
v_cat_column text;
v_sql text;
v_element_table text;
v_verified_id text;
v_inventory boolean;
v_connec_proximity_value text;
v_connec_proximity_active text;
v_result_id text= 'replace feature';
v_project_type text;
v_version text;
v_result text;
v_result_info text;
v_arc_searchnodes_value text;
v_arc_searchnodes_active text;
v_error_context text;
v_audit_result text;
v_level integer;
v_status text;
v_message text;
rec_addfields record;
v_count integer;
v_field_cat text;
v_feature_type_new text;
v_featurecat_id_new text;
v_mapzone_old text;
v_mapzone_new text;
v_fid integer = 143;
v_gully_proximity_value text;
v_gully_proximity_active text;
v_category text;
v_function text;
v_fluid text;
v_location text;
v_node1_graph text;
v_node_1 text;
v_node2_graph  text; 
v_node_2 text;

BEGIN

	-- Search path
	SET search_path = 'SCHEMA_NAME', public;

	SELECT project_type, giswater  INTO v_project_type, v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	--set current process as users parameter
	DELETE FROM config_param_user  WHERE  parameter = 'utils_cur_trans' AND cur_user =current_user;

	INSERT INTO config_param_user (value, parameter, cur_user)
	VALUES (txid_current(),'utils_cur_trans',current_user );
    
	SELECT  value::json->>'value' as value INTO v_arc_searchnodes_value FROM config_param_system where parameter = 'edit_arc_searchnodes';
	SELECT  value::json->>'activated' INTO v_arc_searchnodes_active FROM config_param_system where parameter = 'edit_arc_searchnodes';

	-- manage log (fid: 143)
	DELETE FROM audit_check_data WHERE fid = v_fid AND cur_user=current_user;
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('REPLACE FEATURE'));
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('------------------------------'));

	-- get input parameters
	
	v_feature_type = lower(((p_data ->>'feature')::json->>'type'))::text;
	v_old_feature_id = ((p_data ->>'data')::json->>'old_feature_id')::text;
	v_workcat_id_end = ((p_data ->>'data')::json->>'workcat_id_end')::text;
	v_enddate = ((p_data ->>'data')::json->>'enddate')::text;
	v_keep_elements = ((p_data ->>'data')::json->>'keep_elements')::text;
	v_feature_type_new = ((p_data ->>'data')::json->>'feature_type_new')::text;
	v_featurecat_id_new = ((p_data ->>'data')::json->>'featurecat_id')::text;

	--deactivate connec proximity control
	IF v_feature_type='connec' THEN
		SELECT  value::json->>'value' as value INTO v_connec_proximity_value FROM config_param_system where parameter = 'edit_connec_proximity';
		SELECT  value::json->>'activated' INTO v_connec_proximity_active FROM config_param_system where parameter = 'edit_connec_proximity';
		UPDATE config_param_system SET value ='{"activated":false,"value":0.1}' WHERE parameter='edit_connec_proximity';
	END IF;

	--deactivate gully proximity control
	IF v_feature_type='gully' THEN
		SELECT value::json->>'value' as value INTO v_gully_proximity_value FROM config_param_system WHERE parameter = 'edit_gully_proximity';
		SELECT value::json->>'activated' INTO v_gully_proximity_active FROM config_param_system WHERE parameter = 'edit_gully_proximity';
		UPDATE config_param_system SET value = '{"activated":false,"value":0.1}' WHERE parameter = 'edit_gully_proximity';
	END IF;

	--define columns used for feature_cat
	v_feature_layer = concat('v_edit_',v_feature_type);
	v_feature_type_table = concat('cat_feature_',v_feature_type);
	v_id_column:=concat(v_feature_type,'_id');
	v_type_column=concat(v_feature_type,'_type');
	
	IF v_feature_type='connec' THEN
		v_cat_column='connecat_id';
	ELSIF  v_feature_type='gully' THEN
		v_cat_column = 'gratecat_id';
	ELSIF  v_feature_type='node' THEN
		v_cat_column='nodecat_id';
	ELSIF  v_feature_type='arc' THEN
		v_cat_column='arccat_id';
	END IF;

	--capture old feature type and old feature catalog
	EXECUTE 'SELECT '||v_type_column||'  FROM '|| v_feature_layer  ||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO  v_old_featuretype;

	EXECUTE 'SELECT  '|| v_cat_column||' FROM '|| v_feature_layer  ||'  WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_old_featurecat;

	--capture old feature values for basic attributes
	IF v_feature_type IN ('node', 'arc') THEN
		EXECUTE 'SELECT epa_type, epa_table FROM '||v_feature_layer||' c JOIN sys_feature_epa_type s ON epa_type=s.id 
		WHERE '||v_feature_type||'_type='||quote_literal(v_old_featuretype)||' AND feature_type IN (''NODE'', ''ARC'')
		AND '||v_id_column||'='||quote_literal(v_old_feature_id)||' limit 1'
		INTO v_epa_type,v_epa_table;

		EXECUTE 'SELECT epa_default, epa_table FROM cat_feature_'||v_feature_type||' c JOIN sys_feature_epa_type s ON epa_default=s.id 
		WHERE c.id='||quote_literal(v_feature_type_new)||' AND feature_type IN (''NODE'', ''ARC'')'
		INTO v_epa_type_new, v_epa_table_new;

		IF v_old_featuretype=v_feature_type_new THEN
			v_epa_type_new=v_epa_type;
			v_epa_table_new=v_epa_table;
		END IF;
		IF  v_feature_type='node' AND v_old_feature_id NOT IN (SELECT node_1 FROM v_edit_arc UNION SELECT node_2 FROM v_edit_arc) THEN
			v_epa_type_new='UNDEFINED';
			v_epa_table_new = NULL;
		END IF;
	END IF;

	EXECUTE 'SELECT sector_id FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_sector_id;
	EXECUTE 'SELECT state_type FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_state_type;
	EXECUTE 'SELECT state FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_state;
	EXECUTE 'SELECT dma_id FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_dma_id;
	EXECUTE 'SELECT the_geom FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_the_geom;
	EXECUTE 'SELECT expl_id FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_expl_id;
	EXECUTE 'SELECT verified FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_verified_id;
	EXECUTE 'SELECT inventory FROM '||v_feature_layer||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_inventory;
	EXECUTE 'SELECT n.category_type FROM '||v_feature_layer||' n JOIN man_type_category m ON n.category_type=m.category_type
	WHERE  feature_type = '''||upper(v_feature_type)||''' AND 
	(featurecat_id IS NULL OR '''||v_feature_type_new||''' = ANY(featurecat_id::text[])) AND '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_category;
	EXECUTE 'SELECT n.function_type FROM '||v_feature_layer||' n JOIN man_type_function m ON n.function_type=m.function_type
	WHERE  feature_type = '''||upper(v_feature_type)||''' AND 
	(featurecat_id IS NULL OR '''||v_feature_type_new||''' = ANY(featurecat_id::text[])) AND '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_function;
	EXECUTE 'SELECT n.fluid_type FROM '||v_feature_layer||' n JOIN man_type_fluid m ON n.fluid_type=m.fluid_type
	WHERE  feature_type = '''||upper(v_feature_type)||''' AND 
	(featurecat_id IS NULL OR '''||v_feature_type_new||''' = ANY(featurecat_id::text[])) AND '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_fluid;
	EXECUTE 'SELECT n.location_type FROM '||v_feature_layer||' n JOIN man_type_location m ON n.location_type=m.location_type
	WHERE  feature_type = '''||upper(v_feature_type)||''' AND 
	(featurecat_id IS NULL OR '''||v_feature_type_new||''' = ANY(featurecat_id::text[])) AND '||v_id_column||'='''||v_old_feature_id||''';'
	INTO v_location;

	-- Control of state(1)
	IF (v_state=0 OR v_state=2 OR v_state IS NULL) THEN

		EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
		"data":{"message":"1070", "function":"2126","debug_msg":"State is 0 or 2"}}$$);' INTO v_audit_result;

		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

		v_id := v_old_feature_id;
	ELSE
		
		-- new feature_id
		v_id := (SELECT nextval('SCHEMA_NAME.urn_id_seq'));

		-- code
		EXECUTE 'SELECT code_autofill  FROM cat_feature WHERE id='''||v_old_featuretype||''';'
		INTO v_code_autofill;
		
		IF v_code_autofill IS TRUE THEN
			v_code = v_id;
		END IF;
		-- inserting new feature on parent tables
		IF v_feature_type='node' THEN
			IF v_project_type='WS' then
				INSERT INTO node (node_id, code, nodecat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, workcat_id, the_geom,
				category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featurecat, v_epa_type_new, v_sector_id, v_dma_id, v_expl_id,  
				0, v_state_type, v_workcat_id_end, v_the_geom, v_category, v_function, v_fluid, v_location);
			ELSE 
				INSERT INTO node (node_id, code, node_type, nodecat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, workcat_id, 
				the_geom, category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featuretype, v_old_featurecat, v_epa_type_new, v_sector_id, v_dma_id, v_expl_id, 
				0, v_state_type, v_workcat_id_end, v_the_geom, v_category, v_function, v_fluid, v_location);
			END IF;

			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('New feature (',v_id,') inserted into node table.'));

		ELSIF v_feature_type='arc' THEN
			IF v_project_type='WS' then
				INSERT INTO arc (arc_id, code, arccat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, workcat_id, the_geom, 
				verified, category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featurecat, v_epa_type_new, v_sector_id, v_dma_id, v_expl_id, 0, v_state_type, v_workcat_id_end, v_the_geom, 
				v_verified_id, v_category, v_function, v_fluid, v_location);
			ELSE 
				INSERT INTO arc (arc_id, code, arc_type, arccat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, workcat_id, the_geom, 
				verified, category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featuretype, v_old_featurecat, v_epa_type_new, v_sector_id, v_dma_id, v_expl_id, 0, v_state_type, v_workcat_id_end, 
				v_the_geom, v_verified_id, v_category, v_function, v_fluid, v_location);
			END IF;

			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('New feature (',v_id,') inserted into arc table.'));

		ELSIF v_feature_type ='connec' THEN
		
			IF v_project_type='WS' then
				INSERT INTO connec (connec_id, code, connecat_id, sector_id, dma_id, expl_id, state, state_type, the_geom, workcat_id, verified, 
				inventory, category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featurecat, v_sector_id, v_dma_id,v_expl_id, 0, v_state_type, v_the_geom, v_workcat_id_end, v_verified_id, 
				v_inventory, v_category, v_function, v_fluid, v_location);
			ELSE 
				INSERT INTO connec (connec_id, code, connec_type, connecat_id,  sector_id, dma_id, expl_id, state, state_type, the_geom, workcat_id, 
				verified, inventory, category_type, function_type, fluid_type, location_type) 
				VALUES (v_id, v_code, v_old_featuretype, v_old_featurecat, v_sector_id, v_dma_id, v_expl_id,0, v_state_type, v_the_geom,v_workcat_id_end, 
				v_verified_id, v_inventory, v_category, v_function, v_fluid, v_location);
			END IF;	

			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('New feature (',v_id,') inserted into connec table.'));

		ELSIF v_feature_type = 'gully' THEN
			INSERT INTO gully (gully_id, code, gully_type,gratecat_id, sector_id, dma_id, expl_id, state, state_type, the_geom,workcat_id, verified, 
			inventory, category_type, function_type, fluid_type, location_type) 
			VALUES (v_id, v_code, v_old_featuretype, v_old_featurecat, v_sector_id, v_dma_id,v_expl_id, 0, v_state_type, v_the_geom, v_workcat_id_end, 
			v_verified_id, v_inventory, v_category, v_function, v_fluid, v_location);
			
			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('New feature (',v_id,') inserted into gully table.'));
		END IF;

		-- inserting new feature on table man_table / epa table
		IF v_feature_type='node' or v_feature_type='arc' or (v_feature_type='connec' AND v_project_type='WS') THEN
	
			EXECUTE 'SELECT man_table FROM cat_feature c JOIN sys_feature_cat s ON c.system_id = s.id WHERE c.id='''||v_feature_type_new||''';'
			INTO v_man_table;
	
			v_query_string_insert='INSERT INTO '||v_man_table||' VALUES ('||v_id||');';
			execute v_query_string_insert;

			/*IF v_feature_type='node' or v_feature_type='arc' THEN
				EXECUTE 'SELECT epa_table FROM cat_feature_'||v_feature_type||' c JOIN sys_feature_epa_type s ON epa_default=s.id WHERE c.id='||quote_literal(v_old_featuretype)||' 
				AND feature_type IN (''NODE'', ''ARC'')'
				INTO v_epa_table;*/
			IF v_feature_type='connec' THEN
				v_epa_table_new = 'inp_connec';
			END IF;
			
			IF v_epa_table_new IS NOT NULL THEN
				v_query_string_insert='INSERT INTO '||v_epa_table_new||' VALUES ('||v_id||');';
				execute v_query_string_insert;
			END IF;
		END IF;
		
		-- updating values on feature parent table from values of old feature
		v_sql:='select column_name    FROM information_schema.columns 
							where (table_schema=''SCHEMA_NAME'' and udt_name <> ''inet'' and 
							table_name='''||v_feature_type||''') and column_name!='''||v_id_column||''' and column_name!=''the_geom'' and column_name!=''state''
							and column_name!=''code'' and column_name!=''epa_type'' and column_name!=''state_type'' and column_name!='''||v_cat_column||'''
							and column_name!=''sector_id'' and column_name!=''dma_id'' and column_name!=''expl_id'' and column_name!=''category_type'' 
							and column_name!=''function_type'' and column_name!=''fluid_type'' and column_name!=''location_type'';';

		FOR v_column IN EXECUTE v_sql
		LOOP
			v_query_string_select= 'SELECT '||v_column||' FROM '||v_feature_type||' where '||v_id_column||'='||quote_literal(v_old_feature_id)||';';
			IF v_query_string_select IS NOT NULL THEN
				EXECUTE v_query_string_select INTO v_value;	
			END IF;
			
			v_query_string_update= 'UPDATE '||v_feature_type||' set '||v_column||'='||quote_literal(v_value)||' where '||v_id_column||'='||quote_literal(v_id)||';';
			IF v_query_string_update IS NOT NULL THEN
				EXECUTE v_query_string_update; 
	
			END IF;
		END LOOP;

		-- updating values on table man_table from values of old feature
		IF v_old_featuretype = v_feature_type_new AND (v_feature_type='node' or v_feature_type='arc' or (v_feature_type='connec' AND v_project_type='WS')) THEN
			v_sql:='select column_name    FROM information_schema.columns 
								where (table_schema=''SCHEMA_NAME'' and udt_name <> ''inet'' and 
								table_name='''||v_man_table||''') and column_name!='''||v_id_column||''';';
			FOR v_column IN EXECUTE v_sql
			LOOP
				v_query_string_select= 'SELECT '||v_column||' FROM '||v_man_table||' where '||v_id_column||'='||quote_literal(v_old_feature_id)||';';
				IF v_query_string_select IS NOT NULL THEN
					EXECUTE v_query_string_select INTO v_value;	
				END IF;
				
				v_query_string_update= 'UPDATE '||v_man_table||' set '||v_column||'='||quote_literal(v_value)||' where node_id='||quote_literal(v_id)||';';
				IF v_query_string_update IS NOT NULL THEN
					EXECUTE v_query_string_update; 

				END IF;
				
			END LOOP;
		END IF;
			
		-- updating values on table epa_table from values of old feature
		IF (v_feature_type='node' or v_feature_type='arc' or (v_feature_type='connec' AND v_project_type='WS')) and v_epa_table is not null AND 
		v_epa_type_new = v_epa_type THEN
			v_sql:='select column_name  FROM information_schema.columns 
								where (table_schema=''SCHEMA_NAME'' and udt_name <> ''inet'' and 
								table_name='''||v_epa_table||''') and column_name!='''||v_id_column||''';';
			
			FOR v_column IN EXECUTE v_sql LOOP
				v_query_string_select= 'SELECT '||v_column||' FROM '||v_epa_table||' where '||v_feature_type||'_id='||quote_literal(v_old_feature_id)||';';
				IF v_query_string_select IS NOT NULL THEN
					EXECUTE v_query_string_select INTO v_value;	
				END IF;
				
				v_query_string_update= 'UPDATE '||v_epa_table||' set '||v_column||'='||quote_literal(v_value)||' where '||v_id_column||'='||quote_literal(v_id)||';';
				IF v_query_string_update IS NOT NULL THEN
					EXECUTE v_query_string_update; 

				END IF;
			END LOOP;
		END IF;
		
		-- taking values from old feature (from man_addfields table)
		INSERT INTO man_addfields_value (feature_id, parameter_id, value_param)
		SELECT 
		v_id,
		parameter_id,
		value_param
		FROM man_addfields_value WHERE feature_id=v_old_feature_id;

		IF (SELECT count(parameter_id) FROM man_addfields_value WHERE feature_id = v_id::text) > 0THEN
			FOR rec_addfields IN (SELECT parameter_id, value_param FROM man_addfields_value WHERE feature_id = v_id::text)
			LOOP
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Copy value of addfield ',rec_addfields.parameter_id,' old feature into new one: ',rec_addfields.value_param,'.'));
			END LOOP;
		END IF;

		--Moving elements from old feature to new feature
		IF v_keep_elements IS TRUE THEN
			v_element_table:=concat('element_x_',v_feature_type);
			EXECUTE 'SELECT count(element_id) FROM '||v_element_table||' WHERE '||v_id_column||'='''||v_old_feature_id||''';'
			INTO v_count;
			IF v_count > 0 THEN
				v_element_table:=concat('element_x_',v_feature_type);
				EXECUTE 'UPDATE '||v_element_table||' SET '||v_id_column||'='''||v_id||''' WHERE '||v_id_column||'='''||v_old_feature_id||''';';	
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Assign ',v_count,' elements to the new feature.'));
			END IF;	
		END IF;
	
		-- reconnecting features
		IF v_feature_type='node' THEN
			UPDATE config_param_system SET value =concat('{"activated":','false',', "value":',v_arc_searchnodes_value,'}') WHERE parameter='edit_arc_searchnodes';

			FOR rec_arc IN SELECT arc_id FROM arc WHERE node_1=v_old_feature_id
			LOOP
				UPDATE arc SET node_1=v_id where arc_id=rec_arc.arc_id;
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Reconnect arc ',rec_arc.arc_id,'.'));
			END LOOP;
		
			FOR rec_arc IN SELECT arc_id FROM arc WHERE node_2=v_old_feature_id
			LOOP
				UPDATE arc SET node_2=v_id where arc_id=rec_arc.arc_id;
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Reconnect arc ',rec_arc.arc_id,'.'));
			END LOOP;
			
		ELSIF v_feature_type='arc' THEN
			UPDATE connec SET arc_id = v_id WHERE arc_id = v_old_feature_id;
			GET DIAGNOSTICS v_count = row_count;
			INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(v_count, ' operative connec(s) have been reconnected'));
			
			UPDATE plan_psector_x_connec SET arc_id = v_id WHERE arc_id = v_old_feature_id;
			GET DIAGNOSTICS v_count = row_count;
			INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(v_count, ' planned connec(s) have been reconnected'));

			IF v_project_type='UD' then
				UPDATE gully SET arc_id = v_id WHERE arc_id = v_old_feature_id;
				GET DIAGNOSTICS v_count = row_count;
				INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(v_count, ' operative gully(s) have been reconnected'));
				
				UPDATE plan_psector_x_gully SET arc_id = v_id WHERE arc_id = v_old_feature_id;
				GET DIAGNOSTICS v_count = row_count;
				INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(v_count, ' planned gully(s) have been reconnected'));
			END IF;

		ELSIF v_feature_type='connec' THEN
			-- nothing to do

		ELSIF v_feature_type='gully' THEN
			-- nothing to do		
		END IF;

		-- update node_id on on going or planned psectors
		IF v_feature_type='node' THEN
			SELECT count(psector_id) INTO v_count FROM plan_psector_x_node JOIN plan_psector USING (psector_id) 
			WHERE status in (1,2) AND node_id = v_old_feature_id;
			IF v_count > 0 THEN
				UPDATE plan_psector_x_node SET node_id = v_id FROM plan_psector pp
				WHERE pp.psector_id = plan_psector_x_node.psector_id AND status in (1,2) AND node_id = v_old_feature_id;

				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Replace node id in ',v_count,' psector.'));
			END IF;
		END IF;

		-- upgrading and downgrading features
		v_state_type = (SELECT id FROM value_state_type WHERE state=0 LIMIT 1);
			
		IF v_workcat_id_end IS NOT NULL THEN 
			EXECUTE 'UPDATE '||v_feature_type||' SET state=0, workcat_id_end='''||v_workcat_id_end||''', enddate='''||v_enddate||''', 
			state_type='||v_state_type||' WHERE '||v_id_column||'='''||v_old_feature_id||''';';
		ELSE
			EXECUTE 'UPDATE '||v_feature_type||' SET state=0, enddate='''||v_enddate||''', 
			state_type='||v_state_type||' WHERE '||v_id_column||'='''||v_old_feature_id||''';';
		END IF;

		INSERT INTO audit_check_data (fid, result_id, error_message)
		VALUES (v_fid, v_result_id, concat('Downgraded old feature (',v_old_feature_id,') SETTING state: 0, workcat_id_end: ',v_workcat_id_end,', enddate: ',v_enddate,'.'));

		IF v_id IS NOT NULL THEN
			IF v_workcat_id_end IS NOT NULL THEN 
				EXECUTE 'UPDATE '||v_feature_type||' SET state=1, workcat_id='''||v_workcat_id_end||''', builtdate='''||v_enddate||''', 
				enddate=NULL WHERE '||v_id_column||'='''||v_id||''';';
			ELSE
				EXECUTE 'UPDATE '||v_feature_type||' SET state=1,builtdate='''||v_enddate||''', 
				enddate=NULL WHERE '||v_id_column||'='''||v_id||''';';
			END IF;
			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('Update new feature, set state: 1, workcat_id: ',v_workcat_id_end,', builtdate: ',v_enddate,'.'));
				
			INSERT INTO audit_check_data (fid, result_id, error_message)
			VALUES (v_fid, v_result_id, concat('Common values from old feature have been updated on new feature.'));
			
		END IF;
		
		--reconect existing link to the new feature
		IF v_feature_type='connec' OR v_feature_type='gully' THEN
			SELECT count(link_id) INTO v_count FROM link WHERE (feature_id = v_old_feature_id and feature_type = upper(v_feature_type) and state=1) OR
			(exit_id = v_old_feature_id and exit_type = upper(v_feature_type) and state=1);
			IF v_count > 0 THEN
				UPDATE link SET feature_id = v_id WHERE feature_id = v_old_feature_id and feature_type = upper(v_feature_type) and state=1;
				UPDATE link SET exit_id = v_id WHERE exit_id = v_old_feature_id and exit_type = upper(v_feature_type) and state=1;
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Reconnect ',v_count,' links.'));
			END IF;
			
		ELSIF v_feature_type='node' THEN
			SELECT count(link_id) INTO v_count FROM link WHERE exit_id = v_old_feature_id and exit_type = upper(v_feature_type) and state=1;
			IF v_count > 0 THEN
				UPDATE link SET exit_id = v_id WHERE exit_id = v_old_feature_id and exit_type = upper(v_feature_type) and state=1;
				INSERT INTO audit_check_data (fid, result_id, error_message)
				VALUES (v_fid, v_result_id, concat('Reconnect ',v_count,' links.'));
			END IF;
		END IF;

		-- enable config parameters
		IF v_feature_type='arc' THEN
			UPDATE config_param_system SET value =concat('{"activated":',v_arc_searchnodes_active,', "value":',v_arc_searchnodes_value,'}') WHERE parameter='edit_arc_searchnodes';
		ELSIF v_feature_type='connec' THEN
			UPDATE config_param_system SET value =concat('{"activated":',v_connec_proximity_active,', "value":',v_connec_proximity_value,'}') WHERE parameter='edit_connec_proximity';
		ELSIF v_feature_type='node' THEN
			UPDATE config_param_system SET value =concat('{"activated":',v_arc_searchnodes_active,', "value":',v_arc_searchnodes_value,'}') WHERE parameter='edit_arc_searchnodes';
		ELSIF v_feature_type='gully' THEN
			UPDATE config_param_system SET value = concat('{"activated":',v_gully_proximity_active,', "value":',v_gully_proximity_value,'}') WHERE parameter = 'edit_gully_proximity';
		END IF;
		
	
		IF v_feature_type = 'connec' THEN
			v_field_cat ='connecat_id';
		ELSIF v_feature_type = 'arc' THEN
			v_field_cat ='arccat_id';
		ELSIF v_feature_type = 'gully' THEN
			v_field_cat ='gratecat_id';
		ELSIF v_feature_type = 'node' THEN
			v_field_cat ='nodecat_id';	
		END IF;

		-- log
		INSERT INTO audit_log_data (fid, feature_type,feature_id, log_message) 
		SELECT v_fid, 'ARC', arc_id, concat('{"description":"Pipe replacement", "workcat":"'||quote_nullable(v_workcat_id_end)||'", "sector":"',name,'", "length":',
		(st_length(arc.the_geom))::numeric(12,2),', "newCatalog":"',v_featurecat_id_new,'", "oldCatalog":"',v_old_featurecat,'"}') 
		FROM arc JOIN sector USING (sector_id) WHERE arc_id = v_id::text;

		-- update catalog of new feature
		IF v_featurecat_id_new IS NOT NULL AND v_feature_type_new IS NOT NULL THEN

			EXECUTE 'UPDATE '||v_feature_type||' SET '||v_field_cat||' =  '||quote_literal(v_featurecat_id_new)||' 
			WHERE '||v_feature_type||'_id = '||quote_literal(v_id)||';';

			IF v_project_type = 'UD' THEN
				IF v_feature_type != 'gully' THEN
					EXECUTE 'UPDATE '||v_feature_type||' SET '||v_feature_type||'_type =  '||quote_literal(v_feature_type_new)||' 
					WHERE '||v_feature_type||'_id = '||quote_literal(v_id)||';';
				END IF;
			END IF;
		END IF;
		
		--reset mapzone configuration
		IF v_project_type='WS' THEN

			IF v_feature_type = 'node' THEN

				-- check if old / new nodes they are graphdelimiters
				EXECUTE 'SELECT CASE WHEN lower(graph_delimiter) = ''none'' or lower(graph_delimiter) = ''minsector'' THEN NULL ELSE lower(graph_delimiter) END AS graph 
				FROM '||v_feature_type_table||' c JOIN sys_feature_cat s ON c.type = s.id WHERE c.id='''||v_old_featuretype||''';'
				INTO v_mapzone_old;

				EXECUTE 'SELECT CASE WHEN lower(graph_delimiter) = ''none'' or lower(graph_delimiter) = ''minsector''  THEN NULL ELSE lower(graph_delimiter) END AS graph 
				FROM '||v_feature_type_table||' c JOIN sys_feature_cat s ON c.type = s.id WHERE c.id='''||v_feature_type_new||''';'
				INTO v_mapzone_new;

				IF v_mapzone_old IS NOT NULL OR v_mapzone_new IS NOT NULL THEN
					INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(''));
					INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('-----MAPZONES CONFIGURATION-----'));

					IF v_mapzone_old = v_mapzone_new and v_mapzone_new is not null THEN
						EXECUTE 'SELECT gw_fct_setmapzoneconfig($${
						"client":{"device":4, "infoType":1,"lang":"ES"}, "data":{"parameters":{"nodeIdOld":"'||v_old_feature_id||'",
						"nodeIdNew":"'||v_id||'", "action":"updateNode"}}}$$);';

						INSERT INTO audit_check_data (fid, result_id, error_message)
						VALUES (v_fid, v_result_id, concat('New node and old node are delimiters of the same mapzone. Configuration will be updated.'));
					
					ELSIF  v_mapzone_old is not null AND  v_mapzone_new is nulL THEN
												
						INSERT INTO audit_check_data (fid, result_id, error_message)
						VALUES (v_fid, v_result_id, concat('New node is not a delimiter of a mapzone. Configuration for old node need to be removed.'));

					ELSIF  v_mapzone_old is null AND v_mapzone_new is not null THEN
						INSERT INTO audit_check_data (fid, result_id, error_message)
						VALUES (v_fid, v_result_id, concat('New node is a delimiter of a mapzone that needs to be configured.'));
					
					ELSIF v_mapzone_old!=v_mapzone_new AND  v_mapzone_old is not null AND v_mapzone_new is not null THEN
											
						INSERT INTO audit_check_data (fid, result_id, error_message)
						VALUES (v_fid, v_result_id, concat('New node is a delimiter of a different mapzone type than the old node. New mapzone delimiter and old mapzone delimiter needs to be configured.'));
					END IF;
				END IF;
				
			ELSIF v_feature_type = 'arc' THEN

					--check if final nodes of arc are graph delimiters
					EXECUTE 'SELECT CASE WHEN lower(graph_delimiter) = ''none'' or lower(graph_delimiter) = ''minsector'' THEN NULL ELSE lower(graph_delimiter) END AS graph, node_1 FROM v_edit_arc a 
					JOIN v_edit_node n1 ON n1.node_id=node_1
					JOIN cat_feature_node cf1 ON n1.node_type = cf1.id 
					WHERE a.arc_id='''||v_id||''';'
					INTO v_node1_graph, v_node_1;

					EXECUTE 'SELECT CASE WHEN lower(graph_delimiter) = ''none'' or lower(graph_delimiter) = ''minsector'' THEN NULL ELSE lower(graph_delimiter) END AS graph,node_2 FROM v_edit_arc a 
					JOIN v_edit_node n2 ON n2.node_id=node_2
					JOIN cat_feature_node cf2 ON n2.node_type = cf2.id 
					WHERE a.arc_id='''||v_id||''';'
					INTO v_node2_graph, v_node_2;
										
					IF v_node1_graph IS NOT NULL THEN 
						EXECUTE 'SELECT gw_fct_setmapzoneconfig($${
						"client":{"device":4, "infoType":1,"lang":"ES"}	,"data":{"parameters":{"nodeIdOld":"'||v_node_1||'",
						"arcIdOld":'||v_old_feature_id||',"arcIdNew":'||v_id||',"action":"updateArc"}}}$$);';

						INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(''));
						INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('-----MAPZONES CONFIGURATION-----'));
						INSERT INTO audit_check_data (fid, criticity, error_message)
						VALUES (v_fid, 1, concat('Node_1 is a delimiter of a mapzone if arc was defined as toArc it has been reconfigured with new arc_id.'));
					END IF;

					IF v_node2_graph IS NOT NULL THEN 
						
						EXECUTE 'SELECT gw_fct_setmapzoneconfig($${
						"client":{"device":4, "infoType":1,"lang":"ES"},"data":{"parameters":{"nodeIdOld":"'||v_node_2||'", 
						"arcIdOld":'||v_old_feature_id||',"arcIdNew":'||v_id||',"action":"updateArc"}}}$$);';
						
						INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat(''));
						INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('-----MAPZONES CONFIGURATION-----'));
						INSERT INTO audit_check_data (fid, criticity, error_message)
						VALUES (v_fid, 1, concat('Node_2 is a delimiter of a mapzone if arc was defined as toArc it has been reconfigured with new arc_id.'));
					END IF;
			END IF;
			
		END IF;

		-- get log (fid: 143)
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
		FROM (SELECT id, error_message AS message FROM audit_check_data WHERE cur_user="current_user"() AND fid = v_fid) row;

		IF v_audit_result is null THEN
		v_status = 'Accepted';
		v_level = 3;
		v_message = 'Replace feature done successfully';
	    ELSE

		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
		SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

	    END IF;

	END IF;

	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
			
	-- Control nulls
	v_version := COALESCE(v_version, '{}'); 
	v_result_info := COALESCE(v_result_info, '{}'); 
	
 
	-- Return
	RETURN ('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "featureId":"'||v_id||'",
				"info":'||v_result_info||'}}'||
	    '}')::json;
	    
	--    Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = pg_exception_context;  
	RETURN ('{"status":"Failed", "SQLERR":' || to_json(SQLERRM) || ',"SQLCONTEXT":' || to_json(v_error_context) || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;