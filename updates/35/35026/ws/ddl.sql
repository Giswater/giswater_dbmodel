/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2022/06/07
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_mincut_node", "column":"node_type", "dataType":"character varying(30)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_mincut_connec", "column":"customer_code", "dataType":"character varying(30)", "isUtils":"False"}}$$);

--2022/06/25
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"demand", "dataType":"double precision", "isUtils":"False"}}$$);
