/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/06/26

CREATE OR REPLACE VIEW v_arc AS 
 SELECT arc.arc_id,
    arc.code,
    arc.node_1,
    arc.node_2,
    a.elevation AS elevation1,
    a.depth AS depth1,
    b.elevation AS elevation2,
    b.depth AS depth2,
    arc.arccat_id,
    cat_arc.arctype_id,
    arc_type.type AS sys_type,
    cat_arc.matcat_id,
    cat_arc.pnom,
    cat_arc.dnom,
    arc.epa_type,
    arc.sector_id,
    sector.macrosector_id,
    arc.state,
    arc.state_type,
    arc.annotation,
    arc.observ,
    arc.comment,
    st_length2d(arc.the_geom)::numeric(12,2) AS gis_length,
    arc.custom_length,
    arc.dma_id,
    arc.presszonecat_id,
    arc.soilcat_id,
    arc.function_type,
    arc.category_type,
    arc.fluid_type,
    arc.location_type,
    arc.workcat_id,
    arc.workcat_id_end,
    arc.buildercat_id,
    arc.enddate,
    arc.ownercat_id,
    arc.muni_id,
    arc.postcode,
    arc.streetaxis_id,
    arc.postnumber,
    arc.postcomplement,
    arc.postcomplement2,
    arc.streetaxis2_id,
    arc.postnumber2,
    arc.descript,
    concat(arc_type.link_path, arc.link) AS link,
    arc.verified,
    arc.undelete,
    arc.label_x,
    arc.label_y,
    arc.label_rotation,
    arc.publish,
    arc.inventory,
    dma.macrodma_id,
    arc.expl_id,
    arc.num_value,
    arc.builtdate,
        CASE
            WHEN arc.custom_length IS NOT NULL THEN arc.custom_length::numeric(12,3)
            ELSE st_length2d(arc.the_geom)::numeric(12,3)
        END AS length,
    arc.the_geom,
    arc.minsector_id,
    arc.dqa_id,
    dqa.macrodqa_id,
    cat_arc.label,
    cat_arc.arctype_id AS arc_type,
    a.nodetype_id AS nodetype_1,
    a.staticpressure AS staticpress1,
    b.nodetype_id AS nodetype_2,
    b.staticpressure AS staticpress2,
    arc.lastupdate,
    arc.lastupdate_user,
    arc.insert_user,
    arc.tstamp
   FROM arc
     LEFT JOIN sector ON arc.sector_id = sector.sector_id
     JOIN v_state_arc ON arc.arc_id::text = v_state_arc.arc_id::text
     LEFT JOIN cat_arc ON arc.arccat_id::text = cat_arc.id::text
     JOIN arc_type ON arc_type.id::text = cat_arc.arctype_id::text
     LEFT JOIN dma ON arc.dma_id = dma.dma_id
     LEFT JOIN vu_node a ON a.node_id::text = arc.node_1::text
     LEFT JOIN vu_node b ON b.node_id::text = arc.node_2::text
     LEFT JOIN dqa ON arc.dqa_id = dqa.dqa_id;


CREATE OR REPLACE VIEW ve_arc AS 
 SELECT v_arc.arc_id,
    v_arc.code,
    v_arc.node_1,
    v_arc.node_2,
    v_arc.arccat_id,
    v_arc.arctype_id AS cat_arctype_id,
    v_arc.sys_type,
    v_arc.matcat_id AS cat_matcat_id,
    v_arc.pnom AS cat_pnom,
    v_arc.dnom AS cat_dnom,
    v_arc.epa_type,
    v_arc.sector_id,
    v_arc.macrosector_id,
    v_arc.state,
    v_arc.state_type,
    v_arc.annotation,
    v_arc.observ,
    v_arc.comment,
    v_arc.label,
    v_arc.gis_length,
    v_arc.custom_length,
    v_arc.dma_id,
    v_arc.presszonecat_id,
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
    v_arc.link,
    v_arc.verified,
    v_arc.the_geom,
    v_arc.undelete,
    v_arc.label_x,
    v_arc.label_y,
    v_arc.label_rotation,
    v_arc.publish,
    v_arc.inventory,
    v_arc.macrodma_id,
    v_arc.expl_id,
    v_arc.num_value,
    v_arc.minsector_id,
    v_arc.dqa_id,
    v_arc.macrodqa_id,
    v_arc.arc_type,
    v_arc.nodetype_1,
    v_arc.elevation1,
    v_arc.depth1,
    v_arc.staticpress1,
    v_arc.nodetype_2,
    v_arc.elevation2,
    v_arc.depth2,
    v_arc.staticpress2,
    v_arc.lastupdate,
    v_arc.lastupdate_user,
    v_arc.insert_user,
    v_arc.tstamp
   FROM v_arc;


CREATE OR REPLACE VIEW v_node AS 
 SELECT node.node_id,
    node.code,
    node.elevation,
    node.depth,
    cat_node.nodetype_id,
    node_type.type AS sys_type,
    node.nodecat_id,
    cat_node.matcat_id AS cat_matcat_id,
    cat_node.pnom AS cat_pnom,
    cat_node.dnom AS cat_dnom,
    node.epa_type,
    node.sector_id,
    sector.macrosector_id,
    node.arc_id,
    node.parent_id,
    node.state,
    node.state_type,
    node.annotation,
    node.observ,
    node.comment,
    node.dma_id,
    node.presszonecat_id,
    node.soilcat_id,
    node.function_type,
    node.category_type,
    node.fluid_type,
    node.location_type,
    node.workcat_id,
    node.buildercat_id,
    node.workcat_id_end,
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
    dma.macrodma_id,
    node.expl_id,
    node.hemisphere,
    node.num_value,
    node.minsector_id,
    node.dqa_id,
    dqa.macrodqa_id,
    node.staticpressure,
    cat_node.label,
    cat_node.nodetype_id AS node_type,
    node.lastupdate,
    node.lastupdate_user,
    node.insert_user,
    node.tstamp
   FROM node
     JOIN v_state_node ON v_state_node.node_id::text = node.node_id::text
     LEFT JOIN cat_node ON cat_node.id::text = node.nodecat_id::text
     JOIN node_type ON node_type.id::text = cat_node.nodetype_id::text
     LEFT JOIN dma ON node.dma_id = dma.dma_id
     LEFT JOIN sector ON node.sector_id = sector.sector_id
     LEFT JOIN dqa ON node.dqa_id = dqa.dqa_id;


CREATE OR REPLACE VIEW ve_node AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.elevation,
    v_node.depth,
    v_node.nodetype_id,
    v_node.sys_type,
    v_node.nodecat_id,
    v_node.cat_matcat_id,
    v_node.cat_pnom,
    v_node.cat_dnom,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.arc_id,
    v_node.parent_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.label,
    v_node.dma_id,
    v_node.presszonecat_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.buildercat_id,
    v_node.workcat_id_end,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.postcomplement2,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.descript,
    v_node.svg,
    v_node.rotation,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.hemisphere,
    v_node.num_value,
    v_node.minsector_id,
    v_node.dqa_id,
    v_node.macrodqa_id,
    v_node.staticpressure,
    v_node.node_type,
    v_node.lastupdate,
    v_node.lastupdate_user,
    v_node.insert_user,
    v_node.tstamp
   FROM v_node;



CREATE OR REPLACE VIEW ve_connec AS 
 SELECT connec.connec_id,
    connec.code,
    connec.elevation,
    connec.depth,
    cat_connec.connectype_id,
    connec_type.type AS sys_type,
    connec.connecat_id,
    connec.sector_id,
    sector.macrosector_id,
    connec.customer_code,
    cat_connec.matcat_id AS cat_matcat_id,
    cat_connec.pnom AS cat_pnom,
    cat_connec.dnom AS cat_dnom,
    connec.connec_length,
    connec.state,
    connec.state_type,
    connec.annotation,
    connec.observ,
    connec.comment,
    cat_connec.label,
    connec.dma_id,
    connec.presszonecat_id,
    connec.soilcat_id,
    connec.function_type,
    connec.category_type,
    connec.fluid_type,
    connec.location_type,
    connec.workcat_id,
    connec.workcat_id_end,
    connec.buildercat_id,
    connec.builtdate,
    connec.enddate,
    connec.ownercat_id,
    connec.muni_id,
    connec.postcode,
    connec.streetaxis_id,
    connec.postnumber,
    connec.postcomplement,
    connec.streetaxis2_id,
    connec.postnumber2,
    connec.postcomplement2,
    connec.descript,
    connec.arc_id,
    cat_connec.svg,
    connec.rotation,
    concat(connec_type.link_path, connec.link) AS link,
    connec.verified,
    connec.the_geom,
    connec.undelete,
    connec.label_x,
    connec.label_y,
    connec.label_rotation,
    connec.publish,
    connec.inventory,
    dma.macrodma_id,
    connec.expl_id,
    connec.num_value,
    connec.minsector_id,
    connec.dqa_id,
    dqa.macrodqa_id,
    connec.staticpressure,
    connec.featurecat_id,
    connec.feature_id,
    connec.pjoint_type,
    connec.pjoint_id,
    cat_connec.connectype_id AS connec_type,
    connec.lastupdate,
    connec.lastupdate_user,
    connec.insert_user,
    a.n_hydrometer,
    connec.tstamp
   FROM connec
     LEFT JOIN ( SELECT connec_1.connec_id,
            count(ext_rtc_hydrometer.id)::integer AS n_hydrometer
           FROM ext_rtc_hydrometer
             JOIN connec connec_1 ON ext_rtc_hydrometer.connec_id::text = connec_1.customer_code::text
          GROUP BY connec_1.connec_id) a USING (connec_id)
     JOIN cat_connec ON connec.connecat_id::text = cat_connec.id::text
     JOIN connec_type ON connec_type.id::text = cat_connec.connectype_id::text
     JOIN v_state_connec ON v_state_connec.connec_id::text = connec.connec_id::text
     LEFT JOIN ext_streetaxis ON connec.streetaxis_id::text = ext_streetaxis.id::text
     LEFT JOIN dma ON connec.dma_id = dma.dma_id
     LEFT JOIN sector ON connec.sector_id = sector.sector_id
     LEFT JOIN dqa ON connec.dqa_id = dqa.dqa_id;



CREATE OR REPLACE VIEW v_inp_pjointpattern AS 
 SELECT row_number() OVER (ORDER BY a.pattern_id, a.idrow) AS id,
    a.idrow,
        CASE
            WHEN a.pjoint_type::text = 'VNODE'::text THEN concat('VN', a.pattern_id)::character varying(16)
            ELSE a.pattern_id
        END AS pattern_id,
    sum(a.factor_1)::numeric(10,8) AS factor_1,
    sum(a.factor_2)::numeric(10,8) AS factor_2,
    sum(a.factor_3)::numeric(10,8) AS factor_3,
    sum(a.factor_4)::numeric(10,8) AS factor_4,
    sum(a.factor_5)::numeric(10,8) AS factor_5,
    sum(a.factor_6)::numeric(10,8) AS factor_6,
    sum(a.factor_7)::numeric(10,8) AS factor_7,
    sum(a.factor_8)::numeric(10,8) AS factor_8,
    sum(a.factor_9)::numeric(10,8) AS factor_9,
    sum(a.factor_10)::numeric(10,8) AS factor_10,
    sum(a.factor_11)::numeric(10,8) AS factor_11,
    sum(a.factor_12)::numeric(10,8) AS factor_12,
    sum(a.factor_13)::numeric(10,8) AS factor_13,
    sum(a.factor_14)::numeric(10,8) AS factor_14,
    sum(a.factor_15)::numeric(10,8) AS factor_15,
    sum(a.factor_16)::numeric(10,8) AS factor_16,
    sum(a.factor_17)::numeric(10,8) AS factor_17,
    sum(a.factor_18)::numeric(10,8) AS factor_18
   FROM ( SELECT c.pjoint_type,
                CASE
                    WHEN b.id = (( SELECT min(sub.id) AS min
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 1
                    WHEN b.id = (( SELECT min(sub.id) + 1
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 2
                    WHEN b.id = (( SELECT min(sub.id) + 2
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 3
                    WHEN b.id = (( SELECT min(sub.id) + 3
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 4
                    WHEN b.id = (( SELECT min(sub.id) + 4
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 5
                    WHEN b.id = (( SELECT min(sub.id) + 5
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 6
                    WHEN b.id = (( SELECT min(sub.id) + 6
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 7
                    WHEN b.id = (( SELECT min(sub.id) + 7
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 8
                    WHEN b.id = (( SELECT min(sub.id) + 8
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 9
                    WHEN b.id = (( SELECT min(sub.id) + 9
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 10
                    WHEN b.id = (( SELECT min(sub.id) + 10
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 11
                    WHEN b.id = (( SELECT min(sub.id) + 11
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 12
                    WHEN b.id = (( SELECT min(sub.id) + 12
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 13
                    WHEN b.id = (( SELECT min(sub.id) + 13
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 14
                    WHEN b.id = (( SELECT min(sub.id) + 14
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 15
                    WHEN b.id = (( SELECT min(sub.id) + 15
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 16
                    WHEN b.id = (( SELECT min(sub.id) + 16
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 17
                    WHEN b.id = (( SELECT min(sub.id) + 17
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 18
                    WHEN b.id = (( SELECT min(sub.id) + 18
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 19
                    WHEN b.id = (( SELECT min(sub.id) + 19
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 20
                    WHEN b.id = (( SELECT min(sub.id) + 20
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 21
                    WHEN b.id = (( SELECT min(sub.id) + 21
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 22
                    WHEN b.id = (( SELECT min(sub.id) + 22
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 23
                    WHEN b.id = (( SELECT min(sub.id) + 23
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 24
                    WHEN b.id = (( SELECT min(sub.id) + 24
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 25
                    WHEN b.id = (( SELECT min(sub.id) + 25
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 26
                    WHEN b.id = (( SELECT min(sub.id) + 26
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 27
                    WHEN b.id = (( SELECT min(sub.id) + 27
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 28
                    WHEN b.id = (( SELECT min(sub.id) + 28
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 29
                    WHEN b.id = (( SELECT min(sub.id) + 29
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 30
                    ELSE NULL::integer
                END AS idrow,
            c.pjoint_id AS pattern_id,
            sum(c.demand::double precision * b.factor_1::double precision) AS factor_1,
            sum(c.demand::double precision * b.factor_2::double precision) AS factor_2,
            sum(c.demand::double precision * b.factor_3::double precision) AS factor_3,
            sum(c.demand::double precision * b.factor_4::double precision) AS factor_4,
            sum(c.demand::double precision * b.factor_5::double precision) AS factor_5,
            sum(c.demand::double precision * b.factor_6::double precision) AS factor_6,
            sum(c.demand::double precision * b.factor_7::double precision) AS factor_7,
            sum(c.demand::double precision * b.factor_8::double precision) AS factor_8,
            sum(c.demand::double precision * b.factor_9::double precision) AS factor_9,
            sum(c.demand::double precision * b.factor_10::double precision) AS factor_10,
            sum(c.demand::double precision * b.factor_11::double precision) AS factor_11,
            sum(c.demand::double precision * b.factor_12::double precision) AS factor_12,
            sum(c.demand::double precision * b.factor_13::double precision) AS factor_13,
            sum(c.demand::double precision * b.factor_14::double precision) AS factor_14,
            sum(c.demand::double precision * b.factor_15::double precision) AS factor_15,
            sum(c.demand::double precision * b.factor_16::double precision) AS factor_16,
            sum(c.demand::double precision * b.factor_17::double precision) AS factor_17,
            sum(c.demand::double precision * b.factor_18::double precision) AS factor_18
           FROM ( SELECT inp_connec.connec_id,
                    inp_connec.demand,
                    inp_connec.pattern_id,
                    connec.pjoint_id,
                    connec.pjoint_type
                   FROM inp_connec
                     JOIN connec USING (connec_id)) c
             JOIN inp_pattern_value b USING (pattern_id)
          GROUP BY c.pjoint_type, c.pjoint_id, (
                CASE
                    WHEN b.id = (( SELECT min(sub.id) AS min
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 1
                    WHEN b.id = (( SELECT min(sub.id) + 1
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 2
                    WHEN b.id = (( SELECT min(sub.id) + 2
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 3
                    WHEN b.id = (( SELECT min(sub.id) + 3
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 4
                    WHEN b.id = (( SELECT min(sub.id) + 4
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 5
                    WHEN b.id = (( SELECT min(sub.id) + 5
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 6
                    WHEN b.id = (( SELECT min(sub.id) + 6
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 7
                    WHEN b.id = (( SELECT min(sub.id) + 7
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 8
                    WHEN b.id = (( SELECT min(sub.id) + 8
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 9
                    WHEN b.id = (( SELECT min(sub.id) + 9
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 10
                    WHEN b.id = (( SELECT min(sub.id) + 10
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 11
                    WHEN b.id = (( SELECT min(sub.id) + 11
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 12
                    WHEN b.id = (( SELECT min(sub.id) + 12
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 13
                    WHEN b.id = (( SELECT min(sub.id) + 13
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 14
                    WHEN b.id = (( SELECT min(sub.id) + 14
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 15
                    WHEN b.id = (( SELECT min(sub.id) + 15
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 16
                    WHEN b.id = (( SELECT min(sub.id) + 16
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 17
                    WHEN b.id = (( SELECT min(sub.id) + 17
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 18
                    WHEN b.id = (( SELECT min(sub.id) + 18
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 19
                    WHEN b.id = (( SELECT min(sub.id) + 19
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 20
                    WHEN b.id = (( SELECT min(sub.id) + 20
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 21
                    WHEN b.id = (( SELECT min(sub.id) + 21
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 22
                    WHEN b.id = (( SELECT min(sub.id) + 22
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 23
                    WHEN b.id = (( SELECT min(sub.id) + 23
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 24
                    WHEN b.id = (( SELECT min(sub.id) + 24
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 25
                    WHEN b.id = (( SELECT min(sub.id) + 25
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 26
                    WHEN b.id = (( SELECT min(sub.id) + 26
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 27
                    WHEN b.id = (( SELECT min(sub.id) + 27
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 28
                    WHEN b.id = (( SELECT min(sub.id) + 28
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 29
                    WHEN b.id = (( SELECT min(sub.id) + 29
                       FROM inp_pattern_value sub
                      WHERE sub.pattern_id::text = b.pattern_id::text)) THEN 30
                    ELSE NULL::integer
                END)) a
  GROUP BY a.idrow, a.pattern_id, a.pjoint_type;