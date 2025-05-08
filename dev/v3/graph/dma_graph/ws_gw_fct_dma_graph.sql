/*
This file IS part of Giswater 3
The program IS free software: you can redistribute it and/or modify it under the terms of the GNU General Public License AS published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater IS provided by Giswater Association
*/

CREATE OR REPLACE FUNCTION ws.gw_fct_dma_graph(p_data json)
	RETURNS json
	LANGUAGE plpgsql
AS $function$

-- Function code: 3326

/*

-- TODO: type an example
SELECT ws.gw_fct_dma_graph($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{},"data":{"parameters":{"explId":501, "searchDistRouting":999}}}$$);

*/

DECLARE 
-- input params --
v_expl_id INTEGER;
v_search_dist INTEGER;

-- vars --
v_srid INTEGER;
rec_meter RECORD;
v_tank_id INTEGER;
rec RECORD;
v_sql_pgrouting TEXT;

-- return --
v_version TEXT;
v_result_info TEXT;


BEGIN
	
	-- Search path
	SET search_path = "ws", public;


	-- Input params
	v_expl_id = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'explId')::integer;
	v_search_dist = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'searchDistRouting')::integer;

	SELECT giswater, epsg INTO v_version, v_srid FROM sys_version LIMIT 1;


	-- PART 1 (embeded in  gw_fct_mapzonesanalitics)
	
	
	-- Get topology of dma's
	v_sql_pgrouting = 'WITH entr AS (SELECT node_id, dma_id AS dma_2 FROM om_waterbalance_dma_graph WHERE flow_sign = 1),
	sort AS (SELECT node_id, dma_id AS dma_1 FROM om_waterbalance_dma_graph WHERE flow_sign = -1)
	SELECT node_id::int AS id, dma_1 AS source, dma_2 AS target, 1 AS cost FROM entr 
	LEFT JOIN sort USING (node_id)
	JOIN node n using (node_id) 
	WHERE dma_1 IS NOT NULL AND dma_2 IS NOT NULL AND n.state = 1';


	-- Get the flooding order of the dma's using previous query
	FOR rec in execute 'SELECT DISTINCT "source" from ('||v_sql_pgrouting||')a'
	LOOP
		
		execute '
		INSERT INTO temp_dma_order (meter_id, dma_1, dma_2, agg_cost)
		SELECT edge AS meter_id, '||rec."source"||' AS dma_1, node AS dma_2, agg_cost 
		FROM pgr_drivingDistance('||quote_literal(v_sql_pgrouting)||', '||rec."source"||', '||v_search_dist||')
		ON CONFLICT (meter_id, dma_1, dma_2) DO NOTHING
		';

	END LOOP;
	
	
	-- STEP 1.1 Fill the table dma_graph_meter (the tanks are represented with meter_id = 0)
	INSERT INTO dma_graph_meter (meter_id, object_1, object_2, expl_id, attrib, the_geom) 
	SELECT a.meter_id, a.dma_1, a.dma_2, n.expl_id, 
    json_build_object(
    'networkPressureType', n.category_type,
    'meterId', a.meter_id,
    'meterTransmission', c.matcat_id
    ) AS attributs,
    st_makeline(array[st_centroid(d.the_geom), n.the_geom, st_centroid(e.the_geom)]) AS the_geom    
    FROM temp_dma_order a
    JOIN node n on a.meter_id::text = n.node_id
    JOIN cat_node c on c.id = n.nodecat_id
    LEFT JOIN dma d on d.dma_id = a.dma_1 
    LEFT JOIN dma e on e.dma_id = a.dma_2
    ON CONFLICT (meter_id, expl_id) DO NOTHING;

   	
   	-- STEP 1.2 Fill the table dma_graph_object (it has dma's AND tanks)

	-- INSERT dmas
	INSERT INTO dma_graph_object (object_id, expl_id, object_type, the_geom, order_id)
	SELECT DISTINCT dma_id, d.expl_id, 'DMA', st_centroid(the_geom), min(b.agg_cost) 
	FROM om_waterbalance_dma_graph 
	LEFT JOIN dma d using (dma_id) 
	LEFT JOIN temp_dma_order b on dma_id = b.dma_2
	WHERE expl_id =  514
	group by dma_id, expl_id, st_centroid(the_geom)
	ON CONFLICT (object_id, expl_id) DO NOTHING;

	--INSERT tanks (pgr_drivingdistnace): take them from the meter_id WHERE dma_1 = 0 AND dma_2 > 0

	-- prepare graph: go backward from the meter to look for the tank upstream
	v_sql_pgrouting = '
	SELECT arc_id::int AS id, node_1::int AS target, node_2::int AS source,
	CASE WHEN mv1.closed IS true or mv2.closed then 0
	WHEN a.dma_id = 0 then 1 
	ELSE 0 END AS cost,
	CASE WHEN mv1.closed IS true or mv2.closed then 0
	WHEN a.dma_id = 0 then 1 
	ELSE 0 END AS reverse_cost
	FROM arc a
	LEFT JOIN man_valve mv1 ON node_1=mv1.node_id
	LEFT JOIN man_valve mv2 ON node_2=mv2.node_id
	WHERE a.node_1 IS NOT NULL AND a.node_2 IS NOT NULL AND a.state = 1 AND a.dma_id <1
	AND (mv1.closed IS NOT true OR mv2.closed IS NOT true)
	';

   	-- LOOP for each meter_id WHERE dma_1 = 0 AND dma_2 > 0 -> AND then, find the tank (=last node_id)
   	FOR rec_meter IN SELECT meter_id::INT FROM temp_dma_order WHERE dma_1 = 0 AND dma_2 > 0
   	LOOP

		-- flood all the pipes AND AVOID the pipes that have closed valves AS node_1 or node_2
	   	EXECUTE '
	   	SELECT a.node from pgr_drivingdistance ('||quote_literal(v_sql_pgrouting)||', '||rec_meter.meter_id||', 1000) a
		JOIN node n ON node = n.node_id::int WHERE n.nodecat_id LIKE ''%DEP%''
		ORDER BY a.agg_cost asc LIMIT 1
    	' INTO v_tank_id;
    
    	-- raise notice 'tank_id: %  | meter_id: %  |  expl_id: %', v_tank_id, rec_meter.meter_id
			
   	   	UPDATE dma_graph_meter SET object_1 = v_tank_id  WHERE meter_id = rec_meter.meter_id;
   	   
   	   	IF v_tank_id IS NOT NULL THEN
   	   		
   	   		EXECUTE '
	   	   	INSERT INTO dma_graph_object (object_id, object_type, expl_id, the_geom, order_id) 
			SELECT  '||v_tank_id||', ''TANK'', '||v_expl_id||', c.the_geom, b.agg_cost FROM dma_graph_meter a 
			LEFT JOIN temp_dma_order b using (meter_id)
			LEFT JOIN node c ON b.meter_id = c.node_id::int
			WHERE b.meter_id = '||rec_meter.meter_id||'	
			ON CONFLICT (object_id, expl_id) DO NOTHING
			';
		
		END IF;
	
			
	END LOOP;


	v_version = COALESCE(v_version, '{}');
	v_result_info = COALESCE(v_result_info, '{}');

	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"DMA graph successfully created"}, "version":"'||v_version||'"'||
				',"body":{"form":{}'||
				',"data":{ "info":'||v_result_info||'}}'||
			'}')::json, 3326, null, null, null);

END;

$function$
;