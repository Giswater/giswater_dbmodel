/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


DELETE FROM sys_param_user WHERE id='edit_gully_autoupdate_polgeom';
DELETE FROM config_param_user WHERE parameter='edit_gully_autoupdate_polgeom';

INSERT INTO config_param_system(parameter, value, descript, label, isenabled,  project_type,  datatype, widgettype, ismandatory)
VALUES ('om_profile_nonpriority_statetype', null, 'Features with defined state type won''t be prioritised to be choosen on a profile in case of overlaying conduiuts', 
'Profile non priority state type', false, 'ud', 'integer', 'linetext', false ) ON CONFLICT (parameter) DO NOTHING;