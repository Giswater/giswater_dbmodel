/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2024/11/11
CREATE OR REPLACE VIEW v_edit_node
AS SELECT DISTINCT ON (a.node_id) a.node_id,
    a.code,
    a.top_elev,
    a.custom_top_elev,
    a.sys_top_elev,
    a.ymax,
    a.custom_ymax,
    a.sys_ymax,
    a.elev,
    a.custom_elev,
    a.sys_elev,
    a.node_type,
    a.sys_type,
    a.nodecat_id,
    a.matcat_id,
    a.epa_type,
    a.state,
    a.state_type,
    a.expl_id,
    a.macroexpl_id,
    a.sector_id,
    a.sector_type,
    a.macrosector_id,
    a.drainzone_id,
    a.drainzone_type,
    a.annotation,
    a.observ,
    a.comment,
    a.dma_id,
    a.macrodma_id,
    a.soilcat_id,
    a.function_type,
    a.category_type,
    a.fluid_type,
    a.location_type,
    a.workcat_id,
    a.workcat_id_end,
    a.buildercat_id,
    a.builtdate,
    a.enddate,
    a.ownercat_id,
    a.muni_id,
    a.postcode,
    a.district_id,
    a.streetname,
    a.postnumber,
    a.postcomplement,
    a.streetname2,
    a.postnumber2,
    a.postcomplement2,
    a.region_id,
    a.province_id,
    a.descript,
    a.svg,
    a.rotation,
    a.link,
    a.verified,
    a.the_geom,
    a.undelete,
    a.label,
    a.label_x,
    a.label_y,
    a.label_rotation,
    a.label_quadrant,
    a.publish,
    a.inventory,
    a.uncertain,
    a.xyz_date,
    a.unconnected,
    a.num_value,
    a.tstamp,
    a.insert_user,
    a.lastupdate,
    a.lastupdate_user,
    a.workcat_id_plan,
    a.asset_id,
    a.parent_id,
    a.arc_id,
    a.expl_id2,
    a.is_operative,
    a.minsector_id,
    a.macrominsector_id,
    a.adate,
    a.adescript,
    a.placement_type,
    a.access_type,
        CASE
            WHEN s.sector_id > 0 AND a.is_operative = true AND a.epa_type::text <> 'UNDEFINED'::character varying(16)::text THEN a.epa_type
            ELSE NULL::character varying(16)
        END AS inp_type
   FROM ( SELECT n.node_id,
            n.code,
            n.top_elev,
            n.custom_top_elev,
            n.sys_top_elev,
            n.ymax,
            n.custom_ymax,
            n.sys_ymax,
            n.elev,
            n.custom_elev,
            n.sys_elev,
            n.node_type,
            n.sys_type,
            n.nodecat_id,
            n.matcat_id,
            n.epa_type,
            n.state,
            n.state_type,
            n.expl_id,
            n.macroexpl_id,
            n.sector_id,
            n.sector_type,
            n.macrosector_id,
            n.drainzone_id,
            n.drainzone_type,
            n.annotation,
            n.observ,
            n.comment,
            n.dma_id,
            n.macrodma_id,
            n.soilcat_id,
            n.function_type,
            n.category_type,
            n.fluid_type,
            n.location_type,
            n.workcat_id,
            n.workcat_id_end,
            n.buildercat_id,
            n.builtdate,
            n.enddate,
            n.ownercat_id,
            n.muni_id,
            n.postcode,
            n.district_id,
            n.streetname,
            n.postnumber,
            n.postcomplement,
            n.streetname2,
            n.postnumber2,
            n.postcomplement2,
            n.region_id,
            n.province_id,
            n.descript,
            n.svg,
            n.rotation,
            n.link,
            n.verified,
            n.the_geom,
            n.undelete,
            n.label,
            n.label_x,
            n.label_y,
            n.label_rotation,
            n.label_quadrant,
            n.publish,
            n.inventory,
            n.uncertain,
            n.xyz_date,
            n.unconnected,
            n.num_value,
            n.tstamp,
            n.insert_user,
            n.lastupdate,
            n.lastupdate_user,
            n.workcat_id_plan,
            n.asset_id,
            n.parent_id,
            n.arc_id,
            n.expl_id2,
            n.is_operative,
            n.minsector_id,
            n.macrominsector_id,
            n.adate,
            n.adescript,
            n.placement_type,
            n.access_type
           FROM ( SELECT selector_expl.expl_id
                   FROM selector_expl
                  WHERE selector_expl.cur_user = CURRENT_USER) s_1,
            vu_node n
             JOIN v_state_node USING (node_id)
          WHERE n.expl_id = s_1.expl_id OR n.expl_id2 = s_1.expl_id) a
     JOIN selector_sector s USING (sector_id)
     LEFT JOIN selector_municipality m USING (muni_id)
  WHERE s.cur_user = CURRENT_USER AND (m.cur_user = CURRENT_USER OR a.muni_id IS NULL);


CREATE OR REPLACE VIEW v_edit_inp_dwf
AS SELECT i.dwfscenario_id,
    node_id,
    i.value,
    i.pat1,
    i.pat2,
    i.pat3,
    i.pat4,
    node.the_geom
   FROM config_param_user c,
    inp_dwf i
     JOIN node USING (node_id)
  WHERE c.cur_user::name = CURRENT_USER AND c.parameter::text = 'inp_options_dwfscenario'::text AND c.value::integer = i.dwfscenario_id;


CREATE OR REPLACE VIEW v_edit_raingage
AS SELECT raingage.rg_id,
    raingage.form_type,
    raingage.intvl,
    raingage.scf,
    raingage.rgage_type,
    raingage.timser_id,
    raingage.fname,
    raingage.sta,
    raingage.units,
    raingage.the_geom,
    raingage.expl_id,
    raingage.muni_id
   FROM selector_expl, raingage
  WHERE raingage.expl_id = selector_expl.expl_id AND selector_expl.cur_user = "current_user"()::text;


CREATE OR REPLACE VIEW v_edit_inp_subcatchment AS
 SELECT a.* from (SELECT inp_subcatchment.hydrology_id,
    inp_subcatchment.subc_id,
    inp_subcatchment.outlet_id,
    inp_subcatchment.rg_id,
    inp_subcatchment.area,
    inp_subcatchment.imperv,
    inp_subcatchment.width,
    inp_subcatchment.slope,
    inp_subcatchment.clength,
    inp_subcatchment.snow_id,
    inp_subcatchment.nimp,
    inp_subcatchment.nperv,
    inp_subcatchment.simp,
    inp_subcatchment.sperv,
    inp_subcatchment.zero,
    inp_subcatchment.routeto,
    inp_subcatchment.rted,
    inp_subcatchment.maxrate,
    inp_subcatchment.minrate,
    inp_subcatchment.decay,
    inp_subcatchment.drytime,
    inp_subcatchment.maxinfil,
    inp_subcatchment.suction,
    inp_subcatchment.conduct,
    inp_subcatchment.initdef,
    inp_subcatchment.curveno,
    inp_subcatchment.conduct_2,
    inp_subcatchment.drytime_2,
    inp_subcatchment.sector_id,
    inp_subcatchment.the_geom,
    inp_subcatchment.descript,
    inp_subcatchment.minelev,
    muni_id
   FROM inp_subcatchment
   LEFT JOIN node ON node_id = outlet_id
   ) a, config_param_user, selector_sector, selector_municipality
   WHERE a.sector_id = selector_sector.sector_id AND selector_sector.cur_user = "current_user"()::text
   AND ((a.muni_id = selector_municipality.muni_id AND selector_municipality.cur_user = "current_user"()::text) or a.muni_id is null)
   AND a.hydrology_id = config_param_user.value::integer AND config_param_user.cur_user::text = "current_user"()::text
   AND config_param_user.parameter::text = 'inp_options_hydrology_scenario'::text;

-- 20/11/2024
CREATE OR REPLACE VIEW vu_gully
AS WITH streetaxis AS (
         SELECT v_ext_streetaxis.id,
            v_ext_streetaxis.descript
           FROM v_ext_streetaxis
        ), inp_netw_mode AS (
         WITH inp_netw_mode_aux AS (
                 SELECT count(*) AS t
                   FROM config_param_user
                  WHERE config_param_user.parameter::text = 'inp_options_networkmode'::text AND config_param_user.cur_user::text = CURRENT_USER
                )
         SELECT
                CASE
                    WHEN inp_netw_mode_aux.t > 0 THEN ( SELECT config_param_user.value
                       FROM config_param_user
                      WHERE config_param_user.parameter::text = 'inp_options_networkmode'::text AND config_param_user.cur_user::text = CURRENT_USER)
                    ELSE NULL::text
                END AS value
           FROM inp_netw_mode_aux
        )
 SELECT gully.gully_id,
    gully.code,
    gully.top_elev,
    gully.ymax,
    gully.sandbox,
    gully.matcat_id,
    gully.gully_type,
    cat_feature.system_id AS sys_type,
    gully.gratecat_id,
    cat_grate.matcat_id AS cat_grate_matcat,
    cat_grate.width AS grate_width,
    cat_grate.length AS grate_length,
    gully.units,
    gully.groove,
    gully.groove_height,
    gully.groove_length,
    gully.siphon,
    gully.connec_arccat_id,
    gully.connec_length,
    gully.top_elev - gully.ymax + gully.sandbox AS connec_y1,
    gully.connec_y2,
        CASE
            WHEN ((gully.top_elev - gully.ymax + gully.sandbox + gully.connec_y2) / 2::numeric) IS NOT NULL THEN ((gully.top_elev - gully.ymax + gully.sandbox + gully.connec_y2) / 2::numeric)::numeric(12,3)
            ELSE gully.connec_depth
        END AS connec_depth,
    gully.arc_id,
    gully.epa_type,
    gully.expl_id,
    exploitation.macroexpl_id,
    gully.sector_id,
    sector.macrosector_id,
    sector.sector_type,
    gully.drainzone_id,
    drainzone.drainzone_type,
    gully.state,
    gully.state_type,
    gully.annotation,
    gully.observ,
    gully.comment,
    gully.dma_id,
    dma.macrodma_id,
    dma.dma_type,
    gully.soilcat_id,
    gully.function_type,
    gully.category_type,
    gully.fluid_type,
    gully.location_type,
    gully.workcat_id,
    gully.workcat_id_end,
    gully.workcat_id_plan,
    gully.buildercat_id,
    gully.builtdate,
    gully.enddate,
    gully.ownercat_id,
    gully.muni_id,
    gully.postcode,
    gully.district_id,
    c.descript::character varying(100) AS streetname,
    gully.postnumber,
    gully.postcomplement,
    d.descript::character varying(100) AS streetname2,
    gully.postnumber2,
    gully.postcomplement2,
    mu.region_id,
    mu.province_id,
    gully.descript,
    cat_grate.svg,
    gully.rotation,
    concat(cat_feature.link_path, gully.link) AS link,
    gully.verified,
    gully.undelete,
    cat_grate.label,
    gully.label_x,
    gully.label_y,
    gully.label_rotation,
    gully.label_quadrant,
    gully.publish,
    gully.inventory,
    gully.uncertain,
    gully.num_value,
    gully.pjoint_id,
    gully.pjoint_type,
    gully.asset_id,
        CASE
            WHEN gully.connec_matcat_id IS NULL THEN cc.matcat_id::text
            ELSE gully.connec_matcat_id
        END AS connec_matcat_id,
    gully.gratecat2_id,
    gully.units_placement,
    gully.expl_id2,
    vst.is_operative,
    gully.minsector_id,
    gully.macrominsector_id,
    gully.adate,
    gully.adescript,
    gully.siphon_type,
    gully.odorflap,
    gully.placement_type,
    gully.access_type,
    date_trunc('second'::text, gully.tstamp) AS tstamp,
    gully.insert_user,
    date_trunc('second'::text, gully.lastupdate) AS lastupdate,
    gully.lastupdate_user,
    gully.the_geom,
        CASE
            WHEN gully.sector_id > 0 AND vst.is_operative = true AND gully.epa_type::text = 'GULLY'::character varying(16)::text AND cpu.value = '2'::text THEN gully.epa_type
            ELSE NULL::character varying(16)
        END AS inp_type
   FROM (SELECT inp_netw_mode.value FROM inp_netw_mode) cpu, gully
     LEFT JOIN cat_grate ON gully.gratecat_id::text = cat_grate.id::text
     LEFT JOIN dma ON gully.dma_id = dma.dma_id
     LEFT JOIN sector ON gully.sector_id = sector.sector_id
     LEFT JOIN exploitation ON gully.expl_id = exploitation.expl_id
     LEFT JOIN cat_feature ON gully.gully_type::text = cat_feature.id::text
     LEFT JOIN streetaxis c ON c.id::text = gully.streetaxis_id::text
     LEFT JOIN streetaxis d ON d.id::text = gully.streetaxis2_id::text
     LEFT JOIN cat_connec cc ON cc.id::text = gully.connec_arccat_id::text
     LEFT JOIN value_state_type vst ON vst.id = gully.state_type
     LEFT JOIN ext_municipality mu ON gully.muni_id = mu.muni_id
     LEFT JOIN drainzone USING (drainzone_id);
