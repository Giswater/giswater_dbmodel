/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- config
INSERT INTO audit_cat_param_user VALUES ('edit_gully_doublegeom', 'edit', 'If value,  double geometry is enabled when gully is inserted  and is a multiplication factor againts cat_grate values', 'role_edit', NULL, NULL, NULL, NULL, 'float')
ON CONFLICT (id) DO NOTHING;

