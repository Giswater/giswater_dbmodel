/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


update config_api_layer_field set dv_table='cat_node', dv_id_column='id', dv_name_column='id',form_label='nodecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_node WHERE id IS NOT NULL', dv_filterbyfield= 'nodetype_id' WHERE column_id='nodecat_id';	

update config_api_layer_field set dv_table='cat_arc', dv_id_column='id', dv_name_column='id',form_label='arccat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_node WHERE id IS NOT NULL', dv_filterbyfield= 'arctype_id' WHERE column_id='arccat_id';

update config_api_layer_field set dv_table='cat_connec', dv_id_column='id', dv_name_column='id',form_label='connecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_node WHERE id IS NOT NULL', dv_filterbyfield= 'connectype_id' WHERE column_id='connecat_id';


UPDATE config_api_layer_field SET dv_table='node', dv_id_column='node_id', dv_name_column='node_id', form_label='parent_id' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT node_id FROM node WHERE node_id IS NOT NULL' WHERE column_id='parent_id';


UPDATE config_api_layer_field SET dv_table='arc', dv_id_column='arc_id', dv_name_column='arc_id', form_label='arc_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT arc_id FROM arc WHERE arc_id IS NOT NULL' WHERE column_id='arc_id' and (table_id ilike 've_node%' or table_id ilike 've_connec%');

	

UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='nodetype_id';		


INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (28, 9, 'rpt_node', 'Node Results', NULL, NULL);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (29, 9, 'rpt_arc', 'Link Results', NULL, NULL);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (31, 9, 'rpt_hydraulic_status', 'Hydraulic Status:', NULL, NULL);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (30, 9, 'rpt_energy_usage', 'Pump Factor', NULL, NULL);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (32, 9, 'rpt_cat_result', 'Input Data', NULL, NULL);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (23, 8, 'vi_options', '[OPTIONS]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (0, 8, 'vi_junctions', '[JUNCTIONS]', 'csv1, csv2, csv3, csv4', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (2, 8, 'vi_reservoirs', '[RESERVOIRS]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (3, 8, 'vi_tanks', '[TANKS]', 'csv1, csv2, csv3, csv4, csv5, csv6, csv7, csv8', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (4, 8, 'vi_pipes', '[PIPES]', 'csv1, csv2, csv3, csv4, csv5, csv6, csv7, csv8', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (6, 8, 'vi_valves', '[VALVES]', 'csv1, csv2, csv3, csv4, csv5, csv6, csv7', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (7, 8, 'vi_tags', '[TAGS]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (8, 8, 'vi_demands', '[DEMANDS]', 'csv1, csv2, csv3, csv4', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (9, 8, 'vi_status', '[STATUS]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (18, 8, 'vi_reactions', '[REACTIONS]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (15, 8, 'vi_emitters', '[EMITTERS]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (16, 8, 'vi_quality', '[QUALITY]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (17, 8, 'vi_sources', '[SOURCES]', 'csv1, csv2, csv3, csv4', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (22, 8, 'vi_report', '[REPORT]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (24, 8, 'vi_coordinates', '[COORDINATES]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (26, 8, 'vi_labels', '[LABELS]', 'csv1, csv2, csv3, csv4', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (27, 8, 'vi_backdrop', '[BACKDROP]', 'csv1', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (25, 8, 'vi_vertices', '[VERTICES]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (21, 8, 'vi_times', '[TIMES]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (13, 8, 'vi_rules', '[RULES]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (12, 8, 'vi_controls', '[CONTROLS]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (5, 8, 'vi_pumps', '[PUMPS]', 'csv1, csv2, csv3, csv4', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (11, 8, 'vi_curves', '[CURVES]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (20, 8, 'vi_mixing', '[MIXING]', 'csv1, csv2, csv3', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (10, 8, 'vi_patterns', '[PATTERNS]', 'csv1, csv2', 10);
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, target, fields, reverse_pg2csvcat_id) VALUES (14, 8, 'vi_energy', '[ENERGY]', 'csv1, csv2', 10);


