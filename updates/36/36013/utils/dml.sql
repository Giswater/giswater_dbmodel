/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

DELETE FROM config_form_fields WHERE formname='visit_arc_leak' AND formtype='form_visit' AND columnname='visit_id' AND tabname='tab_data';
DELETE FROM config_form_fields WHERE formname='visit_node_insp' AND formtype='form_visit' AND columnname='visit_id' AND tabname='tab_data';
DELETE FROM config_form_fields WHERE formname='incident_node' AND formtype='form_visit' AND columnname='visit_id' AND tabname='tab_data';

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
    VALUES('generic', 'form_visit', 'tab_data', 'visit_id', 'lyt_data_1', NULL, 'double', 'text', 'Visit id:', NULL, NULL, false, false, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, 1);

UPDATE config_form_fields SET web_layoutorder=2 WHERE formname='visit_connec_leak' AND formtype='form_visit' AND columnname='class_id' AND tabname='tab_data';
UPDATE config_form_fields SET web_layoutorder=2 WHERE formname='incident_node' AND formtype='form_visit' AND columnname='class_id' AND tabname='tab_data';
UPDATE config_form_fields SET web_layoutorder=2 WHERE formname='visit_arc_leak' AND formtype='form_visit' AND columnname='class_id' AND tabname='tab_data';
UPDATE config_form_fields SET web_layoutorder=2 WHERE formname='visit_node_insp' AND formtype='form_visit' AND columnname='class_id' AND tabname='tab_data';


INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES ('layout_name_typevalue', 'lyt_main_1', 'lyt_main_1', 'layoutMain1', '{"lytOrientation":"vertical"}');
INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES ('layout_name_typevalue', 'lyt_main_2', 'lyt_main_2', 'layoutMain2', NULL);
INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES ('layout_name_typevalue', 'lyt_main_3', 'lyt_main_3', 'layoutMain3', NULL);
INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES ('formtype_typevalue', 'form_featuretype_change', 'form_featuretype_change', 'formFeaturetypeChange', NULL);

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'btn_accept', 'lyt_buttons', 2, NULL, 'button', NULL, NULL, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"text": "Accept"}'::json, '{"functionName": "btn_accept_featuretype_change", "module": "featuretype_change_button", "parameters": {}}'::json, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'spacer', 'lyt_buttons', 1, NULL, 'hspacer', NULL, NULL, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'btn_cancel', 'lyt_buttons', 3, NULL, 'button', NULL, NULL, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"text": "Cancel"}'::json, '{"functionName": "btn_cancel_featuretype_change", "module": "featuretype_change_button", "parameters": {}}'::json, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'btn_catalog', 'lyt_main_2', 3, NULL, 'button', NULL, NULL, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, '{"icon": "195", "size": "20x20"}'::json, NULL, '{"functionName": "btn_catalog_featuretype_change", "module": "featuretype_change_button", "parameters": {}}'::json, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'feature_type', 'lyt_main_1', 1, 'string', 'text', 'Current feature type', 'Current feature type', NULL, FALSE, FALSE, FALSE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'feature_type_new', 'lyt_main_1', 1, 'string', 'combo', 'New feature type', 'New feature type', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"functionName": "cmb_new_featuretype_selection_changed", "module": "featuretype_change_button", "parameters": {}}'::json, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'featurecat_id', 'lyt_main_2', 1, 'string', 'combo', 'Catalog id', 'Catalog id', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'fluid_type', 'lyt_main_3', 1, 'string', 'combo', 'Fluid', 'Fluid', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"labelPosition": "top"}'::json, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'location_type', 'lyt_main_3', 2, 'string', 'combo', 'Location', 'Location', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"labelPosition": "top"}'::json, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'category_type', 'lyt_main_3', 3, 'string', 'combo', 'Category', 'Category', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"labelPosition": "top"}'::json, NULL, NULL, FALSE, NULL);
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) VALUES ('generic', 'form_featuretype_change', 'tab_none', 'function_type', 'lyt_main_3', 4, 'string', 'combo', 'Function', 'Function', NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{"labelPosition": "top"}'::json, NULL, NULL, FALSE, NULL);

INSERT INTO sys_function (id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source") VALUES (3324, 'gw_fct_getfeaturereplace', 'utils', 'function', 'json', 'json', 'Function to get feature type change dialog', 'role_edit', NULL, 'core');

UPDATE sys_fprocess SET query_text='SELECT arc_id,arccat_id,the_geom, expl_id FROM v_prefix_arc 
WHERE state = 1 AND node_1 IS NULL UNION SELECT arc_id, arccat_id, the_geom, expl_id FROM v_prefix_arc WHERE state = 1 AND node_2 IS NULL', 
function_name='{gw_fct_om_check_data}', except_level=2, except_msg='arcs without node_1 or node_2', except_msg_feature=NULL WHERE fid=103;

UPDATE sys_fprocess SET query_text='SELECT a.arc_id, arccat_id, a.the_geom, expl_id FROM arc a WHERE sys_slope < 0 AND state > 0 AND inverted_slope IS FALSE', 
function_name='{gw_fct_om_check_data}', except_level=1, except_msg='arcs with inverted slope false and slope negative values. Please, check your data before continue', 
except_msg_feature=NULL WHERE fid=251;

UPDATE sys_fprocess SET query_text='SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM v_prefix_arc a 
JOIN v_prefix_node n ON node_1=node_id WHERE a.state =1 AND n.state=0 UNION
SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM v_prefix_arc a JOIN v_prefix_node n ON node_2=node_id WHERE a.state =1 AND n.state=0', 
function_name='{gw_fct_om_check_data}', except_level=1, except_msg='arcs with state=1 using extremals nodes with state = 0. Please, check your data before continue', 
except_msg_feature=NULL WHERE fid=196;

UPDATE sys_fprocess SET query_text='SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM v_prefix_arc a JOIN v_prefix_node n ON node_1=node_id 
WHERE a.state =1 AND n.state=2 UNION
SELECT a.arc_id, arccat_id, a.the_geom, a.expl_id FROM v_prefix_arc a JOIN v_prefix_node n ON node_2=node_id WHERE a.state =1 AND n.state=2', 
function_name='{gw_fct_om_check_data}', except_level=1, except_msg='arcs with state=1 using extremals nodes with state = 2. Please, check your data before continue', 
except_msg_feature=NULL WHERE fid=197;

UPDATE sys_fprocess SET query_text='SELECT arc_id,arccat_id,the_geom, expl_id FROM v_prefix_arc 
WHERE state = 1 AND node_1 IS NULL UNION SELECT arc_id, arccat_id, the_geom, expl_id FROM v_prefix_arc WHERE state = 1 AND node_2 IS NULL', 
function_name='{gw_fct_om_check_data}', except_level=2, except_msg='arcs without node_1 or node_2', 
except_msg_feature=NULL WHERE fid=103;

UPDATE sys_fprocess SET query_text='SELECT arc_id FROM v_prefix_arc WHERE state > 0 AND state_type IS NULL 
UNION SELECT node_id FROM v_prefix_node WHERE state > 0 AND state_type IS NULL', function_name='{gw_fct_om_check_data}', 
except_level=1, except_msg='features (arc, node) with state_type NULL values found.', 
except_msg_feature='multiple tables' WHERE fid=175;

UPDATE sys_fprocess SET query_text='SELECT node_id, nodecat_id, the_geom, n.expl_id FROM v_prefix_node n JOIN value_state_type s ON id=state_type 
WHERE n.state > 0 AND s.is_operative IS FALSE AND verified <>''2''', function_name='{gw_fct_om_check_data}', 
except_level=2, except_msg='nodes with state > 0 and state_type.is_operative on FALSE', 
except_msg_feature=NULL WHERE fid=187;

UPDATE sys_fprocess SET query_text='SELECT arc_id, arccat_id, the_geom, a.expl_id FROM v_prefix_arc a JOIN value_state_type s ON id=state_type 
WHERE a.state > 0 AND s.is_operative IS FALSE AND verified <>''2''', function_name='{gw_fct_om_check_data}', except_level=2, 
except_msg='arcs with state > 0 and state_type.is_operative on FALSE', 
except_msg_feature=NULL WHERE fid=188;

UPDATE sys_fprocess SET query_text='SELECT node_id, nodecat_id, the_geom FROM v_prefix_node 
JOIN cat_node ON nodecat_id=cat_node.id
JOIN cat_feature ON cat_node.nodetype_id = cat_feature.id
JOIN value_state_type ON state_type = value_state_type.id
WHERE value_state_type.is_operative IS TRUE AND system_id = ''TANK'' and node_id NOT IN 
(SELECT node_id FROM config_graph_mincut WHERE active IS TRUE)', function_name='{gw_fct_om_check_data}', except_level=1, 
except_msg='tanks which are not defined on config_graph_mincut', 
except_msg_feature=NULL WHERE fid=177;