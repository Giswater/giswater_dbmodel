/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source") VALUES(3256, 'It is not possible to upgrade the arc to state planified because it has operative gullies associated', NULL, 2, true, 'utils', 'core') ON CONFLICT DO NOTHING;
INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source") VALUES(3254, 'It is not possible to upgrade the arc to state planified because it has operative connecs associated', NULL, 2, true, 'utils', 'core') ON CONFLICT DO NOTHING;
INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source") VALUES(3258, 'It is not possible to upgrade the node to state planified because node has operative arcs associated', NULL, 2, true, 'utils', 'core') ON CONFLICT DO NOTHING;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder) 
SELECT SUBSTRING(formname FROM 8) AS formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder
FROM config_form_fields
WHERE formname like 'v_edit_inp_dscenario_%' and formname not like 'v_edit_inp_dscenario_flwreg_%'
ON CONFLICT DO NOTHING;

UPDATE config_form_fields
	SET layoutorder=1
	WHERE formname in ('inp_dscenario_controls', 'inp_dscenario_rules') AND columnname='id';
UPDATE config_form_fields
	SET layoutorder=2
	WHERE formname in ('inp_dscenario_controls', 'inp_dscenario_rules') AND columnname='dscenario_id';
UPDATE config_form_fields
	SET layoutorder=3
	WHERE formname in ('inp_dscenario_controls', 'inp_dscenario_rules') AND columnname='sector_id';

UPDATE sys_function SET descript='NO input parameters needed.
The function allows the possibility to find errors and data inconsistency for prices checking catalog elements.' WHERE id=2436 and function_name='gw_fct_plan_check_data';

INSERT INTO edit_typevalue (typevalue, id, idval, descript, addparam) VALUES('graphdelimiter_type', 'CHECKVALVE', 'CHECKVALVE', NULL, NULL);

UPDATE config_toolbox SET active = FALSE WHERE alias='Import epanet file' AND id=2522;
