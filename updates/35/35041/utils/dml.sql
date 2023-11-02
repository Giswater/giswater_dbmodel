/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;

INSERT INTO config_typevalue(typevalue, id, idval, camelstyle, addparam)
VALUES ('tabname_typevalue', 'tab_exploitation_add', 'tab_exploitation_add', 'ExploitationAdd', null) ON CONFLICT (typevalue, id) DO NOTHING;

INSERT INTO sys_fprocess(fid, fprocess_name, project_type, parameters, source, isaudit, fprocess_type, addparam)
VALUES (518, 'Set end feature', 'utils', null, 'core', true, 'Function process', null) 
ON CONFLICT (fid) DO NOTHING;


UPDATE sys_message SET error_message = 'IT iS IMPOSSIBLE TO UPDATE ARC_ID FROM PSECTOR DIALOG BECAUSE THIS PLANNED LINK HAS NOT ARC AS EXIT-TYPE',
hint_message = 'USE CONNECT(CONNEC-GULLY) DIALOG OR EDIT THE GEOMETRY OF THE LINK ON CANVAS TO UPDATE IT'
where id = 3212;

UPDATE config_form_tabs SET orderby=4 WHERE tabname='tab_event' AND orderby IS NULL;
