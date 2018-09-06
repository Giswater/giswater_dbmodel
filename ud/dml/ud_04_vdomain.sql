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

INSERT INTO sys_csv2pg_config VALUES (1, 8, 'vi_options', '[OPTIONS]');
INSERT INTO sys_csv2pg_config VALUES (2, 8, 'vi_evaporation', '[EVAPORATION]');
INSERT INTO sys_csv2pg_config VALUES (3, 8, 'vi_raingages', '[RAINGAGES]');
INSERT INTO sys_csv2pg_config VALUES (4, 8, 'vi_subcatchments', '[SUBCATCHMENTS]');
INSERT INTO sys_csv2pg_config VALUES (5, 8, 'vi_subareas', '[SUBAREAS]');
INSERT INTO sys_csv2pg_config VALUES (6, 8, 'vi_infiltration', '[INFILTRATION]');
INSERT INTO sys_csv2pg_config VALUES (8, 8, 'vi_lid_usage', '[LID_USAGE]');
INSERT INTO sys_csv2pg_config VALUES (7, 8, 'vi_lid_controls', '[LID_CONTROLS]');
INSERT INTO sys_csv2pg_config VALUES (9, 8, 'vi_snowpacks', '[SNOWPACKS]');
INSERT INTO sys_csv2pg_config VALUES (10, 8, 'vi_junction', '[JUNCTIONS]');
INSERT INTO sys_csv2pg_config VALUES (11, 8, 'vi_outfalls', '[OUTFALLS]');
INSERT INTO sys_csv2pg_config VALUES (12, 8, 'vi_conduits', '[CONDUITS]');
INSERT INTO sys_csv2pg_config VALUES (13, 8, 'vi_xsections', '[XSECTIONS]');
INSERT INTO sys_csv2pg_config VALUES (14, 8, 'vi_losses', '[LOSSES]');
INSERT INTO sys_csv2pg_config VALUES (15, 8, 'vi_controls', '[CONTROLS]');
INSERT INTO sys_csv2pg_config VALUES (16, 8, 'vi_pollutants', '[POLLUTANTS]');
INSERT INTO sys_csv2pg_config VALUES (17, 8, 'vi_landuses', '[LANDUSES]');
INSERT INTO sys_csv2pg_config VALUES (18, 8, 'vi_coverages', '[COVERAGES]');
INSERT INTO sys_csv2pg_config VALUES (19, 8, 'vi_loadings', '[LOADINGS]');
INSERT INTO sys_csv2pg_config VALUES (20, 8, 'vi_buildup', '[BUILDUP]');
INSERT INTO sys_csv2pg_config VALUES (22, 8, 'vi_treatment', '[TREATMENT]');
INSERT INTO sys_csv2pg_config VALUES (23, 8, 'vi_dwf', '[DWF]');
INSERT INTO sys_csv2pg_config VALUES (24, 8, 'vi_timeseries', '[TIMESERIES]');
INSERT INTO sys_csv2pg_config VALUES (25, 8, 'vi_patterns', '[PATTERNS]');
INSERT INTO sys_csv2pg_config VALUES (26, 8, 'vi_report', '[REPORT]');
INSERT INTO sys_csv2pg_config VALUES (21, 8, 'vi_washoff', '[WASHOFF]');
INSERT INTO sys_csv2pg_config VALUES (27, 8, 'vi_map', '[MAP]');
INSERT INTO sys_csv2pg_config VALUES (28, 8, 'vi_coordinates', '[COORDINATES]');
INSERT INTO sys_csv2pg_config VALUES (29, 8, 'vi_vertices', '[VERTICES]');
INSERT INTO sys_csv2pg_config VALUES (30, 8, 'vi_symbols', '[SYMBOLS]');
INSERT INTO sys_csv2pg_config VALUES (31, 8, 'vi_polygons', '[Polygons]');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (32, 9, 'rpt_pumping_sum', 'Pumping Summary');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (33, 9, 'rpt_arcflow_sum', 'Link Flow');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (34, 9, NULL, 'Cross Section');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (35, 9, NULL, 'Link Summary');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (36, 9, NULL, 'Node Summary');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (37, 9, NULL, 'Raingage Summary');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (38, 9, NULL, 'Subcatchment Summary');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (39, 9, 'rpt_flowrouting_cont', 'Flow Routing');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (40, 9, 'rpt_storagevol_sum', 'Storage Volume');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (41, 9, 'rpt_subcathrunoff_sum', 'Subcatchment Runoff');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (42, 9, 'rpt_outfallload_sum', 'Outfall Loading');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (43, 9, 'rpt_condsurcharge_sum', 'Conduit Surcharge');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (44, 9, 'rpt_flowclass_sum', 'Flow Classification');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (45, 9, 'rpt_nodeflooding_sum', 'Node Flooding');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (46, 9, 'rpt_nodeinflow_sum', 'Node Inflow');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (47, 9, 'rpt_nodesurcharge_sum', 'Node Surcharge');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (48, 9, 'rpt_nodedepth_sum', 'Node Depth');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (49, 9, 'rpt_routing_timestep', 'Routing Time');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (50, 9, 'rpt_high_flowinest_ind', 'Highest Flow');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (51, 9, 'rpt_timestep_critelem', 'Time-Step Critical');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (52, 9, 'rpt_high_conterrors', 'Highest Continuity');
INSERT INTO sys_csv2pg_config (id, pg2csvcat_id, tablename, header_text) VALUES (53, 9, 'rpt_runoff_quant', 'Runoff Quantity');


