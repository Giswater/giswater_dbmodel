/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2020/08/04
INSERT INTO audit_cat_function (id, function_name, project_type, function_type) 
VALUES (2994, 'gw_fct_vnode_repair', 'utils', 'function')ON CONFLICT (id) DO NOTHING;

UPDATE audit_cat_param_user SET isenabled=TRUE, layout_order=10 WHERE id='om_param_type_vdefault';
UPDATE audit_cat_param_user SET isenabled=FALSE WHERE id like'qgis_qml%';
UPDATE audit_cat_param_user SET layout_order=8 WHERE id='visitenddate_vdefault';
