/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

INSERT INTO om_visit_cat VALUES (1, 'prueba num.1','2017-1-1', '2017-3-31', NULL, FALSE);
INSERT INTO om_visit_cat VALUES (2, 'prueba num.2','2017-4-1', '2017-7-31', NULL, FALSE);
INSERT INTO om_visit_cat VALUES (3, 'prueba num.3','2017-8-1', '2017-9-30', NULL, TRUE);
INSERT INTO om_visit_cat VALUES (4, 'prueba num.4','2017-10-1', '2017-12-31', NULL, TRUE);


INSERT INTO om_visit_parameter VALUES ('Arc rehabit type 1', NULL, 'REHABIT', 'ARC', 'TEXT', NULL, 'Rehabilitation arc parameter 1', 'event_ud_arc_rehabit', 'a');
INSERT INTO om_visit_parameter VALUES ('Arc rehabit type 2', NULL, 'REHABIT', 'ARC', 'TEXT', NULL, 'Rehabilitation arc parameter 2', 'event_ud_arc_rehabit', 'b');
INSERT INTO om_visit_parameter VALUES ('Arc inspection type 1', NULL, 'INSPECTION', 'ARC', 'TEXT', NULL, 'Inspection arc parameter 1', 'event_ud_arc_standard', 'c');
INSERT INTO om_visit_parameter VALUES ('Arc inspection type 2', NULL, 'INSPECTION', 'ARC', 'TEXT', NULL, 'Inspection arc parameter 2', 'event_ud_arc_standard', 'f');
INSERT INTO om_visit_parameter VALUES ('Connec inspection type 1', NULL, 'INSPECTION', 'CONNEC', 'TEXT', NULL, 'Inspection connec parameter 1', 'event_standard', 'd', true);
INSERT INTO om_visit_parameter VALUES ('Connec inspection type 2', NULL, 'INSPECTION', 'CONNEC', 'TEXT', NULL, 'Inspection connec parameter 2', 'event_standard', 'e', true);
INSERT INTO om_visit_parameter VALUES ('Node inspection type 1', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 1', 'event_standard', 'f', true);
INSERT INTO om_visit_parameter VALUES ('Node inspection type 2', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 2', 'event_standard', 'g', true);
INSERT INTO om_visit_parameter VALUES ('Node inspection type 3', NULL, 'INSPECTION', 'NODE', 'TEXT', NULL, 'Inspection node parameter 3', 'event_standard', 'i', true);
INSERT INTO om_visit_parameter VALUES ('Gully inspection type 1', NULL, 'INSPECTION', 'GULLY', 'TEXT', NULL, 'Inspection gully parameter 1', 'event_standard', 'd', true);
INSERT INTO om_visit_parameter VALUES ('Gully inspection type 2', NULL, 'INSPECTION', 'GULLY', 'TEXT', NULL, 'Inspection gully parameter 2', 'event_standard', 'e', true);


INSERT INTO om_typevalue VALUES ('visit_cat_status', 4, 'Finished', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cat_status', 5, 'Validated', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 1, 'PLANNING', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 2, 'PLANNED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 3, 'ASSIGNED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 4, 'ON GOING', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 5, 'EXECUTED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 6, 'REVISED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_cat_status', 7, 'CANCELED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_clean', 0, 'NO', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_clean', 1, 'YES', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_res_level', 0, 'CLEAN', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_res_level', 1, 'HEADED', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_res_level', 2, 'LESS THAN 50%', NULL, NULL);
INSERT INTO om_typevalue VALUES ('gully_res_level', 3, 'MORE THAN 50%', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cat_status', 3, 'Canceled', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cat_status', 1, 'Planned', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cat_status', 2, 'Started', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_x_feature_status', 1, 'Not visited', NULL, NULL);
INSERT INTO om_typevalue VALUES ('lot_x_feature_status', 0, 'Visited', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incidence', 0, 'Bad smell', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incidence', 1, 'Water on the floor', NULL, NULL);


INSERT INTO om_visit_class VALUES (7, 'Gully clean', NULL, true, false, true, 'GULLY', 'role_om', NULL, '{"offlineDefault":"true"}');
INSERT INTO om_visit_class VALUES (5, 'General incidence', NULL, true, false, true, NULL, 'role_om', 2, NULL);


INSERT INTO om_visit_parameter_type VALUES ('INCIDENCE', NULL, NULL);
INSERT INTO om_visit_parameter_type VALUES ('CLEANING', NULL, NULL);


INSERT INTO om_visit_parameter VALUES ('gully_clean', NULL, 'CLEANING', 'GULLY', NULL, NULL, 'Clean gullys', 'event_standard', NULL, NULL);
INSERT INTO om_visit_parameter VALUES ('gully_res_level', NULL, 'CLEANING', 'GULLY', NULL, NULL, 'Gully waste level', 'event_standard', NULL, NULL);
INSERT INTO om_visit_parameter VALUES ('inc_observ', NULL, 'INCIDENCE', 'UNDEFINED', 'text', NULL, 'Generic observations for incidence', 'event_standard', NULL, NULL);
INSERT INTO om_visit_parameter VALUES ('incidence', NULL, 'INCIDENCE', 'UNDEFINED', 'text', NULL, 'Incidence type', 'event_standard', NULL, NULL);



INSERT INTO om_visit_class_x_parameter VALUES (3, 7, 'gully_clean');
INSERT INTO om_visit_class_x_parameter VALUES (5, 7, 'gully_res_level');
INSERT INTO om_visit_class_x_parameter VALUES (26, 5, 'inc_observ');
INSERT INTO om_visit_class_x_parameter VALUES (27, 5, 'incidence');

--------------------
-- VISIT CLASS VIEWS WITH TRIGGERS
--------------------

CREATE OR REPLACE VIEW ve_visit_gully_clean AS 
 SELECT om_visit_x_gully.visit_id,
    om_visit_x_gully.gully_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    "left"(date_trunc('second'::text, om_visit.startdate)::text, 19)::timestamp without time zone AS startdate,
    "left"(date_trunc('second'::text, om_visit.enddate)::text, 19)::timestamp without time zone AS enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit_class.idval AS class_name,
    om_visit.lot_id,
    om_visit.status,
    s.idval AS status_name,
    a.param_1 AS gully_cleaned,
    p.idval AS gully_cleaned_v,
    a.param_2 AS gully_res_level,
    t.idval AS gully_res_level_v
   FROM om_visit
     JOIN om_visit_class ON om_visit_class.id = om_visit.class_id
     JOIN om_visit_x_gully ON om_visit.id = om_visit_x_gully.visit_id
     LEFT JOIN om_typevalue s ON om_visit.status = s.id AND s.typevalue = 'visit_cat_status'::text
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value 
			FROM om_visit JOIN om_visit_event ON om_visit.id= om_visit_event.visit_id 
			JOIN om_visit_class on om_visit_class.id=om_visit.class_id
			JOIN om_visit_class_x_parameter on om_visit_class_x_parameter.parameter_id=om_visit_event.parameter_id 
			where om_visit_class.ismultievent = TRUE ORDER  BY 1,2'::text, ' VALUES (''gully_clean''),(''gully_res_level'')'::text) ct(visit_id integer, param_1 text, param_2 text)) a ON a.visit_id = om_visit.id
     LEFT JOIN om_typevalue t ON t.id::text = a.param_2 AND t.typevalue = 'gully_res_level'::text
     LEFT JOIN om_typevalue p ON p.id::text = a.param_1 AND p.typevalue = 'gully_clean'::text
  WHERE om_visit_class.ismultievent = true AND om_visit_class.id = 7;


CREATE TRIGGER gw_trg_om_visit_multievent
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON ve_visit_gully_clean
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_om_visit_multievent(7);

  
  
  
  CREATE OR REPLACE VIEW ve_visit_incidence AS 
 SELECT om_visit_x_gully.visit_id,
    om_visit_x_gully.gully_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    "left"(date_trunc('second'::text, om_visit.startdate)::text, 19)::timestamp without time zone AS startdate,
    "left"(date_trunc('second'::text, om_visit.enddate)::text, 19)::timestamp without time zone AS enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit_class.idval AS class_name,
    om_visit.lot_id,
    om_visit.status,
    s.idval AS status_name,
    a.param_1 AS incidence,
    p.idval AS incidence_v,
    a.param_2 AS inc_observ
   FROM om_visit
     JOIN om_visit_class ON om_visit_class.id = om_visit.class_id
     JOIN om_visit_x_gully ON om_visit.id = om_visit_x_gully.visit_id
     LEFT JOIN om_typevalue s ON om_visit.status = s.id AND s.typevalue = 'visit_cat_status'::text
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value 
			FROM ud.om_visit JOIN ud.om_visit_event ON om_visit.id= om_visit_event.visit_id 
			JOIN ud.om_visit_class on om_visit_class.id=om_visit.class_id
			JOIN ud.om_visit_class_x_parameter on om_visit_class_x_parameter.parameter_id=om_visit_event.parameter_id 
			where om_visit_class.ismultievent = TRUE ORDER  BY 1,2'::text, ' VALUES (''incidence''),(''inc_observ'')'::text) ct(visit_id integer, param_1 text, param_2 text)) a ON a.visit_id = om_visit.id
     LEFT JOIN om_typevalue p ON p.id::text = a.param_1 AND p.typevalue = 'incidence'::text
  WHERE om_visit_class.ismultievent = true AND om_visit_class.id = 5;


CREATE TRIGGER gw_trg_om_visit_multievent
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON ve_visit_incidence
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_om_visit_multievent(5);
  
----------------------  
--OTHER VIEWS FOR LOT
---------------------

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


 CREATE OR REPLACE VIEW v_lot AS 
 SELECT om_visit_lot.id,
    om_visit_lot.the_geom
   FROM selector_lot,
    om_visit_lot
  WHERE om_visit_lot.id = selector_lot.lot_id AND selector_lot.cur_user = "current_user"()::text;
