/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;


-- 30/11/2023
UPDATE om_visit_cat set alias = name;

INSERT INTO edit_typevalue
(typevalue, id, idval, descript, addparam)
VALUES('value_verified', '3', 'IGNORE CHECK', NULL, NULL) ON CONFLICT (typevalue, id) DO NOTHING;
