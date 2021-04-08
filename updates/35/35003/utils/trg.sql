/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2020/04/07
DROP TRIGGER IF EXISTS gw_trg_edit_config_sysfields ON ve_config_sysfields; 
CREATE TRIGGER gw_trg_edit_config_sysfields INSTEAD OF UPDATE ON ve_config_sysfields 
FOR EACH ROW EXECUTE PROCEDURE gw_trg_edit_config_sysfields();

DROP TRIGGER IF EXISTS gw_trg_edit_config_addfields ON ve_config_addfields; 
CREATE TRIGGER gw_trg_edit_config_addfields INSTEAD OF UPDATE ON ve_config_addfields
FOR EACH ROW EXECUTE PROCEDURE gw_trg_edit_config_addfields();

DROP TRIGGER IF EXISTS gw_trg_config_control ON config_form_fields; 
CREATE TRIGGER gw_trg_config_control BEFORE INSERT OR UPDATE OR DELETE ON config_form_fields
FOR EACH ROW EXECUTE PROCEDURE gw_trg_config_control('config_form_fields');

DROP TRIGGER IF EXISTS gw_trg_typevalue_fk ON config_form_fields; 
CREATE TRIGGER gw_trg_typevalue_fk AFTER INSERT OR UPDATE ON config_form_fields
FOR EACH ROW EXECUTE PROCEDURE gw_trg_typevalue_fk('config_form_fields');

DROP TRIGGER IF EXISTS gw_trg_edit_vnode ON v_vnode;