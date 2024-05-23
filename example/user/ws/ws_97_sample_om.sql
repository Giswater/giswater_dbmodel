/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

UPDATE config_graph_checkvalve SET active = TRUE;

UPDATE config_graph_inlet   SET active = TRUE;

UPDATE config_graph_valve SET active = TRUE;

INSERT INTO om_visit_cat VALUES (1, 'Test', '2024-02-21', '2024-02-21', NULL, true, NULL, NULL, NULL, 'Test');

INSERT INTO om_typevalue VALUES ('visit_cleaned', '1', 'Yes', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cleaned', '2', 'No', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_cleaned', '3', 'Half', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_defect', '1', 'Good state', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_defect', '2', 'Some defects', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_defect', '3', 'Bad state', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_defect', '4', 'No defects', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_leak', '1', 'No leak', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_leak', '2', 'Minor leak', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_sediments', '1', 'No sediments', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_sediments', '2', 'Presence of sediments', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '1', 'Broken cover', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '2', 'Water on the street', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '3', 'Smells', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '4', 'Noisy cover', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '5', 'Others', NULL, NULL);
INSERT INTO om_typevalue VALUES ('incident_type', '6', 'Missing cover', NULL, NULL);
INSERT INTO om_typevalue VALUES ('visit_param_type', 'INCIDENCE', 'INCIDENCE', NULL, NULL);

INSERT INTO config_visit_class VALUES (1, 'Leak on arc', NULL, true, false, true, 'ARC', 'role_om', 1, NULL, 'visit_arc_leak', 've_visit_arc_leak', 'v_ui_visit_arc_leak', NULL, NULL);
INSERT INTO config_visit_class VALUES (2, 'Leak on connec', NULL, true, false, true, 'CONNEC', 'role_om', 1, NULL, 'visit_connec_leak', 've_visit_connec_leak', 'v_ui_visit_connec_leak', NULL, NULL);
INSERT INTO config_visit_class VALUES (3, 'Inspection and clean node', NULL, true, false, true, 'NODE', 'role_om', 1, NULL, 'visit_node_insp', 've_visit_node_insp', 'v_ui_visit_node_insp', NULL, NULL);
INSERT INTO config_visit_class VALUES (4, 'Incident node', NULL, true, false, true, 'NODE', 'role_om', 2, NULL, 'incident_node', 've_visit_incid_node', 'v_ui_visit_incid_node', NULL, NULL);

INSERT INTO config_visit_parameter VALUES ('leak_arc', NULL, 'INSPECTION', 'ARC', 'text', NULL, 'minor leak on arc', 'event_standard', 'defaultvalue', false, 'arc_insp_des', true);
INSERT INTO config_visit_parameter VALUES ('leak_connec', NULL, 'INSPECTION', 'CONNEC', 'text', NULL, 'minor leak on connec', 'event_standard', 'defaultvalue', false, 'con_insp_des', true);
INSERT INTO config_visit_parameter VALUES ('sediments_node', NULL, 'INSPECTION', 'NODE', 'text', NULL, 'Sediments in node', 'event_standard', 'defaultvalue', false, 'node_insp_sed', true);
INSERT INTO config_visit_parameter VALUES ('clean_node', NULL, 'INSPECTION', 'NODE', 'text', NULL, 'Clean of node', 'event_standard', 'defaultvalue', false, 'node_cln_exec', true);
INSERT INTO config_visit_parameter VALUES ('defect_node', NULL, 'INSPECTION', 'NODE', 'text', NULL, 'Defects of node', 'event_standard', 'defaultvalue', false, 'node_defect', true);
INSERT INTO config_visit_parameter VALUES ('incident_comment', NULL, 'INCIDENCE', 'ALL', 'text', NULL, 'incident_comment', 'event_standard', 'defaultvalue', false, 'incident_comment', true);
INSERT INTO config_visit_parameter VALUES ('incident_type', NULL, 'INCIDENCE', 'ALL', 'text', NULL, 'incident type', 'event_standard', 'defaultvalue', false, 'incident_type', true);
INSERT INTO config_visit_parameter VALUES ('insp_observ', NULL, 'INSPECTION', 'ALL', 'text', NULL, 'Inspection observations', 'event_standard', 'defaultvalue', false, 'insp_observ', true);
INSERT INTO config_visit_parameter VALUES ('photo', NULL, 'INSPECTION', 'ALL', 'boolean', NULL, 'Photography', 'event_standard', 'defaultvalue', false, 'photo', true);

INSERT INTO config_visit_class_x_parameter VALUES (1, 'leak_arc', true);
INSERT INTO config_visit_class_x_parameter VALUES (1, 'insp_observ', true);
INSERT INTO config_visit_class_x_parameter VALUES (1, 'photo', true);
INSERT INTO config_visit_class_x_parameter VALUES (2, 'leak_connec', true);
INSERT INTO config_visit_class_x_parameter VALUES (2, 'insp_observ', true);
INSERT INTO config_visit_class_x_parameter VALUES (2, 'photo', true);
INSERT INTO config_visit_class_x_parameter VALUES (3, 'defect_node', true);
INSERT INTO config_visit_class_x_parameter VALUES (3, 'clean_node', true);
INSERT INTO config_visit_class_x_parameter VALUES (3, 'sediments_node', true);
INSERT INTO config_visit_class_x_parameter VALUES (3, 'insp_observ', true);
INSERT INTO config_visit_class_x_parameter VALUES (3, 'photo', true);
INSERT INTO config_visit_class_x_parameter VALUES (4, 'incident_type', true);
INSERT INTO config_visit_class_x_parameter VALUES (4, 'incident_comment', true);
INSERT INTO config_visit_class_x_parameter VALUES (4, 'photo', true);

-- editable views with trigger
DROP VIEW IF EXISTS ve_visit_arc_leak;
CREATE OR REPLACE VIEW ve_visit_arc_leak AS
 SELECT om_visit_x_arc.id,
    om_visit_x_arc.visit_id,
    om_visit_x_arc.arc_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    arc.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.status,
    a.param_1 AS leak_arc,
    a.param_2 AS insp_observ,
    a.param_3 AS photo
   FROM om_visit
     JOIN config_visit_class ON config_visit_class.id = om_visit.class_id
     JOIN om_visit_x_arc ON om_visit.id = om_visit_x_arc.visit_id
     JOIN arc USING (arc_id)
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2,
            ct.param_3
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value
      FROM SCHEMA_NAME.om_visit JOIN SCHEMA_NAME.om_visit_event ON om_visit.id= om_visit_event.visit_id
      LEFT JOIN SCHEMA_NAME.config_visit_class on config_visit_class.id=om_visit.class_id
      where config_visit_class.ismultievent = TRUE and om_visit.class_id = 1 ORDER  BY 1,2'::text,
      ' VALUES (''leak_arc''),(''insp_observ''),(''photo'')'::text)
      ct(visit_id integer, param_1 text, param_2 text, param_3 boolean)) a ON a.visit_id = om_visit.id
  WHERE config_visit_class.ismultievent = true AND config_visit_class.id = 1;

CREATE TRIGGER gw_trg_om_visit_multievent INSTEAD OF
INSERT OR DELETE OR UPDATE ON ve_visit_arc_leak
FOR EACH ROW EXECUTE FUNCTION gw_trg_om_visit_multievent('1');


DROP VIEW IF EXISTS ve_visit_connec_leak;
CREATE OR REPLACE VIEW ve_visit_connec_leak AS
 SELECT om_visit_x_connec.id,
    om_visit_x_connec.visit_id,
    om_visit_x_connec.connec_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    connec.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.status,
    a.param_1 AS leak_connec,
    a.param_2 AS insp_observ,
    a.param_3 AS photo
   FROM om_visit
     JOIN config_visit_class ON config_visit_class.id = om_visit.class_id
     JOIN om_visit_x_connec ON om_visit.id = om_visit_x_connec.visit_id
     JOIN connec USING (connec_id)
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2,
            ct.param_3
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value
      FROM SCHEMA_NAME.om_visit JOIN SCHEMA_NAME.om_visit_event ON om_visit.id= om_visit_event.visit_id
      LEFT JOIN SCHEMA_NAME.config_visit_class on config_visit_class.id=om_visit.class_id
      where config_visit_class.ismultievent = TRUE and om_visit.class_id = 2 ORDER  BY 1,2'::text,
      ' VALUES (''leak_connec''),(''insp_observ''),(''photo'')'::text)
      ct(visit_id integer, param_1 text, param_2 text, param_3 boolean)) a ON a.visit_id = om_visit.id
  WHERE config_visit_class.ismultievent = true AND config_visit_class.id = 2;

CREATE TRIGGER gw_trg_om_visit_multievent INSTEAD OF
INSERT OR DELETE OR UPDATE ON ve_visit_connec_leak
FOR EACH ROW EXECUTE FUNCTION gw_trg_om_visit_multievent('2');


DROP VIEW IF EXISTS ve_visit_node_insp;
CREATE OR REPLACE VIEW ve_visit_node_insp AS
 SELECT om_visit_x_node.id,
    om_visit_x_node.visit_id,
    om_visit_x_node.node_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    node.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.status,
    a.param_1 AS sediments_node,
    a.param_2 AS defect_node,
    a.param_3 AS clean_node,
    a.param_4 AS insp_observ,
    a.param_5 AS photo
   FROM om_visit
     JOIN config_visit_class ON config_visit_class.id = om_visit.class_id
     JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node USING (node_id)
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2,
            ct.param_3,
            ct.param_4,
            ct.param_5
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value
      FROM SCHEMA_NAME.om_visit JOIN SCHEMA_NAME.om_visit_event ON om_visit.id= om_visit_event.visit_id
      LEFT JOIN SCHEMA_NAME.config_visit_class on config_visit_class.id=om_visit.class_id
      where config_visit_class.ismultievent = TRUE and om_visit.class_id = 3 ORDER  BY 1,2'::text,
      ' VALUES (''sediments_node''),(''defect_node''),(''clean_node''),(''insp_observ''),(''photo'')'::text)
      ct(visit_id integer, param_1 text, param_2 text, param_3 text, param_4 text, param_5 boolean)) a ON a.visit_id = om_visit.id
  WHERE config_visit_class.ismultievent = true AND config_visit_class.id = 3;

CREATE TRIGGER gw_trg_om_visit_multievent INSTEAD OF
INSERT OR DELETE OR UPDATE ON ve_visit_node_insp
FOR EACH ROW EXECUTE FUNCTION gw_trg_om_visit_multievent('3');


DROP VIEW IF EXISTS ve_visit_incid_node;
CREATE OR REPLACE VIEW ve_visit_incid_node AS
 SELECT om_visit_x_node.id,
    om_visit_x_node.visit_id,
    om_visit_x_node.node_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    node.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.status,
    a.param_1 AS incident_type,
    a.param_2 AS incident_comment,
    a.param_3 AS photo
   FROM om_visit
     JOIN config_visit_class ON config_visit_class.id = om_visit.class_id
     JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node USING (node_id)
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2,
            ct.param_3
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value
      FROM SCHEMA_NAME.om_visit JOIN SCHEMA_NAME.om_visit_event ON om_visit.id= om_visit_event.visit_id
      LEFT JOIN SCHEMA_NAME.config_visit_class on config_visit_class.id=om_visit.class_id
      where config_visit_class.ismultievent = TRUE and om_visit.class_id = 4 ORDER  BY 1,2'::text,
      ' VALUES (''incident_type''), (''incident_comment''), (''photo'')'::text)
      ct(visit_id integer, param_1 text, param_2 text, param_3 boolean)) a ON a.visit_id = om_visit.id
  WHERE config_visit_class.ismultievent = true AND config_visit_class.id = 4;

CREATE TRIGGER gw_trg_om_visit_multievent INSTEAD OF
INSERT OR DELETE OR UPDATE ON ve_visit_incid_node
FOR EACH ROW EXECUTE FUNCTION gw_trg_om_visit_multievent('4');

-- UI views
CREATE OR REPLACE VIEW v_ui_visit_arc_leak
AS SELECT ve_visit_arc_leak.visit_id,
    ve_visit_arc_leak.arc_id,
    ve_visit_arc_leak.startdate AS "Start date",
    ve_visit_arc_leak.enddate AS "End date",
    ve_visit_arc_leak.user_name AS "User",
    c.idval AS "Visit class",
    t.idval AS "Status",
    z.idval AS "Leak",
    ve_visit_arc_leak.insp_observ AS "Observation",
    ve_visit_arc_leak.photo AS "Photo"
   FROM ve_visit_arc_leak
     JOIN config_visit_class c ON c.id = ve_visit_arc_leak.class_id
     JOIN om_typevalue t ON t.id::integer = ve_visit_arc_leak.status AND t.typevalue = 'visit_status'::text
     LEFT JOIN om_typevalue z ON z.id::integer = ve_visit_arc_leak.leak_arc::integer AND z.typevalue = 'visit_leak'::text;



CREATE OR REPLACE VIEW v_ui_visit_connec_leak
AS SELECT ve_visit_connec_leak.visit_id,
    ve_visit_connec_leak.connec_id,
    ve_visit_connec_leak.startdate AS "Start date",
    ve_visit_connec_leak.enddate AS "End date",
    ve_visit_connec_leak.user_name AS "User",
    c.idval AS "Visit class",
    t.idval AS "Status",
    z.idval AS "Leak",
    ve_visit_connec_leak.insp_observ AS "Observation",
    ve_visit_connec_leak.photo AS "Photo"
   FROM ve_visit_connec_leak
     JOIN config_visit_class c ON c.id = ve_visit_connec_leak.class_id
     JOIN om_typevalue t ON t.id::integer = ve_visit_connec_leak.status AND t.typevalue = 'visit_status'::text
     LEFT JOIN om_typevalue z ON z.id::integer = ve_visit_connec_leak.leak_connec::integer AND z.typevalue = 'visit_leak'::text;


CREATE OR REPLACE VIEW v_ui_visit_node_insp
AS SELECT ve_visit_node_insp.visit_id,
    ve_visit_node_insp.node_id,
    ve_visit_node_insp.startdate AS "Start date",
    ve_visit_node_insp.enddate AS "End date",
    ve_visit_node_insp.user_name AS "User",
    c.idval AS "Visit class",
    t.idval AS "Status",
    z.idval AS "Sediments",
    u.idval AS "Defects",
    y.idval AS "Cleaned",
    ve_visit_node_insp.insp_observ AS "Observation",
    ve_visit_node_insp.photo AS "Photo"
   FROM ve_visit_node_insp
     JOIN config_visit_class c ON c.id = ve_visit_node_insp.class_id
     JOIN om_typevalue t ON t.id::integer = ve_visit_node_insp.status AND t.typevalue = 'visit_status'::text
     LEFT JOIN om_typevalue y ON y.id::integer = ve_visit_node_insp.clean_node::integer AND y.typevalue = 'visit_cleaned'::text
     LEFT JOIN om_typevalue u ON u.id::integer = ve_visit_node_insp.defect_node::integer AND u.typevalue = 'visit_defect'::text
     LEFT JOIN om_typevalue z ON z.id::integer = ve_visit_node_insp.sediments_node::integer AND z.typevalue = 'visit_sediments'::text;


CREATE OR REPLACE VIEW v_ui_visit_incid_node
AS SELECT ve_visit_incid_node.visit_id,
    ve_visit_incid_node.node_id,
    ve_visit_incid_node.startdate AS "Start date",
    ve_visit_incid_node.enddate AS "End date",
    ve_visit_incid_node.user_name AS "User",
    c.idval AS "Visit class",
    t.idval AS "Status",
    y.idval AS "Incident type",
    ve_visit_incid_node.incident_comment AS "Comment",
    ve_visit_incid_node.photo AS "Photo"
   FROM ve_visit_incid_node
     JOIN config_visit_class c ON c.id = ve_visit_incid_node.class_id
     JOIN om_typevalue t ON t.id::integer = ve_visit_incid_node.status AND t.typevalue = 'visit_status'::text
     JOIN om_typevalue y ON y.id::integer = ve_visit_incid_node.incident_type::integer AND y.typevalue = 'incident_type'::text;

INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'class_id', 'lyt_data_1', NULL, 'integer', 'combo', 'Visit class:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM config_visit_class WHERE feature_type=''ARC'' AND  active IS TRUE AND sys_role IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, NULL, NULL, '{"functionName": "get_visit"}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'visit_id', 'lyt_data_1', NULL, 'double', 'text', 'Visit id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'arc_id', 'lyt_data_1', NULL, 'double', 'text', 'Arc id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'startdate', 'lyt_data_1', NULL, 'date', 'datetime', 'Date:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'leak_arc', 'lyt_data_1', NULL, 'string', 'text', 'Leak arc:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'insp_observ', 'lyt_data_1', NULL, 'string', 'text', 'Observations:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'status', 'lyt_data_1', NULL, 'integer', 'combo', 'Status:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''visit_status'' and id =''4''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_data', 'acceptbutton', 'lyt_data_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Accept"}', '{
  "functionName": "set_visit"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_file', 'addfile', 'lyt_files_1', NULL, NULL, 'fileselector', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Add File"}', '{
  "functionName": "add_file"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_file', 'tbl_files', 'lyt_files_1', NULL, NULL, 'tableview', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"saveValue": false}', NULL, 'om_visit_event_photo', false, 2);
INSERT INTO config_form_fields VALUES ('visit_arc_leak', 'form_visit', 'tab_file', 'backbutton', 'lyt_files_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Back"}', '{
  "functionName": "set_previous_form_back"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_connec_leak', 'form_visit', 'tab_data', 'class_id', 'lyt_data_1', NULL, 'integer', 'combo', 'Visit class:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM config_visit_class WHERE feature_type=''CONNEC'' AND  active IS TRUE AND sys_role IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, NULL, NULL, '{"functionName": "get_visit"}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_connec_leak', 'form_visit', 'tab_data', 'acceptbutton', 'lyt_data_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Accept"}', '{
  "functionName": "set_visit"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_connec_leak', 'form_visit', 'tab_file', 'addfile', 'lyt_files_1', NULL, NULL, 'fileselector', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Add File"}', '{
  "functionName": "add_file"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_connec_leak', 'form_visit', 'tab_file', 'tbl_files', 'lyt_files_1', NULL, NULL, 'tableview', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"saveValue": false}', NULL, 'om_visit_event_photo', false, 2);
INSERT INTO config_form_fields VALUES ('visit_connec_leak', 'form_visit', 'tab_file', 'backbutton', 'lyt_files_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Back"}', '{
  "functionName": "set_previous_form_back"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'class_id', 'lyt_data_1', NULL, 'integer', 'combo', 'Visit class:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM config_visit_class WHERE feature_type=''NODE'' AND  active IS TRUE AND sys_role IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, NULL, NULL, '{"functionName": "get_visit"}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'visit_id', 'lyt_data_1', NULL, 'double', 'text', 'Visit id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'node_id', 'lyt_data_1', NULL, 'double', 'text', 'Node id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'startdate', 'lyt_data_1', NULL, 'date', 'datetime', 'Date:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'sediments_node', 'lyt_data_1', NULL, 'string', 'text', 'Sediments node:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'defect_node', 'lyt_data_1', NULL, 'string', 'combo', 'Defect node:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''visit_defect''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'clean_node', 'lyt_data_1', NULL, 'integer', 'combo', 'Clean node:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''visit_cleaned''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'insp_observ', 'lyt_data_1', NULL, 'string', 'text', 'Observations:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'status', 'lyt_data_1', NULL, 'integer', 'combo', 'Status:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''visit_status'' and id =''4''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_data', 'acceptbutton', 'lyt_data_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Accept"}', '{
  "functionName": "set_visit"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_file', 'addfile', 'lyt_files_1', NULL, NULL, 'fileselector', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Add File"}', '{
  "functionName": "add_file"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_file', 'tbl_files', 'lyt_files_1', NULL, NULL, 'tableview', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"saveValue": false}', NULL, 'om_visit_event_photo', false, 2);
INSERT INTO config_form_fields VALUES ('visit_node_insp', 'form_visit', 'tab_file', 'backbutton', 'lyt_files_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Back"}', '{
  "functionName": "set_previous_form_back"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'class_id', 'lyt_data_1', NULL, 'integer', 'combo', 'Visit class:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM config_visit_class WHERE feature_type=''NODE'' AND  active IS TRUE AND sys_role IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, NULL, NULL, '{"functionName": "get_visit"}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'visit_id', 'lyt_data_1', NULL, 'double', 'text', 'Visit id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'node_id', 'lyt_data_1', NULL, 'double', 'text', 'Node id:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'startdate', 'lyt_data_1', NULL, 'date', 'datetime', 'Date:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'incident_type', 'lyt_data_1', NULL, 'integer', 'combo', 'Incident type:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''incident_type''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'incident_comment', 'lyt_data_1', NULL, 'string', 'text', 'Comment:', NULL, NULL, false, false, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'status', 'lyt_data_1', NULL, 'integer', 'combo', 'Status:', NULL, NULL, false, false, true, NULL, NULL, 'SELECT id, idval FROM om_typevalue WHERE typevalue = ''visit_status'' and id =''4''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_data', 'acceptbutton', 'lyt_data_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Accept"}', '{
  "functionName": "set_visit"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_file', 'addfile', 'lyt_files_1', NULL, NULL, 'fileselector', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Add File"}', '{
  "functionName": "add_file"
}', NULL, false, 1);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_file', 'tbl_files', 'lyt_files_1', NULL, NULL, 'tableview', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"saveValue": false}', NULL, 'om_visit_event_photo', false, 2);
INSERT INTO config_form_fields VALUES ('incident_node', 'form_visit', 'tab_file', 'backbutton', 'lyt_files_2', NULL, NULL, 'button', '', NULL, NULL, false, false, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"setMultiline":false, "text":"Back"}', '{
  "functionName": "set_previous_form_back"
}', NULL, false, 1);

INSERT INTO config_form_tabs VALUES ('visit_node_insp', 'tab_file', 'Files', 'Files', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 2, '{5}');
INSERT INTO config_form_tabs VALUES ('visit_node_insp', 'tab_data', 'Data', 'Data', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false}]', 1, '{5}');
INSERT INTO config_form_tabs VALUES ('visit_arc_leak', 'tab_file', 'Files', 'Files', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 2, '{5}');
INSERT INTO config_form_tabs VALUES ('visit_connec_leak', 'tab_data', 'Data', 'Data', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false}]', 1, '{5}');
INSERT INTO config_form_tabs VALUES ('visit_connec_leak', 'tab_file', 'Files', 'Files', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 2, '{5}');
INSERT INTO config_form_tabs VALUES ('incident_node', 'tab_data', 'Data', 'Data', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false}]', 1, '{5}');
INSERT INTO config_form_tabs VALUES ('incident_node', 'tab_file', 'Files', 'Files', 'role_om', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 2, '{5}');

GRANT ALL ON TABLE ve_visit_arc_leak TO role_om;
GRANT ALL ON TABLE ve_visit_connec_leak TO role_om;

GRANT ALL ON TABLE ve_visit_node_insp TO role_om;
GRANT ALL ON TABLE ve_visit_incid_node TO role_om;


GRANT ALL ON TABLE v_ui_visit_arc_leak TO role_om;
GRANT ALL ON TABLE v_ui_visit_connec_leak TO role_om;

GRANT ALL ON TABLE v_ui_visit_node_insp TO role_om;
GRANT ALL ON TABLE v_ui_visit_incid_node TO role_om;
