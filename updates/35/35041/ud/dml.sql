/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


DELETE FROM sys_param_user WHERE id='edit_gully_autoupdate_polgeom';
DELETE FROM config_param_user WHERE parameter='edit_gully_autoupdate_polgeom';

INSERT INTO config_param_system(parameter, value, descript, label, isenabled,  project_type,  datatype, widgettype, ismandatory)
VALUES ('om_profile_nonpriority_statetype', '{"state_type":"", "extra_cost":0.1}', 
'Features with defined state type won''t be prioritised to be chosen on a profile in case of overlaying conduiuts, instead it will have an additional path cost added to it''s length', 
'Profile non priority state type', false, 'ud', 'json', 'linetext', false ) ON CONFLICT (parameter) DO NOTHING;

UPDATE sys_param_user SET layoutorder=26 WHERE id='edit_node_ymax_vdefault';