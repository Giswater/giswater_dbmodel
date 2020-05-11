/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE OR REPLACE VIEW v_ui_om_visit_lot AS 
 SELECT om_visit_lot.id,
    om_visit_lot.serie,
    om_visit_lot.class_id,
    ext_workorder.wotype_name,
    cat_team.idval AS team,
    ext_workorder.observations,
    om_typevalue.idval AS state_name,
    om_visit_lot.real_startdate,
    om_visit_lot.real_enddate,
    om_visit_lot.startdate,
    om_visit_lot.enddate,
    om_visit_lot.descript,
    om_visit_lot.adreca,
    om_visit_class.idval AS visitclass_id,
    om_visit_lot.exercice,
    ext_workorder.wotype_id,
    om_visit_lot.feature_type
   FROM om_visit_lot
     LEFT JOIN ext_workorder ON ext_workorder.serie::text = om_visit_lot.serie::text
     LEFT JOIN om_visit_class ON om_visit_class.id = om_visit_lot.visitclass_id
     LEFT JOIN cat_team ON cat_team.id = om_visit_lot.team_id
     LEFT JOIN om_typevalue ON om_typevalue.id = om_visit_lot.status AND om_typevalue.typevalue = 'lot_cat_status'::text;

	 
	 
 CREATE OR REPLACE VIEW v_res_lot_x_user AS 
 SELECT om_visit_lot_x_user.id,
    om_visit_lot_x_user.user_id,
    om_visit_lot_x_user.team_id,
    om_visit_lot_x_user.lot_id,
    om_visit_lot_x_user.starttime,
    om_visit_lot_x_user.endtime,
    (om_visit_lot_x_user.endtime - om_visit_lot_x_user.starttime)::text AS duration,
    om_visit_lot.the_geom
   FROM selector_date, om_visit_lot_x_user
    JOIN om_visit_lot ON om_visit_lot.id=om_visit_lot_x_user.lot_id
  WHERE "overlaps"(om_visit_lot_x_user.starttime, om_visit_lot_x_user.starttime, selector_date.from_date, selector_date.to_date) AND selector_date.cur_user = "current_user"()::text;
  
  
CREATE OR REPLACE VIEW v_om_team_x_vehicle AS 
 SELECT om_team_x_vehicle.id,
    cat_team.idval AS team,
    ext_cat_vehicle.idval AS vehicle
   FROM om_team_x_vehicle
     JOIN cat_team ON om_team_x_vehicle.team_id = cat_team.id
     JOIN ext_cat_vehicle ON om_team_x_vehicle.vehicle_id::text = ext_cat_vehicle.id::text;
	 
	 
CREATE OR REPLACE VIEW ve_lot_x_arc AS 
 SELECT row_number() OVER (ORDER BY arc.arc_id) AS rid,
    arc.arc_id,
    lower(arc.feature_type::text) AS feature_type,
    arc.code,
    om_visit_lot.visitclass_id,
    om_visit_lot_x_arc.lot_id,
    om_visit_lot_x_arc.status,
    om_typevalue.idval AS status_name,
    arc.the_geom
   FROM selector_lot,
    om_visit_lot
     JOIN om_visit_lot_x_arc ON om_visit_lot_x_arc.lot_id = om_visit_lot.id
     JOIN arc ON arc.arc_id::text = om_visit_lot_x_arc.arc_id::text
     LEFT JOIN om_typevalue ON om_typevalue.id = om_visit_lot_x_arc.status AND om_typevalue.typevalue = 'lot_x_feature_status'::text
  WHERE selector_lot.lot_id = om_visit_lot.id AND selector_lot.cur_user = "current_user"()::text;
  
  
  
 CREATE OR REPLACE VIEW ve_lot_x_connec AS 
 SELECT row_number() OVER (ORDER BY connec.connec_id) AS rid,
    connec.connec_id,
    lower(connec.feature_type::text) AS feature_type,
    connec.code,
    om_visit_lot.visitclass_id,
    om_visit_lot_x_connec.lot_id,
    om_visit_lot_x_connec.status,
    om_typevalue.idval AS status_name,
    connec.the_geom
   FROM selector_lot,
    om_visit_lot
     JOIN om_visit_lot_x_connec ON om_visit_lot_x_connec.lot_id = om_visit_lot.id
     JOIN connec ON connec.connec_id::text = om_visit_lot_x_connec.connec_id::text
     LEFT JOIN om_typevalue ON om_typevalue.id = om_visit_lot_x_connec.status AND om_typevalue.typevalue = 'lot_x_feature_status'::text
  WHERE selector_lot.lot_id = om_visit_lot.id AND selector_lot.cur_user = "current_user"()::text;
	 

 CREATE OR REPLACE VIEW ve_lot_x_node AS 
 SELECT row_number() OVER (ORDER BY node.node_id) AS rid,
    node.node_id,
    lower(node.feature_type::text) AS feature_type,
    node.code,
    om_visit_lot.visitclass_id,
    om_visit_lot_x_node.lot_id,
    om_visit_lot_x_node.status,
    om_typevalue.idval AS status_name,
    node.the_geom
   FROM selector_lot,
    om_visit_lot
     JOIN om_visit_lot_x_node ON om_visit_lot_x_node.lot_id = om_visit_lot.id
     JOIN node ON node.node_id::text = om_visit_lot_x_node.node_id::text
     LEFT JOIN om_typevalue ON om_typevalue.id = om_visit_lot_x_node.status AND om_typevalue.typevalue = 'lot_x_feature_status'::text
  WHERE selector_lot.lot_id = om_visit_lot.id AND selector_lot.cur_user = "current_user"()::text;
  
  
CREATE OR REPLACE VIEW v_ui_om_vehicle_x_parameters AS 
 SELECT row_number() OVER (ORDER BY om_vehicle_x_parameters.tstamp DESC) AS rid,
	ext_cat_vehicle.idval AS vehicle,
	om_vehicle_x_parameters.lot_id,
	cat_team.idval AS team,
	om_vehicle_x_parameters.image,
	om_vehicle_x_parameters.load,
	om_vehicle_x_parameters.cur_user AS "user",
	om_vehicle_x_parameters.tstamp AS date
   FROM om_vehicle_x_parameters
	 JOIN ext_cat_vehicle ON ext_cat_vehicle.id::text = om_vehicle_x_parameters.vehicle_id::text
	 JOIN cat_team ON cat_team.id = om_vehicle_x_parameters.team_id;
	 

CREATE OR REPLACE VIEW v_om_user_x_team AS 
 SELECT om_user_x_team.id,
    om_user_x_team.user_id,
    cat_team.idval AS team,
    cat_users.name AS user_name
   FROM om_user_x_team
     JOIN cat_team ON om_user_x_team.team_id = cat_team.id
     JOIN cat_users ON om_user_x_team.user_id::text = cat_users.id::text;
	 

CREATE OR REPLACE VIEW v_om_team_x_visitclass AS 
 SELECT om_team_x_visitclass.id,
    cat_team.idval AS team,
    om_visit_class.idval AS visitclass
   FROM om_team_x_visitclass
     JOIN cat_team ON om_team_x_visitclass.team_id = cat_team.id
     JOIN om_visit_class ON om_team_x_visitclass.visitclass_id = om_visit_class.id;
	 

CREATE OR REPLACE VIEW v_edit_cat_team AS 
 SELECT cat_team.id,
    cat_team.idval AS "Equip",
    cat_team.descript AS "Descripcio",
    cat_team.active AS "Actiu"
   FROM cat_team;
   
CREATE VIEW v_ext_cat_vehicle AS
SELECT
  id::integer AS id,
  idval AS "Vehicle",
  descript AS "Descripcio",
  model AS "Model",
  number_plate AS "Matricula"
FROM ext_cat_vehicle;

CREATE OR REPLACE VIEW v_ui_om_visit_x_node AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_node.node_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document,
    om_visit.class_id
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_node ON om_visit_x_node.visit_id = om_visit.id
     LEFT JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_node.node_id;
  
CREATE OR REPLACE VIEW v_ui_om_visit_x_connec AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_connec.connec_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document,
    om_visit.class_id
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_connec ON om_visit_x_connec.visit_id = om_visit.id
     JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     LEFT JOIN connec ON connec.connec_id::text = om_visit_x_connec.connec_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_connec.connec_id;
  
CREATE OR REPLACE VIEW v_ui_om_visit_x_arc AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_arc.arc_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document,
    om_visit.class_id
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_arc ON om_visit_x_arc.visit_id = om_visit.id
     LEFT JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     JOIN arc ON arc.arc_id::text = om_visit_x_arc.arc_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_arc.arc_id;
  
CREATE OR REPLACE VIEW v_om_lot_x_user AS 
 SELECT om_visit_lot_x_user.id,
    om_visit_lot_x_user.user_id AS "Usuari",
    cat_team.idval AS "Equip",
    om_visit_lot_x_user.lot_id AS "Lot",
    ext_workorder.wotype_name AS "Tipus actuacio",
    om_visit_lot.serie AS "Serie",
    ext_workorder.observations AS "Descripcio OT",
    om_visit_lot.descript AS "Descripcio",
    om_visit_lot_x_user.starttime AS "Data inici",
    om_visit_lot_x_user.endtime AS "Data fi",
    om_visit_lot_x_user.the_geom
   FROM om_visit_lot_x_user
     JOIN cat_team ON om_visit_lot_x_user.team_id = cat_team.id
     LEFT JOIN om_visit_lot ON om_visit_lot.id = om_visit_lot_x_user.lot_id
     LEFT JOIN ext_workorder ON ext_workorder.serie::text = om_visit_lot.serie::text;
	 
	 
CREATE OR REPLACE VIEW v_visit_lot_user AS 
 SELECT om_visit_lot_x_user.id,
    om_visit_lot_x_user.user_id,
    om_visit_lot_x_user.team_id,
    om_visit_lot_x_user.lot_id,
    om_visit_lot_x_user.starttime,
    om_visit_lot_x_user.endtime,
    now()::date AS date
   FROM om_visit_lot_x_user
  WHERE om_visit_lot_x_user.user_id::name = "current_user"()
  ORDER BY om_visit_lot_x_user.id DESC
 LIMIT 1;
 
 
CREATE OR REPLACE VIEW v_ui_om_visitman_x_arc AS 
 SELECT DISTINCT ON (v_ui_om_visit_x_arc.visit_id) v_ui_om_visit_x_arc.visit_id,
    v_ui_om_visit_x_arc.code,
    om_visit_cat.name AS visitcat_name,
    v_ui_om_visit_x_arc.arc_id,
    date_trunc('second'::text, v_ui_om_visit_x_arc.visit_start) AS visit_start,
    date_trunc('second'::text, v_ui_om_visit_x_arc.visit_end) AS visit_end,
    v_ui_om_visit_x_arc.user_name,
    v_ui_om_visit_x_arc.is_done,
    v_ui_om_visit_x_arc.feature_type,
    v_ui_om_visit_x_arc.form_type
   FROM v_ui_om_visit_x_arc
     LEFT JOIN om_visit_cat ON om_visit_cat.id = v_ui_om_visit_x_arc.visitcat_id;
	 
	 
CREATE OR REPLACE VIEW v_ui_om_visitman_x_connec AS 
 SELECT DISTINCT ON (v_ui_om_visit_x_connec.visit_id) v_ui_om_visit_x_connec.visit_id,
    v_ui_om_visit_x_connec.code,
    om_visit_cat.name AS visitcat_name,
    v_ui_om_visit_x_connec.connec_id,
    date_trunc('second'::text, v_ui_om_visit_x_connec.visit_start) AS visit_start,
    date_trunc('second'::text, v_ui_om_visit_x_connec.visit_end) AS visit_end,
    v_ui_om_visit_x_connec.user_name,
    v_ui_om_visit_x_connec.is_done,
    v_ui_om_visit_x_connec.feature_type,
    v_ui_om_visit_x_connec.form_type
   FROM v_ui_om_visit_x_connec
     LEFT JOIN om_visit_cat ON om_visit_cat.id = v_ui_om_visit_x_connec.visitcat_id;
	 
	 
CREATE OR REPLACE VIEW v_ui_om_visitman_x_node AS 
 SELECT DISTINCT ON (v_ui_om_visit_x_node.visit_id) v_ui_om_visit_x_node.visit_id,
    v_ui_om_visit_x_node.code,
    om_visit_cat.name AS visitcat_name,
    v_ui_om_visit_x_node.node_id,
    date_trunc('second'::text, v_ui_om_visit_x_node.visit_start) AS visit_start,
    date_trunc('second'::text, v_ui_om_visit_x_node.visit_end) AS visit_end,
    v_ui_om_visit_x_node.user_name,
    v_ui_om_visit_x_node.is_done,
    v_ui_om_visit_x_node.feature_type,
    v_ui_om_visit_x_node.form_type
   FROM v_ui_om_visit_x_node
     LEFT JOIN om_visit_cat ON om_visit_cat.id = v_ui_om_visit_x_node.visitcat_id;
