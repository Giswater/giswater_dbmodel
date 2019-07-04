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


--04/07/2019
CREATE OR REPLACE VIEW vu_node AS 
 SELECT node.node_id,
    node.code,
    node.top_elev,
    node.custom_top_elev,
        CASE
            WHEN node.custom_top_elev IS NOT NULL THEN node.custom_top_elev
            ELSE node.top_elev
        END AS sys_top_elev,
    node.ymax,
    node.custom_ymax,
        CASE
            WHEN node.custom_ymax IS NOT NULL THEN node.custom_ymax
            ELSE node.ymax
        END AS sys_ymax,
    node.elev,
    node.custom_elev,
        CASE
            WHEN node.elev IS NOT NULL AND node.custom_elev IS NULL THEN node.elev
            WHEN node.custom_elev IS NOT NULL THEN node.custom_elev
            ELSE (node.top_elev - node.ymax)::numeric(12,3)
        END AS sys_elev,
    node.node_type,
    node_type.type AS sys_type,
    node.nodecat_id,
    cat_node.matcat_id AS cat_matcat_id,
    node.epa_type,
    node.sector_id,
    sector.macrosector_id,
    node.state,
    node.state_type,
    node.annotation,
    node.observ,
    node.comment,
    node.dma_id,
    node.soilcat_id,
    node.function_type,
    node.category_type,
    node.fluid_type,
    node.location_type,
    node.workcat_id,
    node.workcat_id_end,
    node.buildercat_id,
    node.builtdate,
    node.enddate,
    node.ownercat_id,
    node.muni_id,
    node.postcode,
    node.streetaxis_id,
    node.postnumber,
    node.postcomplement,
    node.postcomplement2,
    node.streetaxis2_id,
    node.postnumber2,
    node.descript,
    cat_node.svg,
    node.rotation,
    concat(node_type.link_path, node.link) AS link,
    node.verified,
    node.the_geom,
    node.undelete,
    node.label_x,
    node.label_y,
    node.label_rotation,
    node.publish,
    node.inventory,
    node.uncertain,
    node.xyz_date,
    node.unconnected,
    dma.macrodma_id,
    node.expl_id,
    node.num_value
   FROM node
     LEFT JOIN cat_node ON node.nodecat_id::text = cat_node.id::text
     LEFT JOIN node_type ON node_type.id::text = node.node_type::text
     LEFT JOIN dma ON node.dma_id = dma.dma_id
     LEFT JOIN sector ON node.sector_id = sector.sector_id;

CREATE OR REPLACE VIEW v_arc_x_node AS 
 SELECT v_arc.arc_id,
    v_arc.code,
    v_arc.node_1,
    v_arc.y1,
    v_arc.custom_y1,
    v_arc.elev1,
    v_arc.custom_elev1,
	CASE
	    WHEN sys_elev1 IS NULL THEN a.sys_elev
	    ELSE sys_elev1
	END AS sys_elev1,
    a.sys_top_elev - v_arc.sys_elev1 AS sys_y1,
    a.sys_top_elev - v_arc.sys_elev1 - v_arc.geom1 AS r1,
        CASE
            WHEN a.sys_elev IS NOT NULL THEN v_arc.sys_elev1 - a.sys_elev
            ELSE (v_arc.sys_elev1 - (a.sys_top_elev - a.sys_ymax))::numeric(12,3)
        END AS z1,
    v_arc.node_2,
    v_arc.y2,
    v_arc.custom_y2,
    v_arc.elev2,
    v_arc.custom_elev2,
	CASE
	    WHEN sys_elev2 IS NULL THEN b.sys_elev
	    ELSE sys_elev2
	END AS sys_elev2,
    b.sys_top_elev - v_arc.sys_elev2 AS sys_y2,
    b.sys_top_elev - v_arc.sys_elev2 - v_arc.geom1 AS r2,
        CASE
            WHEN b.sys_elev IS NOT NULL THEN v_arc.sys_elev2 - b.sys_elev
            ELSE (v_arc.sys_elev2 - (b.sys_top_elev - b.sys_ymax))::numeric(12,3)
        END AS z2,
    v_arc.sys_slope AS slope,
    v_arc.arc_type,
    arc_type.type AS sys_type,
    v_arc.arccat_id,
    v_arc.matcat_id,
    v_arc.shape,
    v_arc.geom1,
    v_arc.geom2,
    v_arc.width,
    v_arc.epa_type,
    v_arc.sector_id,
    sector.macrosector_id,
    v_arc.state,
    v_arc.state_type,
    v_arc.annotation,
    v_arc.custom_length,
    v_arc.gis_length,
    v_arc.observ,
    v_arc.comment,
    v_arc.inverted_slope,
    v_arc.dma_id,
    dma.macrodma_id,
    v_arc.soilcat_id,
    v_arc.function_type,
    v_arc.category_type,
    v_arc.fluid_type,
    v_arc.location_type,
    v_arc.workcat_id,
    v_arc.workcat_id_end,
    v_arc.buildercat_id,
    v_arc.builtdate,
    v_arc.enddate,
    v_arc.ownercat_id,
    v_arc.muni_id,
    v_arc.postcode,
    v_arc.streetaxis_id,
    v_arc.postnumber,
    v_arc.postcomplement,
    v_arc.postcomplement2,
    v_arc.streetaxis2_id,
    v_arc.postnumber2,
    v_arc.descript,
    concat(arc_type.link_path, v_arc.link) AS link,
    v_arc.verified,
    v_arc.the_geom,
    v_arc.undelete,
    v_arc.label_x,
    v_arc.label_y,
    v_arc.label_rotation,
    v_arc.publish,
    v_arc.inventory,
    v_arc.uncertain,
    v_arc.expl_id,
    v_arc.num_value
   FROM v_arc
     JOIN sector ON sector.sector_id = v_arc.sector_id
     JOIN arc_type ON v_arc.arc_type::text = arc_type.id::text
     JOIN dma ON v_arc.dma_id = dma.dma_id
     LEFT JOIN vu_node a ON a.node_id::text = v_arc.node_1::text
     LEFT JOIN vu_node b ON b.node_id::text = v_arc.node_2::text


