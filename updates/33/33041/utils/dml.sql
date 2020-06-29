/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/06/29
INSERT INTO audit_cat_param_user
VALUES ('qgis_layers_set_propierties','config','If true, qgis starts setting all layers with appropiate settigs from config_form_fields', 'role_basic', NULL, NULL, 
'QGIS init guide map', NULL, NULL, true, 8, 20, 'utils', false, NULL, NULL, NULL, 
false, 'boolean', 'check', true, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false)
ON conflict (id) DO NOTHING;