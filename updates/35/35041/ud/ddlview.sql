/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE OR REPLACE VIEW v_edit_element
AS SELECT element.element_id,
    element.code,
    element.elementcat_id,
    cat_element.elementtype_id,
    element.serial_number,
    element.state,
    element.state_type,
    element.num_elements,
    element.observ,
    element.comment,
    element.function_type,
    element.category_type,
    element.location_type,
    element.fluid_type,
    element.workcat_id,
    element.workcat_id_end,
    element.buildercat_id,
    element.builtdate,
    element.enddate,
    element.ownercat_id,
    element.rotation,
    concat(element_type.link_path, element.link) AS link,
    element.verified,
    element.the_geom,
    element.label_x,
    element.label_y,
    element.label_rotation,
    element.publish,
    element.inventory,
    element.undelete,
    element.expl_id,
    element.pol_id,
    element.lastupdate,
    element.lastupdate_user,
    element.trace_featuregeom
   FROM selector_expl,
    element
     JOIN v_state_element ON element.element_id::text = v_state_element.element_id::text
     JOIN cat_element ON element.elementcat_id::text = cat_element.id::text
     JOIN element_type ON element_type.id::text = cat_element.elementtype_id::text
  WHERE element.expl_id = selector_expl.expl_id AND selector_expl.cur_user = "current_user"()::text;

  CREATE OR REPLACE VIEW ve_pol_gully
AS SELECT polygon.pol_id,
    polygon.feature_id,
    polygon.featurecat_id,
    polygon.state,
    polygon.sys_type,
    polygon.the_geom,
    gully.fluid_type,
    polygon.trace_featuregeom
   FROM gully
     JOIN v_state_gully USING (gully_id)
     JOIN polygon ON polygon.feature_id::text = gully.gully_id::text;

CREATE OR REPLACE VIEW ve_pol_node
AS SELECT polygon.pol_id,
    polygon.feature_id,
    polygon.featurecat_id,
    polygon.state,
    polygon.sys_type,
    polygon.the_geom,
    polygon.trace_featuregeom
   FROM node
     JOIN v_state_node USING (node_id)
     JOIN polygon ON polygon.feature_id::text = node.node_id::text;

CREATE OR REPLACE VIEW ve_pol_connec
AS SELECT polygon.pol_id,
    polygon.feature_id,
    polygon.featurecat_id,
    polygon.state,
    polygon.sys_type,
    polygon.the_geom,
    polygon.trace_featuregeom
   FROM connec
     JOIN v_state_connec USING (connec_id)
     JOIN polygon ON polygon.feature_id::text = connec.connec_id::text;


CREATE OR REPLACE VIEW ve_pol_element
AS SELECT e.pol_id,
    e.element_id,
    polygon.the_geom,
    polygon.trace_featuregeom
   FROM v_edit_element e
     JOIN polygon USING (pol_id);
	 
--1/11/2023
CREATE OR REPLACE VIEW v_edit_plan_psector_x_gully AS 
SELECT plan_psector_x_gully.id,
    plan_psector_x_gully.gully_id,
    plan_psector_x_gully.arc_id,
    plan_psector_x_gully.psector_id,
    plan_psector_x_gully.state,
    plan_psector_x_gully.doable,
    plan_psector_x_gully.descript,
    plan_psector_x_gully.link_id,
    plan_psector_x_gully.active,
    plan_psector_x_gully.insert_tstamp,
    plan_psector_x_gully.insert_user,
    exit_type
   FROM plan_psector_x_gully
   JOIN v_edit_link USING (link_id);
  
  
drop view if exists v_ui_arc_x_relations;
CREATE OR REPLACE VIEW v_ui_arc_x_relations as
  WITH links_node AS (
         SELECT n.node_id,
            l.feature_id,
            l.exit_type AS proceed_from,
            l.exit_id AS proceed_from_id,
            l.state AS l_state,
            n.state AS n_state
           FROM node n
             JOIN link l ON n.node_id::text = l.exit_id::text
             where l.state = 1
        )
 SELECT row_number() OVER () + 1000000 AS rid,  
    v_connec.arc_id,
    v_connec.connec_type AS featurecat_id,
    v_connec.connecat_id AS catalog,
    v_connec.connec_id AS feature_id,
    v_connec.code AS feature_code,
    v_connec.sys_type,
    a.state as arc_state,
    v_connec.state AS feature_state,
    st_x(v_connec.the_geom) AS x,
    st_y(v_connec.the_geom) AS y,
    l.exit_type AS proceed_from,
    l.exit_id AS proceed_from_id,
    'v_edit_connec'::text AS sys_table_id
   FROM v_connec
     JOIN link l ON v_connec.connec_id::text = l.feature_id::text
     JOIN arc a ON a.arc_id = v_connec.arc_id
  WHERE v_connec.arc_id IS NOT NULL AND l.exit_type::text <> 'NODE'::text AND l.state = 1 AND l.state = 1 and a.state = 1
UNION
 SELECT DISTINCT ON (c.connec_id) row_number() OVER () + 2000000 AS rid,
    a.arc_id,
    c.connec_type AS featurecat_id,
    c.connecat_id AS catalog,
    c.connec_id AS feature_id,
    c.code AS feature_code,
    c.sys_type,
    a.state as arc_state,
    c.state AS feature_state,
    st_x(c.the_geom) AS x,
    st_y(c.the_geom) AS y,
    n.proceed_from,
    n.proceed_from_id,
    'v_edit_connec'::text AS sys_table_id
   FROM arc a
     JOIN links_node n ON a.node_1::text = n.node_id::text
     JOIN v_connec c ON c.connec_id::text = n.feature_id::text
UNION
 SELECT row_number() OVER () + 3000000 AS rid, 
    v_gully.arc_id,
    v_gully.gully_type AS featurecat_id,
    v_gully.gratecat_id AS catalog,
    v_gully.gully_id AS feature_id,
    v_gully.code AS feature_code,
    v_gully.sys_type,
    a.state as arc_state,
    v_gully.state AS feature_state,
    st_x(v_gully.the_geom) AS x,
    st_y(v_gully.the_geom) AS y,
    l.exit_type AS proceed_from,
    l.exit_id AS proceed_from_id,
    'v_edit_gully'::text AS sys_table_id
   FROM v_gully
     JOIN link l ON v_gully.gully_id::text = l.feature_id::text
     JOIN arc a ON a.arc_id = v_gully.arc_id
  WHERE v_gully.arc_id IS NOT NULL AND l.exit_type::text <> 'NODE'::text AND l.state = 1 and a.state =  1
UNION
 SELECT DISTINCT ON (g.gully_id) row_number() OVER () + 4000000 AS rid, 
    a.arc_id,
    g.gully_type AS featurecat_id,
    g.gratecat_id AS catalog,
    g.gully_id AS feature_id,
    g.code AS feature_code,
    g.sys_type,
    a.state as arc_state,
    g.state AS feature_state,
    st_x(g.the_geom) AS x,
    st_y(g.the_geom) AS y,
    n.proceed_from,
    n.proceed_from_id,
    'v_edit_gully'::text AS sys_table_id
   FROM arc a
     JOIN links_node n ON a.node_1::text = n.node_id::text
     JOIN v_gully g ON g.gully_id::text = n.feature_id::text;
     