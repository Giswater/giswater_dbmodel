/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--03/07/2019
CREATE OR REPLACE VIEW "v_plan_node" AS 
SELECT
v_edit_node.node_id,
nodecat_id,
sys_type AS node_type,
top_elev,
elev,
epa_type,
sector_id,
state,
annotation,
the_geom,
v_price_x_catnode.cost_unit,
v_price_compost.descript,
v_price_compost.price as cost,
CASE WHEN v_price_x_catnode.cost_unit::text = 'u' THEN 1
     WHEN v_price_x_catnode.cost_unit::text = 'm3' THEN (CASE 	WHEN sys_type='STORAGE' THEN man_storage.max_volume::numeric 
																WHEN sys_type='CHAMBER' THEN man_chamber.max_volume::numeric
																ELSE NULL END)
     WHEN v_price_x_catnode.cost_unit::text = 'm' THEN
          CASE WHEN v_edit_node.ymax = 0 THEN v_price_x_catnode.estimated_y
			   WHEN v_edit_node.ymax IS NULL THEN v_price_x_catnode.estimated_y
               ELSE v_edit_node.ymax END
    END::numeric(12,2) AS measurement,
CASE WHEN v_price_x_catnode.cost_unit::text = 'u' THEN v_price_x_catnode.cost
     WHEN v_price_x_catnode.cost_unit::text = 'm3' THEN (CASE 	WHEN sys_type='STORAGE' THEN man_storage.max_volume*v_price_x_catnode.cost 
																WHEN sys_type='CHAMBER' THEN man_chamber.max_volume*v_price_x_catnode.cost 
																ELSE NULL END)
     WHEN v_price_x_catnode.cost_unit::text = 'm' THEN
          CASE WHEN v_edit_node.ymax = 0 THEN v_price_x_catnode.estimated_y*v_price_x_catnode.cost
               WHEN v_edit_node.ymax IS NULL THEN v_price_x_catnode.estimated_y*v_price_x_catnode.cost
               ELSE v_edit_node.ymax*v_price_x_catnode.cost END 
END::numeric(12,2) AS budget,
expl_id
FROM v_edit_node
LEFT JOIN v_price_x_catnode ON v_edit_node.nodecat_id::text = v_price_x_catnode.id::text
LEFT JOIN man_chamber ON man_chamber.node_id=v_edit_node.node_id
LEFT JOIN man_storage ON man_storage.node_id=v_edit_node.node_id
JOIN cat_node ON cat_node.id::text = v_edit_node.nodecat_id::text
LEFT JOIN v_price_compost ON v_price_compost.id::text = cat_node.cost::text;

