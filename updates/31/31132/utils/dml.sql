/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


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
INSERT INTO audit_cat_table VALUES ('om_user_x_team', 'O&M', 'Relation between teams and users', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_visit_type', 'O&M', 'Diferent types of visits', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ext_workorder', 'External table', 'Table for existing workorders', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('selector_lot', 'O&M', 'Selector for lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_ui_om_visit_lot', 'UI view', 'User Interface view for Lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_res_lot_x_user', 'O&M', 'View to manage works done by users', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ve_lot_x_arc', 'O&M', 'Editable view for arcs related to their lot', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ve_lot_x_node', 'O&M', 'Editable view for nodes related to their lot', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('ve_lot_x_connec', 'O&M', 'Editable view for connecs related to their lot', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_ui_om_vehicle_x_parameters', 'UI view', 'User Interface view to show relations between vehicles and their parameters', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_om_user_x_team', 'O&M', 'Editable view with relations between users and teams', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_om_team_x_visitclass', 'O&M', 'Editable view with relations between visitclass and teams', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('om_team_x_visitclass', 'O&M', 'Relation between visitclass and teams', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_edit_cat_team', 'O&M', 'Editable view for team catalog', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_ext_cat_vehicle', 'O&M', 'Editable view for vehicle catalog', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_om_lot_x_user', 'O&M', 'Editable with relations between lots and users', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('v_visit_lot_user', 'O&M', NULL, 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);


INSERT INTO audit_cat_function VALUES (2834, 'gw_trg_edit_team_x_user', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_om_user_x_team', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2836, 'gw_trg_edit_team_x_visitclass', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_om_team_x_visitclass', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2838, 'gw_trg_edit_cat_team', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_edit_cat_team', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2840, 'gw_trg_edit_cat_vehicle', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_ext_cat_vehicle', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2842, 'gw_trg_edit_lot_x_user', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_om_lot_x_user', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2844, 'gw_trg_edit_team_x_vehicle', 'utils', 'function trigger', NULL, NULL, NULL, 'Makes editable v_om_team_x_vehicle', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2852, 'gw_fct_lot_psector_geom', 'utils', 'function', NULL, NULL, NULL, 'Generate lot geometry', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2856, 'gw_api_getunexpected', 'utils', 'function', NULL, NULL, NULL, 'Get unexpected visit', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2858, 'gw_api_get_combochilds', 'utils', 'function', NULL, NULL, NULL, 'Get combo childs', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2860, 'gw_api_getselectors', 'utils', 'function', NULL, NULL, NULL, 'Get selectors', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_function VALUES (2862, 'gw_api_setlot', 'utils', 'function', NULL, NULL, NULL, 'Set lot', 'role_om', false) 
ON CONFLICT (id) DO NOTHING;

