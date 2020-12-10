/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/12/10
UPDATE audit_cat_param_user SET id='edit_gullyrotation_disable', description='If true, the automatic rotation calculation on the gullys is disabled. Used for an absolute manual update of rotation field',
label='Disable automatic gully rotation:', project_type='ud' WHERE id='edit_noderotation_update_dissbl';