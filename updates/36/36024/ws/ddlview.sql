/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

CREATE OR REPLACE VIEW ve_epa_connec
AS SELECT inp_connec.connec_id,
    inp_connec.demand,
    inp_connec.pattern_id,
    inp_connec.peak_factor,
    inp_connec.custom_roughness,
    inp_connec.custom_length,
    inp_connec.custom_dint,
    inp_connec.status,
    inp_connec.minorloss,
    inp_connec.emitter_coeff,
    inp_connec.init_quality,
    inp_connec.source_type,
    inp_connec.source_quality,
    inp_connec.source_pattern_id,
    v_rpt_node.result_id,
    v_rpt_node.demand_max AS demandmax,
    v_rpt_node.demand_min AS demandmin,
    v_rpt_node.demand_avg AS demandavg,
    v_rpt_node.head_max AS headmax,
    v_rpt_node.head_min AS headmin,
    v_rpt_node.head_avg AS headavg,
    v_rpt_node.press_max AS pressmax,
    v_rpt_node.press_min AS pressmin,
    v_rpt_node.press_avg AS pressavg,
    v_rpt_node.quality_max AS qualmax,
    v_rpt_node.quality_min AS qualmin,
    v_rpt_node.quality_avg AS qualavg
   FROM inp_connec
   	 left join v_edit_link on v_edit_link.feature_id = inp_connec.connec_id
     LEFT JOIN v_rpt_node ON inp_connec.connec_id::text = v_rpt_node.node_id::text or v_rpt_node.node_id = concat('VN', v_edit_link.link_id);
