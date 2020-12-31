/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/12/30
ALTER TABLE sys_fprocess ADD COLUMN source text;
ALTER TABLE sys_function ADD COLUMN source text;
ALTER TABLE sys_message ADD COLUMN source text;
ALTER TABLE sys_param_user ADD COLUMN source text;
ALTER TABLE sys_table ADD COLUMN source text;