/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/06/04
UPDATE audit_cat_param_user SET vdefault='TRUE',
description = 'Hide initial form when project is loaded and disable check project and disable set widget layers using db config_form_fields'
WHERE id = 'qgis_form_initproject_hidden';
