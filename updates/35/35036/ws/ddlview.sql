/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

DROP VIEW v_minsector;
CREATE OR REPLACE VIEW v_minsector AS
SELECT m.* FROM selector_expl s, minsector m
where m.expl_id = s.expl_id and cur_user = current_user;



CREATE OR REPLACE VIEW vu_connec  AS
 SELECT connec.connec_id,
    connec.code,
    connec.elevation,
    connec.depth,
    cat_connec.connectype_id AS connec_type,
    cat_feature.system_id AS sys_type,
    connec.connecat_id,
    connec.expl_id,
    exploitation.macroexpl_id,
    connec.sector_id,
    sector.name AS sector_name,
    sector.macrosector_id,
    connec.customer_code,
    cat_connec.matcat_id AS cat_matcat_id,
    cat_connec.pnom AS cat_pnom,
    cat_connec.dnom AS cat_dnom,
    connec.connec_length,
    connec.state,
    connec.state_type,
    a.n_hydrometer,
    connec.arc_id,
    connec.annotation,
    connec.observ,
    connec.comment,
    connec.minsector_id,
    connec.dma_id,
    dma.name AS dma_name,
    dma.macrodma_id,
    connec.presszone_id,
    presszone.name AS presszone_name,
    connec.staticpressure,
    connec.dqa_id,
    dqa.name AS dqa_name,
    dqa.macrodqa_id,
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
    connec.district_id,
    c.descript::character varying(100) AS streetname,
    connec.postnumber,
    connec.postcomplement,
    b.descript::character varying(100) AS streetname2,
    connec.postnumber2,
    connec.postcomplement2,
    connec.descript,
    cat_connec.svg,
    connec.rotation,
    concat(cat_feature.link_path, connec.link) AS link,
    connec.verified,
    connec.undelete,
    cat_connec.label,
    connec.label_x,
    connec.label_y,
    connec.label_rotation,
    connec.publish,
    connec.inventory,
    connec.num_value,
    cat_connec.connectype_id,
    connec.pjoint_id,
    connec.pjoint_type,
    date_trunc('second'::text, connec.tstamp) AS tstamp,
    connec.insert_user,
    date_trunc('second'::text, connec.lastupdate) AS lastupdate,
    connec.lastupdate_user,
    connec.the_geom,
    connec.adate,
    connec.adescript,
    connec.accessibility,
    dma.stylesheet ->> 'featureColor'::text AS dma_style,
    presszone.stylesheet ->> 'featureColor'::text AS presszone_style,
    connec.workcat_id_plan,
    connec.asset_id,
    connec.epa_type,
    connec.om_state,
    connec.conserv_state,
    connec.priority,
    connec.valve_location,
    connec.valve_type,
    connec.shutoff_valve,
    connec.access_type,
    connec.placement_type,
    connec.crmzone_id,
    crm_zone.name AS crmzone_name,
    e.press_max,
    e.press_min,
    e.press_avg,
    e.demand,
    connec.expl_id2,
    e.quality_max,
    e.quality_min,
    e.quality_avg
   FROM connec
     LEFT JOIN ( SELECT connec_1.connec_id,
            count(ext_rtc_hydrometer.id)::integer AS n_hydrometer
           FROM selector_hydrometer,
            ext_rtc_hydrometer
             JOIN connec connec_1 ON ext_rtc_hydrometer.connec_id::text = connec_1.customer_code::text
          WHERE selector_hydrometer.state_id = ext_rtc_hydrometer.state_id AND selector_hydrometer.cur_user = "current_user"()::text
          GROUP BY connec_1.connec_id) a USING (connec_id)
     JOIN cat_connec ON connec.connecat_id::text = cat_connec.id::text
     JOIN cat_feature ON cat_feature.id::text = cat_connec.connectype_id::text
     LEFT JOIN dma ON connec.dma_id = dma.dma_id
     LEFT JOIN sector ON connec.sector_id = sector.sector_id
     LEFT JOIN exploitation ON connec.expl_id = exploitation.expl_id
     LEFT JOIN dqa ON connec.dqa_id = dqa.dqa_id
     LEFT JOIN presszone ON presszone.presszone_id::text = connec.presszone_id::text
     LEFT JOIN crm_zone ON crm_zone.id::text = connec.crmzone_id::text
     LEFT JOIN v_ext_streetaxis c ON c.id::text = connec.streetaxis_id::text
     LEFT JOIN v_ext_streetaxis b ON b.id::text = connec.streetaxis2_id::text
     LEFT JOIN connec_add e ON e.connec_id::text = connec.connec_id::text;
     

CREATE OR REPLACE VIEW v_connec AS 
 SELECT vu_connec.connec_id,
    vu_connec.code,
    vu_connec.elevation,
    vu_connec.depth,
    vu_connec.connec_type,
    vu_connec.sys_type,
    vu_connec.connecat_id,
    vu_connec.expl_id,
    vu_connec.macroexpl_id,
    (case when a.sector_id is null then vu_connec.sector_id else a.sector_id end) as sector_id,
    vu_connec.sector_name,
    vu_connec.macrosector_id,
    vu_connec.customer_code,
    vu_connec.cat_matcat_id,
    vu_connec.cat_pnom,
    vu_connec.cat_dnom,
    vu_connec.connec_length,
    vu_connec.state,
    vu_connec.state_type,
    vu_connec.n_hydrometer,
    v_state_connec.arc_id,
    vu_connec.annotation,
    vu_connec.observ,
    vu_connec.comment,
    (case when a.minsector_id is null then vu_connec.minsector_id else a.minsector_id end) as minsector_id,
    (case when a.dma_id is null then vu_connec.dma_id else a.dma_id end) as dma_id,
    (case when a.dma_name is null then vu_connec.dma_name else a.dma_name end) as dma_name,
    (case when a.macrodma_id is null then vu_connec.macrodma_id else a.macrodma_id end) as macrodma_id,
    (case when a.presszone_id is null then vu_connec.presszone_id::varchar(30) else a.presszone_id::varchar(30) end) as presszone_id,
    (case when a.presszone_name is null then vu_connec.presszone_name else a.presszone_name end) as presszone_name,
    vu_connec.staticpressure,
    (case when a.dqa_id is null then vu_connec.dqa_id else a.dqa_id end) as dqa_id,
    (case when a.dqa_name is null then vu_connec.dqa_name else a.dqa_name end) as dqa_name,
    (case when a.macrodqa_id is null then vu_connec.macrodqa_id else a.macrodqa_id end) as macrodqa_id,
    vu_connec.soilcat_id,
    vu_connec.function_type,
    vu_connec.category_type,
    vu_connec.fluid_type,
    vu_connec.location_type,
    vu_connec.workcat_id,
    vu_connec.workcat_id_end,
    vu_connec.buildercat_id,
    vu_connec.builtdate,
    vu_connec.enddate,
    vu_connec.ownercat_id,
    vu_connec.muni_id,
    vu_connec.postcode,
    vu_connec.district_id,
    vu_connec.streetname,
    vu_connec.postnumber,
    vu_connec.postcomplement,
    vu_connec.streetname2,
    vu_connec.postnumber2,
    vu_connec.postcomplement2,
    vu_connec.descript,
    vu_connec.svg,
    vu_connec.rotation,
    vu_connec.link,
    vu_connec.verified,
    vu_connec.undelete,
    vu_connec.label,
    vu_connec.label_x,
    vu_connec.label_y,
    vu_connec.label_rotation,
    vu_connec.publish,
    vu_connec.inventory,
    vu_connec.num_value,
    vu_connec.connectype_id,
    (case when a.exit_id is null then vu_connec.pjoint_id else a.exit_id end) as pjoint_id,
    (case when a.exit_type is null then vu_connec.pjoint_type else a.exit_type end) as pjoint_type,
    vu_connec.tstamp,
    vu_connec.insert_user,
    vu_connec.lastupdate,
    vu_connec.lastupdate_user,
    vu_connec.the_geom,
    vu_connec.adate,
    vu_connec.adescript,
    vu_connec.accessibility,
    vu_connec.workcat_id_plan,
    vu_connec.asset_id,
    vu_connec.dma_style,
    vu_connec.presszone_style,
    vu_connec.epa_type,
    vu_connec.priority,
    vu_connec.valve_location,
    vu_connec.valve_type,
    vu_connec.shutoff_valve,
    vu_connec.access_type,
    vu_connec.placement_type,
    vu_connec.press_max,
    vu_connec.press_min,
    vu_connec.press_avg,
    vu_connec.demand,
    vu_connec.om_state,
    vu_connec.conserv_state,
    crmzone_id,
    crmzone_name,
    vu_connec.expl_id2,
    vu_connec.quality_max,
    vu_connec.quality_min,
    vu_connec.quality_avg
   FROM vu_connec
     JOIN v_state_connec USING (connec_id)
    LEFT JOIN (SELECT DISTINCT ON (feature_id) * FROM v_link_connec WHERE state = 2) a ON feature_id = connec_id;
    

CREATE OR REPLACE VIEW v_edit_connec AS 
SELECT * FROM v_connec;

CREATE OR REPLACE VIEW ve_connec AS 
SELECT * FROM v_connec;

SELECT gw_fct_admin_manage_views($${"client":{"lang":"ES"}, "feature":{},
"data":{"viewName":["v_edit_connec"], "fieldName":"quality_max", "action":"ADD-FIELD","hasChilds":"True"}}$$);

SELECT gw_fct_admin_manage_views($${"client":{"lang":"ES"}, "feature":{},
"data":{"viewName":["v_edit_connec"], "fieldName":"quality_min", "action":"ADD-FIELD","hasChilds":"True"}}$$);

SELECT gw_fct_admin_manage_views($${"client":{"lang":"ES"}, "feature":{},
"data":{"viewName":["v_edit_connec"], "fieldName":"quality_avg", "action":"ADD-FIELD","hasChilds":"True"}}$$);
