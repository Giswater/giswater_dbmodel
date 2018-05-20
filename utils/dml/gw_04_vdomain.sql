/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;



------------------------------
--sys_combo
------------------------------

INSERT INTO sys_combo_cat VALUES (1, NULL);
INSERT INTO sys_combo_cat VALUES (2, NULL);
INSERT INTO sys_combo_cat VALUES (3, NULL);


INSERT INTO sys_combo_values VALUES (1, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (1, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (1, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (1, 4, 'combo4', NULL);
INSERT INTO sys_combo_values VALUES (1, 5, 'combo5', NULL);
INSERT INTO sys_combo_values VALUES (2, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (2, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (2, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (3, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (3, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (3, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (3, 4, 'combo4', NULL);



--------------------------
--sys_api
--------------------------

INSERT INTO sys_api_cat_datatype VALUES (1, 2, 'double');
INSERT INTO sys_api_cat_datatype VALUES (2, 2, 'string');
INSERT INTO sys_api_cat_datatype VALUES (3, 2, 'date');
INSERT INTO sys_api_cat_datatype VALUES (4, 2, 'boolean');
INSERT INTO sys_api_cat_datatype VALUES (5, 2, 'double');
INSERT INTO sys_api_cat_datatype VALUES (1, 1, 'integer');
INSERT INTO sys_api_cat_datatype VALUES (2, 1, 'text');
INSERT INTO sys_api_cat_datatype VALUES (3, 1, 'date');
INSERT INTO sys_api_cat_datatype VALUES (4, 1, 'boolean');
INSERT INTO sys_api_cat_datatype VALUES (5, 1, 'numeric');


INSERT INTO sys_api_cat_widgettype VALUES (1, 1, 'QLineEdit');
INSERT INTO sys_api_cat_widgettype VALUES (2, 1, 'QComboBox');
INSERT INTO sys_api_cat_widgettype VALUES (3, 1, 'QCheckBox');
INSERT INTO sys_api_cat_widgettype VALUES (4, 1, 'QDateEdit');
INSERT INTO sys_api_cat_widgettype VALUES (5, 1, 'QDateTimeEdit');
INSERT INTO sys_api_cat_widgettype VALUES (6, 1, 'QTextEdit');
INSERT INTO sys_api_cat_widgettype VALUES (1, 2, 'text');
INSERT INTO sys_api_cat_widgettype VALUES (2, 2, 'combo');
INSERT INTO sys_api_cat_widgettype VALUES (3, 2, 'checkbox');
INSERT INTO sys_api_cat_widgettype VALUES (4, 2, 'date');
INSERT INTO sys_api_cat_widgettype VALUES (5, 2, 'date');
INSERT INTO sys_api_cat_widgettype VALUES (6, 2, 'textarea');









INSERT INTO sys_api_cat_formtab VALUES (1, 'tabConnect');
INSERT INTO sys_api_cat_formtab VALUES (2, 'tabRelations');
INSERT INTO sys_api_cat_formtab VALUES (3, 'tabDoc');
INSERT INTO sys_api_cat_formtab VALUES (4, 'tabElement');
INSERT INTO sys_api_cat_formtab VALUES (5, 'tabVisit');
INSERT INTO sys_api_cat_formtab VALUES (6, 'tabHydro');
INSERT INTO sys_api_cat_formtab VALUES (7, 'tabMincut');
INSERT INTO sys_api_cat_formtab VALUES (8, 'tabCost');

/*
INSERT INTO sys_api_cat_form VALUES (11, 'custom_form','F11', 'INFO_UD_NODE');
INSERT INTO sys_api_cat_form VALUES (12, 'custom_form','F12', 'INFO_WS_NODE');
INSERT INTO sys_api_cat_form VALUES (13, 'custom_form','F13', 'INFO_UTILS_ARC');
INSERT INTO sys_api_cat_form VALUES (14, 'custom_form','F14', 'INFO_UTILS_CONNEC');
INSERT INTO sys_api_cat_form VALUES (15, 'custom_form','F15', 'INFO_UD_GULLY');
INSERT INTO sys_api_cat_form VALUES (16, 'custom_form','F16', 'GENERIC');
INSERT INTO sys_api_cat_form VALUES (21, NULL, 'F21', 'VISIT');
INSERT INTO sys_api_cat_form VALUES (22, NULL, 'F22', 'VISIT_EVENT_STANDARD');
INSERT INTO sys_api_cat_form VALUES (23, NULL, 'F23', 'VISIT_EVENT_UD_ARC_STANDARD');
INSERT INTO sys_api_cat_form VALUES (24, NULL, 'F24', 'VISIT_EVENT_UD_ARC_REHABIT');
INSERT INTO sys_api_cat_form VALUES (25, NULL, 'F25', 'VISIT_MANAGER');
INSERT INTO sys_api_cat_form VALUES (26, NULL, 'F26', 'ADD_MULTIPLE_VISIT');
INSERT INTO sys_api_cat_form VALUES (27, NULL, 'F27', 'GALLERY');
INSERT INTO sys_api_cat_form VALUES (31, NULL, 'F31', 'SEARCH');
INSERT INTO sys_api_cat_form VALUES (32, NULL, 'F32', 'PRINT');
INSERT INTO sys_api_cat_form VALUES (33, NULL, 'F33', 'FILTER');
INSERT INTO sys_api_cat_form VALUES (41, NULL, 'F41', 'MINCUT_NEW');
INSERT INTO sys_api_cat_form VALUES (42, NULL, 'F42', 'MINCUT_ADD_CONNEC');
INSERT INTO sys_api_cat_form VALUES (43, NULL, 'F43', 'MINCUT_ADD_HYDROMETER');
INSERT INTO sys_api_cat_form VALUES (44, NULL, 'F44', 'MINCUT_END');
INSERT INTO sys_api_cat_form VALUES (45, NULL, 'F45', 'MINCUT_MANAGEMENT');

*/


	
------------------------------------
--man_addfields_parameter
------------------------------------

INSERT INTO man_addfields_parameter VALUES (3, 'bpregister_param_1', 'BYPASS-REGISTER');
INSERT INTO man_addfields_parameter VALUES (4, 'bpregister_param_2', 'BYPASS-REGISTER');
INSERT INTO man_addfields_parameter VALUES (5, 'valregister_param_1', 'VALVE-REGISTER');
INSERT INTO man_addfields_parameter VALUES (6, 'valregister_param_2', 'VALVE-REGISTER');
INSERT INTO man_addfields_parameter VALUES (22, 'shtvalve_param_1', 'SHUTOFF-VALVE');
INSERT INTO man_addfields_parameter VALUES (23, 'shtvalve_param_2', 'SHUTOFF-VALVE');
INSERT INTO man_addfields_parameter VALUES (11, 'outfallvalve_param_1', 'OUTFALL-VALVE');
INSERT INTO man_addfields_parameter VALUES (12, 'outfallvalve_param_2', 'OUTFALL-VALVE');
INSERT INTO man_addfields_parameter VALUES (24, 'greenvalve_param_1', 'GREEN-VALVE');
INSERT INTO man_addfields_parameter VALUES (25, 'greenvalve_param_2', 'GREEN-VALVE');
INSERT INTO man_addfields_parameter VALUES (47, 'checkvalve_param_1', 'CHECK-VALVE');
INSERT INTO man_addfields_parameter VALUES (48, 'checkvalve_param_2', 'CHECK-VALVE');
INSERT INTO man_addfields_parameter VALUES (26, 'airvalve_param_1', 'AIR-VALVE');
INSERT INTO man_addfields_parameter VALUES (27, 'airvalve_param_2', 'AIR-VALVE');
INSERT INTO man_addfields_parameter VALUES (35, 'prbkvalve_param_1', 'PR-BREAK.VALVE');
INSERT INTO man_addfields_parameter VALUES (36, 'prbkvalve_param_2', 'PR-BREAK.VALVE');
INSERT INTO man_addfields_parameter VALUES (28, 'ctrlregister_param_1', 'CONTROL-REGISTER');
INSERT INTO man_addfields_parameter VALUES (29, 'ctrlregister_param_2', 'CONTROL-REGISTER');




-------------------------------
--config_api_layer_field
----------------------------

INSERT INTO "SCHEMA_NAME".config_api_layer_field (table_id, column_id, ismandatory, sys_api_cat_datatype_id, field_length, num_decimals, 
placeholder, form_label, sys_api_cat_widgettype_id, orderby, layout_id, layout_order, iseditable)
SELECT  
tables.table_name, 
column_name, 
(CASE WHEN is_nullable='YES' THEN FALSE ELSE TRUE END),
(CASE WHEN udt_name='varchar' THEN 2 WHEN udt_name='text' THEN 2 WHEN udt_name='bool' THEN 4 WHEN udt_name='numeric' THEN 5
 WHEN udt_name='int2' THEN 1 WHEN udt_name='int4' THEN 1 WHEN udt_name='int8' THEN 1 WHEN udt_name='date' THEN 3 END),
numeric_precision,
numeric_scale,
concat('Ex.:',column_name),
column_name,
(CASE WHEN udt_name='varchar' THEN 1 WHEN udt_name='text' THEN 1 WHEN udt_name='bool' THEN 3 WHEN udt_name='numeric' THEN 1
 WHEN udt_name='int2' THEN 1 WHEN udt_name='int4' THEN 1 WHEN udt_name='int8' THEN 1 WHEN udt_name='date' THEN 4 END),
ordinal_position,
1,
ordinal_position,
true
FROM information_schema.columns, information_schema.tables
	WHERE tables.table_schema='SCHEMA_NAME' 
	AND columns.table_name=tables.table_name and columns.table_schema=tables.table_schema 
	AND tables.table_name in (select distinct table_name FROM information_schema.columns where table_schema='SCHEMA_NAME')
	--AND tables.table_name= 'TABLENAME'
	AND udt_name!='geometry';
	
	

update SCHEMA_NAME.config_api_layer_field set dv_table='cat_node', dv_id_column='id', dv_name_column='id' , sys_api_cat_widgettype_id=2 WHERE column_id='nodecat_id';	

	
	
