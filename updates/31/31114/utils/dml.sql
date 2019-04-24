/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--24/04/2019
UPDATE audit_cat_table SET sys_role_id='role_om' WHERE id='v_ui_om_visitman_x_arc';
UPDATE audit_cat_table SET sys_role_id='role_om' WHERE id='v_ui_om_visitman_x_node';
UPDATE audit_cat_table SET sys_role_id='role_om' WHERE id='v_ui_om_visitman_x_connec';


INSERT INTO audit_cat_error VALUES (2015, 'There is no state-1 feature as endpoint of link. It is impossible to create it', 'Try to connect the link to one arc / node / connec / gully or vnode with state=1', 2, true, NULL);