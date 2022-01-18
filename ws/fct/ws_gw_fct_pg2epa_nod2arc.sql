/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2316

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_nod2arc(varchar);
DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_nod2arc(varchar, boolean);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_nod2arc(result_id_var varchar, p_only_mandatory_nodarc boolean, p_check boolean) 
RETURNS integer 
AS $BODY$

/*example
SELECT SCHEMA_NAME.gw_fct_pg2epa_main($${"data":{"resultId":"t1", "useNetworkGeom":"false"}}$$)

fid: 124
*/


DECLARE

rec_arc record;
v_nod2arc float;
v_querytext text;
v_arcsearchnodes float;
v_nodarc_min float;
v_query_number text;
v_node record;
v_offset integer = 0;
v_limit integer = 5000;
v_count integer = 0;
v_diameter float = 200;
v_roughness float;
v_querystring text;
v_error_context text;

BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	-- Profilactic controls for nodarc value
	SELECT min(st_length(the_geom)) FROM temp_arc JOIN selector_sector ON selector_sector.sector_id=temp_arc.sector_id
		INTO v_nodarc_min;
	v_nod2arc := (SELECT value::float FROM config_param_user WHERE parameter = 'inp_options_nodarc_length' and cur_user=current_user limit 1)::float;
	IF v_nod2arc is null then 
		v_nod2arc = 0.3;
	END IF;
	IF v_nod2arc > v_nodarc_min THEN v_nod2arc = v_nodarc_min-0.005; END IF;
	IF v_nod2arc < 0.009 THEN v_nod2arc = 0.01; END IF;
	
	v_roughness = (SELECT avg(roughness) FROM temp_arc);
	IF v_roughness is null then v_roughness = 0; END IF;

	delete from anl_node  WHERE fid  = 124 and cur_user = current_user;
					
	-- check number of times each node appears in terms of identify nodearcs <> 2
	v_query_number = 'SELECT count(*)as numarcs, node_id FROM node n JOIN 
						      (SELECT node_1 as node_id FROM v_edit_arc 
							UNION ALL SELECT node_2 FROM v_edit_arc) a using (node_id) group by n.node_id';

	-- query text for mandatory node2arcs
	v_querytext = 'SELECT a.*, inp_valve.to_arc FROM temp_node a JOIN inp_valve ON a.node_id=inp_valve.node_id  
				UNION  
				SELECT a.*, inp_pump.to_arc FROM temp_node a JOIN inp_pump ON a.node_id=inp_pump.node_id
				UNION
				SELECT a.*, inp_shortpipe.to_arc FROM temp_node a JOIN inp_shortpipe ON a.node_id=inp_shortpipe.node_id WHERE inp_shortpipe.to_arc IS NOT NULL';

	v_querytext = concat (' INSERT INTO anl_node (num_arcs, arc_id, node_id, elevation, elev, nodecat_id, sector_id, state, state_type, descript, arc_distance, the_geom, fid, cur_user, dma_id, presszone_id, dqa_id, minsector_id)
				SELECT c.numarcs, to_arc, b.node_id, elevation, elev, nodecat_id, sector_id, state, state_type, ''MANDATORY'', demand, the_geom, 124, current_user, dma_id, presszone_id, dqa_id, minsector_id
				FROM ( ',v_querytext, ' ) b JOIN ( ',v_query_number,' ) c USING (node_id)');
	EXECUTE v_querytext; 

	-- query text for non-mandatory node2arcs
	IF p_only_mandatory_nodarc IS FALSE THEN
		v_querytext = 'SELECT a.*, inp_shortpipe.to_arc FROM temp_node a JOIN inp_shortpipe ON a.node_id=inp_shortpipe.node_id WHERE inp_shortpipe.to_arc IS NULL';

		v_querytext = concat (' INSERT INTO anl_node (num_arcs, arc_id, node_id, elevation, elev, nodecat_id, sector_id, state, state_type, descript, arc_distance, the_geom, fid, cur_user, dma_id, presszone_id, dqa_id, minsector_id)
				SELECT c.numarcs, to_arc, b.node_id, elevation, elev, nodecat_id, sector_id, state, state_type, ''NOT-MANDATORY'', demand, the_geom, 124, current_user, dma_id, presszone_id, dqa_id, minsector_id
				FROM ( ',v_querytext, ' ) b JOIN ( ',v_query_number,' ) c USING (node_id)');
		EXECUTE v_querytext; 
	END IF;
	

	RAISE NOTICE ' reverse geometries when node acts as node1 from arc but must be node2';
	EXECUTE 'UPDATE temp_arc SET the_geom = st_reverse(the_geom) , node_1 = node_2 , node_2 = node_1 WHERE arc_id IN (SELECT arc_id FROM (
		SELECT c.arc_id, n.node_id, n.arc_id as to_arc
		FROM temp_arc c JOIN anl_node n ON node_1 = node_id
		WHERE c.arc_id != n.arc_id AND n.arc_id IS NOT NULL
		AND fid  = 124 AND cur_user = current_user)b )';

	RAISE NOTICE ' reverse geometries when node acts as node2 from arc but must be node1';
	EXECUTE 'UPDATE temp_arc SET the_geom = st_reverse(the_geom) , node_1 = node_2 , node_2 = node_1 WHERE arc_id IN (SELECT arc_id FROM (
		SELECT c.arc_id, n.node_id , n.arc_id as to_arc
		FROM temp_arc c JOIN anl_node n ON node_2 = node_id
		WHERE c.arc_id = n.arc_id AND n.arc_id IS NOT NULL
		AND fid  = 124 AND cur_user = current_user )b )';


	RAISE NOTICE 'new nodes when numarcs = 1 (1)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id,state, state_type, descript, 
		arc_distance, the_geom, minsector_id FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_1'') as node_id, elevation, elev, ''NODE2ARC'',
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_LineInterpolatePoint (c.the_geom, ('||0.5*v_nod2arc||'/st_length(c.the_geom))) AS the_geom,
		n.node_id,
		3, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_1 = node_id
		WHERE n.num_arcs = 1';

	RAISE NOTICE 'new nodes when numarcs = 1 (2)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id,state, state_type, descript, 
		arc_distance, the_geom, minsector_id FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_2'') as node_id, elevation, elev, ''NODE2ARC'', 
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_LineInterpolatePoint (c.the_geom, (1 - '||0.5*v_nod2arc||'/st_length(c.the_geom))) AS the_geom,
		n.node_id,
		4, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_2 = node_id
		WHERE n.num_arcs = 1';

	RAISE NOTICE 'new nodes when numarcs = 1 (3)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id,state, state_type, descript, 
		arc_distance, the_geom, minsector_id FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_2'') as node_id, elevation, elev, ''NODE2ARC'', 
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_startpoint(c.the_geom) AS the_geom,
		n.node_id,
		4, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_1 = node_id
		WHERE n.num_arcs = 1';

	RAISE NOTICE 'new nodes when numarcs = 1 (4)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id,state, state_type, descript, 
		arc_distance, the_geom, minsector_id FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_1'') as node_id, elevation, elev, ''NODE2ARC'', 
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_endpoint(c.the_geom) AS the_geom,
		n.node_id,
		3, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_2 = node_id
		WHERE n.num_arcs = 1';

	RAISE NOTICE 'new nodes when numarcs = 2 (1)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id,state, state_type, descript, 
		arc_distance, the_geom, minsector_id FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_1'') as node_id, elevation, elev, ''NODE2ARC'',
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_LineInterpolatePoint (c.the_geom, ('||0.5*v_nod2arc||'/st_length(c.the_geom))) AS the_geom,
		n.node_id,
		1, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_1 = node_id
		WHERE n.num_arcs = 2';

	RAISE NOTICE 'new nodes when numarcs = 2 (2)';
	EXECUTE 'INSERT INTO temp_node (result_id, node_id, elevation, elev, node_type, 
		nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, 
		the_geom, nodeparent, arcposition, dma_id, presszone_id, dqa_id, minsector_id) 
		WITH querytext AS (SELECT node_id, num_arcs, elevation, elev, nodecat_id, state, state_type, descript, 
		arc_distance, minsector_id, the_geom FROM anl_node WHERE fid = 124 AND cur_user = current_user)
		SELECT c.result_id, concat(n.node_id, ''_n2a_2'') as node_id, elevation, elev, ''NODE2ARC'', 
		nodecat_id, ''JUNCTION'', c.sector_id, n.state, n.state_type, n.descript as annotation, arc_distance as demand,
		ST_LineInterpolatePoint (c.the_geom, (1 - '||0.5*v_nod2arc||'/st_length(c.the_geom))) AS the_geom,
		n.node_id,
		2, dma_id, presszone_id, dqa_id, n.minsector_id
		FROM temp_arc c LEFT JOIN querytext n ON node_2 = node_id
		WHERE n.num_arcs = 2 ';

	RAISE NOTICE ' Fix all that nodarcs without to_arc informed, because extremal nodes may appear two times as node_1';
	FOR v_node IN SELECT count(*), node_id FROM temp_node WHERE substring(reverse(node_id),0,2) = '1' group by node_id having count(*) > 1 order by 1 desc
	LOOP
		UPDATE temp_node SET node_id = concat(reverse(substring(reverse(v_node.node_id),2,99)),'2'), arcposition = 2
		WHERE id IN (SELECT id FROM temp_node WHERE node_id = v_node.node_id LIMIT 1);
	END LOOP;

	RAISE NOTICE ' Fix all that nodarcs without to_arc informed, because extremal nodes may appear two times as node_2';
	FOR v_node IN SELECT count(*), node_id FROM temp_node where substring(reverse(node_id),0,2) = '2' group by node_id having count(*) > 1 order by 1 desc
	LOOP
		UPDATE temp_node SET node_id = concat(reverse(substring(reverse(v_node.node_id),2,99)),'1'), arcposition = 1
		WHERE id IN (SELECT id FROM temp_node WHERE node_id = v_node.node_id LIMIT 1);
	END LOOP;

	IF p_check IS FALSE THEN
	
		RAISE NOTICE 'new arcs when numarcs = 1 (NODE2ARC-ENDPOINT)';
		EXECUTE 'INSERT INTO temp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, expl_id, state, state_type, diameter, roughness, annotation, length,
			status, the_geom, minorloss, addparam, dma_id, presszone_id, dqa_id, minsector_id)
			
				WITH result AS (SELECT * FROM temp_node)
				SELECT DISTINCT ON (a.nodeparent)
				a.result_id,
				concat (a.nodeparent, ''_n2a'') as arc_id,
				b.node_id,
				a.node_id,
				''NODE2ARC-ENDPOINT'', 
				a.nodecat_id as arccat_id, 
				c.epa_type,
				a.sector_id, 
				a.expl_id,
				a.state,
				a.state_type,
				case when (c.addparam::json->>''diameter'')::text !='''' then  (c.addparam::json->>''diameter'')::numeric else NULL end as diameter,
				case when (c.addparam::json->>''roughness'')::text !='''' then  (c.addparam::json->>''roughness'')::numeric else '||v_roughness||' end as roughness,
				a.annotation,
				st_length2d(st_makeline(a.the_geom, b.the_geom)) as length,
				c.addparam::json->>''status'' status,
				st_makeline(a.the_geom, b.the_geom) AS the_geom,
				case when (c.addparam::json->>''minorloss'')::text !='''' then  (c.addparam::json->>''minorloss'')::numeric else 0 end as minorloss,
				c.addparam, a.dma_id, a.presszone_id, a.dqa_id, a.minsector_id
				FROM 	result a,
					result b
					LEFT JOIN result c ON c.node_id = b.nodeparent
					WHERE a.nodeparent = b.nodeparent AND a.arcposition = 3 AND b.arcposition = 4';

		RAISE NOTICE 'new arcs when numarcs = 2 (NODE2ARC) with offset  % ', v_offset;
		EXECUTE 'INSERT INTO temp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, expl_id, state, state_type, diameter, roughness, annotation, length, 
			status, the_geom, minorloss, addparam, dma_id, presszone_id, dqa_id, minsector_id)

			WITH result AS (SELECT * FROM temp_node) 
			SELECT DISTINCT ON (a.nodeparent)
			a.result_id,
			concat (a.nodeparent, ''_n2a'') as arc_id,
			b.node_id,
			a.node_id,
			''NODE2ARC'', 
			a.nodecat_id as arccat_id, 
			c.epa_type,
			c.sector_id, 
			c.expl_id,
			a.state,
			a.state_type,
			case when (c.addparam::json->>''diameter'')::text !='''' then  (c.addparam::json->>''diameter'')::numeric else NULL end as diameter,
			case when (c.addparam::json->>''roughness'')::text !='''' then  (c.addparam::json->>''roughness'')::numeric else '||v_roughness||' end as roughness,
			a.annotation,
			st_length2d(st_makeline(a.the_geom, b.the_geom)) as length,
			c.addparam::json->>''status'' status,
			st_makeline(a.the_geom, b.the_geom) AS the_geom,
			case when (c.addparam::json->>''minorloss'')::text !='''' then  (c.addparam::json->>''minorloss'')::numeric else 0 end as minorloss,
			c.addparam, a.dma_id, a.presszone_id, a.dqa_id, c.minsector_id
			FROM 	result a,
				result b
				LEFT JOIN result c ON c.node_id = b.nodeparent
				WHERE a.nodeparent = b.nodeparent AND a.arcposition = 1 AND b.arcposition = 2';		

		RAISE NOTICE ' Mark old node from node table';
		EXECUTE ' UPDATE temp_node SET epa_type =''TODELETE'' FROM (SELECT node_id FROM  anl_node a WHERE fid  = 124 and cur_user = current_user ) b
		  WHERE b.node_id  = temp_node.node_id';

		RAISE NOTICE ' Update geometries and topology for existing arcs (REDUCED-PIPE)' ;
		EXECUTE 'UPDATE temp_arc SET node_1=null, arc_type = ''REDUCED-PIPE'', epa_type = ''PIPE'', the_geom = ST_linesubstring(temp_arc.the_geom, ('||0.5*v_nod2arc||' / st_length(temp_arc.the_geom)) , 1) 
			FROM temp_node n WHERE n.node_id = node_1 AND n.epa_type =''TODELETE'' AND geometrytype(temp_arc.the_geom) =''LINESTRING''';
		EXECUTE 'UPDATE temp_arc SET node_2=null, arc_type = ''REDUCED-PIPE'', epa_type = ''PIPE'', the_geom = ST_linesubstring(temp_arc.the_geom, 0, ( 1 - '||0.5*v_nod2arc||' /  st_length(temp_arc.the_geom)))
			FROM temp_node n WHERE n.node_id = node_2 AND n.epa_type =''TODELETE'' AND geometrytype(temp_arc.the_geom) =''LINESTRING''';
		UPDATE temp_arc a SET node_1 = n.node_id FROM temp_node n WHERE st_dwithin(st_startpoint(a.the_geom), n.the_geom, 0.001) and n.node_type =  'NODE2ARC' and a.arc_type = 'REDUCED-PIPE';
		UPDATE temp_arc a SET node_2 = n.node_id FROM temp_node n WHERE st_dwithin(st_endpoint(a.the_geom), n.the_geom, 0.001) and n.node_type = 'NODE2ARC' and a.arc_type = 'REDUCED-PIPE';
			
	ELSE -- checking for inconsistencies

		RAISE NOTICE ' Mark old node from node table';
		EXECUTE ' UPDATE temp_node SET epa_type =''TODELETE'' FROM (SELECT node_id FROM  anl_node a WHERE fid  = 124 and cur_user = current_user ) b
		  WHERE b.node_id  = temp_node.node_id';

		-- check node distance (on temp_node in exception of 'TODELETE' nodes)
		INSERT INTO anl_node (fid, node_id, descript, the_geom)
		SELECT 417, node_id, 'Node close to other node. Maybe nodarc has some problems with closest linestrings. Try to redraw it', the_geom
		FROM (SELECT DISTINCT t1.node_id, t1.epa_type as epatype1, t2.node_id as node_id_aux, t2.epa_type as epatype2, 106, t1.the_geom
				FROM temp_node AS t1 JOIN temp_node AS t2 ON ST_Dwithin(t1.the_geom, t2.the_geom, 0.02) 
				WHERE t1.node_id != t2.node_id ORDER BY t1.node_id ) a where a.epatype1 != 'TODELETE' AND a.epatype2 != 'TODELETE';


		-- check wrong linestring for node_1. If this crashes sql will be inserted on audit log table....
		FOR rec_arc IN SELECT a.arc_id, a.the_geom FROM temp_arc a JOIN temp_node n ON n.node_id = a.node_1 WHERE n.epa_type = 'TODELETE'
		LOOP 
			v_querystring = 'UPDATE temp_arc a SET the_geom = ST_linesubstring(a.the_geom, ('||0.5*v_nod2arc||' / st_length(a.the_geom)) , 1) 
			WHERE arc_id = '||quote_literal(rec_arc.arc_id)||'::text';
			EXECUTE  v_querystring;

		END LOOP;

		-- check wrong linestring for node_2. If this crashes sql will be inserted on audit log table....
		FOR rec_arc IN SELECT a.arc_id, a.the_geom FROM temp_arc a JOIN temp_node n ON n.node_id = a.node_2 WHERE n.epa_type = 'TODELETE'
		LOOP 
			v_querystring = 'UPDATE temp_arc a SET the_geom = ST_linesubstring(a.the_geom, 0, (1 - '||0.5*v_nod2arc||' / st_length(a.the_geom))) 
			WHERE arc_id = '||quote_literal(rec_arc.arc_id)||'::text';
			EXECUTE  v_querystring;
		END LOOP;
	END IF;

	RAISE NOTICE ' Delete old node from node table';
	EXECUTE ' DELETE FROM temp_node WHERE epa_type =''TODELETE''';


	RAISE NOTICE ' Improve diameter';
	
	-- update nodarc diameter when is null, keeping possible values of inp_valve.diameter USING cat_node.dint
	UPDATE temp_arc SET diameter = dint FROM cat_node c WHERE arccat_id = c.id AND c.id IS NOT NULL AND diameter IS NULL;
	
	RETURN 0;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
