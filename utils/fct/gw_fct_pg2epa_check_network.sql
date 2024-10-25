/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
-- Part of code of this inundation function have been provided by Enric Amat (FISERSA)


--FUNCTION CODE: 2680

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa_inlet_flowtrace(text);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_check_network(p_data json)
RETURNS json AS
$BODY$

/*
--EXAMPLE
SELECT SCHEMA_NAME.gw_fct_pg2epa_check_network('{"data":{"parameters":{"resultId":"test1","fid":227}}}')::json; -- when is called from go2epa

CREATE TEMP TABLE temp_t_anlgraph (LIKE SCHEMA_NAME.temp_anlgraph INCLUDING ALL);
CREATE TEMP TABLE temp_t_anlgraph (LIKE SCHEMA_NAME.temp_anlgraph INCLUDING ALL);
drop table temp_t_anlgraph;

select * from SCHEMA_NAME.temp_t_anlgraph

--RESULTS
SELECT node_id FROM temp_anl_node WHERE fid = 233 AND cur_user=current_user
SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user
SELECT node_id FROM temp_anl_node WHERE fid = 139 AND cur_user=current_user
SELECT * FROM temp_audit_check_data WHERE fid = 139
SELECT * FROM temp_anlgraph;

-- fid: main:139
	other: 227,231,233,228,404,431,454

*/

DECLARE

v_project_type text;
v_affectedrows numeric;
v_cont integer default 0;
v_buildupmode int2;
v_result_id text;
v_result json;
v_result_info json;
v_result_point json;
v_result_line json;
v_boundaryelem text;
v_error_context text;
v_fid integer;
v_querytext text;
v_count integer = 0;
v_min float;
v_max float;
v_version text;
v_networkstats json;
v_sumlength numeric (12,2);
v_linkoffsets text;
v_deldisconnetwork boolean;
v_deldrynetwork boolean;
v_removedemands boolean;
v_minlength float;
v_demand numeric (12,4);
v_networkmode integer;

BEGIN
	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	--  Get input data
	v_result_id = ((p_data->>'data')::json->>'parameters')::json->>'resultId';
	v_fid := ((p_data ->>'data')::json->>'parameters')::json->>'fid';
	
	-- get project type
	v_project_type = (SELECT project_type FROM sys_version ORDER BY id DESC LIMIT 1);
	v_version = (SELECT giswater FROM sys_version ORDER BY id DESC LIMIT 1);
	
	-- get options data
	SELECT value INTO v_linkoffsets FROM config_param_user WHERE parameter = 'inp_options_link_offsets' AND cur_user = current_user;
	SELECT value INTO v_minlength FROM config_param_user WHERE parameter = 'inp_options_minlength' AND cur_user = current_user;
	v_networkmode = (SELECT value FROM config_param_user WHERE parameter='inp_options_networkmode' AND cur_user=current_user);


	-- get user variables
	v_deldisconnetwork = (SELECT value::json->>'delDisconnNetwork' FROM config_param_user WHERE parameter='inp_options_debug' AND cur_user=current_user)::boolean;
	v_deldrynetwork = (SELECT value::json->>'delDryNetwork' FROM config_param_user WHERE parameter='inp_options_debug' AND cur_user=current_user)::boolean;
	v_removedemands = (SELECT value::json->>'removeDemandOnDryNodes' FROM config_param_user WHERE parameter='inp_options_debug' AND cur_user=current_user)::boolean;
	
	-- manage no found results
	IF (SELECT result_id FROM rpt_cat_result WHERE result_id=v_result_id) IS NULL THEN
		v_result  = (SELECT array_to_json(array_agg(row_to_json(row))) FROM (SELECT 1::integer as id, 'No result found with this name' as  message)row);
		v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
		RETURN ('{"status":"Accepted", "message":{"level":1, "text":"No result found"}, "version":"'||v_version||'"'||
			',"body":{"form":{}, "data":{"info":'||v_result_info||'}}}')::json;		
	END IF; 
	
	-- elements
	IF v_project_type  = 'WS' THEN
		v_boundaryelem = 'tank or reservoir';
	ELSIF v_project_type  = 'UD' THEN
		v_boundaryelem = 'outfall';
	END IF;
			
	-- create temporal view
	CREATE OR REPLACE TEMP VIEW v_temp_anlgraph AS
		SELECT anl_graph.arc_id,
		    anl_graph.node_1,
		    anl_graph.node_2,
		    anl_graph.flag,
		    a.flag AS flagi,
		    a.value
		   FROM temp_t_anlgraph anl_graph
		     JOIN ( SELECT anl_graph_1.arc_id,
			    anl_graph_1.node_1,
			    anl_graph_1.node_2,
			    anl_graph_1.water,
			    anl_graph_1.flag,
			    anl_graph_1.checkf,
			    anl_graph_1.value
			   FROM temp_t_anlgraph anl_graph_1
			  WHERE anl_graph_1.water = 1) a ON anl_graph.node_1::text = a.node_2::text
		  WHERE anl_graph.flag < 2 AND anl_graph.water = 0 AND a.flag < 2;
			
			
	-- Header
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 4, 'CHECK RESULT NETWORK ACORDING EPA RULES');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 4, '---------------------------------------------------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 3, 'CRITICAL ERRORS');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 3, '----------------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 2, 'WARNINGS');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 2, '--------------');

	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 1, 'INFO');
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (139, v_result_id, 1, '-------');
	

	RAISE NOTICE '2 - Check node_1 or node_2 nulls on on temp_table (454)';
	v_querytext = '(SELECT arc_id, arccat_id, the_geom, expl_id FROM temp_t_arc WHERE node_1 IS NULL UNION SELECT arc_id, 
	arccat_id, the_geom, expl_id FROM temp_t_arc WHERE node_2 IS NULL) a';

	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, descript, the_geom, expl_id)
			SELECT 454, arc_id, arccat_id, ''node_1 or node_2 nulls'', the_geom, expl_id FROM ', v_querytext);
		INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
		VALUES (v_fid, 3, '454', concat('ERROR-454 (anl_arc): There is/are ',v_count,' arc''s with state=1 and without node_1 or node_2.'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, criticity, result_id,error_message, fcount)
		VALUES (v_fid, 1, '454','INFO: No arcs with without node_1 or node_2 nodes found.', v_count);
	END IF;


	RAISE NOTICE '2 - Check result duplicated nodes on rpt tables (fid:  290)';
	v_querytext = '(SELECT DISTINCT ON(the_geom) n1.node_id as n1, n2.node_id as n2, n1.the_geom FROM temp_t_node n1, temp_t_node n2 
			WHERE st_dwithin(n1.the_geom, n2.the_geom, 0.00001) AND n1.node_id != n2.node_id ) b';

	
	EXECUTE concat('SELECT count(*) FROM ',v_querytext) INTO v_count;
	IF v_count > 0  THEN
		EXECUTE concat ('INSERT INTO temp_anl_node (fid, node_id, descript, the_geom)
		SELECT 290, n1, concat(''Duplicated node with '', n2 ), the_geom FROM ', v_querytext);
		INSERT INTO temp_audit_check_data (fid, criticity, error_message)
		VALUES (v_fid, 3, concat('ERROR-290: There is/are ',v_count,
		' node(s) duplicated on this result. Reason maybe some (connec or node) over other (connec or node) or due wrong state-topology issue.'));
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
		VALUES (v_fid, v_result_id, 1, 'INFO: No duplicated node(s) found on this result.');
	END IF;

	RAISE NOTICE '3 - Check links over nodarcs (404)';

	IF v_networkmode > 2 THEN

		SELECT count(*) INTO v_count FROM v_edit_link l, temp_t_arc a WHERE st_dwithin(st_endpoint(l.the_geom), a.the_geom, 0.001) AND a.epa_type NOT IN ('CONDUIT', 'PIPE', 'VIRTUALVALVE');
		
		IF v_count > 0 THEN
			EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, state, expl_id, the_geom, descript)
				SELECT 404, link_id, ''LINK'', l.state, l.expl_id, l.the_geom, ''Link over nodarc'' FROM v_edit_link l, temp_t_arc a 
				WHERE st_dwithin(st_endpoint(l.the_geom), a.the_geom, 0.001) AND a.epa_type NOT IN (''CONDUIT'', ''PIPE'', ''VIRTUALVALVE'')';
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 3, concat('ERROR-404: There is/are ',v_count,' link(s) with endpoint over nodarcs.'),v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 1,'INFO: No endpoint links checked over nodarcs on this result.',v_count);
		END IF;
	END IF;
	
	
	RAISE NOTICE '4 - Check result arcs without start/end node on rpt tables (fid:  231)';
	v_querytext = '	SELECT 231, arc_id, arccat_id, state, expl_id, the_geom, '||quote_literal(v_result_id)||', ''Arcs without node_1 or node_2.'' FROM temp_t_arc where result_id = '||quote_literal(v_result_id)||'
			EXCEPT ( 
			SELECT 231, arc_id, arccat_id, state, expl_id, the_geom, '||quote_literal(v_result_id)||', ''Arcs without node_1 or node_2.'' FROM temp_t_arc JOIN 
			(SELECT node_id FROM temp_t_node where result_id = '||quote_literal(v_result_id)||' ) a ON node_1=node_id where result_id = '||quote_literal(v_result_id)||'
			UNION 
			SELECT 231, arc_id, arccat_id, state, expl_id, the_geom, '||quote_literal(v_result_id)||', ''Arcs without node_1 or node_2.'' FROM temp_t_arc  JOIN
			(SELECT node_id FROM temp_t_node where result_id = '||quote_literal(v_result_id)||') b ON node_2=node_id where result_id = '||quote_literal(v_result_id)||')';

	EXECUTE 'SELECT count(*) FROM ('||v_querytext ||')a'
		INTO v_count;

	IF v_count > 0 THEN
		EXECUTE 'INSERT INTO temp_anl_arc (fid, arc_id, arccat_id, state, expl_id, the_geom, result_id, descript)'||v_querytext;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, v_result_id, 3, concat('ERROR-231: There is/are ',v_count,
		' arc(s) without start/end nodes on this result. Some inconsistency may have been generated because on-the-fly transformations. Check your network'),v_count);
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
		VALUES (v_fid, v_result_id, 1,'INFO: There is/are no arcs without start/end nodes on this result.',v_count);
	END IF;
	

	RAISE NOTICE '5 - Check disconnected network (139)';	

	-- fill the graph table
	INSERT INTO temp_t_anlgraph (arc_id, node_1, node_2, water, flag, checkf)
	select  a.arc_id, case when node_1 is null then '00000' else node_1 end, case when node_2 is null then '00000' else node_2 end, 0, 0, 0
	from temp_t_arc a
	union all
	select  a.arc_id, case when node_2 is null then '00000' else node_2 end, case when node_1 is null then '00000' else node_1 end, 0, 0, 0
	from temp_t_arc a
	ON CONFLICT (arc_id, node_1) DO NOTHING;
	
	-- set boundary conditions of graph table
	IF v_project_type = 'WS' THEN
		UPDATE temp_t_anlgraph
			SET flag=1, water=1 
			WHERE node_1 IN (SELECT node_id FROM temp_t_node WHERE (epa_type='RESERVOIR' OR epa_type='INLET' OR epa_type='TANK'));

		UPDATE temp_t_anlgraph
			SET flag=1, water=1 
			WHERE node_2 IN (SELECT node_id FROM temp_t_node WHERE (epa_type='RESERVOIR' OR epa_type='INLET' OR epa_type='TANK'));
		
	ELSIF v_project_type = 'UD' THEN
		UPDATE temp_t_anlgraph
			SET flag=1, water=1 
			WHERE node_1 IN (SELECT node_id FROM temp_t_node WHERE epa_type='OUTFALL');
	END IF;
		
	-- inundation process
	LOOP
		v_cont = v_cont+1;
		update temp_t_anlgraph n set water= 1, flag=n.flag+1 from v_temp_anlgraph a where n.node_1 = a.node_1 and n.arc_id = a.arc_id;
		GET DIAGNOSTICS v_affectedrows =row_count;
		EXIT WHEN v_affectedrows = 0;
		EXIT WHEN v_cont = 2000;
	END LOOP;

	-- arc results
	INSERT INTO temp_anl_arc (fid, result_id, arc_id, the_geom, descript)
	SELECT DISTINCT ON (a.arc_id) 139, v_result, a.arc_id, the_geom, concat('Disconnected arc from any ', v_boundaryelem)  
		FROM temp_t_anlgraph a
		JOIN temp_t_arc b ON a.arc_id=b.arc_id
		GROUP BY a.arc_id,the_geom
		having max(water) = 0;

	-- counting arc results
	SELECT count(*) FROM temp_anl_arc INTO v_count WHERE fid = 139 AND cur_user=current_user;
	IF v_count > 0 THEN
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
		VALUES (v_fid, v_result_id, 3, concat('ERROR-',v_fid,': There is/are ',v_count,' arc(s) topological disconnected from any ', v_boundaryelem
		,'. The reason should be: state_type, epa_type, sector_id or expl_id or some node not connected'));
	ELSE
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
		VALUES (v_fid, v_result_id, 1, concat('INFO: No arcs topological disconnected found on this result from any ', v_boundaryelem));
	END IF;

	IF v_project_type = 'WS' THEN

		RAISE NOTICE '6 - Check dry network (232)';	
		DELETE FROM temp_t_anlgraph;
		v_cont = 0;

		-- fill the graph table
		INSERT INTO temp_t_anlgraph (arc_id, node_1, node_2, water, flag, checkf)
		select  a.arc_id, case when node_1 is null then '00000' else node_1 end, case when node_2 is null then '00000' else node_2 end, 0, 0, 0
		from temp_t_arc a
		union all
		select  a.arc_id, case when node_2 is null then '00000' else node_2 end, case when node_1 is null then '00000' else node_1 end, 0, 0, 0
		from temp_t_arc a
		ON CONFLICT (arc_id, node_1) DO NOTHING;
			

		-- set boundary conditions of graph table
		UPDATE temp_t_anlgraph
			SET flag =1 WHERE arc_id IN (SELECT arc_id FROM temp_t_arc WHERE status = 'CLOSED');
		UPDATE temp_t_anlgraph
			SET flag=1, water=1 
			WHERE node_1 IN (SELECT node_id FROM temp_t_node WHERE (epa_type='RESERVOIR' OR epa_type='INLET' OR epa_type='TANK'));
		UPDATE temp_t_anlgraph
			SET flag=1, water=1 
			WHERE node_2 IN (SELECT node_id FROM temp_t_node WHERE (epa_type='RESERVOIR' OR epa_type='INLET' OR epa_type='TANK'));

		-- inundation process
		LOOP
			v_cont = v_cont+1;
			update temp_t_anlgraph n set water= 1, flag=n.flag+1 from v_temp_anlgraph a where n.node_1 = a.node_1 and n.arc_id = a.arc_id;
			GET DIAGNOSTICS v_affectedrows =row_count;
			EXIT WHEN v_affectedrows = 0;
			EXIT WHEN v_cont = 2000;
			RAISE NOTICE '% - %', v_cont, v_affectedrows;
		END LOOP;

	
		-- insert into result table arc results
		INSERT INTO temp_anl_arc (fid, arc_id, the_geom, descript)
		SELECT DISTINCT ON (a.arc_id) 232, a.arc_id, the_geom, concat('Dry arc')
			FROM temp_t_anlgraph a
			JOIN temp_t_arc b ON a.arc_id=b.arc_id
			GROUP BY a.arc_id,the_geom
			having max(water) = 0;

		-- insert into result table dry nodes
		INSERT INTO temp_anl_node (fid, node_id, the_geom, descript)
		SELECT distinct on (node_id) 232, n.node_id, n.the_geom, concat('Dry node') FROM temp_t_node n
			JOIN
			(
			SELECT node_1 AS node_id FROM temp_t_anlgraph JOIN (SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user)a USING (arc_id)
			UNION
			SELECT node_2 FROM temp_t_anlgraph JOIN (SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user)a USING (arc_id)
			)
			a USING (node_id);

		-- insert into result table dry nodes with demands (error)
		INSERT INTO temp_anl_node (fid, node_id, the_geom, descript, demand)
		SELECT distinct on (node_id) 233, n.node_id, n.the_geom, concat('Dry node with demand'), demand FROM temp_t_node n
			JOIN
			(
			SELECT node_1 AS node_id FROM temp_t_anlgraph JOIN (SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user)a USING (arc_id)
			UNION
			SELECT node_2 FROM temp_t_anlgraph JOIN (SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user)a USING (arc_id)
			)
			a USING (node_id)
			WHERE n.demand > 0;


		-- counting arcs
		SELECT count(*) FROM (SELECT arc_id FROM temp_anl_arc INTO v_count WHERE fid = 232 AND cur_user=current_user EXCEPT SELECT arc_id FROM temp_anl_arc WHERE fid = 139 AND cur_user=current_user)a;
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 2, concat('WARNING-232: There is/are ',v_count,' Dry arc(s) because closed elements'), v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 1, concat('INFO: No dry arcs found'),v_count);
		END IF;

		-- counting nodes
		SELECT count(*), sum(demand) FROM temp_anl_node INTO v_count, v_demand WHERE fid = 233 AND cur_user=current_user;
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 2, concat('WARNING-233: There is/are ',v_count,' Dry node(s) with associated demand and total value of ', v_demand), v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 1, concat('INFO: No dry nodes with demand found'), v_count);
		END IF;

	ELSE -- UD project

		-- counting arcs with length less than minlength
		SELECT count(*) INTO v_count FROM temp_t_arc WHERE st_length(the_geom) < v_minlength AND epa_type = 'CONDUIT';

		IF v_count > 0 THEN

			INSERT INTO temp_anl_arc (fid, arc_id, the_geom, descript)
			SELECT 431, arc_id, the_geom, concat('Arc with less length than minimum configured (',v_minlength,')') FROM temp_t_arc WHERE st_length(the_geom) < v_minlength AND epa_type = 'CONDUIT';
		
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 2, concat('WARNING-431 (anl_arc): There is/are ',v_count,' arcs with length with length less than ',v_minlength,' meters (minimum length configured).'), v_count);
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message, fcount)
			VALUES (v_fid, v_result_id, 1, concat('INFO: No arcs with length less than ',v_minlength,' meters (minimum length configured).'), v_count);
		END IF;	
	END IF;


	-- updating values on result
	IF v_deldisconnetwork THEN
		DELETE FROM temp_t_arc WHERE arc_id IN (SELECT arc_id FROM temp_anl_arc WHERE fid = 139 AND cur_user=current_user);
		GET DIAGNOSTICS v_count = row_count;

		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 2, 
			concat('WARNING-227: {delDisconnectNetwork} is enabled and ',v_count,' arcs have been removed.'));
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 1, 
			concat('INFO: {delDisconnectNetwork} is enabled but nothing have been removed.'));
		END IF;

		DELETE FROM temp_t_node WHERE node_id IN (SELECT node_id FROM temp_anl_node WHERE fid = 139 AND cur_user=current_user);
	END IF;

	-- updating values on result
	IF v_deldrynetwork THEN
		DELETE FROM temp_t_arc WHERE arc_id IN (SELECT arc_id FROM temp_anl_arc WHERE fid = 232 AND cur_user=current_user);
		GET DIAGNOSTICS v_count = row_count;

		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 2, 
			concat('WARNING-227: {delDryNetwork} is enabled and ',v_count,' arcs have been removed.'));
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 1, 
			concat('INFO: {delDryNetwork} is enabled but nothing have been removed.'));
		END IF;

		DELETE FROM temp_t_node WHERE node_id IN (SELECT node_id FROM temp_anl_node WHERE fid = 232 AND cur_user=current_user);
	END IF;


	IF v_removedemands THEN
		UPDATE temp_t_node n SET demand = 0, addparam = gw_fct_json_object_set_key(a.addparam::json, 'removedDemand'::text, true::boolean) 
		FROM temp_anl_node a WHERE fid = 233 AND a.cur_user = current_user AND a.node_id = n.node_id;
		GET DIAGNOSTICS v_count = row_count;
		
		IF v_count > 0 THEN
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 2, concat(
			'WARNING-227: {removeDemandsOnDryNetwork} is enabled and demand from ',v_count,' nodes have been removed'));
		ELSE
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message)
			VALUES (v_fid, v_result, 1, concat('INFO: {removeDemandsOnDryNetwork} is enabled but no dry nodes have been found.'));
		END IF;
		DELETE FROM temp_audit_check_data WHERE fid = 227 AND error_message like '%Dry node(s) with demand%' AND cur_user = current_user;
	END IF;
	

	RAISE NOTICE '7 - Stats';
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,concat(''));
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,concat('BASIC STATS'));
	INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,concat('-------------------'));
	
	IF v_project_type =  'WS' THEN

		SELECT sum(length)/1000 INTO v_sumlength FROM temp_t_arc;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Total length (Km) : ',v_sumlength,'.'));
	
		SELECT min(elevation), max(elevation) INTO v_min, v_max FROM temp_t_node;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for node elevation. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));
		
		SELECT min(length), max(length) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'PIPE';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for pipe length. Minimun and maximum values are: (',v_min,' - ',v_max,' ).'));
		
		SELECT min(diameter), max(diameter) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'PIPE';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for pipe diameter. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));

		SELECT min(roughness), max(roughness) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'PIPE';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for pipe roughness. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));

		v_networkstats = gw_fct_json_object_set_key((select json_build_object('sector', array_agg(sector_id)) FROM selector_sector where cur_user=current_user and sector_id > 0)
		 ,'Total Length (Km)', v_sumlength);
				
	ELSIF v_project_type  ='UD' THEN

		SELECT sum(length)/1000 INTO v_sumlength FROM temp_t_arc;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Total length (Km) : ',coalesce(v_sumlength,0::numeric),'.'));
		
		IF v_linkoffsets  = 'ELEVATION' THEN
			SELECT min(((elevmax1-elevmax2)/length)::numeric(12,4)), max(((elevmax1-elevmax2)/length)::numeric(12,4)) 
			INTO v_min, v_max FROM temp_t_arc;
			INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
			concat('Data analysis for conduit slope. Values from [',v_min,'] to [',v_max,'] have been found.'));
		END IF;
		
		SELECT min(length), max(length) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'CONDUIT';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for conduit length. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));

		SELECT min(n), max(n) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'CONDUIT';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for conduit manning roughness coeficient. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));

		SELECT min(elevmax1), max(elevmax1) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'CONDUIT';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for conduit z1. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));
		
		SELECT min(elevmax2), max(elevmax2) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'CONDUIT';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for conduit z2. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));
	
		SELECT min(slope), max(slope) INTO v_min, v_max FROM temp_t_arc WHERE epa_type = 'CONDUIT';
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for conduit slope. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));
		
		SELECT min(elev), max(elev) INTO v_min, v_max FROM temp_t_node;
		INSERT INTO temp_audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, v_result_id, 0,
		concat('Data analysis for node elevation. Minimun and maximum values are: ( ',v_min,' - ',v_max,' ).'));	

		v_networkstats = gw_fct_json_object_set_key((select json_build_object('sector', array_agg(sector_id)) FROM selector_sector where cur_user=current_user and sector_id > 0),
		'Total Length (Km)', v_sumlength);
	END IF;

	
	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM temp_audit_check_data WHERE cur_user="current_user"() AND fid = v_fid order by criticity desc, id asc) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--points
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
  	SELECT jsonb_build_object(
		'type',       'Feature',
		'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
		'properties', to_jsonb(row) - 'the_geom_p'
		) AS feature
		FROM (SELECT id, node_id, node_id, state, expl_id, descript, fid, the_geom
			  FROM  temp_anl_node WHERE cur_user="current_user"() AND fid IN (139,228,227,233,290)
		) row) features;
  	
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point", "features":',v_result, '}');
	
	--lines
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
  	SELECT jsonb_build_object(
		'type',       'Feature',
		'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
		'properties', to_jsonb(row) - 'the_geom'
		) AS feature
		FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript,fid, the_geom
			  FROM  temp_anl_arc WHERE cur_user="current_user"() AND fid IN (139,227,232,404,454)
			 ) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, '}'); 
	
	-- Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 


	DROP VIEW v_temp_anlgraph;

	--  Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Analysis done successfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||
		       '}}'||
	    '}')::json, 2680, null, null, null);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
