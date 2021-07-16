/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/06/21

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('cat_arc','form_feature', 'main', 'pnom',null,null,'double', 'text','pnom',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('cat_arc','form_feature', 'main', 'dnom',null,null,'double', 'text','dnom',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('cat_arc','form_feature', 'main', 'dint',null,null,'double', 'text','dint',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('cat_arc','form_feature', 'main', 'dext',null,null,'double', 'text','dext',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

--2021/06/28
INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden, tabname)
VALUES ('inp_pattern', 'form_feature', 'sector_id', NULL, 'integer', 'combo', 'sector_id', FALSE, FALSE,
TRUE, FALSE, 'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL ' , TRUE, TRUE,
NULL,NULL,NULL, NULL,FALSE,'main') ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden,tabname)
SELECT 'v_edit_inp_pattern', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden,tabname
FROM config_form_fields WHERE formname = 'inp_pattern' AND columnname not in ('pattern_type') 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden,tabname)
SELECT 'v_edit_inp_pattern_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
FALSE, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden,tabname
FROM config_form_fields WHERE formname = 'inp_pattern' AND columnname not in ('pattern_type', 'pattern_id') 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden,tabname)
SELECT 'v_edit_inp_pattern_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden, tabname
FROM config_form_fields WHERE formname = 'inp_pattern_value' AND columnname not ilike '_f%' 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden, tabname)
SELECT 'v_edit_inp_rules', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedobject,  hidden, tabname
FROM config_form_fields WHERE formname = 'inp_rules' ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

--2021/06/30
UPDATE sys_table SET notify_action =
'[{"channel":"desktop","name":"refresh_attribute_table", "enabled":"true", "trg_fields":"pattern_id","featureType":["inp_pump_additional", "inp_source", "inp_pattern_value", "v_edit_inp_demand","v_edit_inp_pump","v_edit_inp_reservoir","v_edit_inp_junction","v_edit_inp_connec","v_edit_inp_pattern_value"]}]'
WHERE id ='inp_pattern';

UPDATE sys_table SET notify_action =
'[{"channel":"desktop","name":"refresh_attribute_table", "enabled":"true", "trg_fields":"id","featureType":["inp_pump_additional", "inp_curve","inp_curve_value","v_edit_inp_valve","v_edit_inp_tank","v_edit_inp_pump","v_edit_inp_curve_value"]}]'
WHERE id ='inp_curve';

--2021/07/13
INSERT INTO sys_table(id, descript, sys_role, sys_criticity)
VALUES ('arc_add', 'Table for additional, uneditable fields related to feature','role_edit', 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_table(id, descript, sys_role, sys_criticity)
VALUES ('node_add', 'Table for additional, uneditable fields related to feature','role_edit', 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_table(id, descript, sys_role, sys_criticity)
VALUES ('connec_add', 'Table for additional, uneditable fields related to feature','role_edit', 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('v_edit_inp_junction','form_feature', 'main', 'peak_factor',null,null,'double', 'text','peak_factor',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id,dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, 
widgetcontrols, widgetfunction, linkedobject, hidden)
VALUES ('v_edit_inp_connec','form_feature', 'main', 'peak_factor',null,null,'double', 'text','peak_factor',null, false,
false, true, false, null, null, null,null, null, null, null,null, null, null, false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;
