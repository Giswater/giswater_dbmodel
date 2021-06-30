/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/06/21
UPDATE sys_param_user SET formname='hidden' WHERE id='edit_cadtools_baselayer_vdefault';

INSERT INTO config_param_system(parameter, value, descript, isenabled, project_type, datatype)
VALUES ('edit_arc_divide', '{"setArcObsolete":"false","setOldCode":"false"}', 
'Configuration of arc divide tool. If setArcObsolete true state of old arc would be set to 0, otherwise arc will be deleted. If setOldCode true, new arcs will have same code as old arc.',
FALSE, 'utils', 'json') ON CONFLICT (parameter) DO NOTHING;

UPDATE config_param_system SET value='{"mode":"disabled", "plan_obsolete_state_type":24}', descript='Define which mode psector trigger would use. Modes: "disabled", "onService"(transform all features afected by psector to its planified state and makes a
 copy of psector), "obsolete"(set all features afected to obsolete but manage their state_type). Define which plan state_type is going to be set to obsolete when execute psector' WHERE parameter='plan_psector_execute_action';

INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, source)
VALUES (3050, 'gw_fct_getfeaturegeom', 'utils', 'function', 'json', 'json',
'Return geometries from id list',
'role_basic', NULL, NULL) ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, source)
VALUES (3056, 'gw_trg_edit_inp_controls', 'utils', 'function trigger', NULL, NULL,
'Allows editing inp controls view','role_epa', NULL, NULL) ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, source)
VALUES (3058, 'gw_trg_edit_inp_rules', 'ws', 'function trigger', NULL, NULL,
'Allows editing inp rules view','role_epa', NULL, NULL) ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, source)
VALUES (3060, 'gw_trg_edit_inp_curve', 'ws', 'function trigger', NULL, NULL,
'Allows editing inp rules view','role_epa', NULL, NULL) ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, source)
VALUES (3062, 'gw_trg_edit_inp_pattern', 'ws', 'function trigger', NULL, NULL,
'Allows editing inp rules view','role_epa', NULL, NULL) ON CONFLICT (id) DO NOTHING;

--2021/06/30
INSERT INTO config_param_system VALUES ('admin_formheader_field', '{"node":"node_id", "arc":"arc_id", "connec":"connec_id", "gully":"gully_id", "element":{"childType":"ELEMENT", "column":"element_id"},
 "hydrometer":{"childType":"HYDROMETER", "column":"hydrometer_id"},  "newText":"NEW"}', 'Field to use as header from every feature_type when getinfofromid. When element and hydrometer, childType is used as text to concat with column. When insert new feature, newText is used to translate the concat text', 
NULL, NULL, NULL, FALSE, NULL, 'utils') ON CONFLICT (parameter) DO NOTHING;