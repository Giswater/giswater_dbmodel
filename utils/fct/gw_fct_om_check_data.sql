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
SELECT SCHEMA_NAME.gw_fct_om_check_data($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{},"data":{"parameters":{"selectionMode":"userSelectors"}}}$$)

SELECT SCHEMA_NAME.gw_fct_om_check_data($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{},"data":{"parameters":{"selectionMode":"wholeSystem"}}}$$)


SELECT * FROM audit_check_data WHERE fid = v_fid

--fid:  main: v_fid
	other: 103,104,106,187,188,196,197,201,202,203,204,205,257,372,417,418,419,421,422,423,424,442,443,461,478,479,488,480,497,498,499  
*/

DECLARE

v_record record;
v_Rec record;
v_project_type text;
v_count integer;
v_saveondatabase boolean;
v_result text;
v_version text;
v_result_info json;
v_result_point json;
v_result_line json;
v_result_polygon json;
v_querytext	text;
v_result_id text;
v_features text;
v_edit text;
v_config_param text;
v_error_context text;
v_feature_id text;
v_arc_array text[];
rec_arc text;
v_node_1 text;
v_partialquery text;
v_check_arcdnom integer;
v_fid integer;
v_rec_process record;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;

	-- getting input data 	
	v_features := ((p_data ->>'data')::json->>'parameters')::json->>'selectionMode'::text;
	v_fid := ((p_data ->>'data')::json->>'parameters')::json->>'fid'::text;
	
	-- select config values
	SELECT project_type, giswater INTO v_project_type, v_version FROM sys_version order by id desc limit 1;

	-- init variables
	v_count=0;
	IF v_fid is null THEN
		v_fid = 125;
	END IF;

	-- set v_edit_ variable
	IF v_features='wholeSystem' THEN
		v_edit = '';
	ELSIF v_features='userSelectors' THEN
		v_edit = 'v_edit_';
	END IF;

	
	--create temp tables
	IF v_fid = 125 OR v_fid = 101 THEN
		CREATE TEMP TABLE temp_anl_arc (LIKE SCHEMA_NAME.anl_arc INCLUDING ALL);
		CREATE TEMP TABLE temp_anl_node (LIKE SCHEMA_NAME.anl_node INCLUDING ALL);
		CREATE TEMP TABLE temp_anl_connec (LIKE SCHEMA_NAME.anl_connec INCLUDING ALL);
		CREATE TEMP TABLE temp_audit_check_data (LIKE SCHEMA_NAME.audit_check_data INCLUDING ALL);
	END IF;

	CREATE TEMP TABLE temp_t_arc (LIKE SCHEMA_NAME.temp_arc INCLUDING ALL);
	
	-- Starting process
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, concat('DATA QUALITY ANALYSIS ACORDING O&M RULES'));
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, '-------------------------------------------------------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 3, 'CRITICAL ERRORS');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 3, '----------------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 2, 'WARNINGS');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 2, '--------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 1, 'INFO');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 1, '-------');

		
	-- UTILS

	RAISE NOTICE '01 - system variables (302)';
	v_querytext = 'SELECT parameter FROM config_param_system WHERE lower(value) != lower(standardvalue) AND standardvalue IS NOT NULL 
	AND  standardvalue NOT ILIKE ''{%}'' UNION
	SELECT parameter FROM config_param_system 
	WHERE lower(json_extract_path_text(value::json,''activated'')) != lower(json_extract_path_text(standardvalue::json,''activated'')) 
	AND standardvalue IS NOT NULL AND standardvalue ILIKE ''{%}'' ';
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	EXECUTE concat('SELECT (array_agg(parameter))::text FROM (',v_querytext,')a') INTO v_result;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '302', concat('WARNING-302: There is/are ',v_count,' system variables with out-of-standard values ',v_result,'.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '302', 'INFO: No system variables with values out-of-standars found.',v_count);
	END IF;

	
	RAISE NOTICE '02 - Check node_1 or node_2 nulls (103)';

/*
	v_querytext = '(SELECT arc_id,arccat_id,the_geom, expl_id FROM '||v_edit||'arc 
	WHERE state = 1 AND node_1 IS NULL UNION SELECT arc_id, arccat_id, the_geom, expl_id FROM '||v_edit||'arc WHERE state = 1 AND node_2 IS NULL) a';

	select * into v_rec_process from sys_fprocess where fid = 103;

	v_querytext = replace(v_rec_process.query_text, 'v_prefix_', v_edit);

	--raise exception 'v_querytext %', v_querytext;

	--EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
*/
	for v_rec in select*from sys_fprocess where query_text is not null --and 'gw_fct_om_check_data' = ANY(function_name) 
	and (project_type = quote_literal(lower(v_project_type)) or project_type = 'utils')
	loop
		raise notice 'v_rec.fid %', v_rec.fid;
		execute 'select gw_fct_check_fprocess($${"client":{"device":4, "infoType":1, "lang":"ES"}, 
	    "form":{},"feature":{},"data":{"parameters":{"functionFid": '||v_fid||', "checkFid":"'||v_rec.fid||'", "prefixTable": "'||v_edit||'"}}}$$)';
   	end loop;


/*

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 103, arc_id, arccat_id, ''node_1 or node_2 nulls'', the_geom, expl_id FROM ', v_querytext);
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '103', concat('ERROR-103 (anl_arc): There is/are ',v_count,' arc''s with state=1 and without node_1 or node_2.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1, '103','INFO: No arc''s with state=1 and without node_1 or node_2 nodes found.', v_count);
	END IF;

	RAISE NOTICE '03 - Check state 1 arcs with state 0 nodes (196)';
	v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM '||v_edit||'arc a 
			JOIN '||v_edit||'node n ON node_1=node_id WHERE a.state =1 AND n.state=0 UNION
			SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=0) a';
			
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
		SELECT 196, arc_id, arccat_id, ''Arc with state=1 using nodes with state = 0'', the_geom, expl_id FROM ', v_querytext);

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3,'196', concat('ERROR-196 (anl_arc): There is/are ',v_count,' arcs with state=1 using extremals nodes with state = 0. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1,'196', 'INFO: No arcs with state=1 using nodes with state=0 found.',v_count);
	END IF;

	RAISE NOTICE '04 - check conduits (UD) with negative slope and inverted slope is not checked (251)';
	IF v_project_type  ='UD' THEN

		IF v_edit IS NULL THEN 
			v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom, expl_id FROM arc a WHERE sys_slope < 0 AND state > 0 AND inverted_slope IS FALSE) a';
		ELSE
			v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom, expl_id FROM v_edit_arc a WHERE slope < 0 AND state > 0 AND inverted_slope IS FALSE) a';
		END IF;
		
		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 251, arc_id, arccat_id, ''Arcs with negative slope and inverted slope is not checked'', the_geom, expl_id FROM ', v_querytext);
			
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 3, '251', concat('ERROR-251 (anl_arc): There is/are ',v_count,' arcs with inverted slope false and slope negative values. Please, check your data before continue'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '251','INFO: No arcs with inverted slope checked found.',v_count);
		END IF;	
	END IF;

	RAISE NOTICE '05 - Check state 1 arcs with state 2 nodes (197)';
	v_querytext = '(SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_1=node_id 
			WHERE a.state =1 AND n.state=2 UNION
			SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM '||v_edit||'arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=2) a';
			
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
		SELECT 197, arc_id, arccat_id, ''Arcs with state=1 using nodes with state = 2'', the_geom, expl_id FROM ', v_querytext);

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '197', 3, concat('ERROR-197 (anl_arc): There is/are ',v_count,' arcs with state=1 using extremals nodes with state = 2. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid,result_id, criticity, error_message, fcount)
		VALUES (v_fid, '197',1, 'INFO: No arcs with state=1 using nodes with state=0 found.',v_count);
	END IF;	

	RAISE NOTICE '06 - Check all state=2 are involved in at least in one psector (252)';
	v_querytext = 'SELECT a.arc_id FROM '||v_edit||'arc a RIGHT JOIN plan_psector_x_arc USING (arc_id) WHERE a.state = 2 AND a.arc_id IS NULL
			UNION
			SELECT a.node_id FROM '||v_edit||'node a RIGHT JOIN plan_psector_x_node USING (node_id) WHERE a.state = 2 AND a.node_id IS NULL
			UNION
			SELECT a.connec_id FROM '||v_edit||'connec a RIGHT JOIN plan_psector_x_connec USING (connec_id) WHERE a.state = 2 AND a.connec_id IS NULL';

	IF v_project_type = 'UD' THEN
		v_querytext = concat (v_querytext, ' UNION SELECT a.gully_id FROM '||v_edit||'gully a RIGHT JOIN plan_psector_x_gully USING (gully_id) WHERE a.state = 2 AND a.gully_id IS NULL');
	END IF;
		
	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '252', concat('ERROR-252: There is/are ',v_count,' features with state=2 without psector assigned. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '252', 'INFO: No features with state=2 without psector assigned.',v_count);
	END IF;


	RAISE NOTICE '07 - Check state_type nulls (arc, node) (175)';

	v_querytext = '(SELECT arc_id FROM '||v_edit||'arc WHERE state > 0 AND state_type IS NULL 
		        UNION SELECT node_id FROM '||v_edit||'node WHERE state > 0 AND state_type IS NULL) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
	
		v_querytext = 'INSERT INTO temp_anl_node (fid, node_id, nodecat_id, the_geom, expl_id, state)
		SELECT 175, node_id, nodecat_id, the_geom, expl_id, state FROM '||v_edit||'node WHERE state > 0 AND state_type IS NULL';
		EXECUTE v_querytext;
	
		v_querytext = 'INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, the_geom, expl_id, state)
		SELECT 175, arc_id, arccat_id, the_geom, expl_id, state FROM '||v_edit||'arc WHERE state > 0 AND state_type IS NULL';
		EXECUTE v_querytext;
	
		INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '175',concat('ERROR-175 (anl_node/arc): There is/are ',v_count,' topologic features (arc, node) with state_type with NULL values. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '175', 'INFO: No topologic features (arc, node) with state_type NULL values found.',v_count);
	END IF;


	RAISE NOTICE '08 - Check nodes with state_type isoperative = false (187)';
	v_querytext = 'SELECT node_id, nodecat_id, the_geom, n.expl_id FROM '||v_edit||'node n JOIN value_state_type s ON id=state_type 
	 	WHERE n.state > 0 AND s.is_operative IS FALSE AND verified <>''2''';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 187, node_id, nodecat_id, ''Nodes with state_type isoperative = false'', the_geom, expl_id FROM (', v_querytext,')a');
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid,'187', 2, concat('WARNING-187 (anl_node): There is/are ',v_count,' node(s) with state > 0 and state_type.is_operative on FALSE. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid,  result_id,criticity, error_message, fcount)
		VALUES (v_fid, '187', 1, 'INFO: No nodes with state > 0 AND state_type.is_operative on FALSE found.',v_count);
	END IF;

	RAISE NOTICE '09 - Check arcs with state_type isoperative = false (188)';
	v_querytext = 'SELECT arc_id, arccat_id, the_geom, a.expl_id FROM '||v_edit||'arc a JOIN value_state_type s ON id=state_type 
	WHERE a.state > 0 AND s.is_operative IS FALSE AND verified <>''2'''; 

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 188, arc_id, arccat_id, ''arcs with state_type isoperative = false'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '188', 2, concat('WARNING-188 (anl_arc): There is/are ',v_count,' arc(s) with state > 0 and state_type.is_operative on FALSE. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '188', 1, 'INFO: No arcs with state > 0 AND state_type.is_operative on FALSE found.',v_count);
	END IF;

	RAISE NOTICE '10 - check if all tanks are defined in config_graph_mincut  (177)';
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node 
		JOIN cat_node ON nodecat_id=cat_node.id
		JOIN cat_feature ON cat_node.nodetype_id = cat_feature.id
		JOIN value_state_type ON state_type = value_state_type.id
		WHERE value_state_type.is_operative IS TRUE AND system_id = ''TANK'' and node_id NOT IN 
		(SELECT node_id FROM config_graph_mincut WHERE active IS TRUE)';
		
		EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;
		EXECUTE concat('SELECT string_agg(a.node_id::text,'','') FROM (',v_querytext,') a ') INTO v_feature_id;

		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom)
			SELECT 177, node_id, nodecat_id, ''Tanks not defined in config_graph_mincut'', the_geom FROM (', v_querytext,')a');
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid,'177', 3, concat('ERROR-177 (anl_node): There is/are ',v_count,' tank(s) which are not defined on config_graph_mincut. Node_id: ',v_feature_id,'. Please, check your data before continue'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, '177', 1, 'INFO: All tanks are defined in config_graph_mincut.',v_count);
		END IF;
	END IF;

	RAISE NOTICE '11 - check if drawn arc direction is the same as defined node_1, node_2 (223)';

	v_querytext = 'SELECT a.arc_id , arccat_id, a.the_geom, a.expl_id FROM '||v_edit||'arc a, '||v_edit||'node n WHERE st_dwithin(st_startpoint(a.the_geom), n.the_geom, 0.0001) and node_2 = node_id
			UNION
			SELECT a.arc_id , arccat_id, a.the_geom, a.expl_id  FROM '||v_edit||'arc a, '||v_edit||'node n WHERE st_dwithin(st_endpoint(a.the_geom), n.the_geom, 0.0001) and node_1 = node_id';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
		SELECT 223, arc_id, arccat_id, ''Drawing direction different than definition of node_1, node_2'', the_geom, expl_id FROM (',v_querytext,')a');
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 2, '223', concat('WARNING-223 (anl_arc): There is/are ',v_count,' arcs with drawing direction different than definition of node_1, node_2'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1, '223', 'INFO: No arcs with drawing direction different than definition of node_1, node_2',v_count);
	END IF;

	RAISE NOTICE '12 - Check nulls customer code for connecs (210)';
	v_querytext = 'SELECT connec_id FROM '||v_edit||'connec WHERE state=1 and customer_code IS NULL';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 210, connec_id, connecat_id, ''Connecs with null customer code'', the_geom, expl_id FROM connec WHERE connec_id IN (', v_querytext,')');
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 2, '210', concat('WARNING-210 (anl_connec): There is/are ',v_count,' connec with customer code null. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1, '210','INFO: No connecs with null customer code.',v_count);
	END IF;

	RAISE NOTICE '13 - Check unique customer code for connecs with state=1 (201)';
	v_querytext = 'SELECT customer_code FROM '||v_edit||'connec WHERE state=1 and customer_code IS NOT NULL group by customer_code, expl_id having count(*) > 1';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,') a ') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 201, connec_id, connecat_id, ''Connecs with customer code duplicated'', the_geom, expl_id FROM connec WHERE customer_code IN (', v_querytext,')');
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '201', concat('WARNING-201 (anl_connec): There is/are ',v_count,' connec customer code duplicated. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '201', 'INFO: No connecs with customer code duplicated.',v_count);
	END IF;


	RAISE NOTICE '14 - Check if all id are integers (202)';
	IF v_project_type = 'WS' THEN
		v_querytext = '(SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
						ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat, the_geom, expl_id FROM '||v_edit||'arc
						UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
   						ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat, the_geom, expl_id FROM '||v_edit||'node
						UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
   						ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat, the_geom, expl_id FROM '||v_edit||'connec) a';

   		EXECUTE concat('SELECT count(*) FROM ',v_querytext,' WHERE feature_id=0') INTO v_count;
   	ELSIF v_project_type = 'UD' THEN
   		v_querytext = ('(SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
						ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat,the_geom, expl_id  FROM '||v_edit||'arc
						UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
   						ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat,the_geom, expl_id FROM '||v_edit||'node
						UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
   						ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat,the_geom, expl_id FROM '||v_edit||'connec
   						UNION SELECT CASE WHEN gully_id~E''^\\d+$'' THEN CAST (gully_id AS INTEGER)
   						ELSE 0 END as feature_id, ''GULLY'' as type, gratecat_id as featurecat,the_geom, expl_id FROM '||v_edit||'gully) a');
   	END IF;

   	EXECUTE concat('SELECT count(*) FROM ',v_querytext,' WHERE feature_id=0') INTO v_count;

   	IF v_count > 0 THEN

		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 202, feature_id, featurecat, ''Connecs with id which is not an integer'', the_geom, expl_id FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''CONNEC'' ');

		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
		SELECT 202,  feature_id, featurecat, ''Arcs with id which is not an integer'', the_geom, expl_id FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''ARC'' ');

		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 202,  feature_id, featurecat, ''Nodes with id which is not an integer'', the_geom, expl_id FROM ', v_querytext,' 
		WHERE  feature_id=0 AND type = ''NODE'' ');
			
		IF v_project_type = 'UD' THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 202, feature_id, featurecat, ''Gullies with id which is not an integer'', the_geom, expl_id FROM ', v_querytext,' 
			WHERE feature_id=0 AND type = ''GULLY'' ');
		END IF;

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '202', concat('ERROR-202 (anl_arc, anl_node, anl_connec): There is/are ',v_count,' which id is not an integer. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '202', 'INFO: All features with id integer.',v_count);
	END IF;

	RAISE NOTICE '15 - Check state not according with state_type (253)';
	IF v_project_type = 'UD' THEN
		v_querytext =  'SELECT arc_id as id, a.state, state_type FROM '||v_edit||'arc a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT node_id as id, a.state, state_type FROM '||v_edit||'node a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT connec_id as id, a.state, state_type FROM '||v_edit||'connec a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT gully_id as id, a.state, state_type FROM '||v_edit||'gully a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state	
				UNION SELECT element_id as id, a.state, state_type FROM '||v_edit||'element a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
			VALUES (v_fid, 3, '253', concat('ERROR-253: There is/are ',v_count,' features(s) with state without concordance with state_type. Please, check your data before continue'),v_count);
			
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message, fcount)
			VALUES (v_fid, 1, '253','INFO: No features without concordance against state and state_type.',v_count);
		END IF;
		
	ELSIF v_project_type = 'WS' THEN
	
		v_querytext =  'SELECT arc_id as id, a.state, state_type FROM '||v_edit||'arc a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT node_id as id, a.state, state_type FROM '||v_edit||'node a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
				UNION SELECT connec_id as id, a.state, state_type FROM '||v_edit||'connec a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state	
				UNION SELECT element_id as id, a.state, state_type FROM '||v_edit||'element a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 3, '253', concat('ERROR-253: There is/are ',v_count,' features(s) with state without concordance with state_type. Please, check your data before continue'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '253', 'INFO: No features without concordance against state and state_type.',v_count);
		END IF;
	END IF;


	RAISE NOTICE '16 - Check code with null values (254)';
	IF v_project_type ='UD' THEN
		v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc WHERE code IS NULL 
					UNION SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node WHERE code IS NULL
					UNION SELECT connec_id, connecat_id, the_geom FROM '||v_edit||'connec WHERE code IS NULL
					UNION SELECT gully_id, gratecat_id, the_geom FROM '||v_edit||'gully WHERE code IS NULL
					UNION SELECT element_id, elementcat_id, the_geom FROM '||v_edit||'element WHERE code IS NULL) a';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
			VALUES (v_fid, 3, '254', concat('ERROR-254: There is/are ',v_count,' features with code with NULL values. Please, check your data before continue'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '254', 'INFO: No features (arc, node, connec, gully, element) with NULL values on code found.',v_count);
		END IF;

	ELSIF v_project_type = 'WS' THEN

		v_querytext = '(SELECT arc_id, arccat_id, the_geom FROM '||v_edit||'arc WHERE code IS NULL 
				UNION SELECT node_id, nodecat_id, the_geom FROM '||v_edit||'node WHERE code IS NULL
				UNION SELECT connec_id, connecat_id, the_geom FROM '||v_edit||'connec WHERE code IS NULL
				UNION SELECT element_id, elementcat_id, the_geom FROM '||v_edit||'element WHERE code IS NULL) a';

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
			VALUES (v_fid, 3, '254', concat('ERROR-254: There is/are ',v_count,' with code with NULL values. Please, check your data before continue'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '254', 'INFO: No features (arc, node, connec, element) with NULL values on code found.',v_count);
		END IF;
	END IF;


	RAISE NOTICE '17 - Check for orphan polygons on polygon table (255)';
	IF v_project_type ='UD' THEN
		IF v_edit IS NULL THEN 
			v_querytext = '(SELECT pol_id FROM polygon WHERE feature_id IS NULL OR feature_id NOT IN (SELECT gully_id FROM gully UNION
			SELECT node_id FROM node UNION SELECT connec_id FROM connec)) b';
		ELSE
			v_querytext = '(SELECT * FROM (SELECT pol_id, feature_id FROM ve_pol_node UNION SELECT pol_id, feature_id FROM ve_pol_connec UNION SELECT pol_id, feature_id FROM ve_pol_gully) a 
			WHERE feature_id IS NULL OR feature_id NOT IN (SELECT gully_id FROM gully UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec)) b';
		END IF; 

		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '255', concat('WARNING-255: There is/are ',v_count,' polygons without parent. Check your data before continue.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '255','INFO: No polygons without parent feature found.',v_count);
		END IF;
	ELSIF v_project_type='WS' THEN
		IF v_edit IS NULL THEN 
			v_querytext = '(SELECT pol_id FROM polygon WHERE feature_id IS NULL OR feature_id NOT IN (SELECT node_id FROM node UNION SELECT connec_id FROM connec)) a';
		ELSE
			v_querytext = '(SELECT * FROM (SELECT * FROM ve_pol_node UNION SELECT * FROM ve_pol_connec)b 
			WHERE feature_id IS NULL OR feature_id NOT IN (SELECT node_id FROM node UNION SELECT connec_id FROM connec))a';
		END IF;
		EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
		
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '255', concat('WARNING-255: There is/are ',v_count,' polygons without parent. Check your data before continue.'), v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '255', 'INFO: No polygons without parent feature found.', v_count);
		END IF;
	END IF;
    
	RAISE NOTICE '18 - connec/gully without link (204)';
    
	v_querytext = 'SELECT connec_id, connecat_id, c.the_geom, c.expl_id from '||v_edit||'connec c WHERE c.state= 1 
					AND connec_id NOT IN (SELECT feature_id FROM link)
					EXCEPT 
					SELECT connec_id, connecat_id, c.the_geom, c.expl_id FROM '||v_edit||'connec c
					LEFT JOIN '||v_edit||'arc a USING (arc_id) WHERE c.state= 1 
					AND arc_id IS NOT NULL AND st_dwithin(c.the_geom, a.the_geom, 0.1)';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 204, connec_id, connecat_id, ''Connecs without links'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '204', 2, concat('WARNING-204 (anl_connec): There is/are ',v_count,' connecs without links or connecs over arc without arc_id'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '204',1, 'INFO: All connecs have links or are over arc with arc_id.',v_count);
	END IF;

	IF v_project_type = 'UD' THEN 
					
		v_querytext = 'SELECT gully_id, gratecat_id, c.the_geom, c.expl_id from '||v_edit||'gully c WHERE c.state= 1 
						AND gully_id NOT IN (SELECT feature_id FROM link)
						EXCEPT 
						SELECT gully_id, gratecat_id, c.the_geom, c.expl_id FROM '||v_edit||'gully c
						LEFT JOIN '||v_edit||'arc a USING (arc_id) WHERE c.state= 1 
						AND arc_id IS NOT NULL AND st_dwithin(c.the_geom, a.the_geom, 0.1)';
	

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
		
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 204, gully_id, gratecat_id, ''Gullies without links'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, '204',2, concat('WARNING-204 (anl_connec): There is/are ',v_count,' gullies without links or gullies over arc without arc_id.'), v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid,'204', 1, 'INFO: All gullies have links or are over arc with arc_id.', v_count);
		END IF;
	
	END IF;


	RAISE NOTICE '19 - connec/gully without arc_id or with arc_id different than the one to which points its link (257)';

	v_querytext = 'SELECT c.connec_id, c.connecat_id, c.the_geom, c.expl_id, l.feature_type, link_id 
		FROM arc a, link l
		JOIN '||v_edit||'connec c ON l.feature_id = c.connec_id 
		WHERE st_dwithin(a.the_geom, st_endpoint(l.the_geom), 0.01)
		AND exit_type = ''ARC''
		AND (a.arc_id <> c.arc_id or c.arc_id is null) 
		AND l.feature_type = ''CONNEC'' AND a.state=1 and c.state = 1 and l.state=1
		EXCEPT
		SELECT c.connec_id, c.connecat_id, c.the_geom, c.expl_id, l.feature_type, link_id
		FROM node n, link l
		JOIN '||v_edit||'connec c ON l.feature_id = c.connec_id 
		WHERE st_dwithin(n.the_geom, st_endpoint(l.the_geom), 0.01)
		AND exit_type IN (''NODE'', ''ARC'')
		AND l.feature_type = ''CONNEC'' AND n.state=1 and c.state = 1 and l.state=1
		ORDER BY feature_type, link_id';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 257, connec_id, connecat_id, ''Connecs without or with incorrect arc_id'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
			VALUES (v_fid, 2, '257', concat('WARNING-257 (anl_connec): There is/are ',v_count,' connecs without or with incorrect arc_id.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
			VALUES (v_fid, 1, '257', 'INFO: All connecs have correct arc_id.',v_count);
		END IF;

		IF v_project_type = 'UD' THEN
			v_querytext = 'SELECT c.gully_id, c.gratecat_id, c.the_geom, c.expl_id, l.feature_type, link_id 
				FROM arc a, link l
				JOIN '||v_edit||'gully c ON l.feature_id = c.gully_id 
				WHERE st_dwithin(a.the_geom, st_endpoint(l.the_geom), 0.01)
				AND exit_type = ''ARC''
				AND (a.arc_id <> c.arc_id or c.arc_id is null) 
				AND l.feature_type = ''GULLY'' AND a.state=1 and c.state = 1 and l.state=1
				EXCEPT
				SELECT c.gully_id, c.gratecat_id, c.the_geom, c.expl_id, l.feature_type, link_id
				FROM node n, link l
				JOIN '||v_edit||'gully c ON l.feature_id = c.gully_id 
				WHERE st_dwithin(n.the_geom, st_endpoint(l.the_geom), 0.01)
				AND exit_type IN (''NODE'', ''ARC'')
				AND l.feature_type = ''GULLY'' AND n.state=1 and c.state = 1 and l.state=1
				ORDER BY feature_type, link_id';

			EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

			IF v_count > 0 THEN
				EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
				SELECT 257, gully_id, gratecat_id, ''Gully without or with incorrect arc_id'', the_geom, expl_id FROM (', v_querytext,')a');

				INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
				VALUES (v_fid, 2, '257', concat('WARNING-257 (anl_gully): There is/are ',v_count,' gullies without or with incorrect arc_id.'),v_count);
			ELSE
				INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
				VALUES (v_fid, 1, '257', 'INFO: All gullies have correct arc_id.', v_count);
			END IF;
		END IF;

	RAISE NOTICE '20 - links without feature_id (260)';
	v_querytext = 'SELECT link_id, the_geom FROM '||v_edit||'link where feature_id is null and state > 0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 3, '260', concat('ERROR-260: There is/are ',v_count,' links with state > 0 without feature_id.'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '260', 'INFO: All links state > 0 have feature_id.', v_count);
	END IF;

	RAISE NOTICE '23 - links without exit_id (261)';
	v_querytext = 'SELECT link_id, the_geom FROM '||v_edit||'link where exit_id is null and state > 0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '261',concat('ERROR-261: There is/are ',v_count,' links with state > 0 without exit_id.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '261', 'INFO: All links state > 0 have exit_id.',v_count);
	END IF;


	RAISE NOTICE '21 - Chained connecs/gullies which has different arc_id than the final connec/gully. (205)';
	IF v_project_type = 'WS' THEN 
		v_querytext = 'with c as (
					Select '||v_edit||'connec.connec_id as id, arc_id as arc, '||v_edit||'connec.connecat_id as 
					feature_catalog, the_geom, '||v_edit||'connec.expl_id
					from '||v_edit||'connec
					)
					select c1.id, c1.feature_catalog, c1.the_geom, c1.expl_id
					from link a
					left join c c1 on a.feature_id = c1.id
					left join c c2 on a.exit_id = c2.id
					where (a.exit_type =''CONNEC'')
					and c1.arc <> c2.arc';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'with c as (
					Select '||v_edit||'connec.connec_id as id, arc_id as arc,'||v_edit||'connec.connecat_id as 
					feature_catalog, the_geom, '||v_edit||'connec.expl_id from '||v_edit||'connec
					UNION select '||v_edit||'gully.gully_id as id, arc_id as arc,'||v_edit||'gully.gratecat_id, 
					the_geom, '||v_edit||'gully.expl_id  from '||v_edit||'gully
					)
					select c1.id, c1.feature_catalog, c1.the_geom,  c1.expl_id
					from link a
					left join c c1 on a.feature_id = c1.id
					left join c c2 on a.exit_id = c2.id
					where (a.exit_type =''CONNEC'' OR a.exit_type =''GULLY'')
					and c1.arc <> c2.arc';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		IF v_project_type = 'UD' THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 205, id, feature_catalog, ''Chained connecs or gullies with different arc_id'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '205', concat('WARNING-205 (anl_connec): There is/are ',v_count,' chained connecs or gullies with different arc_id.'),v_count);
		ELSIF v_project_type = 'WS' THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 205, id, feature_catalog, ''Chained connecs with different arc_id'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '205',concat('WARNING-205 (anl_connec): There is/are ',v_count,' chained connecs with different arc_id.'),v_count);
		END IF;
	ELSE
		IF v_project_type = 'UD' THEN	
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '205','INFO: All chained connecs and gullies have the same arc_id',v_count);
		ELSIF v_project_type = 'WS' THEN
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '205','INFO: All chained connecs have the same arc_id', v_count);
		END IF;
	END IF;

	RAISE NOTICE '22 - features with state 1 and end date (262)';
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
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message, fcount)
		VALUES (v_fid, 2, '262',concat('WARNING-262: There is/are ',v_count,' features on service with value of end date.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '262', 'INFO: No features on service have value of end date', v_count);
	END IF;

	RAISE NOTICE '23 - features with state 0 and without end date (263)';
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
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 2, '263', concat('WARNING-263: There is/are ',v_count,' features with state 0 without value of end date.'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1, '263','INFO: No features with state 0 are missing the end date',v_count);
	END IF;

	RAISE NOTICE '24 - features with state 1 and end date before start date (264)';
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT arc_id as feature_id  from '||v_edit||'arc where enddate < builtdate and state = 1
					UNION SELECT node_id from '||v_edit||'node where enddate < builtdate and state = 1
					UNION SELECT connec_id from '||v_edit||'connec where enddate < builtdate and state = 1';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT arc_id as feature_id from '||v_edit||'arc where enddate < builtdate and state = 1
					UNION SELECT node_id from '||v_edit||'node where enddate < builtdate and state = 1
					UNION SELECT connec_id from '||v_edit||'connec where enddate < builtdate and state = 1
					UNION SELECT gully_id from '||v_edit||'gully where enddate < builtdate and state = 1';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '264',concat('WARNING-264: There is/are ',v_count,' features with end date earlier than built date.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '264','INFO: No features with end date earlier than built date',v_count);
	END IF;

	RAISE NOTICE '25 - Automatic links with more than 100 mts (length out-of-range) (265)';

	EXECUTE 'SELECT count(*) FROM '||v_edit||'link where st_length(the_geom) > 100'
	INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 2, '265', concat('WARNING-265: There is/are ',v_count,' automatic links with longitude out-of-range found.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1,'265', 'INFO: No automatic links with out-of-range Longitude found.',v_count);
	END IF;

    RAISE NOTICE '26 - Duplicated ID values between arc, node, connec, gully(266)';
	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT node_id AS feature_id FROM '||v_edit||'node n JOIN '||v_edit||'arc a ON a.arc_id=n.node_id
					UNION SELECT node_id FROM '||v_edit||'node n JOIN '||v_edit||'connec c ON c.connec_id=n.node_id
					UNION SELECT a.arc_id FROM '||v_edit||'arc a JOIN '||v_edit||'connec c ON c.connec_id=a.arc_id';	
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT node_id AS feature_id FROM '||v_edit||'node n JOIN '||v_edit||'arc a ON a.arc_id=n.node_id
					UNION SELECT node_id FROM '||v_edit||'node n JOIN '||v_edit||'connec c ON c.connec_id=n.node_id
					UNION SELECT node_id FROM '||v_edit||'node n JOIN '||v_edit||'gully g ON g.gully_id=n.node_id
					UNION SELECT connec_id FROM '||v_edit||'connec c JOIN '||v_edit||'gully g ON g.gully_id=c.connec_id
					UNION SELECT a.arc_id FROM '||v_edit||'arc a JOIN '||v_edit||'connec c ON c.connec_id=a.arc_id	
					UNION SELECT a.arc_id FROM '||v_edit||'arc a JOIN '||v_edit||'gully g ON g.gully_id=a.arc_id';	
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count = 1 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '266', concat('ERROR-266: There is ',v_count,' feature with duplicated ID value between arc, node, connec, gully '), v_count);
	ELSIF v_count > 1 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '266', concat('ERROR-266: There are ',v_count,' features with duplicated ID values between arc, node, connec, gully '), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '266','INFO: All features have a diferent ID to be correctly identified',v_count);
	END IF;

	RAISE NOTICE '27 - Check planned connects without reference link (356)';

	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT count(*) FROM plan_psector_x_connec WHERE link_id IS NULL';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT count(*) FROM (SELECT * FROM plan_psector_x_connec WHERE link_id IS NULL
				UNION SELECT * FROM plan_psector_x_gully WHERE link_id IS NULL)a';
	END IF;


	EXECUTE v_querytext INTO v_count;

	IF v_count = 1 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '356', concat('ERROR-356: There is ',v_count,' planned connec or gully without reference link'), v_count);
	ELSIF v_count > 1 THEN
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '356', concat('ERROR-356: There are ',v_count,' planned connecs or gullys without reference link'), v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '356', 'INFO: All planned connecs or gullys have a reference link', v_count);
	END IF;


	RAISE NOTICE '28 - Connecs and gullies with different expl_id than arc (291)';

	IF v_project_type = 'WS' THEN
		v_querytext = 'SELECT DISTINCT connec_id, connecat_id, c.the_geom, c.expl_id FROM '||v_edit||'connec c JOIN '||v_edit||'arc b using (arc_id) WHERE b.expl_id::text != c.expl_id::text';
	ELSIF v_project_type = 'UD' THEN
		v_querytext = 'SELECT * FROM (SELECT DISTINCT connec_id, connecat_id, c.the_geom, c.expl_id FROM '||v_edit||'connec c JOIN '||v_edit||'arc b using (arc_id) 
		WHERE b.expl_id::text != c.expl_id::text
		UNION SELECT DISTINCT  gully_id, gratecat_id, g.the_geom gully_id, g.expl_id FROM '||v_edit||'gully g JOIN '||v_edit||'arc d using (arc_id) WHERE d.expl_id::text != g.expl_id::text)a';
	END IF;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count = 1 THEN
		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 291, connec_id, connecat_id, ''Connec or gully with different expl_id than related arc'', the_geom, expl_id FROM (', v_querytext,')a');
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message)
		VALUES (v_fid, 3, '291', concat('ERROR-291 (anl_connec): There is ',v_count,' connec or gully with exploitation different than the exploitation of the related arc'));
	ELSIF v_count > 1 THEN
		EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
		SELECT 291, connec_id, connecat_id, ''Connec or gully with different expl_id than related arc'', the_geom, expl_id FROM (', v_querytext,')a');
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message)
		VALUES (v_fid, 3, '291', concat('ERROR-291 (anl_connec): There are ',v_count,' connecs or gullies with exploitation different than the exploitation of the related arc'));
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message)
		VALUES (v_fid, 1, '291', 'INFO: All connecs or gullys have the same exploitation as the related arc');
	END IF;


	IF (SELECT value::boolean FROM config_param_system WHERE parameter = 'admin_crm_schema') IS TRUE THEN 

		RAISE NOTICE '29 - Control null values on crm.hydrometer.code(299)';
		v_querytext = 'SELECT id FROM crm.hydrometer WHERE code IS NULL';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
			VALUES (v_fid, 3, '299', concat('ERROR-299: There is/are ',v_count,' hydrometers in crm schema without code.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
			VALUES (v_fid, 1, '299','INFO: All hydrometers on crm schema have code',v_count);
		END IF;
	END IF;

	RAISE NOTICE '30 - Check operative arcs with wrong topology (372)';
	
	EXECUTE 'INSERT INTO temp_t_arc (arc_id, node_1, node_2, result_id, sector_id,state) SELECT arc_id, node_1, node_2, ''372'', sector_id,state 
			 FROM '||v_edit||'arc WHERE state = 1';
	-- update node_1
	UPDATE temp_t_arc t SET node_1 = node_id, state = 9 FROM (
	SELECT arc.arc_id, node.node_id, min(ST_Distance(node.the_geom, ST_startpoint(arc.the_geom))) as d FROM node, arc 
	WHERE arc.state = 1 and node.state = 1 and ST_DWithin(ST_startpoint(arc.the_geom), node.the_geom, 0.02) group by 1,2 ORDER BY 1 DESC,3 DESC
	)a where t.arc_id = a.arc_id AND t.node_1 != a.node_id;
	
	--update node_2
	UPDATE temp_t_arc t SET node_2 = node_id, state = 9 FROM (
	SELECT arc.arc_id, node.node_id, min(ST_Distance(node.the_geom, ST_endpoint(arc.the_geom))) as d FROM node, arc 
	WHERE arc.state = 1 and node.state = 1 and ST_DWithin(ST_endpoint(arc.the_geom), node.the_geom, 0.02) group by 1,2 ORDER BY 1 DESC,3 DESC
	)a where t.arc_id = a.arc_id AND t.node_2 != a.node_id;

	EXECUTE 'SELECT count(*) FROM temp_t_arc WHERE state = 9'
	INTO v_count;
	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, node_1, node_2, descript, the_geom, expl_id)
		SELECT 372, t.arc_id, t.node_1, t.node_2, concat(''Operative arcs with wrong topology. Proposed nodes: {node_1:'',t.node_1,'', node_2:'', t.node_2, ''}''), a.the_geom, a.expl_id 
		FROM temp_t_arc t JOIN arc a USING(arc_id) WHERE t.state = 9'	;
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 3, '372', concat('ERROR-372 (anl_arc): There is/are ',v_count,' operative arcs with wrong topology.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '372','INFO: All arcs has well-defined topology',v_count);
	END IF;
	

	RAISE NOTICE '31 - Check arcs shorter than value set as node proximity (391)';

	v_querytext = 'SELECT arc_id,arccat_id,st_length(the_geom), the_geom, expl_id, json_extract_path_text(value::json,''value'')::numeric as nprox
	FROM '||v_edit||'arc, config_param_system where parameter = ''edit_node_proximity''
	and  st_length(the_geom) < json_extract_path_text(value::json,''value'')::numeric ';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
		SELECT 391, arc_id, arccat_id, ''arcs shorter than value set as node proximity'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, 391, 2, 
		concat('WARNING-391 (anl_arc): There is/are ',v_count,' arc(s) with length shorter than value set as node proximity. Please, check your data before continue'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '391', 1, 'INFO: No arcs shorter than value set as node proximity.',v_count);
	END IF;


	RAISE NOTICE '32 - Check builtdate before 1900  (fid 406)';
	IF v_project_type = 'WS' THEN
		v_querytext='SELECT arc_id, ''ARC''::text FROM '||v_edit||'arc WHERE builtdate < ''1900/01/01''::date
				UNION 
				SELECT  node_id, ''NODE''::text FROM '||v_edit||'node WHERE builtdate < ''1900/01/01''::date
				UNION  
				SELECT  connec_id, ''CONNEC''::text FROM '||v_edit||'connec WHERE builtdate < ''1900/01/01''::date';
				
		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	
	ELSE
		v_querytext='SELECT arc_id, ''ARC''::text FROM '||v_edit||'arc WHERE builtdate < ''1900/01/01''::date
				UNION 
				SELECT  node_id, ''NODE''::text FROM '||v_edit||'node WHERE builtdate < ''1900/01/01''::date
				UNION  
				SELECT  connec_id, ''CONNEC''::text FROM '||v_edit||'connec WHERE builtdate < ''1900/01/01''::date
				UNION 
				SELECT  gully_id, ''GULLY''::text FROM '||v_edit||'gully WHERE builtdate < ''1900/01/01''::date';
				
		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	END IF;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, 406, 2, 
		concat('WARNING-406: There is/are ',v_count,' features with built date before 1900.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '406', 1, 'INFO: No feature with builtdate before 1900.',v_count);
	END IF;


	RAISE NOTICE '33 - Check operative links with wrong topology (417, 418)';

	-- connec_id (417)
	DELETE FROM temp_t_arc;

	IF v_edit IS NULL THEN 
		INSERT INTO temp_t_arc (arc_id, node_1, result_id, state, the_geom) SELECT link_id, feature_id, '417', l.state, l.the_geom 
		FROM link l JOIN connec c ON feature_id = connec_id WHERE l.state = 1 and l.feature_type = 'CONNEC';

		UPDATE temp_t_arc t SET node_1 = connec_id, state = 9 FROM (
		SELECT l.link_id, c.connec_id, (ST_Distance(c.the_geom, ST_startpoint(l.the_geom))) as d FROM connec c, link l
		WHERE l.state = 1 and c.state = 1 and ST_DWithin(ST_startpoint(l.the_geom), c.the_geom, 0.05) group by 1,2,3 ORDER BY 1 DESC,3 DESC
		)a where t.arc_id = a.link_id::text AND t.node_1 = a.connec_id;
	ELSE
		INSERT INTO temp_t_arc (arc_id, node_1, result_id, sector_id, state, the_geom) SELECT link_id, feature_id, '417', l.sector_id, l.state, l.the_geom 
		FROM link l JOIN v_edit_connec c ON feature_id = connec_id WHERE l.state > 0 and l.feature_type = 'CONNEC';

		UPDATE temp_t_arc t SET node_1 = connec_id, state = 9 FROM (
		SELECT l.link_id, c.connec_id, (ST_Distance(c.the_geom, ST_startpoint(l.the_geom))) as d FROM v_edit_connec c, link l
		WHERE l.state = 1 and c.state = 1 and ST_DWithin(ST_startpoint(l.the_geom), c.the_geom, 0.05) group by 1,2,3 ORDER BY 1 DESC,3 DESC
		)a where t.arc_id = a.link_id::text AND t.node_1 = a.connec_id;
	END IF;

	EXECUTE 'SELECT count(*) FROM temp_t_arc WHERE state = 1'
	INTO v_count;
	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, node_1, arccat_id, descript, the_geom, expl_id)
		SELECT 417, t.arc_id, t.node_1, ''LINK'', concat(''Link with wrong topology. Startpoint does not fit with connec '',t.node_1), t.the_geom, a.expl_id 
		FROM temp_t_arc t JOIN '||v_edit||'connec a ON node_1 = connec_id WHERE t.state = 1';
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '417', concat('ERROR-417 (anl_arc): There is/are ',v_count,' links related to connecs with wrong topology, startpoint does not fit connec'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '417','INFO: All connec links has connec on startpoint',v_count);
	END IF;

	-- gullys (418)
	IF v_project_type = 'UD' THEN
		DELETE FROM temp_t_arc;

		IF v_edit IS NULL THEN
			INSERT INTO temp_t_arc (arc_id, node_1, result_id, sector_id, state, the_geom) SELECT link_id, feature_id, '418', l.sector_id, l.state, l.the_geom 
			FROM link l JOIN gully g ON feature_id = gully_id WHERE l.state = 1 and l.feature_type = 'GULLY' ;

			UPDATE temp_t_arc t SET node_1 = gully_id, state = 9 FROM (
			SELECT l.link_id, g.gully_id, (ST_Distance(g.the_geom, ST_startpoint(l.the_geom))) as d FROM gully g, link l
			WHERE l.state = 1 and g.state = 1 and ST_DWithin(ST_startpoint(l.the_geom), g.the_geom, 0.05) group by 1,2,3 ORDER BY 1 DESC,3 DESC
			)a where t.arc_id = a.link_id::text AND t.node_1 = a.gully_id;
		ELSE
			INSERT INTO temp_t_arc (arc_id, node_1, result_id, sector_id, state, the_geom) SELECT link_id, feature_id, '418', l.sector_id, l.state, l.the_geom 
			FROM link l JOIN gully g ON feature_id = gully_id WHERE l.state = 1 and l.feature_type = 'GULLY' ;

			UPDATE temp_t_arc t SET node_1 = gully_id, state = 9 FROM (
			SELECT l.link_id, g.gully_id, (ST_Distance(g.the_geom, ST_startpoint(l.the_geom))) as d FROM gully g, link l
			WHERE l.state = 1 and g.state = 1 and ST_DWithin(ST_startpoint(l.the_geom), g.the_geom, 0.05) group by 1,2,3 ORDER BY 1 DESC,3 DESC
			)a where t.arc_id = a.link_id::text AND t.node_1 = a.gully_id;
		END IF;

		EXECUTE 'SELECT count(*) FROM temp_t_arc WHERE state = 1'
		INTO v_count;
		IF v_count > 0 THEN
			EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, node_1, arccat_id, descript, the_geom, expl_id)
			SELECT 418, t.arc_id, t.node_1, ''LINK'', concat(''Link with wrong topology. Startpoint does not fit with gully '',t.node_1), t.the_geom, a.expl_id 
			FROM temp_t_arc t JOIN '||v_edit||'gully a ON node_1 = gully_id WHERE t.state = 1';
			INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
			VALUES (v_fid, 3, '418', concat('ERROR-418 (anl_arc): There is/are ',v_count,' links related to gully with wrong topology, startpoint does not fit gully)'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
			VALUES (v_fid, 1, '418','INFO: All gully links has gully on startpoint',v_count);
		END IF;
	END IF;

	RAISE NOTICE '34 - Check hydrometer related to more than one connec (419)';
	v_querytext = 'SELECT hydrometer_id, count(*) FROM v_rtc_hydrometer  group by hydrometer_id having count(*)> 1 ';
	EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a'
	INTO v_count;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 2, '419', concat('WARNING-419: There is/are ',v_count,' hydrometer related to more than one connec.'),v_count);
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 2, '419', concat('HINT-419: Type ''SELECT hydrometer_id, count(*) FROM v_rtc_hydrometer  group by hydrometer_id having count(*)> 1'''),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '419','INFO: All hydrometeres are related to a unique connec',v_count);
	END IF;

	RAISE NOTICE '35- Check category_type values which do not exists on man_type table (421)';
	IF v_project_type = 'WS' THEN
		v_querytext='SELECT ''ARC'', arc_id, category_type FROM '||v_edit||'arc WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, category_type FROM '||v_edit||'node WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, category_type FROM '||v_edit||'connec WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL';
		
		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	ELSE
		v_querytext='SELECT ''ARC'', arc_id, category_type FROM '||v_edit||'arc WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, category_type FROM '||v_edit||'node WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, category_type FROM '||v_edit||'connec WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
		UNION
		SELECT ''GULLY'', gully_id, category_type FROM '||v_edit||'gully WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL';

		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	END IF;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 3, '421', concat('ERROR-421: There is/are ',v_count,' features with category_type does not exists on man_type_category table.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '421','INFO: All features has category_type informed on man_type_category table',v_count);
	END IF;

	RAISE NOTICE '36- Check function_type values which do not exists on man_type table (422)';
	IF v_project_type = 'WS' THEN
		v_querytext='SELECT ''ARC'', arc_id, function_type FROM '||v_edit||'arc WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, function_type FROM '||v_edit||'node WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, function_type FROM '||v_edit||'connec WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL';
		
		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	ELSE
		v_querytext='SELECT ''ARC'', arc_id, function_type FROM '||v_edit||'arc WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, function_type FROM '||v_edit||'node WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, function_type FROM '||v_edit||'connec WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
		UNION
		SELECT ''GULLY'', gully_id, function_type FROM '||v_edit||'gully WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL';

		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	END IF;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 3, '422', concat('ERROR-422: There is/are ',v_count,' features with function_type does not exists on man_type_function table.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '422','INFO: All features has function_type informed on man_type_function table',v_count);
	END IF;


	RAISE NOTICE '37- Check fluid_type values which do not exists on man_type table (423)';
	IF v_project_type = 'WS' THEN
		v_querytext='SELECT ''ARC'', arc_id, fluid_type FROM '||v_edit||'arc WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, fluid_type FROM '||v_edit||'node WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, fluid_type FROM '||v_edit||'connec WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL';
		
		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	ELSE
		v_querytext='SELECT ''ARC'', arc_id, fluid_type FROM '||v_edit||'arc WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, fluid_type FROM '||v_edit||'node WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, fluid_type FROM '||v_edit||'connec WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
		UNION
		SELECT ''GULLY'', gully_id, fluid_type FROM '||v_edit||'gully WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL';

		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	END IF;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 3, '423', concat('ERROR-423: There is/are ',v_count,' features with fluid_type does not exists on man_type_fluid table.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '423','INFO: All features has fluid_type informed on man_type_fluid table',v_count);
	END IF;

	RAISE NOTICE '38- Check location_type values which do not exists on man_type table (424)';
	IF v_project_type = 'WS' THEN
		v_querytext='SELECT ''ARC'', arc_id, location_type FROM '||v_edit||'arc WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, location_type FROM '||v_edit||'node WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, location_type FROM '||v_edit||'connec WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL';
		
		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	ELSE
		v_querytext='SELECT ''ARC'', arc_id, location_type FROM '||v_edit||'arc WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
		UNION
		SELECT ''NODE'', node_id, location_type FROM '||v_edit||'node WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
		UNION
		SELECT ''CONNEC'', connec_id, location_type FROM '||v_edit||'connec WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
		UNION
		SELECT ''GULLY'', gully_id, location_type FROM '||v_edit||'gully WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL';

		EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a' INTO v_count;
	END IF;

	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
		VALUES (v_fid, 3, '424', concat('ERROR-424: There is/are ',v_count,' features with location_type does not exists on man_type_location table.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
		VALUES (v_fid, 1, '424','INFO: All features has location_type informed on man_type_location table',v_count);
	END IF;

	RAISE NOTICE '39- Check expl.the_geom is not null when raster DEM is enabled (428)';
	IF (SELECT json_extract_path_text(value::json,'activated')::boolean FROM config_param_system WHERE parameter='admin_raster_dem') IS TRUE THEN
		SELECT count(*) INTO v_count FROM exploitation WHERE the_geom IS NULL AND active IS TRUE and expl_id > 0 ;
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, criticity,result_id,error_message, fcount)
			SELECT v_fid, 2, '428', 
			concat('WARNING-428: There is/are ',v_count,' exploitation(s) without geometry. Capturing values from DEM is enabled, but it will fail on exploitation: ',string_agg(name,', ')),v_count 
			FROM exploitation WHERE the_geom IS NULL AND active IS TRUE and expl_id > 0 ;
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity,result_id, error_message,fcount)
			VALUES (v_fid, 1, '428','INFO: Capturing values from DEM is enabled and will work correctly as all exploitations have geometry.',v_count);
		END IF;
	END IF;

	RAISE NOTICE '40 - Check nodes duplicated (106)';

	v_querytext = 'SELECT * FROM (SELECT DISTINCT t1.node_id AS node_1, t1.nodecat_id AS nodecat_1, t1.state as state1, t2.node_id AS node_2, t2.nodecat_id AS nodecat_2, t2.state as state2, t1.expl_id, 106, t1.the_geom
	FROM '||v_edit||'node AS t1 JOIN node AS t2 ON ST_Dwithin(t1.the_geom, t2.the_geom, 0.01) WHERE t1.node_id != t2.node_id ORDER BY t1.node_id ) a where a.state1 = 1 AND a.state2 = 1';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 106, node_1, nodecat_1, ''Duplicated nodes'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '106', concat('ERROR-106 (anl_node): There is/are ',v_count,' nodes duplicated with state 1.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '106','INFO: There are no nodes duplicated with state 1',v_count);
	END IF;

	RAISE NOTICE '41 - Check orphan nodes with isarcdivide=TRUE (OM)(442)';

	IF v_project_type = 'WS' THEN
		v_partialquery = 'JOIN cat_node nc ON nodecat_id=id JOIN cat_feature_node nt ON nt.id=nc.nodetype_id';
	ELSIF v_project_type = 'UD' THEN
		v_partialquery = 'JOIN cat_feature_node ON id = a.node_type';
	END IF;

	v_querytext = 'SELECT  * FROM '||v_edit||'node a '||v_partialquery||' WHERE a.state>0 AND isarcdivide= ''true'' 
	AND (SELECT COUNT(*) FROM arc WHERE node_1 = a.node_id OR node_2 = a.node_id and arc.state>0) = 0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 442, node_id, nodecat_id, ''Orphan nodes with isarcdivide=TRUE'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '442', concat('WARNING-442 (anl_node): There is/are ',v_count,' orphan nodes with isarcdivide=TRUE.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '442','INFO: There are no orphan nodes with isarcdivide=TRUE',v_count);
	END IF;

	RAISE NOTICE '42 - Check orphan nodes with isarcdivide=FALSE (OM)(443)';

	IF v_project_type = 'WS' THEN
		v_partialquery = 'JOIN cat_node nc ON nodecat_id=id JOIN cat_feature_node nt ON nt.id=nc.nodetype_id WHERE a.state>0 AND isarcdivide=''false'' AND arc_id IS NULL';
	ELSIF v_project_type = 'UD' THEN
		v_partialquery = 'JOIN cat_feature_node ON id = a.node_type WHERE a.state>0 AND isarcdivide=''false''';
	END IF;

	v_querytext = 'SELECT  * FROM '||v_edit||'node a '||v_partialquery;

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 443, node_id, nodecat_id, ''Orphan nodes with isarcdivide=FALSE'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '443', concat('WARNING-443 (anl_node): There is/are ',v_count,' orphan nodes with isarcdivide=FALSE.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '443','INFO: There are no orphan nodes with isarcdivide=FALSE',v_count);
	END IF;

	RAISE NOTICE '43 - Check nodes planified duplicated(453)';
	v_querytext = 'SELECT * FROM (SELECT DISTINCT t1.node_id AS node_1, t1.nodecat_id AS nodecat_1, t1.state as state1, t2.node_id AS node_2, t2.nodecat_id AS nodecat_2, t2.state as state2, t1.expl_id, 453, t1.the_geom
	FROM '||v_edit||'node AS t1 JOIN '||v_edit||'node AS t2 ON ST_Dwithin(t1.the_geom, t2.the_geom, 0.01) WHERE t1.node_id != t2.node_id ORDER BY t1.node_id ) a where a.state1 = 2 AND a.state2 = 2';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
		SELECT 453, node_1, nodecat_1, ''Duplicated nodes'', the_geom, expl_id FROM (', v_querytext,')a');

		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '453', concat('ERROR-453 (anl_node): There is/are ',v_count,' nodes duplicated with state 2.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '453','INFO: There are no nodes duplicated with state 2',v_count);
	END IF;

	RAISE NOTICE '44 - Check redundant values on y-top_elev-elev (461)';

	IF v_project_type = 'UD' THEN

		-- nodes
		v_querytext = 'SELECT node_id, nodecat_id, the_geom, expl_id FROM '||v_edit||'node WHERE (ymax is not null or custom_ymax is not null) 
			      and (top_elev is not null or custom_top_elev is not null) and (elev is not null or custom_elev is not null)';
		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, nodecat_id, descript, the_geom, expl_id)
			SELECT 461, node_id, nodecat_id, ''Redundant values on y-top_elev-elev'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '461', concat('WARNING-461 (anl_node): There is/are ',v_count,' nodes with redundancy on ymax, top_elev & elev values.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '461','INFO: There are no nodes with redundancy on ymax, top_elev & elev values.',v_count);
		END IF;

		-- arcs
		v_querytext = 'SELECT arc_id, arccat_id, the_geom, expl_id FROM '||v_edit||'arc WHERE (y1 is not null or custom_y1 is not null)  
			       and  (elev1 is not null or custom_elev1 is not null)';

		EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;

		IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 461, arc_id, arccat_id, ''Redundant values on y1/y2-elev1/elev2'', the_geom, expl_id FROM (', v_querytext,')a');

			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 2, '461', concat('WARNING-461 (anl_arc): There is/are ',v_count,' arcs with redundancy on y1/y2, elev1/elev2 values.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
			VALUES (v_fid, 1, '461','INFO: There are no arcs with redundancy on y1/y2, elev1/elev2 values.',v_count);
		END IF;
	END IF;

	RAISE NOTICE '45 - Check sector_id 0 or -1 (connec, gully) (478)';

	IF v_project_type = 'WS' THEN
		v_querytext = '(SELECT connec_id, connecat_id, the_geom, expl_id FROM '||v_edit||'connec WHERE state > 0 AND (sector_id=0 OR sector_id=-1))a';
  ELSIF v_project_type = 'UD' THEN
		v_querytext = '(SELECT connec_id, connecat_id, the_geom, expl_id FROM '||v_edit||'connec WHERE state > 0 AND (sector_id=0 OR sector_id=-1)
		        UNION SELECT gully_id, gratecat_id, the_geom, expl_id FROM '||v_edit||'gully WHERE state > 0 AND (sector_id=0 OR sector_id=-1))a';
  END IF;

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
			SELECT 478, connec_id, connecat_id, ''Sector_id with 0 or -1 values'', the_geom, expl_id FROM ', v_querytext,'');

		INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (v_fid, 2, '478',concat('WARNING-478: There is/are ',v_count,' features (connec, gullys) with sector_id 0 or -1.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '478', 'INFO: No features (connec, gullys) with 0 or -1 value on sector_id.',v_count);
	END IF;

	RAISE NOTICE '46 - Check arcs with the same geometry (479)';

	v_querytext = ' (SELECT arc_id, arccat_id, state1, arc_id_aux, node_1, node_2, expl_id, the_geom FROM
				    (WITH q_arc AS (SELECT * FROM arc JOIN v_state_arc using (arc_id))
					SELECT DISTINCT t1.arc_id, t1.arccat_id, t1.state as state1, t2.arc_id as arc_id_aux, 
					t2.state as state2, t1.node_1, t1.node_2, t1.expl_id, t1.the_geom
					FROM q_arc AS t1 JOIN q_arc AS t2 USING(the_geom) JOIN '||v_edit||'arc v ON t1.arc_id = v.arc_id
					WHERE t1.arc_id != t2.arc_id ORDER BY t1.arc_id )a 
					where a.state1 > 0 AND a.state2 > 0	) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
			EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 479, arc_id, arccat_id,''Arcs with duplicated geometry'', the_geom, expl_id FROM ', v_querytext,'');

		INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '479',concat('ERROR-479: There is/are ',v_count,' arcs with duplicated geometry.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 1, '479', 'INFO: No arcs with duplicated geometry.',v_count);
	END IF;
    
    RAISE NOTICE '47 - Check connecs related to arcs with diameter bigger than defined value (488) (ws)';
    IF v_project_type = 'WS' THEN
        IF (SELECT value::json->>'status' FROM config_param_system WHERE parameter = 'edit_link_check_arcdnom')::boolean IS TRUE THEN
            v_check_arcdnom:= (SELECT value::json->>'diameter' FROM config_param_system WHERE parameter = 'edit_link_check_arcdnom');

            v_querytext = '(SELECT connec_id, connecat_id, the_geom, expl_id FROM '||v_edit||'connec WHERE state>0 AND arc_id IN (
                            SELECT arc_id FROM '||v_edit||'arc JOIN cat_arc ON arccat_id=id WHERE dnom::integer>'||v_check_arcdnom||')) a';
                        
            EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
            IF v_count > 0 THEN
                    EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
                    SELECT 488, connec_id, connecat_id, ''Connecs related to arcs with diameter bigger than defined'', the_geom, expl_id FROM ', v_querytext,'');
        
                INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
                VALUES (v_fid, 2, '488',concat('WARNING-488 (anl_connec): There is/are ',v_count,' connecs related to arcs with diameter bigger than defined value (',v_check_arcdnom,')'),v_count);
            ELSE
                INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
                VALUES (v_fid, 1, '488', 'INFO: No connecs related to arcs with diameter bigger than defined value',v_count);
            END IF;
        END IF;
    END IF;
   
    RAISE NOTICE '48 - Check connects with more than 1 link on service (480)';
 
    IF v_project_type = 'WS' THEN
	    v_querytext = '(SELECT connec_id, connecat_id, the_geom, expl_id FROM '||v_edit||'connec WHERE connec_id 
		IN (SELECT feature_id FROM link WHERE state=1 GROUP BY feature_id HAVING count(*) > 1)) a';
	ELSIF v_project_type = 'UD' THEN
	    v_querytext = '(SELECT connec_id, connecat_id, the_geom, expl_id FROM '||v_edit||'connec WHERE connec_id 
		IN (SELECT feature_id FROM link WHERE state=1 GROUP BY feature_id HAVING count(*) > 1)
		UNION SELECT gully_id, gratecat_id, the_geom, expl_id FROM '||v_edit||'gully WHERE gully_id 
		IN (SELECT feature_id FROM link WHERE state=1 GROUP BY feature_id HAVING count(*) > 1)) a';
	END IF;
                
    EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
    IF v_count > 0 THEN
            EXECUTE concat ('INSERT INTO temp_anl_connec (fid, connec_id, connecat_id, descript, the_geom, expl_id)
            SELECT 480, connec_id, connecat_id, ''Connects with more than 1 link on service'', the_geom, expl_id FROM ', v_querytext,'');

        INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
        VALUES (v_fid, 2, '480',concat('WARNING-480 (anl_connec): There is/are ',v_count,' connects with more than 1 link on service'),v_count);
    ELSE
        INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
        VALUES (v_fid, 1, '480', 'INFO: No connects with more than 1 link on service',v_count);
    END IF;

  RAISE NOTICE '49 - Check orphan documents (497)';
  	IF v_project_type = 'WS' THEN
	    v_querytext = '(select id from doc where id not in (
										select distinct  doc_id from doc_x_arc UNION
										select distinct  doc_id from doc_x_connec UNION
										select distinct  doc_id from doc_x_node ))a';
	ELSIF v_project_type = 'UD' THEN
	    v_querytext = '(select id from doc where id not in (
										select distinct  doc_id from doc_x_arc UNION
										select distinct  doc_id from doc_x_connec UNION
										select distinct  doc_id from doc_x_node UNION
										select distinct  doc_id from doc_x_gully))a';
	END IF;

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
    IF v_count > 0 THEN

        INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
        VALUES (v_fid, 2, '497',concat('WARNING-497: There is/are ',v_count,' documents not related to any feature.'),v_count);
    ELSE
        INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
        VALUES (v_fid, 1, '497', 'INFO: All documents are related to the features.',v_count);
    END IF;

  RAISE NOTICE '50 - Check no geometry orphan visits (498)';
  	IF v_project_type = 'WS' THEN
	    v_querytext = '(select id from om_visit where the_geom is null and id not in (
										select distinct visit_id from om_visit_x_arc UNION
										select distinct visit_id from om_visit_x_connec UNION
										select distinct visit_id from om_visit_x_node ))a';
	ELSIF v_project_type = 'UD' THEN
	    v_querytext = '(select id from om_visit where the_geom is null and id not in (
										select distinct visit_id from om_visit_x_arc UNION
										select distinct visit_id from om_visit_x_connec UNION
										select distinct visit_id from om_visit_x_node UNION
										select distinct visit_id from om_visit_x_gully ))a';
	END IF;

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
    IF v_count > 0 THEN

        INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
        VALUES (v_fid, 2, '498',concat('WARNING-498: There is/are ',v_count,' visits not related to any feature and without geometry.'),v_count);
    ELSE
        INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
        VALUES (v_fid, 1, '498', 'INFO: All visits are related to the features or have geometry.',v_count);
    END IF;

  RAISE NOTICE '52 - Check no geometry orphan elements (499)';
  	IF v_project_type = 'WS' THEN
	    v_querytext = '(select element_id from element where the_geom is null and element_id not in (
										select distinct element_id from element_x_arc UNION
										select distinct element_id from element_x_connec UNION
										select distinct element_id from element_x_node ))a';
	ELSIF v_project_type = 'UD' THEN
	    v_querytext = '(select element_id from element where the_geom is null and element_id not in (
										select distinct element_id from element_x_arc UNION
										select distinct element_id from element_x_connec UNION
										select distinct element_id from element_x_node UNION
										select distinct element_id from element_x_gully ))a';
	END IF;

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
    IF v_count > 0 THEN

        INSERT INTO temp_audit_check_data (fid,  criticity, result_id, error_message, fcount)
        VALUES (v_fid, 2, '499',concat('WARNING-499: There is/are ',v_count,' elements not related to any feature and without geometry.'),v_count);
    ELSE
        INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
        VALUES (v_fid, 1, '499', 'INFO: All elements are related to the features or have geometry.',v_count);
    END IF;
   
   	RAISE NOTICE '53 - Check nodes ''T candidate'' with wrong topology (fid: 432)';
	v_querytext = 'with q_arc as (select * from arc JOIN v_state_arc USING (arc_id))
			SELECT b.* FROM (SELECT n1.node_id, n1.nodecat_id, n1.sector_id, n1.expl_id, n1.state,
			''Node ''''T candidate'''' with wrong topology'', 432, n1.the_geom 
	    	FROM q_arc, (select * from node JOIN v_state_node USING (node_id)) n1
	    	JOIN (SELECT node_1 node_id from q_arc UNION select node_2 FROM q_arc) b USING (node_id)
	    	WHERE st_dwithin(q_arc.the_geom, n1.the_geom,0.01) AND n1.node_id NOT IN (node_1, node_2))b, selector_expl e 
	    	where e.expl_id= b.expl_id AND cur_user=current_user';

	EXECUTE 'SELECT count(*) FROM ('||v_querytext||')a'
	INTO v_count;
	
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '432', 3, concat('ERROR-432 (anl_node): There is/are ',v_count,' Node(s) ''T candidate'' with wrong topology'),v_count);

		EXECUTE 'INSERT INTO temp_anl_node (node_id, nodecat_id, sector_id, expl_id, state, descript, fid, the_geom) '||v_querytext;
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, '432', 1, concat('INFO: All Nodes T has right topology.'),v_count);
	END IF;


*/
	-- Removing isaudit false sys_fprocess
	FOR v_record IN SELECT * FROM sys_fprocess WHERE isaudit is false
	LOOP
		-- remove anl tables
		DELETE FROM temp_anl_node WHERE fid = v_record.fid AND cur_user = current_user;
		DELETE FROM temp_anl_arc WHERE fid = v_record.fid AND cur_user = current_user;
		DELETE FROM temp_anl_connec WHERE fid = v_record.fid AND cur_user = current_user;

		DELETE FROM temp_audit_check_data WHERE result_id::text = v_record.fid::text AND cur_user = current_user AND fid = v_fid;		
	END LOOP;


	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 4, '');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 3, '');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 2, '');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 1, '');

	IF v_fid = 125 THEN
	
		-- delete old values on result table
		DELETE FROM audit_check_data WHERE fid = 125 AND cur_user=current_user;
		
		-- delete old values on anl table
		DELETE FROM anl_connec WHERE cur_user=current_user AND fid IN (210,201,202,204,205,257,291,478);
		DELETE FROM anl_arc WHERE cur_user=current_user AND fid IN (103,196,197,188,223,202,372,391,417,418,461,381, 479);
		DELETE FROM anl_node WHERE cur_user=current_user AND fid IN (106,177,187,202,442,443,461,432);

		INSERT INTO anl_arc SELECT * FROM temp_anl_arc;
		INSERT INTO anl_node SELECT * FROM temp_anl_node;
		INSERT INTO anl_connec SELECT * FROM temp_anl_connec;
		INSERT INTO audit_check_data SELECT * FROM temp_audit_check_data;

	ELSIF  v_fid = 101 THEN 
	
		UPDATE temp_audit_check_data SET fid = 125;

		INSERT INTO project_temp_anl_arc SELECT * FROM temp_anl_arc;
		INSERT INTO project_temp_anl_node SELECT * FROM temp_anl_node;
		INSERT INTO project_temp_anl_connec SELECT * FROM temp_anl_connec;
		INSERT INTO project_temp_audit_check_data SELECT * FROM temp_audit_check_data;

	END IF;

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM temp_audit_check_data WHERE cur_user="current_user"() AND 
	fid = 125 order by criticity desc, id asc) row;
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
  	FROM (SELECT node_id, nodecat_id as feature_catalog, state, expl_id, descript, fid, the_geom FROM temp_anl_node WHERE cur_user="current_user"()
	AND fid IN (106,177,187,202,442,443,175,432)
	UNION
	SELECT connec_id, connecat_id, state, expl_id, descript, fid, the_geom FROM temp_anl_connec WHERE cur_user="current_user"()
	AND fid IN (210,201,202,204,205,291,478,488,480)) row) features;

	v_result := COALESCE(v_result, '{}'); 

	IF v_result = '{}' THEN 
		v_result_point = '{"geometryType":"", "features":[]}';
	ELSE 
		v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}');
	END IF;

	--lines
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
  	SELECT jsonb_build_object(
	'type',       'Feature',
	'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	'properties', to_jsonb(row) - 'the_geom'
  	) AS feature
  	FROM (
  	SELECT arc_id, arccat_id, state, expl_id, descript, fid, the_geom FROM  temp_anl_arc WHERE cur_user="current_user"() AND fid IN (103, 196, 197, 188, 223, 202, 372, 391, 417, 418, 479,175)
  	) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "features":',v_result,'}'); 


	IF v_result = '{}' THEN 
		v_result_line = '{"geometryType":"", "features":[]}';
	ELSE 
		v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, '}');
	END IF;

	--polygons
	v_result_polygon = '{"geometryType":"", "values":[]}';
		
	-- Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 
	v_result_polygon := COALESCE(v_result_polygon, '{}'); 
	
	IF v_fid = 125 OR v_fid = 101 THEN
		--drop temporal tables
		DROP TABLE  IF EXISTS temp_anl_arc;
		DROP TABLE IF EXISTS temp_anl_node ;
		DROP TABLE IF EXISTS  temp_anl_connec;
		DROP TABLE  IF EXISTS temp_t_arc;
		DROP TABLE  IF EXISTS temp_audit_check_data;
	END IF;


	-- Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||
		       '}'||
	    '}}')::json, 2670, null, null, null);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  