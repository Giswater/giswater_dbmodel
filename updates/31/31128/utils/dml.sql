/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- config (warning)
INSERT INTO config_param_system(parameter, value, data_type, context, descript)
VALUES ('plan_psector_statetype', '{"done_planified":"98", "done_ficticious":"97", "canceled_planified":"96", "canceled_ficticious":"95"}', 'json', 'plan', 
'Psector statetype assigned to features after executing or canceling planification');

INSERT INTO config_param_system(parameter, value, data_type, context, descript)
VALUES ('plan_statetype_planned', '3', 'integer', 'plan', 'State type for planned elements');

UPDATE config_param_system SET value='99' WHERE parameter='plan_statetype_ficticius';


INSERT INTO audit_cat_error(id, error_message, log_level, show_user, project_type)
VALUES (3024, 'Can''t delete the parameter. There is at least one event related to it', 2, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3026, 'Can''t delete the class. There is at least one visit related to it','The class will be set to unactive.', 
1, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3028, 'Can''t modify typevalue:','It''s impossible to change system values.', 
2, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3030, 'Can''t delete typevalue:','It''s being used in a table.', 
2, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3032, 'Can''t apply the foreign key','there are values already inserted that are not present in the catalog', 
2, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3034, 'Inventory state and state type of planified features has been updated',null, 1, true,'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_cat_error(id, error_message,hint_message, log_level, show_user, project_type)
VALUES (3036, 'Selected state type doesn''t correspond with state','Modify the value of state or state type.', 2, true,'utils')
ON CONFLICT (id) DO NOTHING;

UPDATE value_state_type SET is_doable = False WHERE id = 99;

INSERT INTO value_state_type(id,state, name, is_operative, is_doable)
VALUES (98,0, 'DONE PLANIFIED',false, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO value_state_type(id,state, name, is_operative, is_doable)
VALUES (97,0, 'DONE FICTICIOUS',false, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO value_state_type(id,state, name, is_operative, is_doable)
VALUES (96,0, 'CANCELED PLANIFIED',false, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO value_state_type(id,state, name, is_operative, is_doable)
VALUES (95,0, 'CANCELED FICTICIOUS',false, false)
ON CONFLICT (id) DO NOTHING;