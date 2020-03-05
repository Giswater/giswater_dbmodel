/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO config_param_system(parameter, value, data_type, context, descript) 
VALUES ('use_fire_code_seq', 'TRUE', 'boolean', 'System', 'If TRUE, when insert a new hydrant with fire_code=NULL this field will be filled with next val of sequence');