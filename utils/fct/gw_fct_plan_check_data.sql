/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2436


DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_plan_audit_check_data(integer);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_plan_check_data(p_data json)  
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_plan_check_data($${}$$)

SELECT * FROM anl_arc WHERE fid=115 AND cur_user=current_user;
SELECT * FROM anl_node WHERE fid=115 AND cur_user=current_user;

-- fid: 115

*/

DECLARE 
v_project_type 	text;
v_table_count integer;
v_count integer;
v_global_count	integer;
v_return integer;
v_version text;	
v_result json;
v_result_info json;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_saveondatabase boolean;
v_error_context text;
v_query text;

BEGIN 

	-- init function
	SET search_path="SCHEMA_NAME", public;
	v_return:=0;
	v_global_count:=0;

	SELECT project_type, giswater  INTO v_project_type, v_version FROM sys_version order by 1 desc limit 1;

	-- getting input data 	
	
	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fid=115 AND cur_user=current_user;
	DELETE FROM anl_arc WHERE fid=115 AND cur_user=current_user;
	DELETE FROM anl_node WHERE fid=115 AND cur_user=current_user;

	-- Starting process
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 4, concat('DATA QUALITY ANALYSIS ACORDING PLAN-PRICE RULES'));
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 4, '-------------------------------------------------------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 3, 'CRITICAL ERRORS');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 3, '----------------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 2, 'WARNINGS');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 2, '--------------');

	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 1, 'INFO');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (115, null, 1, '-------');

	--arc catalog
	SELECT count(*) INTO v_table_count FROM cat_arc WHERE active=TRUE;

	--active column
	SELECT count(*) INTO v_count FROM cat_arc WHERE active IS NULL;
	IF v_count>0 THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled, error_message)
		VALUES (115, null, 'cat_arc', 'active', 3, FALSE, concat('ERROR: There are ',v_count,' row(s) without values on cat_arc.active column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_arc.active column.');
	END IF;

	--cost column
	SELECT count(*) INTO v_count FROM cat_arc WHERE cost IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_arc', 'cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_arc.cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_arc.cost column.');
	END IF;

	--m2bottom_cost column
	SELECT count(*) INTO v_count FROM cat_arc WHERE m2bottom_cost IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_arc', 'm2bottom_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_arc.m2bottom_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_arc.m2bottom_cost column.');
	END IF;

	--m3protec_cost column
	SELECT count(*) INTO v_count FROM cat_arc WHERE m3protec_cost IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_arc', 'm3protec_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_arc.m3protec_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_arc.m3protec_cost column.');
	END IF;
	
	--node catalog
	SELECT count(*) INTO v_table_count FROM cat_node WHERE active=TRUE;

	--active column
	SELECT count(*) INTO v_count FROM cat_node WHERE active IS NULL;
	IF v_count>0 THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_node', 'active', 3, FALSE, concat('ERROR: There are ',v_count,' row(s) without values on cat_node.active column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_node.active column.');
	END IF;

	--cost column
	SELECT count(*) INTO v_count FROM cat_node WHERE cost IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_node', 'cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_node.cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) row(s) without values on cat_node.cost column.');
	END IF;

	--cost_unit column
	SELECT count(*) INTO v_count FROM cat_node WHERE cost_unit IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_node', 'cost_unit', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_node.cost_unit column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_node.cost_unit column.');
	END IF;
	
	IF v_project_type='WS' THEN 
		--estimated_depth column
		SELECT count(*) INTO v_count FROM cat_node WHERE estimated_depth IS NOT NULL and active=TRUE;
		IF v_table_count>v_count THEN
			INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
			VALUES (115, null, 'cat_node', 'estimated_depth', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_node.estimated_depth column.'));
		ELSE
			INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
			VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_node.estimated_depth column.');
		END IF;

	ELSIF v_project_type='UD' THEN 
		--estimated_y column
		SELECT count(*) INTO v_count FROM cat_node WHERE estimated_y IS NOT NULL and active=TRUE;
		IF v_table_count>v_count THEN
			INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
			VALUES (115, null, 'cat_node', 'estimated_y', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_node.estimated_y column.'));
		ELSE
			INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
			VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_node.estimated_y column.');
		END IF;
	END IF;

	--connec catalog
	SELECT count(*) INTO v_table_count FROM cat_connec WHERE active=TRUE;

	--active column
	SELECT count(*) INTO v_count FROM cat_connec WHERE active IS NULL;
	IF v_count>0 THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_connec', 'active', 3, FALSE, concat('ERROR: There are ',v_count,' row(s) without values on cat_connec.active column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_connec.active column column.');
	END IF;

	--cost_ut column
	SELECT count(*) INTO v_count FROM cat_connec WHERE cost_ut IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_connec', 'cost_ut', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_connec.cost_ut column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_connec.cost_ut column.');
	END IF;

	--cost_ml column
	SELECT count(*) INTO v_count FROM cat_connec WHERE cost_ml IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_connec', 'cost_ml', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_connec.cost_ml column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_connec.cost_ml column.');
	END IF;

	--cost_m3 column
	SELECT count(*) INTO v_count FROM cat_connec WHERE cost_m3 IS NOT NULL and active=TRUE;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_connec', 'cost_m3', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_connec.cost_m3 column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_connec.cost_m3 column.');
	END IF;

	--pavement catalog
	SELECT count(*) INTO v_table_count FROM cat_pavement;

	--thickness column
	SELECT count(*) INTO v_count FROM cat_pavement WHERE thickness IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_pavement', 'thickness', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_pavement.thickness column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_pavement.thickness column.');
	END IF;

	--m2cost column
	SELECT count(*) INTO v_count FROM cat_pavement WHERE m2_cost IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_pavement', 'm2_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_pavement.m2_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_pavement.m2_cost column.');
	END IF;

	--soil catalog
	SELECT count(*) INTO v_table_count FROM cat_soil ;

	--y_param column
	SELECT count(*) INTO v_count FROM cat_soil WHERE y_param IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'y_param', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.y_param column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.y_param column.');
	END IF;

	--b column
	SELECT count(*) INTO v_count FROM cat_soil WHERE b IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'b', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.b column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.b column.');
	END IF;

	--m3exc_cost column
	SELECT count(*) INTO v_count FROM cat_soil WHERE m3exc_cost IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'm3exc_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.m3exc_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.m3exc_cost column.');
	END IF;

	--m3fill_cost column
	SELECT count(*) INTO v_count FROM cat_soil WHERE m3fill_cost IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'm3fill_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.m3fill_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.m3fill_cost column.');
	END IF;

	--m3excess_cost column
	SELECT count(*) INTO v_count FROM cat_soil WHERE m3excess_cost IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'm3excess_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.m3excess_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.m3excess_cost column.');
	END IF;

	--m2trenchl_cost column
	SELECT count(*) INTO v_count FROM cat_soil WHERE m2trenchl_cost IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'cat_soil', 'm2trenchl_cost', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_soil.m2trenchl_cost column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_soil.m2trenchl_cost column.');
	END IF;

	IF v_project_type='UD' THEN

		--grate catalog
		SELECT count(*) INTO v_table_count FROM cat_grate WHERE active=TRUE;

		--active column
		SELECT count(*) INTO v_count FROM cat_grate WHERE active IS NULL;
		IF v_count>0 THEN
			INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
			VALUES (115, null, 'cat_grate', 'active', 3, FALSE, concat('ERROR: There are ',v_count,' row(s) without values on cat_grate.active column.'));
		ELSE
			INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
			VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_grate.active column.');
		END IF;


		--cost_ut column
		SELECT count(*) INTO v_count FROM cat_grate WHERE cost_ut IS NOT NULL and active=TRUE;
		IF v_table_count>v_count THEN
			INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
			VALUES (115, null, 'cat_grate', 'cost_ut', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on cat_grate.cost_ut column.'));
		ELSE
			INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
			VALUES (115, null, 1,'INFO: There is/are no row(s) without values on cat_grate.cost_ut column.');
		END IF;
	
	END IF;	

	--table plan_arc_x_pavement
	SELECT count(*) INTO v_table_count FROM arc WHERE state>0;

	--rows number
	SELECT count(*) INTO v_count FROM plan_arc_x_pavement;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'plan_arc_x_pavement', 'rows number', 1, FALSE, 'INFO: The number of rows of row(s) of the plan_arc_x_pavement table is less than the arc table.');
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: The number of rows of row(s) of the plan_arc_x_pavement table is same than the arc table.');
	END IF;

	--pavcat_id column
	SELECT count(*) INTO v_table_count FROM plan_arc_x_pavement;
	SELECT count(*) INTO v_count FROM plan_arc_x_pavement WHERE pavcat_id IS NOT NULL;
	IF v_table_count>v_count THEN
		INSERT INTO audit_check_data (fid, result_id, table_id, column_id, criticity, enabled,  error_message)
		VALUES (115, null, 'plan_arc_x_pavement', 'pavcat_id', 2, FALSE, concat('WARNING: There are ',(v_table_count-v_count),' row(s) without values on plan_arc_x_pavement.pavcat_id column.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, null, 1,'INFO: There is/are no row(s) without values on row(s) without values on plan_arc_x_pavement.pavcat_id column.');
	END IF;

	--check if features with state = 2 are related to any psector (252)
	IF v_project_type = 'WS' THEN
		v_query = 'SELECT a.feature_id, a.feature, a.catalog, a.the_geom, count(*) FROM (
		SELECT node_id as feature_id, ''NODE'' as feature, nodecat_id as catalog, the_geom FROM node WHERE state=2 AND node_id NOT IN (select node_id FROM plan_psector_x_node) UNION
		SELECT arc_id as feature_id, ''ARC'' as feature, arccat_id as catalog, the_geom  FROM arc WHERE state=2 AND arc_id NOT IN (select arc_id FROM plan_psector_x_arc) UNION
		SELECT connec_id as feature_id, ''CONNEC'' as feature, connecat_id  as catalog, the_geom  FROM connec WHERE state=2 AND connec_id NOT IN (select connec_id FROM plan_psector_x_connec)) a 
		GROUP BY a.feature_id, a.feature , a.catalog, a.the_geom';

	ELSE	
		v_query = 'SELECT a.feature_id, a.feature , a.catalog, a.the_geom, count(*) FROM (
		SELECT node_id as feature_id, ''NODE'' as feature, nodecat_id as catalog, the_geom FROM node WHERE state=2 AND node_id NOT IN (select node_id FROM plan_psector_x_node) UNION
		SELECT arc_id as feature_id, ''ARC'' as feature, arccat_id as catalog, the_geom  FROM arc WHERE state=2 AND arc_id NOT IN (select arc_id FROM plan_psector_x_arc) UNION
		SELECT connec_id as feature_id, ''CONNEC'' as feature, connecat_id  as catalog, the_geom  FROM connec WHERE state=2 AND connec_id NOT IN (select connec_id FROM plan_psector_x_connec) UNION
		SELECT gully_id as feature_id, ''GULLY'' as feature , gratecat_id as catalog, the_geom FROM gully WHERE state=2 AND gully_id NOT IN (select gully_id FROM plan_psector_x_gully)) a 
		GROUP BY a.feature_id, a.feature ,a.catalog, a.the_geom';
	END IF;

		EXECUTE 'SELECT count(*) FROM ('||v_query||')b'
		INTO v_count; 

	IF v_count > 0 THEN
		EXECUTE 'SELECT count(*) FROM ('||v_query||')b WHERE feature = ''ARC'';'
		INTO v_count; 
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_arc (fid, arc_id, arccat_id, descript, the_geom,state)
			SELECT 252, b.feature_id, b.catalog, ''Arcs state = 2 without psector'', b.the_geom, 2 FROM (', v_query,')b  WHERE feature = ''ARC''');
			INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
			VALUES (115, '252', 3, FALSE, concat('ERROR-252: There are ',v_count,' planified arcs without psector.'));
		END IF;
		EXECUTE 'SELECT count(*) FROM ('||v_query||')b WHERE feature = ''NODE'';'
		INTO v_count; 
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_node (fid, node_id, nodecat_id, descript, the_geom, state)
			SELECT 252, b.feature_id, b.catalog, ''Nodes state = 2 without psector'', b.the_geom, 2 FROM (', v_query,')b  WHERE feature = ''NODE''');
			INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
			VALUES (115, '252', 3, FALSE, concat('ERROR-252: There are ',v_count,' planified node without psector.'));		END IF;
		EXECUTE 'SELECT count(*) FROM ('||v_query||')b WHERE feature = ''CONNEC'';'
		INTO v_count; 
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_connec (fid, connec_id, connecat_id, descript, the_geom,state)
			SELECT 252, b.feature_id, b.catalog, ''Connecs state = 2 without psector'', b.the_geom,2 FROM (', v_query,')b  WHERE feature = ''CONNEC''');
			INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
			VALUES (115, '252', 3, FALSE, concat('ERROR-252: There are ',v_count,' planified connec without psector.'));		END IF;
		EXECUTE 'SELECT count(*) FROM ('||v_query||')b WHERE feature = ''GULLY'';'
		INTO v_count; 
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_gully (fid, gully_id, gullycat_id, descript, the_geom, state)
			SELECT 252, b.feature_id, b.catalog, ''Gullies state = 2 without psector'', b.the_geom, 2 FROM (', v_query,')b  WHERE feature = ''GULLY''');
			INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
			VALUES (115, '252', 3, FALSE, concat('ERROR-252: There are ',v_count,' planified gully without psector.'));		END IF;
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, '252', 1,'INFO: There are no features with state=2 without psector.');
	END IF;

	--check if arcs with state = 2 have final nodes state = 2 in the psector (354)
	v_query =  'SELECT * FROM
	(SELECT pa.arc_id, a.arccat_id, pa.psector_id , node_1 as node, a.the_geom FROM plan_psector_x_arc pa JOIN arc a USING (arc_id)
		JOIN node n ON node_id = node_1 where n.state = 2 AND a.state=2
	EXCEPT
	SELECT pa.arc_id, arc.arccat_id, pa.psector_id , node_1 as node,  arc.the_geom FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
		JOIN plan_psector_x_node pn1 ON pn1.node_id = arc.node_1
		WHERE pa.psector_id = pn1.psector_id and pa.state = 1 AND pn1.state = 1)a
	UNION
	SELECT * FROM
	(SELECT pa.arc_id, a.arccat_id, pa.psector_id , node_2 as node,  a.the_geom FROM plan_psector_x_arc pa JOIN arc a USING (arc_id)
		JOIN node n ON node_id = node_2 where n.state = 2 AND a.state=2
	EXCEPT
	SELECT pa.arc_id, arc.arccat_id, pa.psector_id , node_2 as node,  arc.the_geom FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
		JOIN plan_psector_x_node pn2 ON pn2.node_id = arc.node_2
		WHERE pa.psector_id = pn2.psector_id AND pa.state = 1 AND pn2.state = 1)b';

	EXECUTE 'SELECT count(*) FROM ('||v_query||')c'
	INTO v_count; 

	IF v_count > 0 THEN

		EXECUTE concat ('INSERT INTO anl_arc (fid, arc_id, arccat_id, descript, the_geom,state)
		SELECT 354, c.arc_id, c.arccat_id, ''Arcs state = 2 without planned final nodes in psector'', c.the_geom, 2 FROM (', v_query,')c ');
		INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
		VALUES (115, '354', 3, FALSE, concat('ERROR-354: There are ',v_count,' planified arcs without final planned nodes defined in psector.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, '354', 1,'INFO: There are no arcs with state=2 with planned final nodes not defined psector.');
	END IF;

	--check if arcs with state = 2 have final nodes state = 1 or 2 operative in psector (355)
	v_query =  'SELECT * FROM (
	SELECT pa.arc_id, arc.arccat_id, pa.psector_id , node_1 as node, arc.the_geom FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
	JOIN plan_psector_x_node pn1 ON pn1.node_id = arc.node_1
	WHERE pa.psector_id = pn1.psector_id AND pa.state = 1 AND pn1.state = 0
	UNION
	SELECT pa.arc_id, arc.arccat_id, pa.psector_id, node_2, arc.the_geom FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
	JOIN plan_psector_x_node pn2 ON pn2.node_id = arc.node_2
	WHERE pa.psector_id = pn2.psector_id AND pa.state = 1 AND pn2.state = 0) b';

	EXECUTE 'SELECT count(*) FROM ('||v_query||')c'
	INTO v_count; 

	IF v_count > 0 THEN

		EXECUTE concat ('INSERT INTO anl_arc (fid, arc_id, arccat_id, descript, the_geom,state)
		SELECT 355, c.arc_id, c.arccat_id, concat(''Arcs state = 2 final nodes obsolete in psector '',c.psector_id), c.the_geom, 2 FROM (', v_query,')c ');
		INSERT INTO audit_check_data (fid, result_id,  criticity, enabled,  error_message)
		VALUES (115, '355', 3, FALSE, concat('ERROR-355: There are ',v_count,' planified arcs with final nodes defined as obsolete in psector.'));
	ELSE
		INSERT INTO audit_check_data (fid, result_id, criticity, error_message)
		VALUES (115, '355', 1,'INFO: There are no arcs with state=2 with final nodes obsolete in psector.');
	END IF;
	
	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() 
	AND fid=115 order by id) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
	
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 
	v_result_polygon := COALESCE(v_result_polygon, '{}'); 

		--  Return
	RETURN ('{"status":"Accepted", "message":{"level":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
		     	'"setVisibleLayers":[]'||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||'}'||
		       '}'||
	    '}')::json;

	--  Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
  COST 100;

 	