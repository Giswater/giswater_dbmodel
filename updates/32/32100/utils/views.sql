/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-----------------------
-- remove all the views that are refactored in the v3.2
-----------------------

DROP VIEW IF EXISTS v_ui_doc_x_connec;
DROP VIEW IF EXISTS v_ui_doc_x_arc;
DROP VIEW IF EXISTS v_ui_doc_x_node;
DROP VIEW IF EXISTS v_ui_document;

DROP VIEW IF EXISTS v_ui_element_x_connec;
DROP VIEW IF EXISTS v_ui_elemenst_x_arc;
DROP VIEW IF EXISTS v_ui_element_x_node;
DROP VIEW IF EXISTS v_ui_element_x_gully;
DROP VIEW IF EXISTS v_ui_element;

DROP VIEW IF EXISTS v_ui_om_visit;
DROP VIEW IF EXISTS v_ui_om_visit_x_connec;
DROP VIEW IF EXISTS v_ui_om_visit_x_arc;
DROP VIEW IF EXISTS v_ui_om_visit_x_node;
DROP VIEW IF EXISTS v_ui_om_visit_x_gully;

DROP VIEW IF EXISTS v_ui_om_event_x_connec;
DROP VIEW IF EXISTS v_ui_om_event_x_arc;
DROP VIEW IF EXISTS v_ui_om_event_x_node;
DROP VIEW IF EXISTS v_ui_om_event_x_gully;

DROP VIEW IF EXISTS v_ui_om_visitman_x_node;
DROP VIEW IF EXISTS v_ui_om_visitman_x_arc;
DROP VIEW IF EXISTS v_ui_om_visitman_x_connec;
DROP VIEW IF EXISTS v_ui_om_visitman_x_gully;

DROP VIEW IF EXISTS v_ui_scada_x_node;
DROP VIEW IF EXISTS v_ui_scada_x_node_values;
DROP VIEW IF EXISTS v_ui_arc_x_node;
DROP VIEW IF EXISTS v_ui_rpt_cat_result;
DROP VIEW IF EXISTS v_ui_anl_result_cat;