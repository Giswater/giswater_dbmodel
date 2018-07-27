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


INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (1, 8, 'vi_junctions', '[JUNCTIONS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (2, 8, 'vi_reservoirs', '[RESERVOIRS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (3, 8, 'vi_tanks', '[TANKS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (4, 8, 'vi_pipes', '[PIPES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (5, 8, 'vi_pumps', '[PUMPS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (6, 8, 'vi_valves', '[VALVES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (7, 8, 'vi_tags', '[TAGS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (8, 8, 'vi_demands', '[DEMANDS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (9, 8, 'vi_status', '[STATUS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (10, 8, 'vi_patterns', '[PATTERNS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (11, 8, 'vi_curves', '[CURVES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (12, 8, 'vi_controls', '[CONTROLS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (13, 8, 'vi_rules', '[RULES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (14, 8, 'vi_energy', '[ENERGY]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (15, 8, 'vi_emitters', '[EMITTERS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (16, 8, 'vi_quality', '[QUALITY]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (17, 8, 'vi_sources', '[SOURCES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (18, 8, 'vi_reactions_el', '[REACTIONS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (19, 8, 'vi_reactions_gl', '[REACTIONS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (20, 8, 'vi_mixing', '[MIXING]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (21, 8, 'vi_times', '[TIMES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (22, 8, 'vi_report', '[REPORT]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (23, 8, 'vi_options', '[OPTIONS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (24, 8, 'vi_coordinates', '[COORDINATES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (25, 8, 'vi_vertices', '[VERTICES]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (26, 8, 'vi_labels', '[LABELS]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (27, 8, 'vi_backdrop', '[BACKDROP]');
