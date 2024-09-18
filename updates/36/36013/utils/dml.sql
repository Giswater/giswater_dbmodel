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


-- 17/09/2024
-- graphanalytics_check_data
UPDATE sys_fprocess SET info_msg='There are not operative valve(s) with null values on closed/broken fields.', except_msg='valves (state=1) with broken or closed with NULL values.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT n.node_id, n.nodecat_id, n.the_geom, expl_id FROM man_valve JOIN v_prefix_node n USING (node_id) WHERE n.state = 1 AND (broken IS NULL OR closed IS NULL)) a' WHERE fid=176;

UPDATE sys_fprocess SET info_msg='It seems config_graph_mincut table is well configured. At least, table is filled with nodes from all exploitations.', except_msg='rows with exploitation bad configured on the config_graph_mincut table. Please check your data before continue.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT count(*) INTO v_count FROM config_graph_mincut cgi INNER JOIN node n ON cgi.node_id = n.node_id  WHERE n.expl_id NOT IN (SELECT expl_id FROM exploitation WHERE active IS TRUE)' WHERE fid=177;

UPDATE sys_fprocess SET info_msg='All nodes with cat_feature_node.graphdelimiter=''DMA'' are defined as nodeParent on dma.graphconfig', except_msg='nodes with cat_feature_node.graph_delimiter=''DMA'' not configured on the dma table.
nodes with cat_feature_node.graph_delimiter=''DMA'' configured for unactive mapzone.', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT node_id, nodecat_id, the_geom, a.active, v_prefix_node.expl_id FROM v_prefix_node JOIN cat_node c ON id=nodecat_id JOIN cat_feature_node n ON n.id=c.nodetype_id LEFT JOIN (SELECT node_id, active FROM v_prefix_node JOIN (SELECT (json_array_elements_text((graphconfig::json->>''use'')::json))::json->>''nodeParent'' as node_id, 
  active FROM v_prefix_dma WHERE graphconfig IS NOT NULL )a USING (node_id)) a USING (node_id) WHERE graph_delimiter=''DMA'' AND (a.node_id IS NULL  OR node_id NOT IN (SELECT (json_array_elements_text((graphconfig::json->>''ignore'')::json))::text FROM v_prefix_dma WHERE active IS TRUE))  AND v_prefix_node.state > 0' WHERE fid=180;

UPDATE sys_fprocess SET info_msg='All nodes with cat_feature_node.graphdelimiter=''DMA'' are defined as nodeParent on dma.graphconfig', except_msg='node(s) with cat_feature_node.graph_delimiter=''DQA'' not configured on the dqa table.
node(s) with cat_feature_node.graph_delimiter=''DQA'' configured for unactive mapzone.', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT node_id, nodecat_id, the_geom, a.active,  v_prefix_node.expl_id FROM v_prefix_node JOIN cat_node c ON id=nodecat_id JOIN cat_feature_node n ON n.id=c.nodetype_id  LEFT JOIN (SELECT node_id, active FROM v_prefix_node JOIN (SELECT (json_array_elements_text((graphconfig::json->>''use'')::json))::json->>''nodeParent'' as node_id, 
  active FROM v_prefix_dqa WHERE graphconfig IS NOT NULL )a USING (node_id)) a USING (node_id) WHERE graph_delimiter=''DQA'' AND (a.node_id IS NULL  OR node_id NOT IN (SELECT (json_array_elements_text((graphconfig::json->>''ignore'')::json))::text FROM v_prefix_dqa WHERE active IS TRUE))  AND v_prefix_node.state > 0' WHERE fid=181;

UPDATE sys_fprocess SET info_msg='All nodes with cat_feature_node.graphdelimiter=''PRESSZONE'' are defined as nodeParent on presszone.graphconfig', except_msg='nodes with cat_feature_node.graph_delimiter=''PRESSZONE'' not configured on the presszone table.
nodes with cat_feature_node.graph_delimiter=''PRESSZONE'' configured for unactive mapzone.', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT node_id, nodecat_id, the_geom, a.active,v_prefix_node.expl_id FROM v_prefix_node JOIN cat_node c ON id=nodecat_id JOIN cat_feature_node n ON n.id=c.nodetype_id  LEFT JOIN (SELECT node_id, active FROM v_prefix_node JOIN (SELECT (json_array_elements_text((graphconfig::json->>''use'')::json))::json->>''nodeParent'' as node_id, 
  active FROM v_prefix_presszone WHERE graphconfig IS NOT NULL )a USING (node_id)) a USING (node_id) WHERE graph_delimiter=''PRESSZONE'' AND (a.node_id IS NULL  OR node_id NOT IN (SELECT (json_array_elements_text((graphconfig::json->>''ignore'')::json))::text FROM v_prefix_presszone WHERE active IS TRUE))  AND v_prefix_node.state > 0' WHERE fid=182;

UPDATE sys_fprocess SET info_msg='No nodes ''ischange'' without real change have been found.', except_msg='nodes with ischange on 1 (true) without any variation of arcs in terms of diameter, pn or material. Please, check your data before continue.', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT n.node_id, count(*), nodecat_id, the_geom, a.expl_id FROM 
			(SELECT node_1 as node_id, arccat_id, v_edit_arc.expl_id FROM v_edit_arc WHERE node_1 IN (SELECT node_id FROM v_edit_node JOIN cat_node ON id=nodecat_id WHERE ischange=1)
			  UNION
			 SELECT node_2, arccat_id, v_edit_arc.expl_id FROM v_edit_arc WHERE node_2 IN (SELECT node_id FROM v_edit_node JOIN cat_node ON id=nodecat_id WHERE ischange=1)
			GROUP BY 1,2,3) a	JOIN node n USING (node_id) GROUP BY 1,3,4,5 HAVING count(*) <> 2' WHERE fid=208;

UPDATE sys_fprocess SET info_msg='No nodes without ''ischange'' where arc changes have been found', except_msg='nodes where arc catalog changes without nodecat with ischange on 0 or 2 (false or maybe). Please, check your data before continue.', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT node_id, nodecat_id, array_agg(arccat_id) as arccat_id, the_geom, node.expl_id FROM ( SELECT count(*), node_id, arccat_id FROM   (SELECT node_1 as node_id, arccat_id FROM v_prefix_arc UNION ALL SELECT node_2, arccat_id FROM v_prefix_arc)a GROUP BY 2,3 HAVING count(*) <> 2 ORDER BY 2) b
   JOIN node USING (node_id) JOIN cat_node ON id=nodecat_id WHERE ischange=0 GROUP By 1,2,4,5 HAVING count(*)=2' WHERE fid=209;

UPDATE sys_fprocess SET info_msg='All sectors has graphconfig values not null.', except_msg='sectors on sector table with graphconfig not configured.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT * FROM v_edit_sector WHERE graphconfig IS NULL and sector_id > 0 AND active IS TRUE' WHERE fid=268;

UPDATE sys_fprocess SET info_msg='All dma has graphconfig values not null.', except_msg='dmas on dma table with graphconfig not configured.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT * FROM v_edit_dma WHERE graphconfig IS NULL and dma_id > 0  AND active IS TRUE' WHERE fid=269;

UPDATE sys_fprocess SET info_msg='All dqa has graphconfig values not null.', except_msg='dqas on dqa table with graphconfig not configured.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT * FROM v_edit_dqa WHERE graphconfig IS NULL and dqa_id > 0 AND active IS TRUE' WHERE fid=270;

UPDATE sys_fprocess SET info_msg='All presszones has graphconfig values not null.', except_msg='presszones on presszone table with graphconfig not configured.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT * FROM v_edit_presszone WHERE graphconfig IS NULL and presszone_id > 0::text AND active IS TRUE' WHERE fid=271;

UPDATE sys_fprocess SET info_msg='All arcs defined as nodeParent on v_prefix_ exists on DB.', except_msg='arcs that are configured as toArc for v_prefix_ but is not operative on arc table. Arc_id - '',  string_agg(concat(v_prefix_:,zone_id,-,a.arc_id),
nodes that are configured as nodeParent for v_prefix_ but is not operative on node table. Node_id - ,   string_agg(concat(v_prefix_:,zone_id,-,a.node_id::text),, )', except_level=2, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT b.arc_id, b.v_prefix__id as zone_id FROM (  SELECT v_prefix__id, json_array_elements_text(((json_array_elements_text((graphconfig::json->>''use'')::json))::json->>''toArc'')::json) as arc_id FROM v_prefix_rec)b   WHERE arc_id not in (select arc_id FROM arc WHERE state=1)' WHERE fid=367;

UPDATE sys_fprocess SET info_msg='All presszone_ids are numeric values.', except_msg='presszones with id that is not a numeric value.', except_level=3, function_name='{gw_fct_graphanalytics_check_data}', query_text='SELECT presszone_id FROM presszone WHERE presszone_id!=''-1'' AND presszone_id ~^\d+(\.\d+)?$ is false' WHERE fid=460;


-- gw_fct_admin_check_data
UPDATE sys_fprocess SET info_msg='All features have value on field "active"', except_msg='303: '',v_count,'' features without value on field "active" from cat_feature. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature WHERE active IS NULL;' WHERE fid=303;

UPDATE sys_fprocess SET info_msg='All features have value on field "code_autofill"', except_msg='304: '',v_count,'' features without value on field "code_autofill" from cat_feature. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature WHERE code_autofill IS NULL;' WHERE fid=304;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "num_arcs"', except_msg='305: '',v_count,'' nodes without value on field "num_arcs" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE num_arcs IS NULL;' WHERE fid=305;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "isarcdivide"', except_msg='306: '',v_count,'' nodes without value on field "isarcdivide" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE isarcdivide IS NULL;' WHERE fid=306;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "graph_delimiter"', except_msg='307: '',v_count,'' nodes without value on field "graph_delimiter" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE graph_delimiter IS NULL;' WHERE fid=307;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "isexitupperintro"', except_msg='308: '',v_count,'' nodes without value on field "isexitupperintro" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE isexitupperintro IS NULL;' WHERE fid=308;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "choose_hemisphere"', except_msg='309: '',v_count,'' nodes without value on field "choose_hemisphere" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE choose_hemisphere IS NULL;' WHERE fid=309;

UPDATE sys_fprocess SET info_msg='All nodes have value on field "isprofilesurface"', except_msg='310: '',v_count,'' nodes without value on field "isprofilesurface" from cat_feature_node. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(id,'', '')  INTO v_count,v_feature_list FROM cat_feature_node WHERE isprofilesurface IS NULL;' WHERE fid=310;

UPDATE sys_fprocess SET info_msg=NULL, except_msg='View '',rec.child_layer,'' has wrongly defined man_table''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT * FROM cat_feature WHERE active IS TRUE AND id <> ''''LINK'''';' WHERE fid=311;

UPDATE sys_fprocess SET info_msg=NULL, except_msg='actives addfields that may not be present on the view '',rec.child_layer,''. Addfields: '',v_param_list::text,''.''', except_level=2, function_name='{gw_fct_admin_check_data}', query_text='SELECT * FROM cat_feature WHERE active IS TRUE AND id <> ''''LINK'''';' WHERE fid=312;

UPDATE sys_fprocess SET info_msg=NULL, except_msg='View '',rec.child_layer,'' is defined in cat_feature table but is not created in a DB''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT * FROM cat_feature WHERE active IS TRUE AND id <> ''''LINK'''';' WHERE fid=313;

UPDATE sys_fprocess SET info_msg='All active features have child view name in cat_feature table', except_msg='314: '',v_count,'' active features which views names are not present in cat_feature table. Features - '',v_feature_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*),string_agg(id,'','')  INTO v_count,v_feature_list FROM cat_feature WHERE active IS TRUE AND child_layer IS NULL;' WHERE fid=314;

UPDATE sys_fprocess SET info_msg='All active features have child view defined in config_info_layer_x_type', except_msg='315: '',v_count,'' active features which views are not defined in config_info_layer_x_type. Undefined views: '',v_view_list::text,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(id), string_agg(child_layer,'','')  INTO v_count,v_view_list FROM cat_feature WHERE active IS TRUE AND child_layer not in (select tableinfo_id FROM config_info_layer_x_type);' WHERE fid=315;

UPDATE sys_fprocess SET info_msg='All active features have child view defined in config_form_fields', except_msg='ERRO-316: '',v_count,'' active features which views are not defined in config_form_fields. Undefined views: '',v_view_list,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(id), string_agg(child_layer,'','')  INTO v_count,v_view_list FROM cat_feature WHERE active IS TRUE AND child_layer not in (select formname FROM config_form_fields);' WHERE fid=316;

UPDATE sys_fprocess SET info_msg=NULL, except_msg='View '',rec.table_name,'' is defined in a DB but is not related to any feature in cat_feature.''', except_level=2, function_name='{gw_fct_admin_check_data}', query_text='select string_agg(child_layer,'','') FROM cat_feature where child_layer IS NOT NULL' WHERE fid=317;

UPDATE sys_fprocess SET info_msg='All feature form fields have defined data type.', except_msg='318: '',v_count,'' feature form fields in config_form_fields that don''''t have data type. Fields: '',v_view_list,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(concat(formname,''.'',columnname),'','') INTO v_count, v_view_list FROM config_form_fields WHERE datatype IS NULL AND formtype=''feature'';' WHERE fid=318;

UPDATE sys_fprocess SET info_msg='All feature form fields have defined widget type.', except_msg='319: '',v_count,'' feature form fields in config_form_fields that don''''t have widget type. Fields: '',v_view_list,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(concat(formname,''.'',columnname),'','') INTO v_count, v_view_list FROM config_form_fields WHERE widgettype IS NULL AND formtype=''feature'';' WHERE fid=319;

UPDATE sys_fprocess SET info_msg='All feature form fields with widget type combo or typeahead have dv_querytext defined.', except_msg='320: '',v_count,'' feature form fields in config_form_fields that are combo or typeahead but don''''t have dv_querytext defined. Fields: '',v_view_list,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(concat(formname,''.'',columnname),'','') INTO v_count, v_view_list  FROM config_form_fields WHERE (widgettype = ''combo'' or widgettype =''typeahead'') and dv_querytext is null and columnname !=''composer'';' WHERE fid=320;

UPDATE sys_fprocess SET info_msg='All addfields are defined in config_form_fields.', except_msg='321: '',v_count,'' addfields that are not defined in config_form_fields. Addfields: '',v_view_list,''.''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT count(*), string_agg(concat(child_layer,'': '',param_name),'','') INTO v_count, v_view_list FROM sys_addfields JOIN cat_feature ON cat_feature.id=sys_addfields.cat_feature_id WHERE sys_addfields.active IS TRUE AND param_name not IN (SELECT columnname FROM config_form_fields JOIN cat_feature ON cat_feature.child_layer=formname);' WHERE fid=321;

UPDATE sys_fprocess SET info_msg='All fields defined in config_form_fields have unduplicated order.', except_msg='322: form names with duplicated layout order defined in config_form_fields: ''', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='SELECT array_agg(a.list::text) into v_field_array FROM (SELECT concat(''Formname: '',formname, '', layoutname: '',layoutname, '', layoutorder: '',layoutorder) as list FROM config_form_fields WHERE formtype = ''feature'' AND hidden is false group by layoutorder,formname,layoutname having count(*)>1)a;' WHERE fid=322;

UPDATE sys_fprocess SET info_msg='Configuration of cat_manager and config_user_x_expl is consistent.', except_msg='"472: '''',''||v_count||'','''' inconsistent configurations on cat_manager and config_user_x_expl for user: '''',string_agg(DISTINCT usern,'''', '''')),''||v_count||'' FROM ''||v_querytext||'';''"', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='(WITH exploit AS (SELECT COALESCE(m.rolname, s.rolname) AS usern, id FROM ( SELECT id, unnest(rolename) AS role FROM cat_manager WHERE expl_id IS NOT NULL  ) q LEFT JOIN pg_roles r ON q.role = r.rolname LEFT JOIN pg_auth_members am ON r.oid = am.roleid  LEFT JOIN pg_roles m ON am.member = m.oid AND m.rolcanlogin = TRUE  LEFT JOIN pg_roles s ON q.role = s.rolname AND s.rolcanlogin = TRUE WHERE (m.rolcanlogin IS TRUE OR s.rolcanlogin IS TRUE)  )  SELECT *, CONCAT(explots, ''''-'''', usern, ''''-'''', id) FROM (    SELECT id, unnest(expl_id) explots, usern FROM cat_manager   JOIN exploit using(id)) a    WHERE CONCAT(explots, ''''-'''', usern, ''''-'''', id) NOT IN   (SELECT CONCAT(expl_id, ''''-'''', username, ''''-'''', manager_id) FROM config_user_x_expl cuxe) AND explots != 0   ) a' WHERE fid=472;

UPDATE sys_fprocess SET info_msg='Configuration of cat_manager and config_user_x_sector is consistent.', except_msg='"473: '''',''||v_count||'','''' inconsistent configurations on cat_manager and config_user_x_sector for user: '''',string_agg(DISTINCT usern,'''', '''')), ''||v_count||'' FROM ''||v_querytext||'';''"', except_level=3, function_name='{gw_fct_admin_check_data}', query_text='"( WITH sectores AS (    SELECT COALESCE(m.rolname, s.rolname) AS usern,  id  FROM (     SELECT id, unnest(rolename) AS role FROM cat_manager     WHERE sector_id IS NOT NULL    ) q    LEFT JOIN pg_roles r ON q.role = r.rolname    LEFT JOIN pg_auth_members am ON r.oid = am.roleid    LEFT JOIN pg_roles m ON am.member = m.oid AND m.rolcanlogin = TRUE LEFT JOIN pg_roles s ON q.role = s.rolname AND s.rolcanlogin = TRUE    WHERE (m.rolcanlogin IS TRUE OR s.rolcanlogin IS TRUE)   )   SELECT *, CONCAT(sectors, ''''-'''', usern, ''''-'''', id) FROM (    SELECT id, unnest(sector_id) sectors, usern FROM cat_manager    JOIN sectores using(id)) a    WHERE CONCAT(sectors, ''''-'''', usern, ''''-'''', id) NOT IN (SELECT CONCAT(sector_id, ''''-'''', username, ''''-'''', manager_id) FROM config_user_x_sector cuxe) AND sectors NOT IN (0, -1)   ) a"' WHERE fid=473;
