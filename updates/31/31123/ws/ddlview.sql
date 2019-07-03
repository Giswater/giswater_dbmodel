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
elevation AS top_elev,
elevation-depth as elev,
epa_type,
sector_id,
state,
annotation,
the_geom,
v_price_x_catnode.cost_unit,
v_price_compost.descript,
v_price_compost.price as cost,
CASE WHEN v_price_x_catnode.cost_unit::text = 'u' THEN (CASE WHEN sys_type='PUMP' THEN (CASE WHEN pump_number IS NOT NULL THEN pump_number ELSE 1 END) ELSE 1 END)
     WHEN v_price_x_catnode.cost_unit::text = 'm3' THEN (CASE WHEN sys_type='TANK' THEN vmax ELSE NULL END)
     WHEN v_price_x_catnode.cost_unit::text = 'm' THEN (CASE WHEN v_edit_node.depth = 0 THEN v_price_x_catnode.estimated_depth 
															 WHEN v_edit_node.depth IS NULL THEN v_price_x_catnode.estimated_depth ELSE v_edit_node.depth END)
END::numeric(12,2) AS measurement,
CASE WHEN v_price_x_catnode.cost_unit::text = 'u' THEN (CASE WHEN sys_type='PUMP' THEN (CASE WHEN pump_number IS NOT NULL THEN pump_number ELSE 1 END) ELSE 1 END)*v_price_x_catnode.cost
     WHEN v_price_x_catnode.cost_unit::text = 'm3' THEN (CASE WHEN sys_type='TANK' THEN vmax ELSE NULL END)*v_price_x_catnode.cost
     WHEN v_price_x_catnode.cost_unit::text = 'm' THEN (CASE WHEN v_edit_node.depth = 0 THEN v_price_x_catnode.estimated_depth
															 WHEN v_edit_node.depth IS NULL THEN v_price_x_catnode.estimated_depth ELSE v_edit_node.depth END)*v_price_x_catnode.cost
END::numeric(12,2) AS budget,
expl_id
FROM v_edit_node
LEFT JOIN v_price_x_catnode ON v_edit_node.nodecat_id::text = v_price_x_catnode.id::text
LEFT JOIN man_tank ON man_tank.node_id=v_edit_node.node_id
LEFT JOIN man_pump ON man_pump.node_id=v_edit_node.node_id
JOIN cat_node ON cat_node.id::text = v_edit_node.nodecat_id::text
LEFT JOIN v_price_compost ON v_price_compost.id::text = cat_node.cost::text;

