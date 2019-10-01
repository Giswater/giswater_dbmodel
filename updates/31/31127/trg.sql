/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


DROP TRIGGER gw_trg_topocontrol_node ON node;

CREATE TRIGGER gw_trg_topocontrol_node
  AFTER INSERT OR UPDATE OF the_geom, state, top_elev, ymax, elev, custom_top_elev, custom_ymax, custom_elev
  ON node  FOR EACH ROW  EXECUTE PROCEDURE gw_trg_topocontrol_node();
