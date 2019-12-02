/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 24/11/2019
INSERT INTO sys_fprocess_cat(id, fprocess_name, context, fprocess_i18n, project_type)
VALUES (99, 'Mincut process', 'om', 'Mincut process', 'ws');

INSERT INTO om_visit_type VALUES (1, 'planned');
INSERT INTO om_visit_type VALUES (2, 'unexpected');

INSERT INTO audit_cat_table VALUES ('ext_cat_vehicle', 'External table', 'Vehicle catalog', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_lot', 'O&M', 'Table for lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_lot_x_arc', 'O&M', 'Table for arcs related to their lot', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_lot_x_connec', 'O&M', 'Table for connecs related to their lot', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_lot_x_node', 'O&M', 'Table for nodes related to their lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_lot_x_user', 'O&M', 'Table for save information related to users and lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('cat_team', 'Catalog', 'Catalog of teams', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_vehicle_x_parameters', 'O&M', 'Table to save values of vehicles and their diferent parameters', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_team_x_vehicle', 'O&M', 'Relation between teams and vehicles', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ext_workorder_class', 'External table', 'Classes of workorders', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ext_workorder_type', 'External table', 'Types of workorders', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_typevalue', 'O&M', 'Table to save diferent values related to O&M tables', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_class', 'O&M', 'Diferent classes of visits', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_class_x_parameter', 'O&M', 'Parameters related to their class', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_class_x_wo', 'O&M', 'Relation between classes and workorders', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_team_x_user', 'O&M', 'Relation between teams and users', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_type', 'O&M', 'Diferent types of visits', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ext_workorder', 'External table', 'Table for existing workorders', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('selector_lot', 'O&M', 'Selector for lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);

