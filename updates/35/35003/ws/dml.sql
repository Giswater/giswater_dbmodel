/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/02/27
UPDATE sys_feature_epa_type SET active = true;
UPDATE sys_feature_epa_type SET active = false WHERE id IN('PUMP-IMPORTINP','VALVE-IMPORTINP', 'INLET');

UPDATE config_form_fields SET dv_querytext = 'SELECT id, id as idval FROM sys_feature_epa_type WHERE active AND feature_type = ''ARC'''  WHERE columnname = 'epa_type' AND formname like '%_arc%';
UPDATE config_form_fields SET dv_querytext = 'SELECT id, id as idval FROM sys_feature_epa_type WHERE active AND feature_type = ''NODE'''  WHERE columnname = 'epa_type' AND formname like '%_node%';

DELETE FROM sys_table WHERE id = 'inp_rules_controls_importinp';

UPDATE cat_feature_node SET epa_default  ='UNDEFINED' WHERE epa_default  ='NOT DEFINED';
UPDATE cat_feature_arc SET epa_default  ='UNDEFINED' WHERE epa_default  ='NOT DEFINED';
UPDATE sys_feature_epa_type SET id  ='UNDEFINED' WHERE id  ='NOT DEFINED';
UPDATE arc SET epa_type ='UNDEFINED' WHERE epa_type  ='NOT DEFINED';
UPDATE node SET epa_type ='UNDEFINED' WHERE epa_type  ='NOT DEFINED';

--2021/03/29
UPDATE config_toolbox SET  inputparams =
'[{"widgetname":"grafClass", "label":"Graf class:", "widgettype":"combo","datatype":"text","tooltip": "Grafanalytics method used", "layoutname":"grl_option_parameters","layoutorder":1,"comboIds":["PRESSZONE","DQA","DMA","SECTOR"],
"comboNames":["Pressure Zonification (PRESSZONE)", "District Quality Areas (DQA) ", "District Metering Areas (DMA)", "Inlet Sectorization (SECTOR-HIGH / SECTOR-LOW)"], "selectedId":""}, 

{"widgetname":"exploitation", "label":"Exploitation:","widgettype":"combo","datatype":"text","tooltip": "Choose exploitation to work with", "layoutname":"grl_option_parameters","layoutorder":2, 
"dvQueryText":"select expl_id as id, name as idval from exploitation where active is not false order by name", "selectedId":"$userExploitation"},

{"widgetname":"floodFromNode", "label":"Flood from node: (*)","widgettype":"linetext","datatype":"text", "isMandatory":false, "tooltip":"Optative parameter to constraint algorithm to work only flooding from any node on network, used to define only the related mapzone", "placeholder":"1015", "layoutname":"grl_option_parameters","layoutorder":3, "value":""},

{"widgetname":"forceOpen", "label":"Force open nodes: (*)","widgettype":"linetext","datatype":"text", "isMandatory":false, "tooltip":"Optative node id(s) to temporary open closed node(s) in order to force algorithm to continue there", "placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layoutorder":4, "value":""},

{"widgetname":"forceClosed", "label":"Force closed nodes: (*)","widgettype":"text","datatype":"text", "isMandatory":false, "tooltip":"Optative node id(s) to temporary close open node(s) to force algorithm to stop there","placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layoutorder":5,"value":""},

{"widgetname":"usePlanPsector", "label":"Use selected psectors:", "widgettype":"check","datatype":"boolean","tooltip":"If true, use selected psectors. If false ignore selected psectors and only works with on-service network" , "layoutname":"grl_option_parameters","layoutorder":6,"value":""},

{"widgetname":"updateMapZone", "label":"Mapzone constructor method:","widgettype":"combo","datatype":"integer","layoutname":"grl_option_parameters","layoutorder":7,
"comboIds":[0,1,2,3,4], "comboNames":["NONE", "CONCAVE POLYGON", "PIPE BUFFER", "PLOT & PIPE BUFFER", "LINK & PIPE BUFFER"], "selectedId":"4"}, 

{"widgetname":"geomParamUpdate", "label":"Pipe buffer","widgettype":"text","datatype":"float","tooltip":"Buffer from arcs to create mapzone geometry using [PIPE BUFFER] options. Normal values maybe between 3-20 mts.", "layoutname":"grl_option_parameters","layoutorder":8, "isMandatory":false, "placeholder":"5-30", "value":""}]'
WHERE id = 2768;

UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'REGISTER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'MINSECTOR' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'DQA' WHERE type =  'NETELEMENT' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'REGISTER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'EXPANSIONTANK' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'FILTER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'MINSECTOR' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'FLEXUNION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'DMA' WHERE type =  'METER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'MINSECTOR' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'HYDRANT' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'MANHOLE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'NETELEMENT' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'NETSAMPLEPOINT' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'PRESSZONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'PRESSZONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'PRESSZONE' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'METER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'PUMP' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'REDUCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'REGISTER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'MINSECTOR' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'SECTOR' WHERE type =  'SOURCE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'SECTOR' WHERE type =  'TANK' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'MINSECTOR' WHERE type =  'VALVE' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'REGISTER' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'NETWJOIN' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'SECTOR' WHERE type =  'WATERWELL' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'SECTOR' WHERE type =  'WTP' AND graf_delimiter IS NULL;
UPDATE cat_feature_node SET graf_delimiter= 'NONE' WHERE type =  'JUNCTION' AND graf_delimiter IS NULL;

UPDATE config_param_system SET value  =
'{"SECTOR":{"mode":"Random", "column":"sector_id"}, "DMA":{"mode":"Random", "column":"name"}, "PRESSZONE":{"mode":"Stylesheet", "column":"presszone_id"}, "DQA":{"mode":"Random", "column":"dqa_id"}, "MINSECTOR":{"mode":"Random", "column":"minsector_id"}}'
WHERE parameter = 'utils_grafanalytics_dynamic_symbology';


UPDATE config_form_tabs SET tabactions = '[{"actionName":"actionEdit",  "disabled":false},
{"actionName":"actionZoom",  "disabled":false},
{"actionName":"actionCentered",  "disabled":false},
{"actionName":"actionZoomOut" , "disabled":false},
{"actionName":"actionCatalog",  "disabled":false},
{"actionName":"actionWorkcat",  "disabled":false},
{"actionName":"actionCopyPaste",  "disabled":false},
{"actionName":"actionLink",  "disabled":false},
{"actionName":"actionMapZone",  "disabled":false},
{"actionName":"actionSetToArc",  "disabled":false},
{"actionName":"actionGetParentId",  "disabled":false},
{"actionName":"actionGetArcId", "disabled":false},
{"actionName": "actionRotation","disabled": false}]'
WHERE formname ='v_edit_node';


UPDATE config_form_tabs SET tabactions = '[{"actionName":"actionEdit", "disabled":false},
{"actionName":"actionZoom", "disabled":false},
{"actionName":"actionCentered", "disabled":false},
{"actionName":"actionZoomOut", "disabled":false},
{"actionName":"actionCatalog", "disabled":false},
{"actionName":"actionWorkcat", "disabled":false},
{"actionName":"actionCopyPaste","disabled":false},
{"actionName":"actionSection", "disabled":false},
{"actionName":"actionLink",  "disabled":false}]'
WHERE formname ='v_edit_arc';

UPDATE config_form_tabs SET tabactions = '[{"actionName":"actionEdit", "disabled":false},
{"actionName":"actionZoom", "disabled":false},
{"actionName":"actionCentered", "disabled":false},
{"actionName":"actionZoomOut", "disabled":false},
{"actionName":"actionCatalog", "disabled":false},
{"actionName":"actionWorkcat","disabled":false},
{"actionName":"actionCopyPaste",  "disabled":false},
{"actionName":"actionLink",  "disabled":false},
{"actionName":"actionGetArcId", "disabled":false}]'
WHERE formname ='v_edit_connec';

-- 2021/04/24
DELETE FROM sys_table WHERE id = 'inp_rules_importinp';

-- 2021/04/30

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,hidden)
VALUES ('cat_feature_node','form_feature', 'main','id',null,null, 'string','text', 'id',null,null,true,
false, false, false, false, NULL, true, false,null, null,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,hidden)
VALUES ('cat_feature_node','form_feature', 'main','type',null,null, 'string','text', 'type',null,null,true,
false, false, false, false, NULL, true, true,null, null,false) 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,hidden)
VALUES ('cat_feature_node','form_feature', 'main','epa_default',null,null, 'string','combo', 'epa default',null,null,true,
false, true, false, false, 'SELECT id as id, id as idval FROM sys_feature_epa_type WHERE feature_type =''NODE''', true, false,null, null,false) 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder,datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate,hidden)
VALUES ('cat_feature_node','form_feature', 'main','num_arcs',null,null, 'integer','text', 'arcs number',null,null,false,
false,true,false,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder,datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate,hidden)
VALUES ('cat_feature_node','form_feature', 'main','choose_hemisphere',null,null, 'boolean','check', 'choose hemisphere',null,null,false,
false,true,false,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder,datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate,hidden)
VALUES ('cat_feature_node','form_feature', 'main','isarcdivide',null,null, 'boolean','check', 'divides arc',null,null,false,
false,true,false,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,hidden)
VALUES ('cat_feature_node','form_feature', 'main','graf_delimiter',null,null, 'string','combo', 'Graf delimiter',null,null,true,
false, true, false, false, 'SELECT id, idval FROM edit_typevalue WHERE typevalue =''grafdelimiter_type''', true, false,null, null,false) 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;

INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder,datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate,hidden)
VALUES ('cat_feature_node','form_feature', 'main','isprofilesurface',null,null, 'boolean','check', 'Profile surface',null,null,false,
false,true,false,false) ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;


UPDATE sys_table SET notify_action = '[{"channel":"desktop","name":"refresh_attribute_table", "enabled":"true", "trg_fields":"pattern_id","featureType":["inp_pump_additional", "inp_source", "inp_pattern_value", "v_edit_inp_demand","v_edit_inp_pump","v_edit_inp_reservoir","v_edit_inp_junction","v_edit_inp_connec"]}]'
WHERE id = 'inp_pattern';

DELETE FROM sys_table WHERE id = 'inp_rules_x_node';
DELETE FROM sys_table WHERE id = 'inp_rules_x_arc';

UPDATE sys_table SET id = 'inp_controls', sys_sequence = 'inp_controls_id_seq' WHERE id = 'inp_controls_x_arc';
UPDATE sys_table SET id = 'inp_rules', sys_sequence = 'inp_rules_id_seq'  WHERE id = 'inp_rules_x_sector';

-- 2021/05/03
INSERT INTO config_form_fields(formname, formtype, tabname, columnname, layoutname, layoutorder, datatype, widgettype, label, tooltip, placeholder, ismandatory, 
isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,hidden)
VALUES ('v_edit_inp_demand','form_feature', 'main','feature_type','lyt_data_1', 7, 'string','combo', 'feature_type','feature_type', null,false,
false, true, false, false, 'SELECT id as id, id as idval FROM sys_feature_type WHERE id IN (''NODE'', ''CONNEC'')', true, false,null, null,false) 
ON CONFLICT (formname, formtype, columnname, tabname) DO NOTHING;


update config_form_fields set formname='inp_rules' WHERE formname = 'inp_rules_x_arc';
update config_form_fields set columnname='sector_id', label='sector_id', widgettype='combo', dv_querytext='SELECT sector_id as id, name as idval FROM sector WHERE sector_id<>0', dv_orderby_id=true, dv_isnullvalue=false WHERE formname = 'inp_rules' AND columnname='arc_id';
delete from config_form_fields where formname in ('inp_rules_x_node', 'inp_rules_x_sector');

update config_form_fields set formname='inp_controls' WHERE formname = 'inp_controls_x_arc';
update config_form_fields set columnname='sector_id', label='sector_id', widgettype='combo', dv_querytext='SELECT sector_id as id, name as idval FROM sector WHERE sector_id<>0', dv_orderby_id=true, dv_isnullvalue=false WHERE formname = 'inp_controls' AND columnname='arc_id';
update config_form_fields set widgetcontrols='{"setMultiline":true}' WHERE formname = 'inp_controls' AND columnname='text';


INSERT INTO inp_controls (sector_id, text, active)
SELECT arc.sector_id, text, active FROM _inp_controls_x_arc_
JOIN arc USING(arc_id);

INSERT INTO inp_rules (sector_id, text, active)
SELECT arc.sector_id, text, active FROM _inp_rules_x_arc_
JOIN arc USING(arc_id);

INSERT INTO inp_rules (sector_id, text, active)
SELECT node.sector_id, text, active FROM _inp_rules_x_node_
JOIN node USING(node_id);