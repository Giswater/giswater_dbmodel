/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2021/01/21
CREATE OR REPLACE VIEW v_edit_inp_junction AS 
SELECT DISTINCT ON (node_id) * FROM (
 SELECT node.node_id,
    node.top_elev,
    node.custom_top_elev,
    node.ymax,
    node.custom_ymax,
    node.elev,
    node.custom_elev,
    node.elev AS sys_elev,
    node.nodecat_id,
    node.sector_id,
    macrosector_id,
    node.state,
    node.state_type,
    node.annotation,
    node.expl_id,
    inp_junction.y0,
    inp_junction.ysur,
    inp_junction.apond,
    inp_junction.outfallparam::text AS outfallparam,
    node.the_geom
   FROM selector_sector,
    node
     JOIN inp_junction USING (node_id)
     JOIN vi_parent_arc a ON node_1 = node_id

  WHERE node.sector_id = selector_sector.sector_id AND selector_sector.cur_user = "current_user"()::text
UNION
 SELECT node.node_id,
    node.top_elev,
    node.custom_top_elev,
    node.ymax,
    node.custom_ymax,
    node.elev,
    node.custom_elev,
    node.elev AS sys_elev,
    node.nodecat_id,
    node.sector_id,
    macrosector_id,
    node.state,
    node.state_type,
    node.annotation,
    node.expl_id,
    inp_junction.y0,
    inp_junction.ysur,
    inp_junction.apond,
    inp_junction.outfallparam::text AS outfallparam,
    node.the_geom
   FROM selector_sector,
    node
     JOIN inp_junction USING (node_id)
     JOIN vi_parent_arc a ON node_2 = node_id
  WHERE node.sector_id = selector_sector.sector_id AND selector_sector.cur_user = "current_user"()::text)a;

