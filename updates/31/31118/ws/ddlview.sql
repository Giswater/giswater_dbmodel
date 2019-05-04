/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;



DROP VIEW v_rtc_hydrometer_x_node_period;
CREATE OR REPLACE VIEW v_rtc_hydrometer_x_node_period AS 
 SELECT a.hydrometer_id,
    a.node_1 AS node_id,
    a.arc_id,
    b.dma_id,
    b.period_id,
    b.lps_avg * 0.5::double precision AS lps_avg_real,
    c.effc::numeric(5,4) AS losses,
    b.lps_avg * 0.5::double precision / c.effc AS lps_avg,
    c.minc AS cmin,
    b.lps_avg * 0.5::double precision / c.effc * c.minc AS lps_min,
    c.maxc AS cmax,
    b.lps_avg * 0.5::double precision / c.effc * c.maxc AS lps_max,
    pattern_id
   FROM v_rtc_hydrometer_x_arc a
     JOIN v_rtc_hydrometer_period b ON b.hydrometer_id::bigint = a.hydrometer_id::bigint
     JOIN ext_rtc_scada_dma_period c ON c.cat_period_id::text = b.period_id::text AND c.dma_id::text = b.dma_id::text
UNION
 SELECT a.hydrometer_id,
    a.node_2 AS node_id,
    a.arc_id,
    b.dma_id,
    b.period_id,
    b.lps_avg * 0.5::double precision AS lps_avg_real,
    c.effc::numeric(5,4) AS losses,
    b.lps_avg * 0.5::double precision / c.effc AS lps_avg,
    c.minc AS cmin,
    b.lps_avg * 0.5::double precision / c.effc * c.minc AS lps_min,
    c.maxc AS cmax,
    b.lps_avg * 0.5::double precision / c.effc * c.maxc AS lps_max,
    pattern_id
   FROM v_rtc_hydrometer_x_arc a
     JOIN v_rtc_hydrometer_period b ON b.hydrometer_id::bigint = a.hydrometer_id::bigint
     JOIN ext_rtc_scada_dma_period c ON c.cat_period_id::text = b.period_id::text AND c.dma_id::text = b.dma_id::text;
	 

	 
DROP VIEW v_inp_junction;
CREATE OR REPLACE VIEW v_inp_junction AS 
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elevation,
    rpt_inp_node.elev,
    rpt_inp_node.demand,
    rpt_inp_node.pattern_id,
    st_x(rpt_inp_node.the_geom)::numeric(16,3) AS xcoord,
    st_y(rpt_inp_node.the_geom)::numeric(16,3) AS ycoord
   FROM inp_selector_result,
    rpt_inp_node
     LEFT JOIN inp_junction ON inp_junction.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.epa_type::text = 'JUNCTION'::text AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text AND inp_selector_result.cur_user = "current_user"()::text
  ORDER BY rpt_inp_node.node_id;
