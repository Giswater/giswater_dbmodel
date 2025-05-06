/*
This file IS part of Giswater 3
The program IS free software: you can redistribute it and/or modify it under the terms of the GNU General Public License AS published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater IS provided by Giswater Association
*/

CREATE OR REPLACE FUNCTION ws.gw_fct_dma_graph(p_data json)
	RETURNS json
	LANGUAGE plpgsql
AS $function$

/*

-- TODO: type an example
SELECT ws.gw_fct_dma_graph('1', $${"client":{"device":3,"infoType":100,"lang":"es"},"form":{},
"data":{"parameters":{"explId":525},"fields":{},"pageInfo":null}}$$)


*/

DECLARE 
v_expl_id INTEGER;
rec_meter record;

BEGIN
	
	-- Search path
	SET search_path = "ws", public;


	-- Input params
	v_expl_id = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'explId')::integer;	
		

	-- PART 1 (embeded in  gw_fct_mapzonesanalitics)


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
    JOIN ws.node n on a.meter_id::text = n.node_id
    JOIN ws.cat_node c on c.id = n.nodecat_id
    LEFT JOIN ws.dma d on d.dma_id = a.dma_1 
    LEFT JOIN ws.dma e on e.dma_id = a.dma_2;

   	
   	-- STEP 1.2 Fill the table dma_graph_object (it has dma's and tanks)

	-- INSERT dmas
	INSERT INTO dma_graph_object (object_id, expl_id, object_type, the_geom)
	SELECT distinct dma_id, expl_id, 'DMA', st_centroid(the_geom) FROM om_waterbalance WHERE expl_id =  v_expl_id;

	-- INSERT tanks (pgr_drivingdistnace): take them from the meter_id where dma_1 = 0 and dma_2 > 0
	--v_sql = '
	--SELECT arc_id::integer AS id, node_1::integer AS source, node_2::integer AS target,
	SELECT arc_id, node_1, node_2, 
	CASE WHEN mv1.closed IS true or mv2.closed then 1
	--WHEN arc_id = el que tiene al lado com dma then 1
	ELSE 0 END AS cost
	FROM ws.arc a
	LEFT JOIN ws.man_valve mv1 ON node_1=mv1.node_id
	LEFT JOIN ws.man_valve mv2 ON node_2=mv2.node_id
	WHERE mv1.closed IS NOT true OR mv2.closed IS NOT true
	and a.node_1 IS NOT NULL AND a.node_2 IS NOT NULL AND a.state = 1;
	--';
 
   	-- LOOP for each meter_id where dma_1 = 0 and dma_2 > 0 -> and then, find the tank (=last node_id)
   FOR rec_meter IN SELECT meter_id FROM temp_dma_order WHERE dma_1 = 0 AND dma_2 > 0
   LOOP

		-- TO-DO: flood all the pipes and AVOID the pipes that 1) have closed valves as node_1 or node_2 and 2) have dma_id = 0
		-- TO-DO: querytext as a variable and add schema name to tables
   		SELECT node INTO v_tank FROM pgr_drivingdistance (
			'SELECT arc_id::integer AS id, node_1::integer AS source, node_2::integer AS target, 
			CASE WHEN mv1.closed IS true or mv2.closed then 1
			--WHEN arc_id = el que tiene al lado com dma then 1
			 ELSE  0 end AS cost
			FROM ws.arc a
			LEFT JOIN ws.man_valve mv1 ON node_1=mv1.node_id
			LEFT JOIN man_valve mv2 ON node_2=mv2.node_id
			WHERE node_1 IS not null and node_2 IS not null and a.state = 1
			and mv1.closed IS not true or mv2.closed IS not true'::text,
			rec_meter , 1000) JOIN node n ON node = n.node_id WHERE n.nodecat_id LIKE '%DEP%' ORDER BY agg_cost ASC LIMIT 1
    
   
   	   	-- UPDATE dma_graph_meter WHERE object_1 = v_tank  WHERE meter_id = v_meter
		-- INSERT dma_graph_object (object_id, object_type, expl_id) SELECT v_tank_id, v_expl_id, 'TANK', the_geom FROM node WHERE node_id = v_tank_id
			
	END LOOP;

END;

$function$
;
