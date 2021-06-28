/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/06/13
UPDATE config_form_fields SET dv_querytext = 'SELECT macrosector_id as id,name as idval FROM macrosector WHERE macrosector_id IS NOT NULL'
WHERE columnname = 'macrosector_id' AND formname = 'v_edit_inp_pump';

UPDATE inp_controls_x_arc i SET sector_id = a.sector_id FROM arc a WHERE a.arc_id = i.arc_id;
UPDATE inp_rules_x_arc i SET sector_id = a.sector_id FROM arc a WHERE a.arc_id = i.arc_id;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
VALUES ('inp_curve', 'form_feature', 'sector_id', NULL, 'integer', 'combo', 'sector_id', FALSE, FALSE,
TRUE, FALSE, 'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL ' , TRUE, TRUE,
NULL,NULL,NULL, NULL,FALSE) ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
VALUES ('inp_pattern', 'form_feature', 'sector_id', NULL, 'integer', 'combo', 'sector_id', FALSE, FALSE,
TRUE, FALSE, 'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL ' , TRUE, TRUE,
NULL,NULL,NULL, NULL,FALSE) ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
VALUES ('inp_controls_x_arc', 'form_feature', 'sector_id', NULL, 'integer', 'combo', 'sector_id', TRUE, FALSE,
TRUE, FALSE, 'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL ' , TRUE, FALSE,
NULL,NULL,NULL, NULL,FALSE) ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
VALUES ('inp_rules_x_arc', 'form_feature', 'sector_id', NULL, 'integer', 'combo', 'sector_id', TRUE, FALSE,
TRUE, FALSE, 'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL ' , TRUE, FALSE,
NULL,NULL,NULL, NULL,FALSE) ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_curve', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_curve' ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_curve_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
false, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_curve' AND columnname IN ('curve_type', 'descript', 'sector_id')
ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_curve_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_curve_value' ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_pattern', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_pattern' AND columnname not in ('pattern_type') ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_pattern_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
false, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_pattern' AND columnname not in ('pattern_type', 'pattern_id') ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_pattern_value', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_pattern_value' AND columnname not ilike '_f%' ON CONFLICT (formname, formtype, columnname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_rules', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_rules_x_arc' ON CONFLICT (formname, formtype, columnname) DO NOTHING;


INSERT INTO config_form_fields(formname, formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden)
SELECT 'v_edit_inp_inp_controls', formtype, columnname, layoutorder, datatype, widgettype, label,  ismandatory, isparent, 
iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, 
dv_parent_id, dv_querytext_filterc, widgetfunction, linkedaction,  hidden
FROM config_form_fields WHERE formname = 'inp_controls_x_arc' ON CONFLICT (formname, formtype, columnname) DO NOTHING;

