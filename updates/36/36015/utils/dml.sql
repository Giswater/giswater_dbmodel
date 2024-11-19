/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source")
VALUES(3270, 'You can''t create or update a document with an empty name. Please provide a valid name.', NULL, 2, true, 'utils', 'core');

UPDATE config_form_fields SET dv_querytext = 'SELECT muni_id as id, name as idval from v_ext_municipality WHERE muni_id IS NOT NULL' WHERE columnname  = 'muni_id' AND widgettype = 'combo';

INSERT INTO selector_municipality SELECT DISTINCT 0, cur_user FROM selector_expl ON CONFLICT (muni_id, cur_user) DO NOTHING;

-- 19/11/24
UPDATE config_form_fields SET widgetfunction='{"functionName": "open_selected_path", "parameters":{"targetwidget":"tab_hydrometer_tbl_hydrometer", "columnfind": "hydrometer_link"}}'::json WHERE formname='connec' AND formtype='form_feature' AND columnname='btn_link' AND tabname='tab_hydrometer';
UPDATE config_form_fields SET widgetfunction='{"functionName": "open_selected_path", "parameters":{"targetwidget":"tab_hydrometer_tbl_hydrometer", "columnfind": "hydrometer_link"}}'::json WHERE formname='node' AND formtype='form_feature' AND columnname='btn_link' AND tabname='tab_hydrometer';
