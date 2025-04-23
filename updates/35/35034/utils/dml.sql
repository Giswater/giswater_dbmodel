/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO config_param_system ("parameter", value, descript, "label", dv_querytext, dv_filterbyfield, isenabled, layoutorder, project_type, dv_isparent, isautoupdate, "datatype", widgettype, ismandatory, iseditable, dv_orderby_id, dv_isnullvalue, stylesheet, widgetcontrols, placeholder, standardvalue, layoutname)
VALUES('edit_connec_downgrade_force', 'false', 'If true allow downgrade connecs no matter if they have operative hydrometers related', NULL, NULL, NULL, false, NULL, 'utils', NULL, NULL, 'boolean', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

UPDATE sys_function SET input_params='json', return_type='json' WHERE id=3204;

UPDATE config_toolbox SET alias = 'Configuration of border features', inputparams = 
'[{"widgetname":"configZone", "label":"Configurate zone:","widgettype":"combo","datatype":"text","layoutname":"grl_option_parameters","layoutorder":1,
"comboIds":["EXPL", "SECTOR", "ALL"], 
"comboNames":["EXPLOITATION", "SECTOR", "EXPLOITATION & SECTOR"]}]', active = true WHERE id=3204;

ALTER TABLE connec DISABLE TRIGGER gw_trg_connect_update;

UPDATE connec set pjoint_type=a.exit_type, pjoint_id=a.exit_id
from (select feature_id, exit_type, exit_id from link)a
where a.feature_id=connec_id and pjoint_id is null and state=1;

ALTER TABLE connec ENABLE TRIGGER gw_trg_connect_update;