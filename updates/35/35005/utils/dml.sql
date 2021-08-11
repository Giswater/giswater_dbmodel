/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/05/11
INSERT INTO config_param_system(parameter, value, descript,  project_type, datatype, label, isenabled, dv_isparent, isautoupdate, widgettype,
ismandatory, iseditable, layoutname, layoutorder)
VALUES ('edit_arc_divide', '{"setArcObsolete":"true","setOldCode":"false"}', 
'Configuration of arc divide tool. If setArcObsolete true state of old arc would be set to 0, otherwise arc will be deleted. If setOldCode true, new arcs will have same code as old arc.',
'utils', 'json', 'Arc divide:', true, false, false, 'linetext', true, true, 'lyt_topology', 18 ) ON CONFLICT (parameter) DO NOTHING;

--2021/05/11
UPDATE man_type_location set featurecat_id=NULL WHERE featurecat_id in ('{NODE}','{CONNEC}','{ARC}','{GULLY}');
UPDATE man_type_category set featurecat_id=NULL WHERE featurecat_id in ('{NODE}','{CONNEC}','{ARC}','{GULLY}');
UPDATE man_type_function set featurecat_id=NULL WHERE featurecat_id in ('{NODE}','{CONNEC}','{ARC}','{GULLY}');
UPDATE man_type_fluid set featurecat_id=NULL WHERE featurecat_id in ('{NODE}','{CONNEC}','{ARC}','{GULLY}');


INSERT INTO sys_function (id, function_name, project_type, function_type, sys_role) 
VALUES (3034, 'gw_fct_pg2epa_autorepair_epatype', 'utils', 'function', 'role_epa') ON CONFLICT (id) DO NOTHING;

UPDATE config_toolbox SET inputparams = '[{"widgetname":"resultId", "label":"Result Id:","widgettype":"text","datatype":"text","layoutname":"grl_option_parameters","layoutorder":1,"value":"$userInpResult"}]'
WHERE id = 2680;

UPDATE config_toolbox SET inputparams = '[{"widgetname":"resultId", "label":"Result Id:","widgettype":"text","datatype":"text","layoutname":"grl_option_parameters","layoutorder":1,"value":"$userInpResult"}]'
WHERE id = 2848;

--2021/05/18
UPDATE sys_table SET notify_action=
'[{"channel":"desktop","name":"refresh_attribute_table", "enabled":"true", "trg_fields":"expl_id, name","featureType":["arc", "node", "connec","v_edit_element", "v_edit_samplepoint","v_edit_pond", "v_edit_pool", "v_edit_dma", "v_edit_presszone", "v_ext_plot","v_ext_streetaxis", "v_ext_address"]}]'
WHERE id='exploitation';

--2021/05/21
UPDATE config_form_tabs SET orderby = 5 where tabname='tab_psector' and formname='selector_basic';
UPDATE config_form_tabs SET orderby = 4 where tabname='tab_sector' and formname='selector_basic';

--2021/05/22
UPDATE sys_feature_epa_type SET active=true WHERE id = 'INLET';

--2021/05/24
DELETE FROM sys_table WHERE id IN ('vp_epa_node','vp_epa_arc');

ALTER TABLE cat_connec DROP CONSTRAINT IF EXISTS cat_connec_matcat_id_fkey;

INSERT INTO cat_mat_arc (id,descript, link, active) SELECT id,descript, link, active FROM cat_mat_node WHERE id in (select matcat_id from cat_connec) 
and id not in (select id from cat_mat_arc);

DELETE FROM cat_mat_node WHERE id in (select matcat_id from cat_connec) AND id not in (select matcat_id from cat_node);

UPDATE config_form_fields SET dv_querytext = 'SELECT id, descript AS idval FROM cat_mat_arc WHERE id IS NOT NULL' 
WHERE columnname='matcat_id' AND formname='cat_connec';

UPDATE config_form_fields SET dv_querytext = 'SELECT id, id AS idval FROM cat_mat_arc' 
WHERE columnname='matcat_id' AND formname ilike 've_connec%';

--2021/05/28
UPDATE config_form_fields set dv_querytext=concat(dv_querytext,' ')
where (formname ilike 've_arc%' or formname ilike 've_node%' or formname ilike 've_connec%' or formname ilike 've_gully%') 
and concat(dv_querytext,dv_querytext_filterc) ilike '%NULLAND%';

--2021/05/31
INSERT INTO config_form_fields(
formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, iseditable, 
isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('v_edit_exploitation', 'form_feature', 'main', 'active', null, null, 'boolean', 'check', 'active', false, false, true, 
false, false, null, null,false, null, null,null,
null,null,null,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(
formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, iseditable, 
isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('v_edit_dma', 'form_feature', 'main', 'active', null, null, 'boolean', 'check', 'active', false, false, true, 
false, false, null, null,false, null, null,null,
null,null,null,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(
formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, iseditable, 
isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('v_edit_sector', 'form_feature', 'main', 'active', null, null, 'boolean', 'check', 'active', false, false, true, 
false, false, null, null,false, null, null,null,
null,null,null,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;


INSERT INTO edit_typevalue VALUES ('value_boolean','0','FALSE');
INSERT INTO edit_typevalue VALUES ('value_boolean','1','MAYBE');
INSERT INTO edit_typevalue VALUES ('value_boolean','2','TRUE');
INSERT INTO edit_typevalue VALUES ('value_boolean','3','UNKNOWN');

INSERT INTO sys_typevalue VALUES ('edit_typevalue', 'value_boolean');