/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/06/24
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_timeseries", "column":"fname", "dataType":"character varying(254)", "isUtils":"False"}}$$);

--2021/07/13
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"gully", "column":"asset_id", "dataType":"character varying(50)", "isUtils":"False"}}$$);
