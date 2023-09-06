/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"link", "column":"epa_type", "dataType":"character varying(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"link", "column":"is_operative", "dataType":"boolean", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"element", "column":"trace_featuregeom", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE element ALTER COLUMN trace_featuregeom SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"polygon", "column":"trace_featuregeom", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE polygon ALTER COLUMN trace_featuregeom SET DEFAULT TRUE;