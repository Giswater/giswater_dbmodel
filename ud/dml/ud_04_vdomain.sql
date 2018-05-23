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