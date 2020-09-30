/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/09/29
INSERT INTO sys_fprocess_cat VALUES (288, 'Store plan psector values for especific user', 'utils')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sys_fprocess_cat VALUES (289, 'Store exploitation values for especific user', 'utils')
ON CONFLICT (id) DO NOTHING;