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
    b.m3_total_period*0.5 AS m3_hydrometer_period,
    b.lps_avg * 0.5::double precision AS lps_avg_real,
    c.effc::numeric(5,4) AS losses,
    b.lps_avg * 0.5::double precision / c.effc AS lps_avg,
    c.minc AS cmin,
    b.lps_avg * 0.5::double precision / c.effc * c.minc AS lps_min,
    c.maxc AS cmax,
    b.lps_avg * 0.5::double precision / c.effc * c.maxc AS lps_max,
    c.pattern_id
   FROM v_rtc_hydrometer_x_arc a
     JOIN v_rtc_hydrometer_period b ON b.hydrometer_id::bigint = a.hydrometer_id::bigint
     JOIN ext_rtc_scada_dma_period c ON c.cat_period_id::text = b.period_id::text AND c.dma_id::text = b.dma_id::text
UNION
 SELECT a.hydrometer_id,
    a.node_2 AS node_id,
    a.arc_id,
    b.dma_id,
    b.period_id,
    b.m3_total_period*0.5,
    b.lps_avg * 0.5::double precision AS lps_avg_real,
    c.effc::numeric(5,4) AS losses,
    b.lps_avg * 0.5::double precision / c.effc AS lps_avg,
    c.minc AS cmin,
    b.lps_avg * 0.5::double precision / c.effc * c.minc AS lps_min,
    c.maxc AS cmax,
    b.lps_avg * 0.5::double precision / c.effc * c.maxc AS lps_max,
    c.pattern_id
   FROM v_rtc_hydrometer_x_arc a
     JOIN v_rtc_hydrometer_period b ON b.hydrometer_id::bigint = a.hydrometer_id::bigint
     JOIN ext_rtc_scada_dma_period c ON c.cat_period_id::text = b.period_id::text AND c.dma_id::text = b.dma_id::text;


DROP VIEW v_inp_pattern;
CREATE OR REPLACE VIEW v_inp_pattern AS 
 SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
   JOIN rpt_inp_node b ON inp_pattern_value.pattern_id=b.pattern_id
UNION
 SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
JOIN inp_reservoir b ON inp_pattern_value.pattern_id=b.pattern_id
UNION
   SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
   JOIN v_inp_demand b ON inp_pattern_value.pattern_id=b.pattern_id
  ORDER BY 1;