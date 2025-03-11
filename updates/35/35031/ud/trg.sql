/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2022/09/29
CREATE TRIGGER gw_trg_edit_review_node
  INSTEAD OF INSERT OR UPDATE
  ON v_edit_review_node
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_review_node();


CREATE TRIGGER gw_trg_edit_review_audit_node
  INSTEAD OF UPDATE
  ON v_edit_review_audit_node
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_review_audit_node();


CREATE TRIGGER gw_trg_edit_drainzone
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_drainzone
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_drainzone();


CREATE TRIGGER gw_trg_edit_review_connec
  INSTEAD OF INSERT OR UPDATE
  ON v_edit_review_connec
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_review_connec();

CREATE TRIGGER gw_trg_edit_review_arc
  INSTEAD OF INSERT OR UPDATE
  ON v_edit_review_arc
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_review_arc();

CREATE TRIGGER w_trg_edit_review_gully
  INSTEAD OF INSERT OR UPDATE
  ON v_edit_review_gully
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_review_gully();


DROP TRIGGER IF EXISTS gw_trg_vi_timeseries ON vi_timeseries;
CREATE TRIGGER gw_trg_vi_timeseries
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_timeseries
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_timeseries');


CREATE TRIGGER gw_trg_edit_link
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_link_connec
  FOR EACH ROW 
  EXECUTE PROCEDURE gw_trg_edit_link();
  
 
 CREATE TRIGGER gw_trg_edit_link
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_link_gully
  FOR EACH ROW 
  EXECUTE PROCEDURE gw_trg_edit_link();

  
CREATE TRIGGER gw_trg_edit_link
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_link
  FOR EACH ROW 
  EXECUTE PROCEDURE gw_trg_edit_link();

CREATE TRIGGER gw_trg_edit_plan_psector_connec
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_plan_psector_x_connec
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_plan_psector_x_connect('plan_psector_x_connec');


CREATE TRIGGER gw_trg_edit_plan_psector_gully
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_plan_psector_x_gully
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_plan_psector_x_connect('plan_psector_x_gully');
