/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


DROP TRIGGER IF EXISTS gw_trg_om_lot_x_arc_geom ON om_visit_lot_x_arc; 
CREATE TRIGGER gw_trg_om_lot_x_arc_geom AFTER INSERT OR UPDATE OR DELETE
ON om_visit_lot_x_arc FOR EACH ROW EXECUTE PROCEDURE gw_trg_plan_psector_geom('lot');

DROP TRIGGER IF EXISTS gw_trg_om_lot_x_connec_geom ON om_visit_lot_x_connec; 
CREATE TRIGGER gw_trg_om_lot_x_connec_geom AFTER INSERT OR UPDATE OR DELETE
ON om_visit_lot_x_connec FOR EACH ROW EXECUTE PROCEDURE gw_trg_plan_psector_geom('lot');

DROP TRIGGER IF EXISTS gw_trg_om_lot_x_node_geom ON om_visit_lot_x_node; 
CREATE TRIGGER gw_trg_om_lot_x_node_geom AFTER INSERT OR UPDATE OR DELETE
ON om_visit_lot_x_node FOR EACH ROW EXECUTE PROCEDURE gw_trg_plan_psector_geom('lot');

DROP TRIGGER IF EXISTS gw_trg_edit_team_x_vehicle ON v_om_team_x_vehicle; 
CREATE TRIGGER gw_trg_edit_team_x_vehicle INSTEAD OF INSERT OR UPDATE OR DELETE
ON v_om_team_x_vehicle FOR EACH ROW EXECUTE PROCEDURE gw_trg_edit_team_x_vehicle();

DROP TRIGGER IF EXISTS gw_trg_om_visit ON om_visit_x_node;
CREATE TRIGGER gw_trg_om_visit AFTER INSERT 
ON om_visit_x_node FOR EACH ROW EXECUTE PROCEDURE gw_trg_om_visit('node');

DROP TRIGGER IF EXISTS gw_trg_om_visit ON om_visit_x_arc;
CREATE TRIGGER gw_trg_om_visit AFTER INSERT 
ON om_visit_x_arc FOR EACH ROW EXECUTE PROCEDURE gw_trg_om_visit('arc');

DROP TRIGGER IF EXISTS gw_trg_om_visit ON om_visit_x_connec;
CREATE TRIGGER gw_trg_om_visit AFTER INSERT 
ON om_visit_x_connec FOR EACH ROW EXECUTE PROCEDURE gw_trg_om_visit('connec');

DROP TRIGGER IF EXISTS gw_trg_edit_psector ON v_edit_plan_psector;
CREATE TRIGGER gw_trg_edit_psector INSTEAD OF INSERT OR UPDATE OR DELETE
ON v_edit_plan_psector FOR EACH ROW EXECUTE PROCEDURE ws_test.gw_trg_edit_psector('plan');