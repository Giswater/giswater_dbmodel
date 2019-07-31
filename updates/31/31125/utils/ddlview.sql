/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE OR REPLACE VIEW v_plan_current_psector AS 
 SELECT plan_psector.psector_id,
    plan_psector.name,
    plan_psector.psector_type,
    plan_psector.descript,
    plan_psector.priority,
    a.suma::numeric(14,2) AS total_arc,
    b.suma::numeric(14,2) AS total_node,
    c.suma::numeric(14,2) AS total_other,
    plan_psector.text1,
    plan_psector.text2,
    plan_psector.observ,
    plan_psector.rotation,
    plan_psector.scale,
    plan_psector.sector_id,
    plan_psector.active,
    (
        CASE
            WHEN a.suma IS NULL THEN 0::numeric
            ELSE a.suma
        END +
        CASE
            WHEN b.suma IS NULL THEN 0::numeric
            ELSE b.suma
        END +
        CASE
            WHEN c.suma IS NULL THEN 0::numeric
            ELSE c.suma
        END)::numeric(14,2) AS pem,
    plan_psector.gexpenses,
    ((100::numeric + plan_psector.gexpenses) / 100::numeric)::numeric(14,2) * (
        CASE
            WHEN a.suma IS NULL THEN 0::numeric
            ELSE a.suma
        END +
        CASE
            WHEN b.suma IS NULL THEN 0::numeric
            ELSE b.suma
        END +
        CASE
            WHEN c.suma IS NULL THEN 0::numeric
            ELSE c.suma
        END)::numeric(14,2) AS pec,
    plan_psector.vat,
    ((100::numeric + plan_psector.gexpenses) / 100::numeric * ((100::numeric + plan_psector.vat) / 100::numeric))::numeric(14,2) * (
        CASE
            WHEN a.suma IS NULL THEN 0::numeric
            ELSE a.suma
        END +
        CASE
            WHEN b.suma IS NULL THEN 0::numeric
            ELSE b.suma
        END +
        CASE
            WHEN c.suma IS NULL THEN 0::numeric
            ELSE c.suma
        END)::numeric(14,2) AS pec_vat,
    plan_psector.other,
    ((100::numeric + plan_psector.gexpenses) / 100::numeric * ((100::numeric + plan_psector.vat) / 100::numeric) * ((100::numeric + plan_psector.other) / 100::numeric))::numeric(14,2) * (
        CASE
            WHEN a.suma IS NULL THEN 0::numeric
            ELSE a.suma
        END +
        CASE
            WHEN b.suma IS NULL THEN 0::numeric
            ELSE b.suma
        END +
        CASE
            WHEN c.suma IS NULL THEN 0::numeric
            ELSE c.suma
        END)::numeric(14,2) AS pca,
    plan_psector.the_geom,
    d.suma AS affec_length,
    e.suma AS plan_length,
    f.suma AS current_length
   FROM plan_psector
     JOIN plan_psector_selector ON plan_psector.psector_id = plan_psector_selector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_arc.total_budget) AS suma,
            v_plan_psector_x_arc.psector_id
           FROM v_plan_psector_x_arc
          GROUP BY v_plan_psector_x_arc.psector_id) a ON a.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_node.total_budget) AS suma,
            v_plan_psector_x_node.psector_id
           FROM v_plan_psector_x_node
          GROUP BY v_plan_psector_x_node.psector_id) b ON b.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_other.total_budget) AS suma,
            v_plan_psector_x_other.psector_id
           FROM v_plan_psector_x_other
          GROUP BY v_plan_psector_x_other.psector_id) c ON c.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(st_length2d(arc.the_geom)::numeric(12,2)) AS suma,
            pa.psector_id
           FROM arc
             JOIN plan_psector_x_arc pa USING (arc_id)
          WHERE pa.state = 0 AND pa.doable = false AND (pa.addparam->>'arcDivide' != 'parent' OR pa.addparam->>'arcDivide' IS NULL) OR arc.state_type = ((( SELECT config_param_system.value
                   FROM config_param_system
                  WHERE config_param_system.parameter::text = 'plan_statetype_reconstruct'::text))::smallint)
          GROUP BY pa.psector_id) d ON d.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(st_length2d(arc.the_geom)::numeric(12,2)) AS suma,
            pa.psector_id
           FROM arc
             JOIN plan_psector_x_arc pa USING (arc_id)
          WHERE pa.state = 1 AND pa.doable = true
          GROUP BY pa.psector_id) e ON e.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(st_length2d(arc.the_geom)::numeric(12,2)) AS suma,
            pa.psector_id
           FROM arc
             JOIN plan_psector_x_arc pa USING (arc_id)
          WHERE pa.state = 1 AND pa.doable = false
          GROUP BY pa.psector_id) f ON f.psector_id = plan_psector.psector_id
  WHERE plan_psector_selector.cur_user = "current_user"()::text;
  
  
CREATE OR REPLACE VIEW v_plan_psector_arc_affect AS 
SELECT pa.arc_id, pa.psector_id, a.the_geom, pa.state, pa.doable, pa.descript, vst.name
FROM selector_psector, plan_psector_x_arc pa
JOIN arc a USING (arc_id)
JOin value_state_type vst ON vst.id=a.state_type 
WHERE ((pa.state=0 AND pa.doable=FALSE 
AND (pa.addparam->>'arcDivide' != 'parent' OR pa.addparam->>'arcDivide' IS NULL))
OR (a.state_type = ( SELECT config_param_system.value FROM config_param_system WHERE config_param_system.parameter = 'plan_statetype_reconstruct')::smallint))
AND  pa.psector_id = selector_psector.psector_id AND selector_psector.cur_user = "current_user"()::text;
COMMENT ON VIEW v_plan_psector_arc_affect is 'Return the arcs which will be removed by a psector. Arcs divided by a node to generate ficticius will not count. 
Arcs with state_type=RECONSTRUCT will be considered because geometry do not change but old arc are removed. Be careful with plan_statetype_reconstruct
variable, it must be configured correctly. Filtered by psector selector';


CREATE OR REPLACE VIEW v_plan_psector_arc_current AS 
SELECT pa.arc_id, pa.psector_id, a.the_geom, pa.state, pa.doable, pa.descript, vst.name 
FROM selector_psector, plan_psector_x_arc pa
JOIN arc a USING (arc_id)
JOin value_state_type vst ON vst.id=a.state_type 
WHERE pa.state=1 AND pa.doable=FALSE
AND  pa.psector_id = selector_psector.psector_id AND selector_psector.cur_user = "current_user"()::text;
COMMENT ON VIEW v_plan_psector_arc_current is 'Return ficticius arcs created by arc division in a psector. They will be considered current arcs because its geometry already exists in real network.
 Ficticius arcs means: state in the psector=1 and doable=FALSE. Filtered by psector selector';

CREATE OR REPLACE VIEW v_plan_psector_arc_planif AS 
SELECT pa.arc_id, pa.psector_id, a.the_geom, pa.state, pa.doable, pa.descript, vst.name
FROM selector_psector, plan_psector_x_arc pa
JOIN arc a USING (arc_id)
JOIN value_state_type vst ON a.state_type = vst.id
WHERE pa.state=1 AND pa.doable=TRUE
AND  pa.psector_id = selector_psector.psector_id AND selector_psector.cur_user = "current_user"()::text;
COMMENT ON VIEW v_plan_psector_arc_planif is 'Return the arcs which will be new in a psector. New arcs means: state in the psector=1 and doable=TRUE. Filtered by psector selector';