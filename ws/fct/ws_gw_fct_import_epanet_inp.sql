/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2522

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_utils_csv2pg_import_epanet_inp(text);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_utils_csv2pg_import_epanet_inp(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_import_epanet_inp(p_data json)
  RETURNS json AS

$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_import_epanet_inp('{"data":{"parameters":{"debugMode":true}}}')
SELECT SCHEMA_NAME.gw_fct_import_epanet_inp($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{}, "data":{"parameters":{}}}$$)

-- fid: 239

*/

DECLARE

rpt_rec record;
v_epsg integer;
v_point_geom public.geometry;
v_mantype text;
v_epatablename text;
v_count integer=0;
v_projecttype varchar;
geom_array public.geometry array;
geom_array_vertex public.geometry array;
v_data record;
v_extend_val public.geometry;
v_rec_table record;
v_query_fields text;
v_rec_view record;
v_sql text;
v_fid integer = 239;
v_thegeom public.geometry;
v_node_id text;
v_node1 text;
v_node2 text;
v_elevation float;
v_isgwproject boolean = FALSE; -- MOST IMPORTANT variable of this function. When true importation will be used making and arc2node reverse transformation for pumps and valves. Only works using Giswater sintaxis of additional pumps
v_delete_prev boolean = true; -- used on dev mode to
v_querytext text;
v_nodecat text;
i integer=1;
v_arc_id text;
v_curvetype text;
v_result json;
v_result_info json;
v_result_point json;
v_result_line json;
v_version json;
v_debugmode boolean;
v_error_context text;
v_record record;
v_epatype text;
v_count_total integer;
v_status text = 'Accepted';
v_pumptype text;
v_newnode text;
v_oldarc text;
v_replace text='';

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get project type
	SELECT project_type, epsg INTO v_projecttype, v_epsg FROM sys_version ORDER BY id DESC LIMIT 1;

	-- get input data
	v_debugmode := ((p_data ->>'data')::json->>'parameters')::json->>'debugMode'::text;
	
	IF (select count(*) from SCHEMA_NAME.temp_csv where CSV1 = ';Created by Giswater') = 1 THEN
		v_isgwproject := TRUE;
	END IF;

	-- delete previous data on log table
	DELETE FROM audit_check_data WHERE cur_user="current_user"() AND fid=239;
		
	-- create a header
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 4, 'IMPORT INP EPANET FILE');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 4, '--------------------------------');

	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 3, 'ERRORS');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 3, '-----------');

	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, 'WARNINGS');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, '-------------');

	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, '-------');

	IF v_debugmode IS NOT TRUE THEN
		
		IF v_isgwproject THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES 
			(239, 2, 'WARNING-239: It seems that inp file comes from Giswater project. If there are nodarcs (valves and pumps) they will be re-shaped ''on the fly'' to nodes');
		ELSE
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES 
			(239, 2, 'WARNING-239: It seems that inp file not comes from Giswater project. All nodarcs (valves and pumps) will be imported as arc feature');
		END IF;

		IF v_delete_prev THEN
			
			DELETE FROM rpt_cat_result;
			DELETE FROM config_graph_valve;

			-- Disable constraints
			PERFORM gw_fct_admin_manage_ct($${"client":{"lang":"ES"}, "data":{"action":"DROP"}}$$);

			-- Delete system and user catalogs
			DELETE FROM macroexploitation;
			DELETE FROM exploitation;
			DELETE FROM sector;
			DELETE FROM dma;
			DELETE FROM dqa;
			DELETE FROM presszone;
			DELETE FROM ext_municipality;
			DELETE FROM selector_expl;
			DELETE FROM selector_state;
			
			DELETE FROM cat_feature_arc ;
			DELETE FROM cat_feature_node ;
			DELETE FROM cat_feature_connec ;
			DELETE FROM cat_feature;
			DELETE FROM cat_mat_arc;
			DELETE FROM cat_mat_node;
			DELETE FROM cat_mat_roughness;
			DELETE FROM cat_arc;
			DELETE FROM cat_node;
	 
			-- Delete data
			DELETE FROM node;
			DELETE FROM arc;
			DELETE FROM plan_arc_x_pavement;

			DELETE FROM man_tank;
			DELETE FROM man_source;
			DELETE FROM man_junction;
			DELETE FROM man_pipe;
			DELETE FROM man_pump;
			DELETE FROM man_valve ;
			
			DELETE FROM inp_reservoir;
			DELETE FROM inp_junction;
			DELETE FROM inp_pipe;
			DELETE FROM inp_shortpipe;
			DELETE FROM inp_pump;
			DELETE FROM inp_tank;
			DELETE FROM inp_valve;
			DELETE FROM inp_pump_importinp;
			DELETE FROM inp_pump_additional;
			DELETE FROM inp_valve_importinp ;
			
			DELETE FROM inp_tags;
			DELETE FROM inp_dscenario_demand;
			DELETE FROM inp_pattern;
			DELETE FROM inp_pattern_value;
			DELETE FROM inp_curve;
			DELETE FROM inp_curve_value;
			DELETE FROM inp_controls;
			DELETE FROM inp_rules;
			DELETE FROM inp_emitter;
			DELETE FROM inp_quality;
			DELETE FROM inp_source;
			DELETE FROM inp_mixing;
			DELETE FROM config_param_user;
			DELETE FROM inp_label;
			DELETE FROM inp_backdrop;
			DELETE FROM rpt_inp_arc;
			DELETE FROM rpt_inp_node;
			DELETE FROM rpt_cat_result;
			DELETE FROM config_graph_inlet;
		ELSE 
			-- Disable constraints
			PERFORM gw_fct_admin_manage_ct($${"client":{"lang":"ES"}, "data":{"action":"DROP"}}$$);		
		END IF;
		
		-- check for network object id string length
		v_count := (SELECT max(length(csv1)) FROM temp_csv WHERE source IN ('[PIPES]','[JUNCTIONS]','[TANKS]','[RESERVOIRS]','[VALVES]','[PUMPS]') AND csv1 NOT LIKE ';%');
		IF v_count < 13 THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: All network id''s have less than 13 digits');

		ELSIF v_count > 12 AND v_count < 17 THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, 'WARNING-239: There are at least one network id with more than 12 digits. This might crash using during the ''on-the-fly'' transformations');

		ELSIF v_count > 16 THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 3, 'ERROR-239: There are at least one network id with more than 16 digits. Please check your data before continue');
			v_status = 'Failed';
		END IF;
		 
		-- check for non visual object id string length
		v_count := (SELECT max(length(csv1)) FROM temp_csv WHERE source IN ('[CURVES]','[PATTERNS]') AND csv1 NOT LIKE ';%');
		IF v_count < 17 THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: All non visual objects (curves & patterns) id''s have a maximum of 16 digits');

		ELSIF v_count > 16 THEN
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 3, 'ERROR-239: There are at least one non visual objects (curves & patterns) id with more than 16 digits. Please check your data before continue');
			v_status = 'Failed';
		END IF;

		IF v_status = 'Accepted' THEN

			RAISE NOTICE 'step 1/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Constraints of schema temporary disabled -> Done');

			RAISE NOTICE 'step 2/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Inserting data from inp file to temp_csv table -> Done');

			--refactor options target
			UPDATE temp_csv SET csv1='SPECIFIC GRAVITY', csv2=csv3, csv3=NULL WHERE source = '[OPTIONS]' AND lower(csv1)='specific';
			UPDATE temp_csv SET csv1='DEMAND MULTIPLIER', csv2=csv3, csv3=NULL WHERE source = '[OPTIONS]' and lower(csv1)='demand';
			UPDATE temp_csv SET csv1='EMITTER EXPONENT', csv2=csv3, csv3=NULL WHERE source = '[OPTIONS]' and lower(csv1)='emitter';
			UPDATE temp_csv SET csv2=concat(csv2,' ',csv3), csv3=NULL WHERE source = '[OPTIONS]' and lower(csv1)='unbalanced';
			UPDATE temp_csv SET csv1='f_factor', csv2=concat(csv2,' ',csv3), csv3=NULL WHERE source = '[OPTIONS]' and lower(csv1)='f-factor';

			--refactor times target
			UPDATE temp_csv SET csv1=concat(csv1,'_',csv2), csv2=concat(csv3,' ',csv4), csv3=null,csv4=null WHERE source = '[TIMES]' and lower(csv2)='clocktime';
			UPDATE temp_csv SET csv1=concat(csv1,'_',csv2), csv2=csv3, csv3=null WHERE source = '[TIMES]' and lower(csv2) ilike 'timestep' OR lower(csv2) ILIKE 'start';

			--refactor energy target
			UPDATE temp_csv SET csv1=concat(csv1,' ',csv2,' ',csv3), csv2=csv4, csv3=null,  csv4=null WHERE source = '[ENERGY]' and lower(csv1)='pump';
			UPDATE temp_csv SET csv1=concat(csv1,' ',csv2), csv2=csv3, csv3=null WHERE source = '[ENERGY]' AND (lower(csv1) ILIKE 'global' OR lower(csv1) ILIKE 'demand');

			--refactor controls target
			UPDATE temp_csv SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10 ),
			csv2=null, csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE source = '[CONTROLS]' and csv2 IS NOT NULL;

			--refactor rules target
			UPDATE temp_csv SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10 ),
			csv2=null, csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE source = '[RULES]' and csv2 IS NOT NULL;

			--refactor backdrop target
			UPDATE temp_csv SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10 ),
			csv2=null, csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE source = '[BACKDROP]' and csv2 IS NOT NULL;

			-- refactor curves target
			FOR rpt_rec IN SELECT * FROM temp_csv WHERE source ='[CURVES]'
			LOOP
				IF rpt_rec.csv2 is null THEN
					v_curvetype=replace(replace(rpt_rec.csv1,';',''),':','');
				ELSE
					UPDATE temp_csv SET csv4=v_curvetype WHERE temp_csv.id=rpt_rec.id;
				END IF;	
			END LOOP;	

			-- refactor [PIPES] target when minorloss is null and other has values
			UPDATE temp_csv SET csv8=csv7, csv7=null WHERE source = '[PIPES]' and csv7 IN ('CV', 'CLOSED', 'OPEN') and csv8 is null;


			RAISE NOTICE 'step 3/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1,'INFO: Creating map zones and catalogs -> Done');

			-- MAPZONES
			INSERT INTO macroexploitation(macroexpl_id,name) VALUES(1,'macroexploitation1');
			INSERT INTO exploitation(expl_id,name,macroexpl_id) VALUES(1,'exploitation1',1);
			INSERT INTO sector(sector_id,name) VALUES(1,'sector1');
			INSERT INTO dma(dma_id,name,expl_id) VALUES(1,'dma1',1);
			INSERT INTO dqa(dqa_id,name,expl_id) VALUES(1,'dqa1',1);
			INSERT INTO presszone(presszone_id,name,expl_id) VALUES(1,'presszone1',1);
			INSERT INTO ext_municipality(muni_id,name) VALUES(1,'municipality1');

			-- SELECTORS
			INSERT INTO selector_expl(expl_id,cur_user) VALUES (1,current_user) ON CONFLICT (expl_id,cur_user) do nothing;
			INSERT INTO selector_state(state_id,cur_user) VALUES (1,current_user) ON CONFLICT (state_id,cur_user) do nothing;
			INSERT INTO selector_sector(sector_id,cur_user) VALUES (1,current_user) ON CONFLICT (sector_id,cur_user) do nothing;

			-- CATALOGS
			--cat_feature
			ALTER TABLE cat_feature DISABLE TRIGGER gw_trg_cat_feature;
			--node
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('JUNCTION','JUNCTION','NODE', 'v_edit_node', 'Junction', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('TANK','TANK','NODE', 'v_edit_node', 'Tank', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('RESERVOIR','SOURCE','NODE', 'v_edit_node', 'Reservoir', true) ON CONFLICT (id) DO NOTHING;
			--arc
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('PIPE','PIPE','ARC', 'v_edit_arc', 'Pipe', true) ON CONFLICT (id) DO NOTHING;

			--nodarc (AS arc)
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCCHV','VARC','ARC', 'v_edit_arc', 'Check valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCFCV','VARC','ARC', 'v_edit_arc', 'Flow control valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCGPV','VARC','ARC', 'v_edit_arc', 'General purpose valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCPBV','VARC','ARC', 'v_edit_arc', 'Presure break valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCPSV','VARC','ARC', 'v_edit_arc', 'Presure sustain valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCPRV','VARC','ARC', 'v_edit_arc', 'Presure reduction valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCTCV','VARC','ARC', 'v_edit_arc', 'Throttle control valve (arc)', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('ARCPUMP','VARC','ARC', 'v_edit_arc', 'Pump (arc)', true) ON CONFLICT (id) DO NOTHING;

			--nodarc (AS node)
		
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('FCV','VALVE','NODE', 'v_edit_node','Flow control valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('GPV','VALVE','NODE', 'v_edit_node','General purpose valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('PBV','VALVE','NODE', 'v_edit_node','Presure break valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('PSV','VALVE','NODE', 'v_edit_node','Presure sustain valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('PRV','VALVE','NODE', 'v_edit_node','Presure reduction valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('TCV','VALVE','NODE', 'v_edit_node','Throttle control valve when comes from giswater project', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('PUMP','PUMP','NODE', 'v_edit_node','Pump', true) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature (id, system_id, feature_type, parent_layer, descript, code_autofill) 
			VALUES ('SHORTPIPE','VALVE','NODE', 'v_edit_node','Other shortpipe (meters, checkvalve, shutoff valves)  when comes from giswater project', true) 
			ON CONFLICT (id) DO NOTHING;
			

			--arc_type
			--arc
			INSERT INTO cat_feature_arc VALUES ('PIPE', 'PIPE', 'PIPE') ON CONFLICT (id) DO NOTHING;
			--nodarc
			INSERT INTO cat_feature_arc VALUES ('ARCCHV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCFCV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCGPV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCPBV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCPSV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCPRV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCTCV', 'VARC', 'VALVE-IMPORTINP') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_arc VALUES ('ARCPUMP', 'VARC', 'PUMP-IMPORTINP') ON CONFLICT (id) DO NOTHING;

			--cat_feature_node
			--node
			INSERT INTO cat_feature_node VALUES ('JUNCTION', 'JUNCTION', 'JUNCTION', 9, FALSE, TRUE, 'NONE') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('TANK', 'TANK', 'TANK', 9, FALSE, TRUE, 'SECTOR') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('RESERVOIR', 'SOURCE', 'RESERVOIR', 1, FALSE, TRUE, 'SECTOR') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('FCV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'MINSECTOR') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('GPV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'MINSECTOR') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('PBV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'PRESSZONE') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('PSV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'PRESSZONE') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('TCV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'MINSECTOR') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('PRV', 'VALVE', 'VALVE', 2, FALSE, TRUE, 'PRESSZONE') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('PUMP', 'PUMP', 'PUMP', 2, FALSE, TRUE, 'PRESSZONE') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_feature_node VALUES ('SHORTPIPE', 'VALVE', 'SHORTPIPE', 2, FALSE, TRUE, 'MINSECTOR') ON CONFLICT (id) DO NOTHING;

			ALTER TABLE cat_feature ENABLE TRIGGER gw_trg_cat_feature;
			--Materials
			INSERT INTO cat_mat_arc 
			SELECT DISTINCT csv6, csv6 FROM temp_csv WHERE source='[PIPES]' AND csv6 IS NOT NULL;
			DELETE FROM cat_mat_roughness; -- forcing delete because when new material is inserted on cat_mat_arc automaticly this table is filled
			INSERT INTO cat_mat_node VALUES ('MAT', 'MAT') ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_mat_arc VALUES ('MAT', 'MAT');

			--Roughness
			INSERT INTO cat_mat_roughness (matcat_id, period_id, init_age, end_age, roughness)
			SELECT id, 'default period',  0, 999, id::float FROM cat_mat_arc WHERE id !='MAT';

			--cat_arc
			--pipe
			INSERT INTO cat_arc( id, arctype_id, matcat_id,  dint)
			SELECT DISTINCT ON (csv6, csv5) concat(csv6::numeric(10,3),'-',csv5::numeric(10,3))::text, 'PIPE', csv6, csv5::float FROM temp_csv WHERE source='[PIPES]' AND csv1 not like ';%' AND csv5 IS NOT NULL  ON CONFLICT (id) DO NOTHING;

			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCPUMP', 'ARCPUMP', 'MAT', TRUE)  ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCCHV', 'ARCCHV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCFCV', 'ARCFCV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCGPV', 'ARCGPV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCPBV', 'ARCPBV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCPSV', 'ARCPSV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCTCV', 'ARCTCV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_arc (id, arctype_id, matcat_id, active) VALUES ('ARCPRV', 'ARCPRV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;

			--cat_node
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('JUNCTION', 'JUNCTION', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('TANK', 'TANK', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('RESERVOIR', 'RESERVOIR', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('FCV', 'FCV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('GPV', 'GPV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('PBV', 'PBV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('PSV', 'PSV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('TCV', 'TCV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('PRV', 'PRV', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('PUMP', 'PUMP', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;
			INSERT INTO cat_node (id, nodetype_id, matcat_id, active) VALUES ('SHORTPIPE', 'SHORTPIPE', 'MAT', TRUE) ON CONFLICT (id) DO NOTHING;


			-- insert other catalog tables
			INSERT INTO cat_work VALUES ('IMPORTINP', 'IMPORTINP') ON CONFLICT (id) DO NOTHING;


			--create child views 
			PERFORM gw_fct_admin_manage_child_views($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{},
			"data":{"filterFields":{}, "pageInfo":{}, "action":"MULTI-CREATE" }}$$);

			-- enable temporary the constraint in order to use ON CONFLICT on insert
			ALTER TABLE config_param_user ADD CONSTRAINT config_param_user_parameter_cur_user_unique UNIQUE(parameter, cur_user);

			-- improve velocity for junctions using directy tables in spite of vi_junctions view
			INSERT INTO node (node_id, elevation, nodecat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, presszone_id) 
			SELECT csv1, csv2::numeric(12,3), 'JUNCTION', 'JUNCTION', 1, 1, 1, 1, 2, 1
			FROM temp_csv where source='[JUNCTIONS]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user order by 1;
			INSERT INTO inp_junction SELECT csv1, csv3::numeric(12,6), csv4::varchar(16) FROM temp_csv where source='[JUNCTIONS]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user;
			INSERT INTO man_junction SELECT csv1 FROM temp_csv where source='[JUNCTIONS]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user;

			-- improve velocity for pipes using directy tables in spite of vi_pipes view
			INSERT INTO arc (arc_id, node_1, node_2, custom_length, arccat_id, epa_type, sector_id, dma_id, expl_id, state, state_type, presszone_id) 
			SELECT csv1, csv2, csv3, csv4::numeric(12,3), concat((csv6::numeric(12,3))::text,'-',(csv5::numeric(12,3))::text), 'PIPE', 1, 1, 1, 1, 2, 1 
			FROM temp_csv where source='[PIPES]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user order by 1;
			INSERT INTO inp_pipe (arc_id, minorloss, status) 
			SELECT csv1, csv7::numeric(12,6), upper(csv8) FROM temp_csv where source='[PIPES]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user;

			-- delete those custom_length with same value of real_length
			UPDATE arc SET custom_length = null WHERE custom_length::numeric(12,3) <> (st_length(the_geom))::numeric(12,3);
			
			INSERT INTO man_pipe SELECT csv1 FROM temp_csv where source='[PIPES]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user;
			
			-- insert controls
			INSERT INTO inp_controls (sector_id, text, active)
			select 1, csv1, true FROM temp_csv where source='[CONTROLS]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';-%' AND csv1 NOT LIKE ';text') AND cur_user=current_user order by 1;

			-- insert rules
			INSERT INTO inp_rules (sector_id, text, active)
			select 1, csv1, true FROM temp_csv where source='[RULES]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';-%' AND csv1 NOT LIKE ';text') AND cur_user=current_user order by 1;


			-- LOOPING THE EDITABLE VIEWS TO INSERT DATA
			FOR v_rec_table IN SELECT * FROM config_fprocess WHERE fid=v_fid AND tablename NOT IN ('vi_pipes', 'vi_junctions', 'v_valves', 'vi_status', 'vi_controls', 'vi_rules', 'vi_coordinates') order by orderby
			LOOP
				--identifing the number of fields of the editable view
				FOR v_rec_view IN SELECT row_number() over (order by v_rec_table.tablename) as rid, column_name, data_type from information_schema.columns 
				where table_name=v_rec_table.tablename AND table_schema='SCHEMA_NAME'
				LOOP	
					-- profilactic control for postgis specific datatypes
					IF v_rec_view.data_type = 'USER-DEFINED' THEN v_rec_view.data_type = 'text'; END IF;

					IF v_rec_view.rid=1 THEN
						--insert of fields which are concatenation 
						v_query_fields = concat ('csv',v_rec_view.rid,'::',v_rec_view.data_type);
					ELSE
						v_query_fields = concat (v_query_fields,' , csv',v_rec_view.rid,'::',v_rec_view.data_type);
					END IF;

				END LOOP;

				--inserting values on editable view
				v_sql = 'INSERT INTO '||v_rec_table.tablename||' SELECT '||v_query_fields||' FROM temp_csv where source='||quote_literal(v_rec_table.target)||'
				AND fid = '||v_fid||'  AND (csv1 NOT LIKE ''[%'' AND csv1 NOT LIKE '';%'') AND cur_user='||quote_literal(current_user)||' ORDER BY id';

				raise notice 'v_sql %', v_sql;
				EXECUTE v_sql;
				
			END LOOP;

			-- update coordinates
			UPDATE node SET the_geom=ST_SetSrid(ST_MakePoint(csv2::numeric,csv3::numeric),v_epsg)
			FROM temp_csv where source='[COORDINATES]' AND fid = 239  AND (csv1 NOT LIKE '[%' AND csv1 NOT LIKE ';%') AND cur_user=current_user 
			AND csv1 = node_id;

			-- force state type for arcs and nodes
			UPDATE arc SET state_type = 2;
			UPDATE node SET state_type = 2;

			-- update status
			UPDATE inp_valve_importinp SET status = upper(csv2) FROM temp_csv where source='[STATUS]'  and arc_id = csv1;
			UPDATE inp_pump_importinp SET status = upper(csv2) FROM temp_csv where source='[STATUS]' and arc_id = csv1;

			--set options configuration
			UPDATE config_param_user set value=NULL WHERE cur_user=current_user AND parameter ILIKE 'inp_options%';

			UPDATE config_param_user set value=csv2 FROM temp_csv
			WHERE source ='[OPTIONS]' AND replace(parameter,'inp_options_','')=lower(csv1);

			--set raport configuration
			UPDATE config_param_user set value=NULL WHERE cur_user=current_user AND parameter ILIKE 'inp_report%';

			UPDATE config_param_user set value=csv2 FROM temp_csv
			WHERE source ='[REPORT]' AND replace(parameter,'inp_report_','')=lower(csv1);

			--set raport configuration
			UPDATE config_param_user set value=NULL WHERE cur_user=current_user AND parameter ILIKE 'inp_times';

			UPDATE config_param_user set value=csv2 FROM temp_csv
			WHERE source ='[TIMES]' AND replace(parameter,'inp_times_','')=lower(csv1);

			-- disable temporary the constraint in order to use ON CONFLICT on insert
			ALTER TABLE config_param_user DROP CONSTRAINT config_param_user_parameter_cur_user_unique;

			RAISE NOTICE 'step 4/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Values of options /times / report have been set.');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Inserting data into tables using vi_* views -> Done');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, 'WARNING-239: If controls exists, it would have been related to the whole sector');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, 'WARNING-239: If rules exits, it would have been related to the whole sector');

			IF v_isgwproject THEN -- manage pumps & valves as a reverse nod2arc. It means transforming lines into points reversing sintaxis applied on Giswater exportation

				-- to_arc on pumps
				UPDATE inp_pump_importinp SET to_arc = b.to_arc FROM
					(select a.arc_id, n.arc_id AS to_arc from inp_pump_importinp 
					JOIN arc a USING (arc_id) 
					JOIN (SELECT arc_id, node_1 FROM arc)n ON a.node_2 = n.node_1
					WHERE a.arc_id NOT IN (SELECT arc_id FROM inp_pump_importinp WHERE substring(reverse(arc_id),0,2) ~ '^\d+$')
					AND a.arc_id != n.arc_id)b
				WHERE  b.arc_id = inp_pump_importinp.arc_id;

				-- to_arc on valves
				UPDATE inp_valve_importinp SET to_arc = b.to_arc FROM
					(select a.arc_id, n.arc_id AS to_arc from inp_valve_importinp 
					JOIN arc a USING (arc_id) 
					JOIN (SELECT arc_id, node_1 FROM arc UNION SELECT arc_id, node_2 FROM arc)n ON a.node_2 = n.node_1
					WHERE a.arc_id NOT IN (SELECT arc_id FROM inp_valve_importinp WHERE substring(reverse(arc_id),0,2) ~ '^\d+$')
					AND a.arc_id != n.arc_id)b
				WHERE  b.arc_id = inp_valve_importinp.arc_id;

				-- to_arc on pressurepump
				UPDATE inp_pump_importinp SET to_arc = b.to_arc FROM
					(select a.arc_id, n.arc_id AS to_arc from inp_pump_importinp 
					JOIN arc a USING (arc_id) 
					JOIN (SELECT arc_id, node_1 FROM arc UNION SELECT arc_id, node_2 FROM arc)n ON a.node_2 = n.node_1
					WHERE a.arc_id NOT IN (SELECT arc_id FROM inp_pump_importinp WHERE substring(reverse(arc_id),0,4) ~ '^\d+$')
					AND a.arc_id != n.arc_id)b
				WHERE  b.arc_id = inp_pump_importinp.arc_id;

				FOR v_data IN SELECT * FROM arc WHERE arc_id like '%_n2a' OR arc_id like '%_n2a_5'
				LOOP
					IF v_data.epa_type = 'VALVE-IMPORTINP' THEN 
						v_nodecat = (SELECT valv_type FROM inp_valve_importinp WHERE arc_id = v_data.arc_id);
						v_epatype = 'VALVE';
						
					ELSIF v_data.epa_type = 'PUMP-IMPORTINP' THEN 
						IF v_data.arc_id like '%_n2a_5' THEN 
							v_pumptype  = 'PRESSPUMP';	
						ELSE 
							v_pumptype  = 'FLOWPUMP';
						END IF;
						v_nodecat = 'PUMP';
						v_epatype = 'PUMP';
					ELSE 
						v_nodecat = 'SHORTPIPE';
						v_epatype = 'SHORTPIPE';
					END IF;
					
					-- getting man_table to work with
					SELECT type, epa_table INTO v_mantype, v_epatablename FROM cat_feature_node c JOIN sys_feature_epa_type s ON c.epa_default = s.id 
					WHERE epa_default = v_epatype;
					
					-- defining geometry of new node
					SELECT array_agg(the_geom) INTO geom_array FROM node WHERE v_data.node_1=node_id;
					FOR rpt_rec IN SELECT * FROM temp_csv WHERE cur_user=current_user AND fid = v_fid and source='[VERTICES]' AND csv1=v_data.arc_id order by id
					LOOP	
						v_point_geom=ST_SetSrid(ST_MakePoint(rpt_rec.csv2::numeric,rpt_rec.csv3::numeric),v_epsg);
						geom_array=array_append(geom_array,v_point_geom);
					END LOOP;

					geom_array=array_append(geom_array,(SELECT the_geom FROM node WHERE v_data.node_2=node_id));

					--line geometry
					v_thegeom=ST_MakeLine(geom_array);

					UPDATE arc SET the_geom=v_thegeom WHERE arc_id=v_data.arc_id;

					-- point geometry
					v_thegeom=ST_LineInterpolatePoint(v_thegeom, 0.5);

					-- defining new node parameters
					v_node_id = replace(v_data.arc_id, '_n2a_5', '');
					v_node_id = replace(v_node_id, '_n2a', '');

					-- Introducing new node transforming line into point
					INSERT INTO node (node_id, nodecat_id, epa_type, sector_id, dma_id, expl_id, state, state_type,the_geom) VALUES (v_node_id, v_nodecat, v_epatype,1,1,1,1,2, v_thegeom) ;

					EXECUTE 'INSERT INTO man_'||v_mantype||' VALUES ('||quote_literal(v_node_id)||')';

					IF v_epatablename = 'inp_pump' THEN
						INSERT INTO inp_pump (node_id, power, curve_id, speed, pattern, status, energyparam, energyvalue, to_arc, pump_type)
						SELECT v_node_id, power, curve_id, speed, pattern, status, energyparam, energyvalue, to_arc, v_pumptype FROM inp_pump_importinp WHERE arc_id=v_data.arc_id;

					ELSIF v_epatablename = 'inp_valve' THEN
						INSERT INTO inp_valve (node_id, valv_type, pressure, custom_dint, flow, coef_loss, curve_id, minorloss, status, to_arc)
						SELECT v_node_id, valv_type, pressure, diameter, flow, coef_loss, curve_id, minorloss, status, to_arc FROM inp_valve_importinp WHERE arc_id=v_data.arc_id;

					ELSE						
						INSERT INTO inp_shortpipe (node_id, status) SELECT v_node_id, status FROM inp_pipe WHERE arc_id=v_data.arc_id;
						
					END IF;
						
					-- get old nodes
					SELECT node_1, node_2 INTO v_node1, v_node2 FROM arc WHERE arc_id=v_data.arc_id;

					-- calculate elevation from old nodes
					v_elevation = ((SELECT elevation FROM node WHERE node_id=v_node1) + (SELECT elevation FROM node WHERE node_id=v_node2))/2;

					-- downgrade to obsolete arcs and nodes
					UPDATE arc SET state=0,state_type=2 WHERE arc_id=v_data.arc_id;
					UPDATE node SET state=0,state_type=2 WHERE node_id IN (v_node1, v_node2);

					-- reconnect topology
					UPDATE arc SET node_1=v_node_id WHERE node_1=v_node1 OR node_1=v_node2;
					UPDATE arc SET node_2=v_node_id WHERE node_2=v_node1 OR node_2=v_node2;
							
					-- update elevation of new node
					UPDATE node SET elevation = v_elevation WHERE node_id=v_node_id;
					
				END LOOP;			
		
				-- to_arc on shortpipes
				UPDATE inp_shortpipe SET to_arc = b.to_arc FROM
					(
					select a.arc_id, n.arc_id AS to_arc from inp_pipe
					JOIN arc a USING (arc_id)
					JOIN (SELECT arc_id, node_1 FROM arc UNION SELECT arc_id, node_2 FROM arc)n ON a.node_2 = n.node_1
					WHERE 
					a.arc_id != n.arc_id
					and status = 'CV')b
				WHERE  b.arc_id = concat(inp_shortpipe.node_id,'_n2a');

				-- transform pump additional from node to inp_pump_additional table		
				INSERT INTO inp_pump_additional (node_id, order_id, power, curve_id, speed, pattern, status, energyparam, energyvalue)
				select 
				replace(arc_id, reverse(substring(reverse(arc_id),0,6)), ''), 
				(substring(reverse(arc_id),0,2))::integer,
				power, curve_id, speed, pattern, status, energyparam, energyvalue
				from inp_pump_importinp WHERE substring(reverse(arc_id),0,2) ~ '^\d+$' AND substring(reverse(arc_id),2,1) !='_';

				-- update state=0 pump additionals 
				UPDATE arc SET state = 0 WHERE arc_id IN (SELECT arc_id FROM inp_pump_importinp);
							
				-- delete objects
				--DELETE FROM inp_pump_importinp;
				--DELETE FROM inp_valve_importinp;
				DELETE FROM inp_pipe WHERE substring(reverse(arc_id),0,5) = 'a2n_';

				INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 
				'INFO: Link geometries from VALVES AND PUMPS have been transformed using reverse nod2arc strategy as nodes. Geometry from arcs and nodes are saved using state=0');
			END IF;


			RAISE NOTICE 'step 5/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Creating arc geometry from extremal nodes and intermediate vertex -> Done');

			-- Create arc geom
			IF v_isgwproject THEN
				v_querytext = 'SELECT * FROM arc WHERE epa_type=''PIPE''';
			ELSE 
				v_querytext = 'SELECT * FROM arc ';
			END IF;

			FOR v_data IN EXECUTE v_querytext
			LOOP
				--Insert start point, add vertices if exist, add end point
				SELECT array_agg(the_geom) INTO geom_array FROM node WHERE v_data.node_1=node_id;

				SELECT array_agg(ST_SetSrid(ST_MakePoint(csv2::numeric,csv3::numeric),v_epsg)order by id) INTO  geom_array_vertex FROM temp_csv
				WHERE cur_user=current_user AND fid = v_fid and source='[VERTICES]' and csv1=v_data.arc_id;
				
				IF geom_array_vertex IS NOT NULL THEN
					geom_array=array_cat(geom_array, geom_array_vertex);
				END IF;
				
				geom_array=array_append(geom_array,(SELECT the_geom FROM node WHERE v_data.node_2=node_id));

				UPDATE arc SET the_geom=ST_MakeLine(geom_array) where arc_id=v_data.arc_id;

			END LOOP;

			--mapzones
			EXECUTE 'SELECT ST_Multi(ST_ConvexHull(ST_Collect(the_geom))) FROM arc;'
			into v_extend_val;
			update exploitation SET the_geom=v_extend_val;
			update sector SET the_geom=v_extend_val;
			update dma SET the_geom=v_extend_val;
			update presszone SET the_geom=v_extend_val;
			update dqa SET the_geom=v_extend_val;
			update ext_municipality SET the_geom=v_extend_val;

			INSERT INTO inp_pattern SELECT DISTINCT pattern_id FROM inp_pattern_value;

			RAISE NOTICE 'step-6/7';
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Creating arc geometries -> Done');

			-- Enable constraints
			PERFORM gw_fct_admin_manage_ct($${"client":{"lang":"ES"},"data":{"action":"ADD"}}$$);

			IF v_isgwproject THEN -- Reconnect those arcs connected to dissapeared nodarcs to the new node

				-- reconnect presspumps
				FOR v_node_id, v_newnode, v_oldarc IN SELECT  node_id, replace (node_id, '_n2a_2', ''), replace (node_id, '_n2a_2', '_n2a_4') FROM node where substring(reverse(node_id),1,2) = '2_'
				LOOP
					UPDATE arc SET node_1=v_newnode WHERE node_1=v_node_id;
					UPDATE arc SET node_2=v_newnode WHERE node_2=v_node_id;
					DELETE FROM node WHERE node_id = v_node_id;
					DELETE FROM arc WHERE arc_id = v_oldarc;
					
					UPDATE node SET the_geom = the_geom WHERE node_id = v_newnode;
				END LOOP;

				-- set nodearc variable as a max length/2+0.01 of arcs with state=0 (only are nod2arcs)
				UPDATE config_param_system SET value = ((SELECT max(st_length(the_geom)) FROM arc WHERE state=0)/2+0.01) WHERE parameter='edit_arc_searchnodes';
				
				-- delete old nodes
				UPDATE arc SET node_1=null where node_1 IN (SELECT node_id FROM node WHERE state=0);
				UPDATE arc SET node_2=null where node_2 IN (SELECT node_id FROM node WHERE state=0);
				DELETE FROM node WHERE state=0;
					
				-- repair arcs
				SELECT gw_fct_arc_repair(concat('{"client":{"device":4, "infoType":1, "lang":"ES"},"form":{}, 
				"feature":{"tableName":"arc","featureType":"ARC", "id":["',arc_id,'"]},"data":{"filterFields":{}, "pageInfo":{}, "selectionMode":"previousSelection","parameters":{}}}')::json)
				FROM arc
				INTO v_record;

				-- restore default default values
				UPDATE config_param_system SET value='{"activated":true,"value":0.1}' where parameter = 'edit_arc_searchnodes';

			END IF;

			RAISE NOTICE 'step-7/7 - last';
			INSERT INTO selector_sector VALUES (1,current_user) ON CONFLICT (sector_id, cur_user) DO NOTHING;
			UPDATE arc SET code = arc_id;
			UPDATE node SET code = node_id;

			-- delete from arc
			DELETE FROM arc WHERE state = 0;

			-- config graph
			INSERT INTO config_graph_inlet SELECT node_id, 1, null, true FROM node WHERE epa_type IN ('TANK', 'RESERVOIR');
			
			-- purge catalog tables
			DELETE FROM cat_arc WHERE id NOT IN (SELECT DISTINCT(arccat_id) FROM arc);
			DELETE FROM cat_node WHERE id NOT IN (SELECT DISTINCT(nodecat_id) FROM node);
			DELETE FROM cat_mat_arc WHERE id NOT IN (SELECT DISTINCT(matcat_id) FROM cat_arc);
			DELETE FROM cat_mat_node WHERE id NOT IN (SELECT DISTINCT(matcat_id) FROM cat_node);
			DELETE FROM cat_feature WHERE id NOT IN (SELECT DISTINCT(arctype_id) FROM cat_arc) AND feature_type = 'ARC';
			DELETE FROM cat_feature WHERE id NOT IN (SELECT DISTINCT(nodetype_id) FROM cat_node) AND feature_type = 'NODE';

			-- last process. Harmonize values
			UPDATE inp_valve SET status = 'ACTIVE' WHERE status IS NULL;
			UPDATE node SET presszone_id = '1' WHERE presszone_id is null;
			UPDATE arc SET presszone_id = '1' WHERE presszone_id is null;
			
			UPDATE node SET code = node_id  WHERE code is null;
			UPDATE arc SET code = arc_id WHERE code is null;
			
			UPDATE config_param_user SET value = null WHERE parameter = 'inp_options_pattern';
						
			INSERT INTO config_param_user VALUES ('inp_options_patternmethod', '13', current_user);
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Enabling constraints -> Done');
			INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: Process finished');

			UPDATE inp_pump SET status ='OPEN' WHERE status is null;

		END IF;

	ELSE
	
		INSERT INTO audit_check_data (fid, criticity, error_message) 
		VALUES (239, 4, 'Variable import_epa_debug is True. As result import have been partially sucessfull.');
		INSERT INTO audit_check_data (fid, criticity, error_message) 
		VALUES (239, 4, 'Inp file data is stored on temp_csv table. To debug import process take a look on https://github.com/Giswater/giswater_dbmodel/wiki/import-inp-file-debug-mode');
	END IF;

	-- check project (to initialize config_param_user among others)
	PERFORM gw_fct_setcheckproject ($${"client":{"device":4, "infoType":1, "lang":"ES"}, "data":{"filterFields":{}, "fid":101}}$$);

	-- insert spacers on log
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 4, '');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 3, '');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, '');
	INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, '');
	
	--set urn id
	PERFORM gw_fct_import_inp_urn();

	-- check for integer or varchar id's
	v_count_total := (SELECT count(*) FROM (SELECT arc_id fid FROM arc UNION SELECT node_id FROM node)a);
	v_count := (SELECT count(*) FROM (SELECT arc_id fid FROM arc UNION SELECT node_id FROM node)a WHERE fid ~ '^\d+$');

	IF v_count =v_count_total THEN
		INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 1, 'INFO: All arc & node id''s are integer');
	ELSIF v_count < v_count_total THEN
		INSERT INTO audit_check_data (fid, criticity, error_message) VALUES (239, 2, concat('WARNING-239: There is/are ',
		v_count_total - v_count,' element(s) with id''s not integer(s). It creates a limitation to use some functionalities of Giswater'));
	END IF;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND (fid=239 OR fid=439) order by criticity DESC, id) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	-- replace
	SELECT json_agg(json_build_object(source,csv1)) INTO v_replace
		FROM (
		SELECT source, array_agg(distinct csv1) as csv1
		FROM temp_csv
		WHERE fid='239' and length(csv1) > 16 and csv1 not ilike ';%' 
			and source in ('[PIPES]','[JUNCTIONS]','[TANKS]','[RESERVOIRS]','[VALVES]','[PUMPS]','[CURVES]','[PATTERNS]') 
		GROUP BY source ORDER BY 1) a;

	-- Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 	
	v_version := COALESCE(v_version, '{}'); 	

	IF v_replace IS NOT NULL THEN
		v_replace := '"replace":'||v_replace||',';
	ELSE
		v_replace := '';
	END IF;

	-- Return
	RETURN gw_fct_json_create_return(('{"status":"'||v_status||'",  "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
			 	v_replace||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||'}'||
	    '}}')::json, 2522, null, null, null);
	
	--  Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed", "body":{"data":{"info":{"values":[{"message":"IMPORT INP FILE FUNCTION"},
		{"message":"-----------------------------"},
		{"message":""},
		{"message":"ERRORS"},
		{"message":"----------"},
		{"message":'||to_json(v_error_context)||'},
		{"message":'||to_json(SQLERRM)||'}]}}}, "NOSQLERR":' || 
	to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;
	
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
