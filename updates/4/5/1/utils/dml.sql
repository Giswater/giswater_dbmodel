/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

UPDATE sys_message SET error_message = 'The %feature_type% with id %connec_id% has been successfully connected to the arc with id %arc_id%'
WHERE id = 4430;

DELETE FROM config_form_fields WHERE formname='generic' AND formtype='psector' AND columnname='chk_enable_all' AND tabname='tab_general';

UPDATE config_typevalue
SET idval = substring(idval FROM 12 FOR length(idval) - 12)
WHERE typevalue = 'sys_table_context' and idval like '{"levels":%';

DELETE FROM sys_function WHERE id = 3346; -- gw_trg_mantypevalue_fk
DROP FUNCTION gw_trg_mantypevalue_fk() CASCADE;

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''ARC''', '''ARC''=ANY(feature_type)')
WHERE columnname = 'function_type'
AND formname ILIKE 've_arc%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''NODE''', '''NODE''=ANY(feature_type)')
WHERE columnname = 'function_type'
AND formname ILIKE 've_node%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''CONNEC''', '''CONNEC''=ANY(feature_type)')
WHERE columnname = 'function_type'
AND formname ILIKE 've_connec%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type = ''ELEMENT''', '''ELEMENT''=ANY(feature_type)')
WHERE columnname = 'function_type'
AND formname ILIKE 've_element%';

--
UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''ARC''', '''ARC''=ANY(feature_type)')
WHERE columnname = 'location_type'
AND formname ILIKE 've_arc%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''NODE''', '''NODE''=ANY(feature_type)')
WHERE columnname = 'location_type'
AND formname ILIKE 've_node%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''CONNEC''', '''CONNEC''=ANY(feature_type)')
WHERE columnname = 'location_type'
AND formname ILIKE 've_connec%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type = ''ELEMENT''', '''ELEMENT''=ANY(feature_type)')
WHERE columnname = 'location_type'
AND formname ILIKE 've_element%';

-- 
UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''ARC''', '''ARC''=ANY(feature_type)')
WHERE columnname = 'category_type'
AND formname ILIKE 've_arc%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''NODE''', '''NODE''=ANY(feature_type)')
WHERE columnname = 'category_type'
AND formname ILIKE 've_node%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''CONNEC''', '''CONNEC''=ANY(feature_type)')
WHERE columnname = 'category_type'
AND formname ILIKE 've_connec%';

UPDATE config_form_fields
SET dv_querytext = REPLACE(dv_querytext, 'feature_type = ''ELEMENT''', '''ELEMENT''=ANY(feature_type)')
WHERE columnname = 'category_type'
AND formname ILIKE 've_element%';

UPDATE sys_param_user
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''ARC''', '''ARC''=ANY(feature_type)')
WHERE id ILIKE 'edit_arc_%'
AND dv_querytext ILIKE '%man_type%';

UPDATE sys_param_user
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''NODE''', '''NODE''=ANY(feature_type)')
WHERE id ILIKE 'edit_node_%'
AND dv_querytext ILIKE '%man_type%';

UPDATE sys_param_user
SET dv_querytext = REPLACE(dv_querytext, 'feature_type=''CONNEC''', '''CONNEC''=ANY(feature_type)')
WHERE id ILIKE 'edit_connec_%'
AND dv_querytext ILIKE '%man_type%';


INSERT INTO sys_message (id,error_message,log_level,show_user,project_type,"source",message_type)
	VALUES (4432,'PLEASE, SET SOME VALUE FOR STATE_TYPE FOR PLANIFIED OBJECTS (CONFIG DIALOG)',0,true,'utils','core','UI');

UPDATE plan_typevalue SET descript='The Psector is being planned.' WHERE typevalue='psector_status' AND id='1';
UPDATE plan_typevalue SET descript='The Psector is planned and ready to work with.' WHERE typevalue='psector_status' AND id='2';
UPDATE plan_typevalue SET descript='The Psector is being executed on the network.' WHERE typevalue='psector_status' AND id='3';
UPDATE plan_typevalue SET descript='The Psector has been executed.' WHERE typevalue='psector_status' AND id='4';
UPDATE plan_typevalue SET descript='The Psector has been executed, and the objects defined during the planning phase (additions and removals) have been automatically implemented.' WHERE typevalue='psector_status' AND id='5';
UPDATE plan_typevalue SET descript='The Psector has been executed and is now archived.' WHERE typevalue='psector_status' AND id='6';
UPDATE plan_typevalue SET descript='The Psector has been cancelled because it was not executed and archived at the same time.' WHERE typevalue='psector_status' AND id='7';
UPDATE plan_typevalue SET descript='The Psector was archived but has been restored.' WHERE typevalue='psector_status' AND id='8';


DELETE FROM sys_label WHERE id=1006;
DELETE FROM sys_label WHERE id=1007;
DELETE FROM sys_label WHERE id=1008;
DELETE FROM sys_label WHERE id = 3013;

INSERT INTO sys_message (id,error_message,log_level,show_user,project_type,"source",message_type)
VALUES(4442, 'To check CRITICAL ERRORS or WARNINGS, execute a query FROM anl_table WHERE fid=error number AND current_user. For example:  SELECT * FROM MySchema.anl_arc WHERE fid = Myfid AND cur_user=current_user;  Only the errors with anl_table next to the number can be checked this way. Using Giswater Toolbox it''s also posible to check these errors.',
0,true,'utils','core','AUDIT');


INSERT INTO sys_message (id, error_message, log_level, show_user, project_type, "source", message_type) 
VALUES(4444, 'It is not allowed to change the exploitation because your current psector does not belong to the exploitation you have selected. Click on the Play button to exit psector mode and then, change the exploitation.', 0, true, 'utils', 'core', 'UI');

INSERT INTO sys_message (id, error_message, log_level, show_user, project_type, "source", message_type) 
VALUES(4446, 'It is not allowed to change the sector because your current psector does not belong to the sector you have selected. Click on the Play button to exit psector mode and then, change the sector.', 0, true, 'utils', 'core', 'UI');
