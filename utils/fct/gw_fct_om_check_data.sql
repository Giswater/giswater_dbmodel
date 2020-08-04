/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2670

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_om_check_data(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_om_check_data(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT gw_fct_om_check_data($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{},"data":{"parameters":{"selectionMode":"userSelectors"}}}$$)

SELECT gw_fct_om_check_data($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{},"data":{"parameters":{"selectionMode":"wholeSystem"}}}$$)

*/


DECLARE
v_project_type 		text;
v_count			integer;
v_saveondatabase 	boolean;
v_result 		text;
v_version		text;
v_result_info 		json;
v_result_point		json;
v_result_line 		json;
v_result_polygon	json;
v_querytext		text;
v_result_id 		text;
v_features 		text;
v_edit			text;
v_config_param 		text;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;

	-- getting input data 	
	v_features := ((p_data ->>'data')::json->>'parameters')::json->>'selectionMode'::text;
	
	-- select config values
	SELECT wsoftware, giswater INTO v_project_type, v_version FROM version order by id desc limit 1;

	-- init variables
	v_count=0;


	-- set v_edit_ variable
	IF v_features='wholeSystem' THEN
		v_edit = '';
	ELSIF v_features='userSelectors' THEN
		v_edit = 'v_edit_';
	END IF;
	
	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fprocesscat_id=25 AND user_name=current_user;
	
	-- delete old values on anl table
	DELETE FROM anl_connec WHERE cur_user=current_user AND fprocesscat_id IN (101,102,104,105,106);
	DELETE FROM anl_arc WHERE cur_user=current_user AND fprocesscat_id IN (4,88,102);
	DELETE FROM anl_node WHERE cur_user=current_user AND fprocesscat_id IN (4,87,96,97,102,103);

	-- Starting process
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 4, concat('DATA QUALITY ANALYSIS ACORDING O&M RULES'));
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 4, '-------------------------------------------------------------');

	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 3, 'CRITICAL ERRORS');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 3, '----------------------');	

	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 2, 'WARNINGS');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 2, '--------------');	

	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 1, 'INFO');
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, null, 1, '-------');

		
	-- UTILS

	-- system variables
	v_querytext = 'SELECT parameter FROM config_param_system WHERE lower(value) != lower(standardvalue) AND standardvalue IS NOT NULL';
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	EXECUTE concat('SELECT (array_agg(parameter))::text FROM (',v_querytext,')a') INTO v_result;

	IF v_count > 0 THEN
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' system variables with out-of-standard values ',v_result,'.'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No system variables with values out-of-standars found.');
	END IF;

	
	
	-- Check node_1 or node_2 nulls (fprocesscat = 4)
	v_querytext = '(SELECT arc_id,arccat_id,the_geom FROM '||v_edit||'arc WHERE state > 0 AND node_1 IS NULL UNION SELECT arc_id, arccat_id, the_geom FROM '
	||v_edit||'arc WHERE state > 0 AND node_2 IS NULL) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) 
			SELECT 4, arc_id, arccat_id, ''node_1 or node_2 nulls'', the_geom FROM ', v_querytext);
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 3, concat('ERROR: There is/are ',v_count,' arc''s without node_1 or node_2.'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 3, concat('SELECT * FROM anl_arc WHERE fprocesscat_id=4 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No arc''s without node_1 or node_2 nodes found.');
	END IF;

	-- Chec state 1 arcs with state 0 nodes (96)
	v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_1=node_id WHERE a.state =1 AND n.state=0 UNION
			SELECT a.arc_id, arccat_id, a.the_geom FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=0) a';
			
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) 
		SELECT 96, arc_id, arccat_id, ''Arc with state=1 using nodes with state = 0'', the_geom FROM ', v_querytext);

		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (25, 3, concat('ERROR: There is/are ',v_count,' arcs with state=1 using extremals nodes with state = 0. Please, check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 3, concat('SELECT * FROM anl_arc WHERE fprocesscat_id=96 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No arcs with state=1 using nodes with state=0 found.');
	END IF;

	-- Chec state 1 arcs with state 2 nodes (97)
	v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_1=node_id WHERE a.state =1 AND n.state=2 UNION
			SELECT a.arc_id, arccat_id, a.the_geom FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=2) a';
			
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) 
		SELECT 97, arc_id, arccat_id, ''Arcs with state=1 using nodes with state = 2'', the_geom FROM ', v_querytext);

		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (25, 3, concat('ERROR: There is/are ',v_count,' arcs with state=1 using extremals nodes with state = 2. Please, check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 3, concat('SELECT * FROM anl_arc WHERE fprocesscat_id=97 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No arcs with state=1 using nodes with state=0 found.');
	END IF;	
	
	-- Check state_type nulls (arc, node)
	v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc WHERE state > 0 AND state_type IS NULL 
		        UNION SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node WHERE state > 0 AND state_type IS NULL) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (25, 3, concat('ERROR: There is/are ',v_count,' topologic features (arc, node) with state_type with NULL values. Please, check your data before continue'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No topologic features (arc, node) with state_type NULL values found.');
	END IF;


	-- Check nodes with state_type isoperative = false (fprocesscat = 87)
	v_querytext = 'SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node n JOIN value_state_type ON id=state_type WHERE n.state > 0 AND is_operative IS FALSE';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_node (fprocesscat_id, node_id, nodecat_id, descript, the_geom) 
		SELECT 87, node_id, nodecat_id, ''Nodes with state_type isoperative = false'', the_geom FROM (', v_querytext,')a');
		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' node(s) with state > 0 and state_type.is_operative on FALSE. Please, check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('SELECT * FROM anl_node WHERE fprocesscat_id=87 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No nodes with state > 0 AND state_type.is_operative on FALSE found.');
	END IF;


	-- Check arcs with state_type isoperative = false (fprocesscat = 88)
	v_querytext = 'SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc a JOIN value_state_type ON id=state_type WHERE a.state > 0 AND is_operative IS FALSE';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) 
			SELECT 88, arc_id, arccat_id, ''arcs with state_type isoperative = false'', the_geom FROM (', v_querytext,')a');

		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' arc(s) with state > 0 and state_type.is_operative on FALSE. Please, check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('SELECT * FROM anl_arc WHERE fprocesscat_id=88 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No arcs with state > 0 AND state_type.is_operative on FALSE found.');
	END IF;


	-- Check nulls customer code for connecs (110)
	v_querytext = 'SELECT customer_code FROM '||v_edit||'connec WHERE state=1 and customer_code IS NULL';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
		SELECT 110, connec_id, connecat_id, ''Connecs with null customer code'', the_geom FROM connec WHERE customer_code IN (', v_querytext,')');
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' connec with customer code null. Please, check your data before continue'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No connecs with null customer code.');
	END IF;


	-- Check unique customer code for connecs with state=1 
	v_querytext = 'SELECT customer_code FROM '||v_edit||'connec WHERE state=1 and customer_code IS NOT NULL group by customer_code having count(*) > 1';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
		SELECT 101, connec_id, connecat_id, ''Connecs with customer code duplicated'', the_geom FROM connec WHERE customer_code IN (', v_querytext,')');
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' connec customer code duplicated. Please, check your data before continue'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No connecs with customer code duplicated.');
	END IF;

	--Check if all id are integers
	IF v_project_type = 'WS' THEN
		v_querytext = '(SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
						ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat, the_geom FROM '||v_edit||'arc
						UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
   						ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat, the_geom FROM '||v_edit||'node
						UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
   						ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat, the_geom FROM '||v_edit||'connec) a';

   		EXECUTE concat('SELECT count(*) FROM ',v_querytext,' WHERE feature_id=0') INTO v_count;
   	ELSIF v_project_type = 'UD' THEN
   		v_querytext = ('(SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
						ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat,the_geom  FROM '||v_edit||'arc
						UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
   						ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat,the_geom FROM '||v_edit||'node
						UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
   						ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat,the_geom FROM '||v_edit||'connec
   						UNION SELECT CASE WHEN gully_id~E''^\\d+$'' THEN CAST (gully_id AS INTEGER)
   						ELSE 0 END as feature_id, ''GULLY'' as type, gratecat_id as featurecat,the_geom FROM '||v_edit||'gully) a');
   	END IF;

   	EXECUTE concat('SELECT count(*) FROM ',v_querytext,' WHERE feature_id=0') INTO v_count;

   	IF v_count > 0 THEN

		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
		SELECT 102, feature_id, featurecat, ''Connecs with id which is not an integer'', the_geom FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''CONNEC'' ');

		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) 
		SELECT 102,  feature_id, featurecat, ''Arcs with id which is not an integer'', the_geom FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''ARC'' ');

		EXECUTE concat ('INSERT INTO anl_node (fprocesscat_id, node_id, nodecat_id, descript, the_geom) 
		SELECT 102,  feature_id, featurecat, ''Nodes with id which is not an integer'', the_geom FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''NODE'' ');
			
		IF v_project_type = 'UD' THEN
			EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, node_id, nodecat_id, descript, the_geom) 
			SELECT 102, feature_id, featurecat, ''Gullies with id which is not an integer'', the_geom FROM ', v_querytext,' 
			WHERE feature_id=0 AND type = ''GULLY'' ');
		END IF;

		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 3, concat('ERROR: There is/are ',v_count,' which id is not an integer. Please, check your data before continue'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: All features with id integer.');
	END IF;

	-- Check state not according with state_type	
	IF v_project_type = 'UD' THEN
		v_querytext =  'SELECT a.state, state_type FROM '||v_edit||'arc a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT a.state, state_type FROM '||v_edit||'node a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT a.state, state_type FROM '||v_edit||'connec a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state	
				UNION SELECT a.state, state_type FROM '||v_edit||'element a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 3, concat('ERROR: There is/are ',v_count,' features(s) with state without concordance with state_type. Please, check your data before continue'));
			
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No features without concordance againts state and state_type.');
		END IF;
		
	ELSIF v_project_type = 'WS' THEN
	
		v_querytext =  'SELECT a.state, state_type FROM '||v_edit||'arc a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT a.state, state_type FROM '||v_edit||'node a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT a.state, state_type FROM '||v_edit||'connec a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state	
				UNION SELECT a.state, state_type FROM '||v_edit||'element a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 3, concat('ERROR: There is/are ',v_count,' features(s) with state without concordance with state_type. Please, check your data before continue'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No features without concordance againts state and state_type.');
		END IF;
	END IF;
	
	-- Check code with null values
	IF v_project_type ='UD' THEN
		v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc WHERE code IS NULL 
					UNION SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node WHERE code IS NULL
					UNION SELECT connec_id, connecat_id, the_geom FROM '||v_edit||'connec WHERE code IS NULL
					UNION SELECT gully_id, gratecat_id, the_geom FROM '||v_edit||'gully WHERE code IS NULL
					UNION SELECT element_id, elementcat_id, the_geom FROM '||v_edit||'element WHERE code IS NULL) a';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
			VALUES (25, 3, concat('ERROR: There is/are ',v_count,' with code with NULL values. Please, check your data before continue'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No features (arc, node, connec, gully, element) with NULL values on code found.');
		END IF;

	ELSIF v_project_type ='WS' THEN

		v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc WHERE code IS NULL 
				UNION SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node WHERE code IS NULL
				UNION SELECT connec_id, connecat_id, the_geom FROM '||v_edit||'connec WHERE code IS NULL
				UNION SELECT element_id, elementcat_id, the_geom FROM '||v_edit||'element WHERE code IS NULL) a';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
			VALUES (25, 3, concat('ERROR: There is/are ',v_count,' with code with NULL values. Please, check your data before continue'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No features (arc, node, connec, element) with NULL values on code found.');
		END IF;
	END IF;
			
	-- Check for orphan polygons on polygon table
	IF v_project_type ='UD' THEN

		v_querytext = '(SELECT pol_id FROM polygon EXCEPT SELECT pol_id FROM (select pol_id from gully UNION select pol_id from man_chamber 
					   UNION select pol_id from man_netgully UNION select pol_id from man_storage UNION select pol_id from man_wwtp) a) b';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' polygons without parent (gully, netgully, chamber, storage or wwtp).  We recommend you to clean data before continue.'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No polygons without parent feature (gully, netgully, chamber, storage or wwtp) found.');
		END IF;
	ELSIF v_project_type ='WS' THEN

	END IF;

	-- Check for orphan rows on man_addfields values table
	IF v_project_type ='UD' THEN

		v_querytext = 'SELECT * FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec UNION SELECT gully_id FROM gully)';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	
		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' rows on man_addfields_value without parent feature. We recommend you to clean data before continue.'));
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('SELECT * FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec UNION SELECT gully_id FROM gully)'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No rows without feature found on man_addfields_value table.');
		END IF;	

	ELSIF v_project_type='WS' THEN
		v_querytext = '(SELECT pol_id FROM polygon EXCEPT SELECT pol_id FROM (select pol_id from man_register UNION select pol_id from man_tank UNION select pol_id from man_fountain) a) b';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' polygons without parent (register, tank, fountain).  We recommend you to clean data before continue.'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: No polygons without parent feature (register, tank, fountain) found.');
		END IF;

	END IF;
	
	-- connec/gully without link
	v_querytext = 'SELECT connec_id,connecat_id,the_geom from '||v_edit||'connec WHERE state= 1 
					AND connec_id NOT IN (select feature_id from link)';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
		SELECT 104, connec_id, connecat_id, ''Connecs without links'', the_geom FROM (', v_querytext,')a');

		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' connecs without links.'));
	ELSE
		INSERT INTO audit_check_data 	(fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: All connecs have links.');
	END IF;

	IF v_project_type = 'UD' THEN 
		v_querytext = 'SELECT gully_id,gratecat_id,the_geom from '||v_edit||'gully WHERE state= 1 
						AND gully_id NOT IN (select feature_id from link)';
	

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
		
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
			SELECT 104, gully_id, gratecat_id, ''Gullies without links'', the_geom FROM (', v_querytext,')a');

			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' gullies without links.'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: All gullies have links.');
		END IF;
	
	END IF;

	-- check vnode inconsistency (link without vnode)
	v_querytext = 'SELECT * FROM v_edit_link LEFT JOIN vnode ON vnode_id = exit_id::integer where exit_type =''VNODE'' AND vnode_id IS NULL';
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
		
	IF v_count > 0 THEN -- automatic repair
		PERFORM gw_fct_vnode_repair();	
	END IF;

	-- check vnode inconsistency (vnode without link)
	v_querytext = 'SELECT vnode_id FROM vnode LEFT JOIN link ON vnode_id = exit_id::integer where link_id IS NULL';
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN -- automatic delete
		EXECUTE 'DELETE FROM vnode WHERE vnode_id IN ('||v_querytext||')a';
	END IF;

	--connec/gully without arc_id or with arc_id different than the one to which points its link
	v_querytext = 'SELECT  '||v_edit||'connec.connec_id,  '||v_edit||'connec.connecat_id,  '||v_edit||'connec.the_geom
				FROM '||v_edit||'link
				LEFT JOIN '||v_edit||'connec ON '||v_edit||'link.feature_id = '||v_edit||'connec.connec_id 
				INNER JOIN arc ON st_dwithin(arc.the_geom, st_endpoint('||v_edit||'link.the_geom), 0.01)
				WHERE exit_type = ''VNODE'' AND (arc.arc_id <> '||v_edit||'connec.arc_id or '||v_edit||'connec.arc_id is null) 
				AND '||v_edit||'link.feature_type = ''CONNEC'' AND arc.state=1 and '||v_edit||'connec.connec_id IS NOT NULL
				and '||v_edit||'link.feature_id NOT IN (SELECT connec_id FROM node,link
				LEFT JOIN '||v_edit||'connec ON '||v_edit||'link.feature_id = '||v_edit||'connec.connec_id 
				LEFT JOIN vnode ON '||v_edit||'link.exit_id=vnode.vnode_id::text
				WHERE exit_type = ''VNODE'' AND st_dwithin(vnode.the_geom, node.the_geom,0.01))
				ORDER BY '||v_edit||'link.feature_type, link_id';


	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
		SELECT 106, connec_id, connecat_id, ''Connecs without or with incorrect arc_id'', the_geom FROM (', v_querytext,')a');

		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' connecs without or with incorrect arc_id.'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: All connecs have correct arc_id.');
	END IF;

	IF v_project_type = 'UD' THEN
		v_querytext = 'SELECT  '||v_edit||'gully.gully_id,  '||v_edit||'gully.gratecat_id,  '||v_edit||'gully.the_geom
					FROM '||v_edit||'link
					LEFT JOIN '||v_edit||'gully ON '||v_edit||'link.feature_id = '||v_edit||'gully.gully_id 
					INNER JOIN arc ON st_dwithin(arc.the_geom, st_endpoint('||v_edit||'link.the_geom), 0.01)
					WHERE exit_type = ''VNODE'' AND (arc.arc_id <> '||v_edit||'gully.arc_id or '||v_edit||'gully.arc_id is null) 
					AND '||v_edit||'link.feature_type = ''GULLY'' AND arc.state=1 AND '||v_edit||'gully.gully_id IS NOT NULL
					and '||v_edit||'link.feature_id NOT IN (SELECT gully_id FROM node,link
					LEFT JOIN '||v_edit||'gully ON '||v_edit||'link.feature_id = '||v_edit||'gully.gully_id 
					LEFT JOIN vnode ON '||v_edit||'link.exit_id=vnode.vnode_id::text
					WHERE exit_type = ''VNODE'' AND st_dwithin(vnode.the_geom, node.the_geom,0.01))
					ORDER BY '||v_edit||'link.feature_type, link_id';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
			SELECT 106, gully_id, gratecat_id, ''Gullies without or with incorrect arc_id'', the_geom FROM (', v_querytext,')a');

			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' gullies without or with incorrect arc_id.'));
		ELSE
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: All gullies have correct arc_id.');
		END IF;
	END IF;

	--Chained connecs/gullies which has different arc_id than the final connec/gully.
	IF v_project_type = 'WS' THEN 
		v_querytext = 'with c as (
					Select '||v_edit||'connec.connec_id as id, arc_id as arc, '||v_edit||'connec.connecat_id as 
					feature_catalog, the_geom 
					from '||v_edit||'connec
					)
					select c1.id, c1.feature_catalog, c1.the_geom
					from link a
					left join c c1 on a.feature_id = c1.id
					left join c c2 on a.exit_id = c2.id
					where (a.exit_type =''CONNEC'')
					and c1.arc <> c2.arc';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'with c as (
					Select '||v_edit||'connec.connec_id as id, arc_id as arc,'||v_edit||'connec.connecat_id as 
					feature_catalog, the_geom from '||v_edit||'connec
					UNION select '||v_edit||'gully.gully_id as id, arc_id as arc,'||v_edit||'gully.gratecat_id, 
					the_geom from '||v_edit||'gully
					)
					select c1.id, c1.feature_catalog, c1.the_geom
					from link a
					left join c c1 on a.feature_id = c1.id
					left join c c2 on a.exit_id = c2.id
					where (a.exit_type =''CONNEC'' OR a.exit_type =''GULLY'')
					and c1.arc <> c2.arc';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		IF v_project_type = 'UD' THEN
			EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
			SELECT 105, id, feature_catalog, ''Chained connecs or gullies with different arc_id'', the_geom FROM (', v_querytext,')a');

			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' chained connecs or gullies with different arc_id.'));
		ELSIF v_project_type = 'WS' THEN
			EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) 
			SELECT 105, id, feature_catalog, ''Chained connecs with different arc_id'', the_geom FROM (', v_querytext,')a');

			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 2, concat('WARNING: There is/are ',v_count,' chained connecs with different arc_id.'));
		END IF;
	ELSE
		IF v_project_type = 'UD' THEN	
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: All chained connecs and gullies have the same arc_id');
		ELSIF v_project_type = 'WS' THEN
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (25, 1, 'INFO: All chained connecs have the same arc_id');
		END IF;
	END IF;

	--features with state 1 and end date
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT arc_id as feature_id  from '||v_edit||'arc where state = 1 and enddate is not null
					UNION SELECT node_id from '||v_edit||'node where state = 1 and enddate is not null
					UNION SELECT connec_id from '||v_edit||'connec where state = 1 and enddate is not null';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT arc_id as feature_id from '||v_edit||'arc where state = 1 and enddate is not null
					UNION SELECT node_id from '||v_edit||'node where state = 1 and enddate is not null
					UNION SELECT connec_id from '||v_edit||'connec where state = 1 and enddate is not null
					UNION SELECT gully_id from '||v_edit||'gully where state = 1 and enddate is not null';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' features on service with value of end date.'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No features on service have value of end date');
	END IF;

	--features with state 0 and without end date
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT arc_id as feature_id  from '||v_edit||'arc where state = 0 and enddate is null
					UNION SELECT node_id from '||v_edit||'node where state = 0 and enddate is null
					UNION SELECT connec_id from '||v_edit||'connec where state = 0 and enddate is null';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT arc_id as feature_id from '||v_edit||'arc where state = 0 and enddate is null
					UNION SELECT node_id from '||v_edit||'node where state = 0 and enddate is null
					UNION SELECT connec_id from '||v_edit||'connec where state = 0 and enddate is null
					UNION SELECT gully_id from '||v_edit||'gully where state = 0 and enddate is null';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' features with state 0 without value of end date.'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No features with state 0 are missing the end date');
	END IF;

	--features with state 1 and end date
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT arc_id as feature_id  from '||v_edit||'arc where enddate < builtdate
					UNION SELECT node_id from '||v_edit||'node where enddate < builtdate
					UNION SELECT connec_id from '||v_edit||'connec where enddate < builtdate';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT arc_id as feature_id from '||v_edit||'arc where enddate < builtdate
					UNION SELECT node_id from '||v_edit||'node where enddate < builtdate
					UNION SELECT connec_id from '||v_edit||'connec where enddate < builtdate
					UNION SELECT gully_id from '||v_edit||'gully where enddate < builtdate';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 2, concat('WARNING: There is/are ',v_count,' features with end date earlier than built date.'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (25, 1, 'INFO: No features with end date earlier than built date');
	END IF;
		
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, v_result_id, 4, '');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, v_result_id, 3, '');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, v_result_id, 2, '');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (25, v_result_id, 1, '');
	
	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND 
	fprocesscat_id=25 order by criticity desc, id asc) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
	
	--points
	v_result = null;

	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, node_id as feature_id, nodecat_id as feature_catalog, state, expl_id, descript,fprocesscat_id, the_geom FROM anl_node WHERE cur_user="current_user"() 
	AND fprocesscat_id IN (4,87,96,87,102,103)
	UNION
	SELECT id, connec_id, connecat_id, state, expl_id, descript,fprocesscat_id, the_geom FROM anl_connec WHERE cur_user="current_user"() 
	AND fprocesscat_id IN (101,102,104,105,106)) row;  

	v_result := COALESCE(v_result, '{}'); 
	
	IF v_result = '{}' THEN 
		v_result_point = '{"geometryType":"", "values":[]}';
	ELSE 
		v_result_point = concat ('{"geometryType":"Point", "values":',v_result, '}');
	END IF;

	--lines
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript, the_geom FROM anl_arc WHERE cur_user="current_user"() 
	AND (fprocesscat_id=4 OR fprocesscat_id=88 OR fprocesscat_id=102)) row; 
	v_result := COALESCE(v_result, '{}'); 

	IF v_result = '{}' THEN 
		v_result_line = '{"geometryType":"", "values":[]}';
	ELSE 
		v_result_line = concat ('{"geometryType":"LineString", "values":',v_result, '}');
	END IF;

	--polygons
	v_result_polygon = '{"geometryType":"", "values":[]}';
		
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 
	v_result_polygon := COALESCE(v_result_polygon, '{}'); 
	
--  Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||','||
				'"setVisibleLayers":[] }'||
		       '}'||
	    '}')::json;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
