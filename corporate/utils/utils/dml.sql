/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = "utils", public, pg_catalog;

INSERT INTO config_param_system(id, parameter, value, data_type, context, descript)
VALUES (1, 'ws_current_schema', NULL , 'text', 'NULL','WS');

INSERT INTO config_param_system(id, parameter, value, data_type, context, descript)
VALUES (2, 'ud_current_schema', NULL , 'text', NULL,'UD');