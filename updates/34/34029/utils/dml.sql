/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2021/01/30
INSERT INTO sys_function(id, function_name, project_type, function_type, input_params, return_type, descript, sys_role)
VALUES (3020,'gw_fct_pg2epa_breakpipes', 'ws', 'function', 'json', 'json', 'Function that creates additional vnodes to enhance epanet models', 'role_epa') 
ON CONFLICT (function_name, project_type) DO NOTHING;

UPDATE config_visit_parameter SET active = TRUE WHERE active IS NULL;
