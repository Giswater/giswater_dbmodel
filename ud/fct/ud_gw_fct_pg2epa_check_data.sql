/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION CODE:2431

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa_check_data(text);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa_check_data(varchar);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_epa_check_data(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_check_data(p_data json)
 RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_pg2epa_check_data($${"data":{"parameters":{"fid":127}}}$$)-- when is called from go2epa_main
SELECT SCHEMA_NAME.gw_fct_pg2epa_check_data($${"data":{"parameters":{"fid":101}}}$$)-- when is called from checkproject

-- fid: main: 225,
	other: 106,107,111,113,164,175,187,188,294,295,379,427,430,440,480,522,528,529,530

SELECT * FROM audit_check_data WHERE fid = v_fid

*/

DECLARE
v_record record;
v_project_type text;
v_count	integer;
v_count_2 integer;
v_result text;
v_version text;
v_result_info json;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_querytext text;
v_result_id text;
v_defaultdemand	float;
v_error_context text;
v_fid integer;
v_nodetolerance float;
v_minlength float = 0;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;

	-- getting input data 	
	v_result_id := ((p_data ->>'data')::json->>'parameters')::json->>'resultId'::text;
	v_fid := ((p_data ->>'data')::json->>'parameters')::json->>'fid';
	v_nodetolerance :=  (SELECT value::json->>'value' FROM config_param_system WHERE parameter = 'edit_node_proximity');
	v_minlength := (SELECT value FROM config_param_user WHERE parameter = 'inp_options_minlength' AND cur_user = current_user);

	-- select config values
	SELECT project_type, giswater  INTO v_project_type, v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	-- init variables
	v_count=0;
	IF v_fid is null THEN v_fid = 225; END IF;	

	IF v_fid IN (101,225) THEN
		
		CREATE TEMP TABLE temp_anl_arc (LIKE SCHEMA_NAME.anl_arc INCLUDING ALL);
		CREATE TEMP TABLE temp_anl_node (LIKE SCHEMA_NAME.anl_node INCLUDING ALL);
		CREATE TEMP TABLE temp_audit_check_data (LIKE SCHEMA_NAME.audit_check_data INCLUDING ALL);
		CREATE TEMP TABLE temp_anl_polygon (LIKE SCHEMA_NAME.anl_polygon INCLUDING ALL);
		
		-- Header
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 4, concat('DATA QUALITY ANALYSIS ACORDING EPA RULES'));
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 4, '-----------------------------------------------------------');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 3, 'CRITICAL ERRORS');
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 3, '----------------------');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 2, 'WARNINGS');
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 2, '--------------');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 1, 'INFO');
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 1, '-------');
		
	END IF;
			
	RAISE NOTICE '1 - Check orphan nodes (fid:  107)';
	v_querytext = '(SELECT node_id, nodecat_id, the_geom FROM (SELECT node_id FROM v_edit_node EXCEPT 
			(SELECT node_1 as node_id FROM v_edit_arc UNION SELECT node_2 FROM v_edit_arc))a JOIN v_edit_node USING (node_id)
			JOIN selector_sector USING (sector_id) 
			JOIN value_state_type v ON state_type = v.id
			WHERE epa_type != ''UNDEFINED'' and v_edit_node.is_operative = true and cur_user = current_user ) b';	
		
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom) SELECT 107, node_id, nodecat_id, ''Orphan node'',
		the_geom FROM ', v_querytext);
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '107',concat('ERROR-107 (anl_node): There is/are ',v_count,' node''s orphan. If they are JUNCTIONS, on the exportation will be removed.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1,'107', 'INFO: No node(s) orphan found.',v_count);
	END IF;
	
	
	RAISE NOTICE '4 - Check state_type nulls (arc, node) (175)';
	v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM v_edit_arc JOIN selector_sector USING (sector_id) WHERE state_type IS NULL AND cur_user = current_user
			UNION 
			SELECT node_id, nodecat_id, the_geom FROM v_edit_node JOIN selector_sector USING (sector_id) WHERE state_type IS NULL AND cur_user = current_user) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '175',concat('ERROR-175: There is/are ',v_count,' topologic features (arc, node) with state_type with NULL values. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '175','INFO: No topologic features (arc, node) with state_type NULL values found.',v_count);
	END IF;
	
	
	RAISE NOTICE '5- Check for missed features on inp tables';
		v_querytext = '(SELECT arc_id, ''arc'' as feature_tpe FROM arc JOIN
				(select arc_id from inp_conduit UNION select arc_id from inp_virtual UNION select arc_id from inp_weir UNION select arc_id from inp_pump UNION select arc_id from inp_outlet UNION select arc_id from inp_orifice) a
				USING (arc_id) 
				WHERE state > 0 AND epa_type !=''UNDEFINED'' AND a.arc_id IS NULL
				UNION
				SELECT node_id, ''node'' FROM node JOIN
				(select node_id from inp_junction UNION select node_id from inp_storage UNION select node_id from inp_outfall UNION select node_id from inp_divider) a
				USING (node_id) 
				WHERE state > 0 AND epa_type !=''UNDEFINED'' AND a.node_id IS NULL) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id,  criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '272', concat('ERROR-272: There is/are ',v_count,' missed features on inp tables. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '272', 'INFO: No features missed on inp_tables found.',v_count);
	END IF;

	RAISE NOTICE '6- Nodes sink (113)';
	INSERT INTO temp_anl_node (fid, node_id, nodecat_id, the_geom, descript)
	
	SELECT 113, node_id, nodecat_id, v_edit_node.the_geom, 'Node sink' FROM v_edit_node WHERE epa_type !='UNDEFINED' AND node_id IN

	-- those nodes as node_1 on arc no pump with negative slope except arcs with this node as node_1 and positive slope
	(SELECT node_1 FROM (SELECT arc_id, node_1, node_2 FROM v_edit_arc JOIN cat_arc c ON c.id = arccat_id 
	JOIN selector_sector USING (sector_id) JOIN cat_arc_shape s ON c.shape = s.id WHERE slope < 0 AND s.epa != 'FORCE_MAIN')a
	EXCEPT 
	SELECT node_1 FROM (SELECT arc_id, node_1, node_2 FROM v_edit_arc JOIN cat_arc c ON c.id = arccat_id 
	JOIN selector_sector USING (sector_id) JOIN cat_arc_shape s ON c.shape = s.id WHERE slope > 0)a);
	
	SELECT count(*) into v_count FROM temp_anl_node WHERE fid=113 AND cur_user=current_user;
	
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 2, '113', concat('WARNING-113 (anl_node): There is/are ',v_count,
		' junction(s) type sink which means that junction only have entry arcs without any exit arc (FORCE_MAIN is not valid).'),v_count);

		-- check nodes sink automaticly swiched to outfall (fuction gw_fct_temp_anl_node_sink have been called on pg2epa_fill_data function)
		SELECT count(*) into v_count_2 FROM temp_anl_node JOIN inp_junction USING (node_id) 
		WHERE outfallparam IS NOT NULL AND fid=113 AND cur_user=current_user;
		
		IF v_count_2 > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
			VALUES (v_fid, v_result_id, 2, '113', concat('WARNING-113 (anl_node):  ',v_count_2,' from ',v_count,
			' junction(s) type sink has/have outfallparam field defined and has/have been switched to OUTFALL using defined parameters.'),v_count);
		END IF;
		v_count=0;
		v_count_2=0;
	ELSE 
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '113', concat('INFO: Any junction have been swiched on the fly to OUTFALL. Only nodes sink with outfallparam values can do it.'),v_count);
	END IF;
	
	RAISE NOTICE '107- Node exit upper intro (111)';
	INSERT INTO temp_anl_node (fid, node_id, nodecat_id, sector_id, the_geom, descript)
	SELECT 111, node_id, nodecat_id, sector_id, a.the_geom, concat('Node exit upper intro with: Max. entry: ', max_entry , ', Max. exit:',max_exit) 
	FROM ( SELECT node_id, max(sys_elev1) AS max_exit, nodecat_id, node.sector_id, node.the_geom FROM v_edit_arc JOIN node ON node_1 = node_id JOIN cat_feature_node ON node_type = id
	WHERE isexitupperintro = 0 GROUP BY node_id, node.sector_id )a
	JOIN ( SELECT node_id, max(sys_elev2) AS max_entry FROM v_edit_arc JOIN node ON node_2 = node_id JOIN cat_feature_node ON node_type = id WHERE isexitupperintro = 0 GROUP BY node_id )b USING (node_id)
	JOIN selector_sector USING (sector_id) 
	WHERE max_entry < max_exit AND cur_user = current_user;

	SELECT count(*) into v_count FROM temp_anl_node WHERE fid=111 AND cur_user=current_user;
	
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 2, '111', concat('WARNING-111 (anl_node): There is/are ',v_count,' junction(s) with exits upper intro'),v_count);
	ELSE 
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '111', concat('INFO: Any junction have been detected with exits upper intro.'),v_count);
	END IF;


	RAISE NOTICE '8 - Null sys elevation control (fid: 164, 284)';
	SELECT count(*) INTO v_count FROM v_edit_node JOIN selector_sector USING (sector_id) WHERE epa_type !='UNDEFINED' AND sys_elev IS NULL AND cur_user = current_user;

	--arcs without sys elevation (164)
	IF v_count > 0 THEN
		INSERT INTO temp_anl_node (fid, node_id, nodecat_id, the_geom)
		SELECT 164, node_id, nodecat_id, the_geom FROM v_edit_node JOIN selector_sector USING (sector_id) 
		WHERE epa_type !='UNDEFINED' AND sys_elev IS NULL AND cur_user = current_user;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '164', concat('ERROR-164 (anl_node): There is/are ',v_count,' EPA node(s) without sys_elevation values.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '164', 'INFO: No nodes with null values on field elevation have been found.',v_count);
	END IF;
	--arcs without sys elevation (284)
	SELECT count(*) INTO v_count FROM v_edit_arc JOIN selector_sector USING (sector_id) WHERE cur_user = current_user AND sys_elev1 = NULL OR sys_elev2 = NULL;
	IF v_count > 0 THEN
		INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, the_geom)
		SELECT 284, arc_id, arccat_id, the_geom FROM v_edit_arc JOIN selector_sector USING (sector_id) WHERE cur_user = current_user AND sys_elev1 = NULL OR sys_elev2 = NULL;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '284', concat('ERROR-284 (anl_arc): There is/are ',v_count,' arc(s) without values on sys_elev1 or sys_elev2.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '284', 'INFO: No arcs with null values on field elevation (sys_elev1 or sys_elev2) have been found.',v_count);
	END IF;
		
	RAISE NOTICE '9- Raingage data (285)';
	SELECT count(*) INTO v_count FROM v_edit_raingage where (form_type is null) OR (intvl is null) OR (rgage_type is null);
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '285', concat('ERROR-285: There is/are ',v_count,
		' raingage(s) with null values at least on mandatory columns for rain type (form_type, intvl, rgage_type).'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '285', concat('INFO: Mandatory colums for raingage (form_type, intvl, rgage_type) have been checked without any values missed.'),v_count);
	END IF;		
	
	SELECT count(*) INTO v_count FROM v_edit_raingage where rgage_type='TIMESERIES' AND timser_id IS NULL;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '286', concat('ERROR-286: There is/are ',v_count,' raingage(s) with null values on the mandatory column for ''TIMESERIES'' raingage type.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '286', concat('INFO: Mandatory colums for ''TIMESERIES'' raingage type have been checked without any values missed.'),v_count);
	END IF;		

	SELECT count(*) INTO v_count FROM v_edit_raingage where rgage_type='FILE' AND (fname IS NULL or sta IS NULL or units IS NULL);
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '287', concat('ERROR-287: There is/are ',v_count,
		' raingage(s) with null values at least on mandatory columns for ''FILE'' raingage type (fname, sta, units).'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '287', concat('INFO: Mandatory colums (fname, sta, units) for ''FILE'' raingage type have been checked without any values missed.'),v_count);
	END IF;	

	RAISE NOTICE '10 - Inconsistency on inp node tables (294)';
	INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom)
		SELECT 294, n.node_id, n.nodecat_id, concat(epa_type, ' using inp_junction table') AS epa_table, n.the_geom FROM v_edit_inp_junction JOIN node n USING (node_id) WHERE epa_type !='JUNCTION'
		UNION
		SELECT 294, n.node_id, n.nodecat_id,  concat(epa_type, ' using inp_storage table') AS epa_table, n.the_geom FROM v_edit_inp_storage JOIN node n USING (node_id) WHERE epa_type !='STORAGE'
		UNION
		SELECT 294, n.node_id, n.nodecat_id,  concat(epa_type, ' using inp_outfall table') AS epa_table, n.the_geom FROM v_edit_inp_outfall JOIN node n USING (node_id) WHERE epa_type !='OUTFALL'
		UNION
		SELECT 294, n.node_id, n.nodecat_id,  concat(epa_type, ' using inp_divider table') AS epa_table, n.the_geom FROM v_edit_inp_divider JOIN node n USING (node_id) WHERE epa_type !='DIVIDER';

		
	SELECT count(*) FROM temp_anl_node INTO v_count WHERE fid=294 AND cur_user=current_user;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '294',concat(
		'ERROR-294 (anl_node): There is/are ',v_count,' node features with epa_type not according with epa table. Check your data before continue'), v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '294','INFO: Epa type for node features checked. No inconsistencies aganints epa table found.', v_count);
	END IF;	

	RAISE NOTICE '11 - Inconsistency on inp arc tables (295)';
	INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom)
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_pump table') AS epa_table, a.the_geom FROM v_edit_inp_pump JOIN arc a USING (arc_id) WHERE epa_type !='PUMP'
		UNION
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_conduit table') AS epa_table, a.the_geom FROM v_edit_inp_conduit JOIN arc a USING (arc_id) WHERE epa_type !='CONDUIT'
		UNION
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_outlet table') AS epa_table, a.the_geom FROM v_edit_inp_outlet JOIN arc a USING (arc_id) WHERE epa_type !='OUTLET'
		UNION
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_orifice table') AS epa_table, a.the_geom FROM v_edit_inp_orifice JOIN arc a USING (arc_id) WHERE epa_type !='ORIFICE'
		UNION
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_weir table') AS epa_table, a.the_geom FROM v_edit_inp_weir JOIN arc a USING (arc_id) WHERE epa_type !='WEIR'
		UNION
		SELECT 295, a.arc_id, a.arccat_id, concat(epa_type, ' using inp_virtual table') AS epa_table, a.the_geom FROM v_edit_inp_virtual JOIN arc a USING (arc_id) WHERE epa_type !='VIRTUAL';

		
	SELECT count(*) FROM temp_anl_arc INTO v_count WHERE fid=295 AND cur_user=current_user;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '295',concat(
		'ERROR-295 (anl_arc): There is/are ',v_count,' arc features with epa_type not according with epa table. Check your data before continue'), v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '295','INFO: Epa type for arc features checked. No inconsistencies aganints epa table found.', v_count);
	END IF;	


	RAISE NOTICE '12 - Topological nodes with epa_type UNDEFINED (379)';
	v_querytext = 'SELECT n.node_id, nodecat_id, the_geom, n.expl_id FROM (SELECT node_1 node_id, sector_id FROM v_edit_arc WHERE epa_type !=''UNDEFINED'' UNION 
			   SELECT node_2, sector_id FROM v_edit_arc WHERE epa_type !=''UNDEFINED'' )a 
		       LEFT JOIN  (SELECT node_id, nodecat_id, the_geom, expl_id FROM v_edit_node WHERE epa_type = ''UNDEFINED'') n USING (node_id) 
		       JOIN selector_sector USING (sector_id) 
		       WHERE n.node_id IS NOT NULL AND cur_user = current_user';
	
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id) SELECT 379, node_id, nodecat_id, 
		''Topological node with epa_type UNDEFINED'', the_geom, expl_id FROM (', v_querytext,')a');
		INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '379' ,concat('WARNING-379 (anl_node): There is/are ',v_count,' node(s) with epa_type UNDEFINED acting as node_1 or node_2 of arcs. Please, check your data before continue.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
	VALUES (v_fid, 1, '379','INFO: No nodes with epa_type UNDEFINED acting as node_1 or node_2 of arcs found.',v_count);
	END IF;
	

	RAISE NOTICE '13- y0 on storage data (381)';
	SELECT count(*) INTO v_count FROM v_edit_inp_storage where (y0 is null);
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '381', concat('ERROR-381: There is/are ',v_count,
		' storages) with null values at least on mandatory columns for initial status (y0).'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '381', concat('INFO: No y0 column without values for storages.'),v_count);
	END IF;		


	RAISE NOTICE '14- Volume dimensions for storage data (382)';
	SELECT count(*) INTO v_count FROM v_edit_inp_storage where (a1 is null and a2 is null and a0 is null AND storage_type='FUNCTIONAL') OR (curve_id IS NULL AND storage_type='TABULAR');
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '382', concat('ERROR-382: There is/are ',v_count,
		' storage(s) with null values at least on mandatory columns to define volume parameters (a1,a2,a0 for FUNCTIONAL or curve_id for TABULAR).'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '382', concat('INFO: Mandatory colums for volume values used on storage type have been checked without any values missed.'),v_count);
	END IF;		

	RAISE NOTICE '15- Manning values for cat_mat_arc';
	SELECT COUNT(DISTINCT cat_mat_arc.*)  INTO v_count FROM cat_mat_arc JOIN v_edit_arc ON matcat_id = id where sys_type !='VARC' AND n is null;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '383', concat('ERROR-383: There is/are ',v_count,
		' material(s) with null values on manning coefficient column used on a real arc wich manning is needed.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '383', concat('INFO: Manning coefficient on cat_mat_arc is filled for those materials used on real arcs (not varcs).'),v_count);
	END IF;	

	
	RAISE NOTICE '16- Duplicated nodes';

	v_querytext = 'SELECT * FROM (
		SELECT DISTINCT t1.node_id, t1.nodecat_id, t1.state as state1, t2.node_id, t2.nodecat_id, t2.state as state2, t1.expl_id, 106, t1.the_geom
		FROM selector_sector s, node AS t1 
		JOIN node AS t2 ON ST_Dwithin(t1.the_geom, t2.the_geom,('||v_nodetolerance||')) 
		JOIN v_state_node v1 ON t2.node_id = v1.node_id
		JOIN v_state_node v2 ON t1.node_id = v2.node_id
		WHERE t1.node_id != t2.node_id 
		AND s.sector_id = t1.sector_id AND cur_user = current_user 
		ORDER BY t1.node_id ) a where a.state1 > 0 AND a.state2 > 0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 2, '106' ,concat('WARNING-106 (anl_node): There is/are ',v_count,' nodes with less proximity than minimum configured (',v_nodetolerance,').'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '106','INFO: All nodes has the minimum distance among them acording with the configured value ',v_count);
	END IF;
	
	RAISE NOTICE '18 - Check EPA OBJECTS (curves, patterns, timeseries, lids, polluntats and snowpacks) have not spaces on names (fid: 429)';
	SELECT count(*) INTO v_count FROM inp_curve WHERE id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' curve(s) has/have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All curves checked have names without spaces.'),v_count);
	END IF;

	SELECT count(*) INTO v_count FROM inp_pattern WHERE pattern_id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' pattern(s) have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity,table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All patterns checked have names without spaces.'),v_count);
	END IF;

	SELECT count(*) INTO v_count FROM inp_timeseries WHERE id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' timeseries have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity,table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All timeseries checked have names without spaces.'),v_count);
	END IF;

	SELECT count(*) INTO v_count FROM inp_lid WHERE lidco_id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' lid(s) have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity,table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All lids checked have names without spaces.'),v_count);
	END IF;

	SELECT count(*) INTO v_count FROM inp_pollutant WHERE poll_id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' pollutant(s) have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity,table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All pollutants checked have names without spaces.'),v_count);
	END IF;

	SELECT count(*) INTO v_count FROM inp_snowpack WHERE snow_id like'% %';
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '429',concat('ERROR-429: ',v_count,' snowpack(s) have name with spaces. Please fix it!'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity,table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 1, '429', concat('INFO: All snowpacks checked have names without spaces.'),v_count);
	END IF;

	RAISE NOTICE '19 - Check flow regulator length fits on destination arc (427)';

	v_querytext = 'SELECT 427, nodarc_id, ''Orifice flow regulator length do not respect the minimum length for target arc'', f.the_geom FROM selector_sector s, v_edit_inp_flwreg_orifice f
			JOIN node n USING (node_id) JOIN arc a ON a.arc_id = to_arc 
			WHERE n.sector_id = s.sector_id AND cur_user=current_user AND flwreg_length + '||v_minlength||' > st_length(a.the_geom)';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) '||v_querytext;
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-427 (anl_arc): There is/are ',v_count,' orifice flow regulator(s) wich his length do not respect the minimum length for target arc.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All orifice flow regulators has lengh wich fits target arc.', v_count);
	END IF;	

	v_querytext = 'SELECT 427, nodarc_id, ''Weir flow regulator length do not respect the minimum length for target arc'', f.the_geom FROM selector_sector s, v_edit_inp_flwreg_weir f
			JOIN node n USING (node_id) JOIN arc a ON a.arc_id = to_arc 
			WHERE n.sector_id = s.sector_id AND cur_user=current_user AND flwreg_length + '||v_minlength||' > st_length(a.the_geom)';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) '||v_querytext;
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-427 (anl_arc): There is/are ',v_count,' weir flow regulator(s) wich his length do not respect the minimum length for target arc.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All weir flow regulators has lengh wich fits target arc.',v_count);
	END IF;	

	v_querytext = 'SELECT 427, nodarc_id, ''Outlet flow regulator length do not respect the minimum length for target arc'', f.the_geom FROM selector_sector s, v_edit_inp_flwreg_pump f
			JOIN node n USING (node_id) JOIN arc a ON a.arc_id = to_arc 
			WHERE n.sector_id = s.sector_id AND cur_user=current_user AND flwreg_length + '||v_minlength||' > st_length(a.the_geom)';


	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) '||v_querytext;
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-427 (anl_arc): There is/are ',v_count,' outlet flow regulator(s) wich his length do not respect the minimum length for target arc.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All outlet flow regulators has lengh wich fits target arc.', v_count);
	END IF;	

	v_querytext = 'SELECT 427, nodarc_id, ''Pump flow regulator length do not respect the minimum length for target arc'', f.the_geom FROM selector_sector s, v_edit_inp_flwreg_outlet f
			JOIN node n USING (node_id) JOIN arc a ON a.arc_id = to_arc 
			WHERE n.sector_id = s.sector_id AND cur_user=current_user AND flwreg_length + '||v_minlength||' > st_length(a.the_geom)';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) '||v_querytext;
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-427 (anl_arc): There is/are ',v_count,' pump flow regulator(s) wich his length do not respect the minimum length for target arc.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All pump flow regulators has lengh wich fits target arc.',v_count);
	END IF;	

	RAISE NOTICE '20 - Check valid relative timeseries(459)';
	SELECT count(*) INTO v_count FROM 
	(SELECT id, timser_id, case when time is not null then time end as time FROM v_edit_inp_timeseries_value) a JOIN
	(SELECT id-1 as id, timser_id, case when time is not null then time end as time FROM v_edit_inp_timeseries_value)b USING (id)
	where a.time::time - b.time::time > '0 seconds' AND a.timser_id = b.timser_id;
	
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-459: There is/are ',v_count,' columns on relative timeserires related to this exploitation with errors. '),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All relative timeseries related ot this exploitation are correctly defined.',v_count);
	END IF;	


	RAISE NOTICE '21 - Check matcat not null on arc (430)';
	SELECT count(*) INTO v_count FROM v_edit_arc a, selector_sector s WHERE a.sector_id = s.sector_id and cur_user=current_user 
	AND matcat_id IS NULL AND sys_type !='VARC';
	
	IF v_count > 0 THEN

		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) SELECT 430, arc_id, ''Arc without material'', the_geom 
		FROM v_edit_arc a, selector_sector s WHERE a.sector_id = s.sector_id and cur_user=current_user 
		AND matcat_id IS NULL AND sys_type !=''VARC'''; 

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-430: There is/are ',v_count,' arcs without matcat_id informed.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All arcs have matcat_id filled.',v_count);
	END IF;	

	RAISE NOTICE '22 - Check outlet_id assigned to subcatchments (440)';
	v_querytext = 'WITH query AS (SELECT * FROM (SELECT 440 as fid, subc_id, outlet_id, st_centroid(the_geom) from v_edit_inp_subcatchment where left(outlet_id::text, 1) != ''{''::text 
	UNION
	SELECT 440, subc_id, unnest(outlet_id::text[]), st_centroid(the_geom) from v_edit_inp_subcatchment where left(outlet_id::text, 1) = ''{''::text
	)a
	WHERE outlet_id not in 
	(select node_id FROM v_edit_inp_junction UNION select node_id FROM v_edit_inp_outfall UNION
	select node_id FROM v_edit_inp_storage UNION select node_id FROM v_edit_inp_divider UNION
	select subc_id FROM v_edit_inp_subcatchment))
	SELECT q1.* FROM query q1 
	LEFT JOIN 
	(SELECT * FROM (
	SELECT 440, subc_id, outlet_id, the_geom from v_edit_inp_subcatchment where left(outlet_id::text, 1) != ''{''::text 
	UNION
	SELECT 440, subc_id, unnest(outlet_id::text[]), the_geom AS outlet_id from v_edit_inp_subcatchment where left(outlet_id::text, 1) = ''{''::text)a)b
	USING (outlet_id)
	WHERE b.subc_id IS NULL';

	EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a'
	INTO v_count;

	IF v_count > 0 THEN
	
		EXECUTE 'INSERT INTO temp_anl_node (fid, descript, node_id, the_geom) SELECT * FROM ('||v_querytext||')a';
			
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, '427',concat(
		'ERROR-440 (anl_node): There is/are ',v_count,' outlets defined on subcatchments view, that are not present on junction, outfall, storage, divider or subcatchment view.'),v_count);
		v_count=0;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, table_id, error_message, fcount)
		VALUES (v_fid, v_result_id , 1,  '427','INFO: All outlets set on subcatchments are correctly defined.',v_count);
	END IF;	

	RAISE NOTICE '24 - Check percentage of arcs with custom_length values';
	SELECT count(*) FROM v_edit_arc into v_count;

	IF v_count>0 then
		WITH cust_len AS (SELECT count(*) FROM v_edit_arc WHERE custom_length IS NOT NULL), arcs AS (SELECT count(*) FROM v_edit_arc)
		SELECT cust_len.count::numeric / arcs.count::numeric *100 INTO v_count FROM arcs, cust_len;
	
		IF v_count > (SELECT json_extract_path_text(value::json,'customLength','maxPercent')::NUMERIC FROM config_param_system WHERE parameter = 'epa_outlayer_values') THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, '482', 2, concat('WARNING-482: Over ',round(v_count::numeric,2),' percent of arcs have value on custom_length.'),round(v_count::numeric,2));
		ELSIF v_count=0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, '482', 1, 'INFO: No arcs have value on custom_length.',round(v_count::numeric,2));
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, '482', 1, concat('INFO: Less then ',round(v_count::numeric,2),' percent of arcs have value on custom_length.'),round(v_count::numeric,2));
		END IF;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '482', 1, 'INFO: No arcs have value on custom_length.',round(v_count::numeric,2));
	END IF;
	v_count=0;

	RAISE NOTICE '25 - Check shape with null values on arc catalog';
	SELECT count(*) INTO v_count FROM cat_arc WHERE shape is null;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '482', 3, concat('ERROR-482: There is/are ',v_count,' rows on arc catalog without values on shape column.'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '482', 1, 'INFO: No rows on arc catalog without values on shape column.', v_count);
	END IF;
	v_count=0;
	
	RAISE NOTICE '26 - Check geom1 with null values on arc catalog';
	SELECT count(*) INTO v_count FROM cat_arc WHERE geom1 is null;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '482', 3, concat('ERROR-482: There is/are ',v_count,' rows on arc catalog without values on geom1 column.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '482', 1, 'INFO: No rows on arc catalog without values on geom1 column.', v_count);
	END IF;
	v_count=0;

	RAISE NOTICE '27 - Check if outfalls have more than 1 connected arc';
	select count(*) into v_count 
	from (select node_2 from v_edit_inp_conduit a join v_edit_inp_outfall n on node_2 = node_id group by node_2 having count(*) > 1)a;   
	
	IF v_count>0 then
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '522', 3, concat('ERROR-522: There is/are ',v_count,' outfalls with more than 1 arc connected.'),v_count);
		
		EXECUTE 'INSERT INTO temp_anl_node (fid, node_id, descript, the_geom, expl_id, nodecat_id) 
		select 522, node.node_id, ''Outfall with more than 1 arc'', node.the_geom, node.expl_id, node.nodecat_id 
		from node, arc where node.epa_type=''OUTFALL'' and st_dwithin(node.the_geom, arc.the_geom, 0.01) 
		group by node.node_id having count(node.node_id)>1';
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '522', 1, 'INFO: All outlets have a valid number of connected arcs.',v_count);
	END IF;
	v_count=0;

	RAISE NOTICE '528 - Check if outlet_id exists in v_edit_junction (if outlet_id is a node) or in v_edit_inp_subcatchment (if outlet_id is a subcathment)';
	
	v_querytext = '(select outlet_id from v_edit_inp_subc2outlet
			LEFT JOIN (
			select node_id from v_edit_inp_junction 
			UNION select node_id from v_edit_inp_outfall
			UNION select node_id from v_edit_inp_storage 
			UNION select node_id from v_edit_inp_netgully
			) a on outlet_id = node_id
			where outlet_type in (''JUNCTION'') and node_id is null
			union
			select a.outlet_id from v_edit_inp_subc2outlet a LEFT JOIN v_edit_inp_subcatchment s on a.outlet_id = s.subc_id
			where outlet_type = ''SUBCATCHMENT'' and s.subc_id is null)';
	
	EXECUTE concat('SELECT count(*) FROM ',v_querytext, 'a') INTO v_count;
	
	IF v_count>0 then
		EXECUTE concat ('INSERT INTO temp_anl_polygon (fid, pol_id, descript, the_geom) 
		SELECT 528, subc_id, ''Non-existing outlet_id related to subcatchment'', the_geom from v_edit_inp_subcatchment where outlet_id in ', v_querytext);
		
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '528', 3, concat('ERROR-528 (anl_node): There is/are ',v_count,' non-existing node_id or subc_id as an outlet_id.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '528', 1, 'INFO: All subcatchments have an existing outlet_id',v_count);
	END IF;
	v_count=0;
	
	RAISE NOTICE '529 - Check null values on inp_weir';
	v_querytext='(select arc_id, weir_type, cd, geom1, geom2, offsetval from v_edit_inp_weir 
	where weir_type is null or cd is null or geom1 is null or geom2 is null or offsetval is null)';

	execute concat('select count(*) from ', v_querytext, 'a') into v_count;
	
	IF v_count>0 then 
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) 
		SELECT 529, arc_id, ''Missing values on some data of Inp Weir (weir_type, cd, geom1, geom2, offsetval)'', the_geom from v_edit_inp_weir 
		where weir_type is null or cd is null or geom1 is null or geom2 is null or offsetval is null';
		
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '529', 3, concat('ERROR-529: There is/are ',v_count,' null values on table Inp Weir (weir_type, cd, geom1, geom2, offsetval)'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '529', 1, 'INFO: No missing data on Inp Weir.', v_count);
	END IF;
	v_count=0;
	
	
	RAISE NOTICE '530 - Check null values on inp_orifice';
	v_querytext='(select ori_type, geom1, offsetval from v_edit_inp_orifice
	where ori_type is null or geom1 is null or offsetval is null)';

	execute concat('select count(*) from ', v_querytext, 'a') into v_count;
	
	IF v_count>0 then 
	
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, descript, the_geom) 
		SELECT 530, arc_id, ''Missing values on some data of Inp Orifice (ori_type, geom1, offsetval)'', the_geom from v_edit_inp_orifice
		where ori_type is null or geom1 is null or offsetval is null';
	
	
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '530', 3, concat('ERROR-530: There is/are ',v_count,' null values on table Inp Orifice (ori_type, geom1, offsetval)'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '530', 1, 'INFO: No missing data on Inp Orifice.', v_count);
	END IF;
	v_count=0;

	IF v_result_id IS NULL THEN
		UPDATE temp_audit_check_data SET result_id = table_id WHERE cur_user="current_user"() AND fid=v_fid AND result_id IS NULL;
		UPDATE temp_audit_check_data SET table_id = NULL WHERE cur_user="current_user"() AND fid=v_fid; 
	END IF;
	
	-- Removing isaudit false sys_fprocess
	FOR v_record IN SELECT * FROM sys_fprocess WHERE isaudit is false
	LOOP
		-- remove anl tables
		DELETE FROM temp_anl_node WHERE fid = v_record.fid AND cur_user = current_user;
		DELETE FROM temp_anl_arc WHERE fid = v_record.fid AND cur_user = current_user;
		DELETE FROM temp_audit_check_data WHERE result_id::text = v_record.fid::text AND cur_user = current_user;
	END LOOP;

	-- insert spacers for log
	INSERT INTO temp_audit_check_data (fid, criticity, error_message) VALUES (v_fid, 4, '');
	INSERT INTO temp_audit_check_data (fid, criticity, error_message) VALUES (v_fid, 3, '');
	INSERT INTO temp_audit_check_data (fid, criticity, error_message) VALUES (v_fid, 2, '');
	INSERT INTO temp_audit_check_data (fid, criticity, error_message) VALUES (v_fid, 1, ''); 

	-- 101 - checkproject
	-- 127 - go2epa main
	-- 225 - triggered alone
	
	IF v_fid = 225 THEN
			
		DELETE FROM anl_arc WHERE fid =225 AND cur_user=current_user;
		DELETE FROM anl_node WHERE fid =225 AND cur_user=current_user;
		DELETE FROM audit_check_data WHERE fid =225 AND cur_user=current_user;

		INSERT INTO anl_arc SELECT * FROM temp_anl_arc;
		INSERT INTO anl_node SELECT * FROM temp_anl_node;
		INSERT INTO audit_check_data SELECT * FROM temp_audit_check_data;
		INSERT INTO anl_polygon SELECT * FROM temp_anl_polygon;

	ELSIF  v_fid = 101 THEN 
		UPDATE temp_audit_check_data SET fid = 225;

		INSERT INTO project_temp_anl_arc SELECT * FROM temp_anl_arc;
		INSERT INTO project_temp_anl_node SELECT * FROM temp_anl_node;
		INSERT INTO project_temp_audit_check_data SELECT * FROM temp_audit_check_data;
	END IF;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT error_message as message FROM temp_audit_check_data WHERE cur_user="current_user"() 
	AND fid=225 order by criticity desc, id asc) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
	
	--points
	v_result = null;

	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
	 'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom'
	) AS feature
	FROM (SELECT node_id, nodecat_id, state, expl_id, descript,fid, the_geom
	FROM  temp_anl_node WHERE cur_user="current_user"() AND fid IN (106, 107, 111, 113, 164, 187, 294, 379)) row) features;
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point",  "features":',v_result, '}'); 

	--lines
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
	'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom'
	) AS feature
	FROM (SELECT arc_id, arccat_id, state, expl_id, descript, the_geom, fid
	FROM  temp_anl_arc WHERE cur_user="current_user"() AND fid IN (188, 284, 295, 427,430, 522, 529, 530)) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "features":',v_result,'}'); 

	-- polygon
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	SELECT jsonb_build_object(
	'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom'
	) AS feature
	FROM (SELECT pol_id, pol_type, state, expl_id, descript, the_geom, fid
	FROM  temp_anl_polygon WHERE cur_user="current_user"() AND fid IN (528)) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_polygon = concat ('{"geometryType":"Polygon", "features":',v_result, '}');

	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 
	v_result_polygon := COALESCE(v_result_polygon, '{}'); 

	--drop temp tables 
	IF v_fid IN (101,225) THEN
		DROP TABLE IF EXISTS temp_anl_arc;
		DROP TABLE IF EXISTS temp_anl_node ;
		DROP TABLE IF EXISTS temp_audit_check_data;
		DROP TABLE IF EXISTS temp_anl_polygon;
	END IF;

	--  Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
		',"body":{"form":{}'||
			',"data":{"info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||
				'}'||
			'}'||
		'}')::json, 2431, null, null, null);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;