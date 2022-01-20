/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2022/01/02
CREATE TRIGGER gw_trg_vi_tags
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_tags
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_tags');


CREATE TRIGGER gw_trg_vi_demands
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_demands
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_demands');
  

CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_valve
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('VALVE');

    
CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_pump
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('PUMP');


CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_pump_additional
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('PUMP_ADDITIONAL');


CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_shortpipe
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('SHORTPIPE');
  
  
CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_junction
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('JUNCTION');
  
    
CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_connec
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('CONNEC');
  
  
  CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_inlet
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('INLET');
  
    
  CREATE TRIGGER gw_trg_edit_inp_dscenario
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON v_edit_inp_dscenario_virtualvalve
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_edit_inp_dscenario('VIRTUALVALVE');