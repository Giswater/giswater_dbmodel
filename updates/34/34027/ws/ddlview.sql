/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2021/01/21

CREATE OR REPLACE VIEW v_edit_inp_junction AS 
SELECT DISTINCT ON (node_id) * FROM (
 SELECT	n.node_id,
    n.elevation,
    n.depth,
    n.nodecat_id,
    n.sector_id,
    a.macrosector_id,
    n.dma_id,
    n.state,
    n.state_type,
    n.annotation,
    inp_junction.demand,
    inp_junction.pattern_id,
    n.the_geom
   FROM selector_sector,
    node n
     JOIN inp_junction USING (node_id)
     JOIN vi_parent_arc a ON a.node_1::text = n.node_id::text
  WHERE n.sector_id = selector_sector.sector_id AND selector_sector.cur_user = "current_user"()::text
UNION
 SELECT n.node_id,
    n.elevation,
    n.depth,
    n.nodecat_id,
    n.sector_id,
    a.macrosector_id,
    n.dma_id,
    n.state,
    n.state_type,
    n.annotation,
    inp_junction.demand,
    inp_junction.pattern_id,
    n.the_geom
   FROM selector_sector,
    node n
     JOIN inp_junction USING (node_id)
     JOIN vi_parent_arc a ON a.node_2::text = n.node_id::text
  WHERE n.sector_id = selector_sector.sector_id AND selector_sector.cur_user = "current_user"()::text)a;

