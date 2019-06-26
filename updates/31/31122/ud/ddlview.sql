/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

--2019/06/26

CREATE OR REPLACE VIEW v_node AS
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
    JOIN v_state_node ON node.node_id::text = v_state_node.node_id::text
    LEFT JOIN cat_node ON node.nodecat_id::text = cat_node.id::text
    LEFT JOIN node_type ON node_type.id::text = node.node_type::text
    LEFT JOIN dma ON node.dma_id = dma.dma_id
    LEFT JOIN sector ON node.sector_id = sector.sector_id;