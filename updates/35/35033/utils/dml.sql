/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO config_param_system(parameter, value, descript, 
label,  isenabled,  project_type, datatype, widgettype, ismandatory, iseditable)
VALUES ('edit_review_auto_field_checked', 'false', 'If true, at saving review data it would be automatically set as finished.',
'Review automatic field check:',
false, 'utils', 'boolean', 'check', false,true);

INSERT INTO sys_function(id, function_name, project_type, function_type, descript, sys_role,  source)
VALUES (3194, 'gw_fct_infofromid', 'utils', 'function', 'Function that works internally with gw_fct_getinfofromid', 'role_basic', 'core') ON CONFLICT (id) DO NOTHING;

ALTER TABLE arc ALTER COLUMN state_type SET NOT NULL;

INSERT INTO sys_function (id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source") 
VALUES(3198, 'gw_fct_setclosestaddress', 'utils', 'function', NULL, NULL, 'Function to capture automatically closest address from every node/connec.
- Type: choose if you want to update all node/connec or just a specific type of them.
- Field to update: possible fields to update are postnumber(integer) and postcomplement(text). The most usual is postnumber, but if address number is not numeric, then you will need to update postcomplement.
- Search buffer: maximum distance to look for an address from the point.
- Elements to update: if you dont''t want to update all elements, choose to only update the ones where streetaxis_id, postnumber or postcomplement is null.', 'role_edit', NULL, 'core');

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam) 
VALUES(486, 'Get address values from closest street number', 'utils', NULL, 'core', false, 'Function process', NULL);

UPDATE sys_fprocess SET project_type = 'utils', source = 'core', fprocess_type = 'Function process' WHERE fid = 432;

UPDATE sys_function set function_name = 'gw_trg_feature_border' WHERE id = 3190;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, 
datatype, widgettype, label, tooltip,  ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_isnullvalue, hidden)
SELECT  'v_edit_arc','form_feature', 'data', 'parent_id', 'lyt_data_1', max(layoutorder)+1, 'string', 'typeahead', 'parent_id', 'parent_id - Identificador de su nodo pariente. Un nodo padre puede tener varios otros nodos contenidos dentro de él',
false, false,true,false,false, 'SELECT node_id AS id, node_id AS idval FROM node WHERE node_id IS NOT NULL', true, true
FROM config_form_fields where formname = 'v_edit_node' and layoutname = 'lyt_data_1'
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, 
datatype, widgettype, label, tooltip,  ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_isnullvalue, hidden)
select 've_arc','form_feature', 'data', 'parent_id', 'lyt_data_1', max(layoutorder)+1, 'string', 'typeahead', 'parent_id', 'parent_id - Identificador de su nodo pariente. Un nodo padre puede tener varios otros nodos contenidos dentro de él',
false, false,true,false,false, 'SELECT node_id AS id, node_id AS idval FROM node WHERE node_id IS NOT NULL', true, true
FROM config_form_fields where formname = 've_node' and layoutname = 'lyt_data_1'
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, 
datatype, widgettype, label, tooltip,  ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,  hidden)
SELECT distinct child_layer,formtype, tabname, columnname, layoutname, max(layoutorder)+1, datatype, widgettype, label, tooltip,  ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, hidden
FROM config_form_fields, cat_feature
WHERE feature_type = 'ARC' AND  (formname ilike 'v_edit_node' and columnname = 'parent_id')  group by child_layer,formtype, tabname, columnname, layoutname,
datatype, widgettype, label, tooltip,  ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,  hidden 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO sys_table(id, descript, sys_role, source)
VALUES ('v_sector_node', 'View that filter nodes by sector', 'role_basic', 'core');

INSERT INTO sys_table(id, descript, sys_role, source)
VALUES ('node_border_sector', 'Table that stores relation between node and it''s additional sectors.', 'role_basic', 'core');


UPDATE config_form_tabs
	SET tabactions='[{"actionName":"actionEdit", "disabled":false},
{"actionName":"actionZoom", "disabled":false},
{"actionName":"actionCentered", "disabled":false},
{"actionName":"actionZoomOut", "disabled":false},
{"actionName":"actionCatalog", "disabled":false},
{"actionName":"actionWorkcat", "disabled":false},
{"actionName":"actionCopyPaste","disabled":false},
{"actionName":"actionSection", "disabled":false},
{"actionName":"actionGetParentId", "disabled":false},
{"actionName":"actionLink",  "disabled":false}]'::json
	WHERE formname='v_edit_arc' AND device=4;



INSERT INTO config_typevalue (typevalue,id,idval,camelstyle)
VALUES ('formtemplate_typevalue','element','element','element');

INSERT INTO config_info_layer (layer_id, is_parent, tableparent_id, is_editable, formtemplate, headertext, orderby, tableparentepa_id, addparam) 
VALUES('v_edit_element', false, NULL, true, 'element', 'Element', 6, NULL, '{"forceWhenActive":true}'::json);

INSERT INTO sys_message(id, error_message, hint_message, log_level, show_user, project_type, "source")
VALUES(3228, 'It is not possible to insert arc into psector because has operative connects associated', 'You need to previously insert related connects into psector', 2, true, 'utils', 'core') ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_param_user VALUES('edit_plan_order_control', 'dynamic', 'To manage if plan order control is executed or not. On some automatic processes is set to FALSE, on manual process is TRUE', 'role_edit', NULL, NULL, NULL, NULL, true, NULL, 'utils', false, NULL, NULL, NULL, false, 'boolean', NULL, true, NULL, 'true', NULL, NULL, NULL, NULL, NULL, NULL, 'core');

INSERT INTO sys_function
(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source")
VALUES(3200, 'gw_trg_arc_node_values', 'ws', 'function trigger', NULL, NULL, 'Trigger that updates arc node related values such as type, elevation, depth', 'role_edit', NULL, 'core') ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_function
(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source")
VALUES(3202, 'gw_trg_arc_node_values', 'ud', 'function trigger', NULL, NULL, 'Trigger that updates arc node related values such as type, elevation, depth', 'role_edit', NULL, 'core') ON CONFLICT (id) DO NOTHING;

INSERT INTO edit_typevalue (typevalue, id, idval)
VALUES ('value_review_status', 4, 'Only review observations') ON CONFLICT  (typevalue, id) DO NOTHING;

INSERT INTO sys_function (id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source")
VALUES(3204, 'gw_fct_config_feature_border', 'utils', 'function', NULL, NULL, 'Function that configures nodes located on sector and exploitation border', 'role_master', NULL, 'core') ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam) 
VALUES(487, 'Configuration of border nodes', 'utils', NULL, 'core', false, 'Function process', NULL);

INSERT INTO config_toolbox (id, alias, functionparams, inputparams, observ, active) VALUES (3204, 'Configuration of border nodes', '{"featureType":[]}', null, NULL, false);

INSERT INTO sys_table(id, descript, sys_role, source)
VALUES ('arc_border_expl', 'Table that stores relation between arc and it''s additional exploitation.', 'role_basic', 'core');