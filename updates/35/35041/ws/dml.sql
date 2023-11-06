/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;

-- 27/10/23

UPDATE cat_feature_node SET epa_default='UNDEFINED', isarcdivide=false WHERE id='AIR_VALVE';

UPDATE sys_message SET hint_message='Unlink hydrometers first or set edit_connec_downgrade_force on config_param_system to true' WHERE id=3194;
