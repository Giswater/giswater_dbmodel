/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


INSERT INTO audit_cat_error VALUES (1081,'There are not psectors defined on the project','Define at least one to start to work with', 2, TRUE);
INSERT INTO audit_cat_error VALUES (1083,'Please configure your own psector vdefault variable','To work with planified elements it is mandatory to have always defined the work psector using the psector vdefault variable', 2, TRUE);
INSERT INTO audit_cat_error VALUES (1097,'It is not allowed to insert/update one node with state(1) over another one with state (1) also. The node is:','Please ckeck it', 2, TRUE);

INSERT INTO value_state_type VALUES (99, 2, 'Ficticius', true, true)
ON CONFLICT (id) DO NOTHING;
