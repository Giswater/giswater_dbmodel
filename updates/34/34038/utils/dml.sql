/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/09/08
DELETE FROM config_param_user WHERE "parameter" ='edit_link_update_connecrotation';

INSERT INTO config_param_system (parameter, value, descript, label, isenabled, layoutorder, project_type, "datatype", widgettype, iseditable, layoutname) 
SELECT id, 'true', descript, label, true, 10, 'utils', 'boolean', 'check', true, 'lyt_system' FROM sys_param_user spu WHERE id ='edit_link_update_connecrotation';

DELETE FROM sys_param_user WHERE id='edit_link_update_connecrotation';

UPDATE config_param_system SET descript='If true, connec''s label and symbol will be rotated using the angle of link. You need to have label symbol configurated with "CASE WHEN label_x = 5 THEN ''    '' ||  "connec_id"  
ELSE  "connec_id"  || ''    ''  END", label_x as quadrant and label_rotation as rotation' WHERE "parameter" = 'edit_link_update_connecrotation';
