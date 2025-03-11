/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

CREATE TRIGGER gw_trg_edit_inp_gully
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_gully
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_gully();

CREATE TRIGGER gw_trg_arc_node_values
    AFTER INSERT OR UPDATE OF node_1, node_2
    ON arc
    FOR EACH ROW
    EXECUTE FUNCTION gw_trg_arc_node_values();
    
DROP TRIGGER IF EXISTS gw_trg_vi_timeseries ON vi_timeseries;
CREATE TRIGGER gw_trg_vi_timeseries
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_timeseries
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_timeseries');