/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 07/04/2026
UPDATE config_toolbox
SET active = FALSE
WHERE id = 3560;

UPDATE inp_typevalue
SET typevalue = '_inp_typevalue_dscenario'
WHERE typevalue = 'inp_typevalue_dscenario' AND id = 'LOSSES';
