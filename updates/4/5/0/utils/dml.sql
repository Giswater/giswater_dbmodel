/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

WITH numbered AS (
    SELECT id,
        typevalue,
        (ROW_NUMBER() OVER (ORDER BY id)) - 1 AS new_id
    FROM config_typevalue
    WHERE typevalue = 'sys_table_context'
)
UPDATE config_typevalue c
SET idval = c.id, id = n.new_id
FROM numbered n
WHERE c.id = n.id AND c.typevalue = n.typevalue AND c.typevalue = 'sys_table_context';

INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES('widgettype_typevalue', 'multiple_checkbox', 'multiple_checkbox', 'multipleCheckbox', NULL);

INSERT INTO config_typevalue (typevalue, id, idval, camelstyle, addparam) VALUES('widgettype_typevalue', 'multiple_option', 'multiple_option', 'multipleOption', NULL);

INSERT INTO sys_function (id, function_name, project_type, function_type, input_params, return_type, descript, sys_role, sample_query, "source", function_alias) VALUES(3516, 'gw_fct_manage_inserts_by_ids', 'utils', 'function', 'integer, text, text, integer[]', 'integer', 'Function to manage batch inserts of features into various relation tables (campaign, lot, psector, element, visit) based on relation type and feature type. Returns the number of inserted features.', NULL, NULL, 'core', NULL);

INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source", message_type) VALUES(4408, 'There are no nodes to be repaired.', NULL, 0, true, 'utils', 'core', 'AUDIT');

INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source", message_type) VALUES(4410, '%v_count% nodes have been created to repair topology.', NULL, 0, true, 'utils', 'core', 'AUDIT');

-- activate matcat_id and sys_elev null values checks.
UPDATE sys_fprocess
SET isaudit=true, active=true
WHERE fid=569;

UPDATE sys_fprocess
SET isaudit=true,active=true
WHERE fid=584;

INSERT INTO sys_table (id, descript, sys_role, project_template, context, orderby, alias, notify_action, isaudit, keepauditdays, "source", addparam)
VALUES('man_vlink', 'Additional information for vlink management', 'role_edit', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'core', NULL) ON CONFLICT DO NOTHING;

-- 15/10/2025
INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source", message_type) VALUES(4412, 'It is not allowed to delete planified features in operative mode', 'Switch to plan mode to delete the feature', 1, true, 'utils', 'core', 'UI');
INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source", message_type) VALUES(4414, 'It is not allowed to delete features from a different psector than the current one', 'Switch to the correct psector to delete the feature', 1, true, 'utils', 'core', 'UI');
INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, "source", message_type) VALUES(4416, 'It is not allowed to delete operative features in plan mode', 'Switch to operative mode to delete the feature', 1, true, 'utils', 'core', 'UI');

INSERT INTO sys_param_user (id, formname, descript, sys_role, idval, "label", dv_querytext, dv_parent_id, isenabled, layoutorder, project_type, isparent, dv_querytext_filterc, feature_field_id, feature_dv_parent_value, isautoupdate, "datatype", widgettype, ismandatory, widgetcontrols, vdefault, layoutname, iseditable, dv_orderby_id, dv_isnullvalue, stylesheet, placeholder, "source") 
VALUES('plan_psector_disable_forced_style', 'config', 'Variable to disable forced style changes to apply GwPlan', 'role_edit', NULL, 'Style forcing value', NULL, NULL, true, 11, 'utils', NULL, NULL, NULL, NULL, false, 'boolean', 'check', true, NULL, 'false', 'lyt_masterplan', true, NULL, NULL, NULL, NULL, 'core');

-- 20/10/2025
UPDATE sys_fprocess SET query_text='SELECT * FROM temp_t_node JOIN selector_sector USING (sector_id) WHERE top_elev IS NULL AND cur_user = current_user'
WHERE fid=164;
UPDATE sys_fprocess SET query_text='SELECT * FROM temp_t_node JOIN selector_sector USING (sector_id) WHERE top_elev = 0 AND cur_user = current_user'
WHERE fid=165;

INSERT INTO sys_message (id, error_message, hint_message, log_level, show_user, project_type, source, message_type) 
VALUES(4428, 'DATA QUALITY ANALYSIS ACORDING O&M RULES', '', 0, true, 'utils', 'core', 'AUDIT');

UPDATE config_form_fields SET label = 'Dma', tooltip = 'dma_id' WHERE formname LIKE '%_node%' AND formtype = 'form_feature' AND columnname = 'dma_id';
UPDATE config_form_fields SET label = 'Dma', tooltip = 'dma_id' WHERE formname LIKE '%_connec%' AND formtype = 'form_feature' AND columnname = 'dma_id';
UPDATE config_form_fields SET label = 'Dma', tooltip = 'dma_id' WHERE formname LIKE '%_arc%' AND formtype = 'form_feature' AND columnname = 'dma_id';
UPDATE config_form_fields SET label = 'Dma', tooltip = 'dma_id' WHERE formname LIKE '%_gully%' AND formtype = 'form_feature' AND columnname = 'dma_id';

UPDATE sys_fprocess
SET except_table='anl_arc'
WHERE fid=372;

UPDATE sys_fprocess
SET except_table='anl_node'
WHERE fid=432;

INSERT INTO sys_message (id,error_message,log_level,project_type,"source",message_type)
VALUES (4430,'The %feature_type% with id %connec_id% has been successfully connected to the arc with id %arc_id%',0,'generic','core','AUDIT');
