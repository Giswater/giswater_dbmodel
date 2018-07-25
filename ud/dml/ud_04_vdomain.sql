/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

update config_api_layer_field set dv_table='cat_node', dv_id_column='id', dv_name_column='id',form_label='nodecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_node WHERE id IS NOT NULL' WHERE column_id='nodecat_id';	

update config_api_layer_field set dv_table='cat_arc', dv_id_column='id', dv_name_column='id',form_label='arccat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_arc WHERE id IS NOT NULL' WHERE column_id='arccat_id';

update config_api_layer_field set dv_table='cat_connec', dv_id_column='id', dv_name_column='id',form_label='connecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat-connec WHERE id IS NOT NULL' WHERE column_id='connecat_id';

update config_api_layer_field set dv_table='cat_grate', dv_id_column='id', dv_name_column='id',form_label='gratecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_grate WHERE id IS NOT NULL' WHERE column_id='gratecat_id';


update config_api_layer_field set dv_table='node_type', dv_id_column='id', dv_name_column='id',form_label='node_type', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM node_type WHERE id IS NOT NULL' WHERE column_id='node_type';	

update config_api_layer_field set dv_table='arc_type', dv_id_column='id', dv_name_column='id',form_label='arc_type', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM arc_type WHERE id IS NOT NULL' WHERE column_id='arc_type';

update config_api_layer_field set dv_table='connec_type', dv_id_column='id', dv_name_column='id',form_label='connec_type', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM connec_type WHERE id IS NOT NULL' WHERE column_id='connec_type';

update config_api_layer_field set dv_table='gully_type', dv_id_column='id', dv_name_column='id',form_label='gully_type', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM gully_type WHERE id IS NOT NULL' WHERE column_id='gully_type';


update config_api_layer_field set dv_table='cat_arc', dv_id_column='id', dv_name_column='id',form_label='connec_arccat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id FROM cat_arc WHERE id IS NOT NULL' WHERE column_id='connec_arccat_id';


UPDATE config_api_layer_field SET dv_table='arc', dv_id_column='arc_id', dv_name_column='arc_id', form_label='arc_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT arc_id FROM arc WHERE arc_id IS NOT NULL' WHERE column_id='arc_id' and (table_id ilike 've_node%' or table_id ilike 've_connec%' or table_id ilike 've_gully');



INSERT INTO sys_csv2pg_config VALUES (1, 4, 'vi_options', 'OPTIONS');
INSERT INTO sys_csv2pg_config VALUES (2, 4, 'vi_evaporation', 'EVAPORATION');
INSERT INTO sys_csv2pg_config VALUES (3, 4, 'vi_raingages', 'RAINGAGES');
INSERT INTO sys_csv2pg_config VALUES (4, 4, 'vi_subcatchments', 'SUBCATCHMENTS');
INSERT INTO sys_csv2pg_config VALUES (5, 4, 'vi_subareas', 'SUBAREAS');
INSERT INTO sys_csv2pg_config VALUES (6, 4, 'vi_infiltration', 'INFILTRATION');
INSERT INTO sys_csv2pg_config VALUES (8, 4, 'vi_lid_usage', 'LID_USAGE');
INSERT INTO sys_csv2pg_config VALUES (7, 4, 'vi_lid_controls', 'LID_CONTROLS');
INSERT INTO sys_csv2pg_config VALUES (9, 4, 'vi_snowpacks', 'SNOWPACKS');
INSERT INTO sys_csv2pg_config VALUES (10, 4, 'vi_junctions', 'JUNCTIONS');
INSERT INTO sys_csv2pg_config VALUES (11, 4, 'vi_outfalls', 'OUTFALLS');
INSERT INTO sys_csv2pg_config VALUES (12, 4, 'vi_conduits', 'CONDUITS');
INSERT INTO sys_csv2pg_config VALUES (13, 4, 'vi_xsections', 'XSECTIONS');
INSERT INTO sys_csv2pg_config VALUES (14, 4, 'vi_losses', 'LOSSES');
INSERT INTO sys_csv2pg_config VALUES (15, 4, 'vi_controls', 'CONTROLS');
INSERT INTO sys_csv2pg_config VALUES (16, 4, 'vi_pollutants', 'POLLUTANTS');
INSERT INTO sys_csv2pg_config VALUES (17, 4, 'vi_landuses', 'LANDUSES');
INSERT INTO sys_csv2pg_config VALUES (18, 4, 'vi_coverages', 'COVERAGES');
INSERT INTO sys_csv2pg_config VALUES (19, 4, 'vi_loadings', 'LOADINGS');
INSERT INTO sys_csv2pg_config VALUES (20, 4, 'vi_buildup', 'BUILDUP');
INSERT INTO sys_csv2pg_config VALUES (22, 4, 'vi_treatment', 'TREATMENT');
INSERT INTO sys_csv2pg_config VALUES (23, 4, 'vi_dwf', 'DWF');
INSERT INTO sys_csv2pg_config VALUES (24, 4, 'vi_timeseries', 'TIMESERIES');
INSERT INTO sys_csv2pg_config VALUES (25, 4, 'vi_patterns', 'PATTERNS');
INSERT INTO sys_csv2pg_config VALUES (26, 4, 'vi_report', 'REPORT');
INSERT INTO sys_csv2pg_config VALUES (21, 4, 'vi_washoff', 'WASHOFF');
INSERT INTO sys_csv2pg_config VALUES (27, 4, 'vi_map', 'MAP');
INSERT INTO sys_csv2pg_config VALUES (28, 4, 'vi_coordinates', 'COORDINATES');
INSERT INTO sys_csv2pg_config VALUES (29, 4, 'vi_vertices', 'VERTICES');
INSERT INTO sys_csv2pg_config VALUES (30, 4, 'vi_symbols', 'SYMBOLS');
INSERT INTO sys_csv2pg_config VALUES (31, 4, 'vi_polygons', 'Polygons');
