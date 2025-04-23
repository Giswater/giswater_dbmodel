/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME ,public;

ALTER TABLE raingage ALTER COLUMN the_geom SET NOT NULL;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_arc", "column":"drainzone_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"drainzone_id", "dataType":"integer", "isUtils":"False"}}$$);