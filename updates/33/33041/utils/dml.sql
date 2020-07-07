/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/06/29
INSERT INTO audit_cat_param_user
VALUES ('qgis_layers_set_propierties','config','If true, qgis starts setting all layers with appropiate settigs from config_form_fields', 'role_basic', NULL, NULL, 
'QGIS set layer properties', NULL, NULL, true, 8, 21, 'utils', false, NULL, NULL, NULL, 
false, 'boolean', 'check', true, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false)
ON conflict (id) DO NOTHING;


--2020/07/06

INSERT INTO config_param_system (parameter, value, data_type,context, descript, isenabled, isdeprecated)
VALUES ('grafanalytics_lrs_feature', '{"arc":{"costField":""}, "nodeChild":{"valueField":"", "headerField":""}}', 'json', 'system', 'List of fields updated during the process of calculating linear reference',false, false)
ON CONFLICT (parameter) DO NOTHING;

INSERT INTO config_param_system (parameter, value, data_type,context, descript, isenabled, isdeprecated)
VALUES ('grafanalytics_lrs_graf', '{"headers":[{"node": "", "toArc": [""]}],"ignoreArc":[""]}', 'json', 'system', 'Configuration of starting points(headers) and arc which indicate direction of calculating linear reference',false, false)
ON CONFLICT (parameter) DO NOTHING;

INSERT INTO audit_cat_function(id, function_name, project_type, function_type, input_params, return_type,  descript, sys_role_id, isdeprecated, istoolbox, 
alias, isparametric)
VALUES ('2826', 'gw_fct_grafanalytics_lrs', 'utils', 'function', '{"featureType":[]}',
'[{"widgetname":"exploitation", "label":"Exploitation ids:","widgettype":"combo","datatype":"text","layoutname":"grl_option_parameters","layout_order":2, 
"dvQueryText":"select expl_id as id, name as idval from exploitation where active is not false order by name", "selectedId":"1"}]',
'Function that calculates linear reference', 'role_edit', false, true,'LRS',TRUE) ON CONFLICT (id) DO NOTHING;

