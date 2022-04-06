/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2022/01/31
UPDATE sys_table SET id = 'vi_subcatch2outlet' WHERE id = 'vi_subcatch2node';
UPDATE sys_table SET sys_role='role_edit' WHERE id='inp_gully';

UPDATE config_form_fields SET widgettype='combo', dv_querytext='SELECT lidco_id AS id, lidco_id as idval FROM inp_lid WHERE lidco_id IS NOT NULL',
widgetcontrols='{"setMultiline":false,"valueRelation":{"nullValue":true, "layer": "inp_lid", "activated": true, "keyColumn": "lidco_id", "valueColumn": "lidco_id", "filterExpression":""}}'::json
WHERE columnname='lidco_id' AND formname='inp_lid_value';

--2022/03/14
update sys_table set addparam='{"pkey":"dwfscenario_id, node_id"}' where id='v_edit_inp_dwf';

update sys_table set context='{"level_1":"EPA","level_2":"RESULTS"}', orderby=15, alias='LID Performance' where id='v_rpt_lidperfomance_sum';
update sys_table set context='{"level_1":"EPA","level_2":"COMPARE"}', orderby=15, alias='LID Performance Compare' where id='v_rpt_comp_lidperfomance_sum';
update sys_table set context='{"level_1":"EPA","level_2":"HYDROLOGY"}', orderby=3, alias='Subcatchment outlet' where id='vi_subcatch2outlet';

INSERT INTO config_fprocess VALUES (140,'rpt_arcpollutant_sum','Link Pollutant Load Summary', null, 99);

INSERT INTO sys_table (id, descript, sys_role, source) VALUES ('rpt_arcpollutant_sum','Table to store arcpollutant values', 'role_epa','core');

update sys_param_user set isenabled=true, layoutname='lyt_other', layoutorder=24, formname='config' where id='edit_node_interpolate';

UPDATE config_form_fields SET dv_querytext = 'SELECT snow_id as id, snow_id as idval FROM inp_snowpack WHERE snow_id IS NOT NULL' 
WHERE formname = 'v_edit_inp_subcatchment' AND columnname = 'snow_id';
