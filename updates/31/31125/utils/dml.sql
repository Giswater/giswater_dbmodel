/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

ALTER TABLE config_param_system ADD CONSTRAINT config_param_system_parameter_unique UNIQUE (parameter);

INSERT INTO config_param_system (parameter, value, data_type, context, descript) 
VALUES ('plan_statetype_reconstruct','4','integer', 'plan', 'Value used to identify reconstruct arcs in order to manage length of planified network') ON CONFLICT (parameter) DO NOTHING;