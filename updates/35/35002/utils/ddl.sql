/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


set search_path = 'SCHEMA_NAME';

DROP TABLE IF EXISTS config_form_groupbox;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"config_fprocess", "column":"fields", "newName":"querytext"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_check_data", "column":"fcount", "dataType":"integer", "isUtils":"False"}}$$);


CREATE TABLE IF NOT EXISTS audit_fid_log
(id serial NOT NULL  PRIMARY KEY,
fid smallint,
fcount integer,
groupby text,
criticity integer,
tstamp timestamp without time zone DEFAULT now()
);


SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"layermanager"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"sytle"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"actions"}}$$);

--2020/09/24 
DROP FUNCTION IF EXISTS gw_fct_edit_check_data(json);
DROP FUNCTION IF EXISTS gw_fct_getinsertfeature(json);
DROP FUNCTION IF EXISTS gw_fct_admin_schema_copy(json);

--2020/10/19
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"config_fprocess", "column":"fid2"}}$$);

--2020/11/25
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"plan_psector", "column":"sector_id"}}$$);

--2020/12/14
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_brand", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_brand ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_brand_model", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_brand_model ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_builder", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_builder ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_mat_arc", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_mat_arc ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_mat_node", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_mat_node ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_mat_element", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_mat_element ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_owner", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_owner ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_pavement", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_pavement ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_soil", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_soil ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_work", "column":"active", "dataType":"boolean", "isUtils":"False"}}$$);
ALTER TABLE cat_work ALTER COLUMN active SET DEFAULT TRUE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_param_user", "column":"isdeprecated"}}$$);