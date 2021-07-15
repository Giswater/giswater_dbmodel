/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/06/29
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_curve", "column":"sector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"ext_rtc_hydrometer", "column":"shutdown_date", "dataType":"date", "isUtils":"False"}}$$);

--2021/07/13
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"arc", "column":"asset_id", "dataType":"character varying(50)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"node", "column":"asset_id", "dataType":"character varying(50)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"connec", "column":"asset_id", "dataType":"character varying(50)", "isUtils":"False"}}$$);

--2021/07/15
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_feature", "column":"config", "dataType":"json", "isUtils":"False"}}$$);

ALTER TABLE arc ALTER COLUMN verified DROP NOT NULL;

