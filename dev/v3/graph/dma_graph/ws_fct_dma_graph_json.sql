/*
This file IS part of Giswater 3
The program IS free software: you can redistribute it and/or modify it under the terms of the GNU General Public License AS published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater IS provided by Giswater Association
*/

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_dma_graph_json(p_data json)
	RETURNS json
	LANGUAGE plpgsql
AS $function$


DECLARE
v_schema_date date;
v_json_result_header json;

BEGIN

	-- Input params
	--
	SELECT "date" INTO v_schema_date FROM sys_version ORDER BY giswater DESC LIMIT 1;
	
	-- Build Network info:
	
	SELECT json_build_object(
		'name', concat(expl_id, ' - ', e.name), 
		'description', concat('DMA graph de ', e.name),
		'macroExpl', concat(n.macroexpl_id, ' - ', f.name),
		'entity', 'ent',
		'generatedDate', now(),
		'schemaDate', v_schema_date,
	) INTO v_json_result_header
	FROM ws.v_edit_node n 
	JOIN exploitation e USING (expl_id) 
	JOIN macroexploitation f ON e.macroexpl_id = f.macroexpl_id
	LIMIT 1;


	/*
	"name": "Red de...",
    "description": "Sect...",
    "municipality": "municipio",
    "entity": "entity",
    "generatedDate": "2025-04-08T20:46:34Z",
    "schemaDate": "Nov 1998",
    "schemaNumber": "1",
    "sheetNumber": "1"
	 */
	

	
	-- Build key "nodes" (table dma_graph_object)
	
	/*
	"id": "CONN_IB",
  	"type": "ETAPConnection",
  	"label": "IB",
  	"attributes": {},
  	"schematicPosition": { "x": 400, "y": 50 }
	*/
	
	
	
	-- Build key "links" (table dma_graph_meter)
	
	/*
 	"id": "L01_TZO",
 	"type": "Pipe",
  	"from_node": "CONN_IB",
  	"to_node": "DEP",
  	"attributes": { "networkPressureType": "Baja", "meterId": "98040", "meterTransmission": "Wf" }
 	*/



END;

$function$
;
