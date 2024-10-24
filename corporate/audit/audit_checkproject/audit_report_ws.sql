/*
Copyright © 2023 by BGEO. All rights reserved.
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


INSERT INTO config_report
(id, alias, query_text, addparam, filterparam, sys_role, descript, active, device)
VALUES(903, 'Check health WS', 'SELECT * FROM audit.v_fidlog_ws_index', '{"orderBy":"1", "orderType": "DESC"}'::json, NULL, 'role_master', NULL, true, '{4}');

INSERT INTO config_report
(id, alias, query_text, addparam, filterparam, sys_role, descript, active, device)
VALUES(904, 'Check health WS (Detail)', 'SELECT date, type, fprocess_name, (case when criticity = 2 then ''WARNING'' WHEN criticity = 3 THEN ''ERROR'' END) criticity, value 
FROM audit.v_fidlog_ws_aux WHERE type IS NOT NULL
', '{"orderBy":"1", "orderType": "DESC"}'::json, '[{"columnname":"type", "label":"Type:",
 "widgettype":"combo","datatype":"text","layoutorder":2, "dvquerytext":"Select distinct on (type) type AS id, type AS idval FROM audit.v_fidlog_ws_aux ORDER BY type DESC"}]'::json, 'role_master', NULL, true, '{4}');



