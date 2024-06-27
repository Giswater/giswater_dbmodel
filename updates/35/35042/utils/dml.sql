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
VALUES('value_verified', '2', 'IGNORE CHECK', NULL, NULL) ON CONFLICT (typevalue, id) DO NOTHING;

INSERT INTO config_param_system ("parameter", value, descript, "label", project_type,"datatype", widgettype)
VALUES('plan_node_replace_code', 'false', 'If true, when a node replace in planification is performed, new arcs will have the same code as the replaced one. Otherwise, new arcs will have the same code as its arc_id.', 'Plan node replace code', 'utils', 'boolean', 'text') ON CONFLICT (parameter) DO NOTHING;