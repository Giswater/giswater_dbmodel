/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_node", "column":"inflow", "dataType":"numeric(12,3)", "isUtils":"False"}}$$);


CREATE OR REPLACE VIEW vi_timeseries
AS SELECT DISTINCT t.timser_id,
    t.other1::date,
    t.other2::time,
    t.other3
   FROM selector_expl s,
    ( SELECT a.timser_id,
            a.other1,
            a.other2,
            a.other3,
            a.expl_id
           FROM ( SELECT inp_timeseries_value.id,
                    inp_timeseries_value.timser_id,
                    inp_timeseries_value.date AS other1,
                    inp_timeseries_value.hour AS other2,
                    inp_timeseries_value.value AS other3,
                    inp_timeseries.expl_id
                   FROM inp_timeseries_value
                     JOIN inp_timeseries ON inp_timeseries_value.timser_id::text = inp_timeseries.id::text
                  WHERE inp_timeseries.times_type::text = 'ABSOLUTE'::text
                UNION
                 SELECT inp_timeseries_value.id,
                    inp_timeseries_value.timser_id,
                    concat('FILE', ' ', inp_timeseries.fname) AS other1,
                    NULL::character varying AS other2,
                    NULL::numeric AS other3,
                    inp_timeseries.expl_id
                   FROM inp_timeseries_value
                     JOIN inp_timeseries ON inp_timeseries_value.timser_id::text = inp_timeseries.id::text
                  WHERE inp_timeseries.times_type::text = 'FILE'::text
                UNION
                 SELECT inp_timeseries_value.id,
                    inp_timeseries_value.timser_id,
                    NULL::text AS other1,
                    inp_timeseries_value."time" AS other2,
                    inp_timeseries_value.value::numeric AS other3,
                    inp_timeseries.expl_id
                   FROM inp_timeseries_value
                     JOIN inp_timeseries ON inp_timeseries_value.timser_id::text = inp_timeseries.id::text
                  WHERE inp_timeseries.times_type::text = 'RELATIVE'::text) a
          ORDER BY a.id) t
  WHERE t.expl_id = s.expl_id AND s.cur_user = "current_user"()::text OR t.expl_id IS NULL
  ORDER BY t.timser_id, t.other1::date, t.other2::time, t.other3;