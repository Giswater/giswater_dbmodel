/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;


CREATE OR REPLACE VIEW vi_demands AS 
 SELECT temp_demand.feature_id,
    temp_demand.demand,
    temp_demand.pattern_id,
    concat(';', temp_demand.dscenario_id, ' ', temp_demand.source, ' ', temp_demand.demand_type) AS other
   FROM temp_demand
     JOIN temp_node ON temp_demand.feature_id::text = temp_node.node_id::text
     where temp_demand.demand is not null
  ORDER BY temp_demand.feature_id, (concat(';', temp_demand.dscenario_id, ' ', temp_demand.source, ' ', temp_demand.demand_type));
  
  
  CREATE OR REPLACE VIEW v_ui_arc_x_relations AS 
 SELECT row_number() OVER (ORDER BY v_node.node_id) + 1000000 AS rid,
    v_node.arc_id,
    v_node.nodetype_id AS featurecat_id,
    v_node.nodecat_id AS catalog,
    v_node.node_id AS feature_id,
    v_node.code AS feature_code,
    v_node.sys_type,
    v_arc.state AS arc_state,
    v_node.state AS feature_state,
    st_x(v_node.the_geom) AS x,
    st_y(v_node.the_geom) AS y,
    'v_edit_node'::text AS sys_table_id
   FROM v_node
     JOIN arc v_arc ON v_arc.arc_id::text = v_node.arc_id::text
  WHERE v_node.arc_id IS NOT NULL
UNION
 SELECT row_number() OVER () + 2000000 AS rid,
    v_arc.arc_id,
    v_connec.connectype_id AS featurecat_id,
    v_connec.connecat_id AS catalog,
    v_connec.connec_id AS feature_id,
    v_connec.code AS feature_code,
    v_connec.sys_type,
    v_arc.state AS arc_state,
    v_connec.state AS feature_state,
    st_x(v_connec.the_geom) AS x,
    st_y(v_connec.the_geom) AS y,
    'v_edit_connec'::text AS sys_table_id
   FROM v_connec
     JOIN arc v_arc ON v_arc.arc_id::text = v_connec.arc_id::text
  WHERE v_connec.arc_id IS NOT NULL;