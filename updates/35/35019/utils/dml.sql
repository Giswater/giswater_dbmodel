/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2021/11/23
UPDATE config_param_system SET value = gw_fct_json_object_set_key(value::json, 'typeaheadForced', 'true'::boolean) 
WHERE parameter IN ('basic_selector_tab_sector', 'basic_selector_tab_psector', 'basic_selector_tab_macroexploitation', 'basic_selector_tab_exploitation');

--2021/11/24
DELETE FROM sys_param_user WHERE id='om_visit_class_vdefault';
DELETE FROM config_param_user WHERE parameter='om_visit_class_vdefault';

INSERT INTO config_param_system (parameter, value, descript, label, isenabled) VALUES
('qgis_form_selector_stylesheet', '{"rowsColor":false}', 'Variable to customize the look of the selectors dialog', 'Selectors stylesheet:', FALSE);