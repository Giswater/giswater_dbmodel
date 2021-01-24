/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


set search_path = 'SCHEMA_NAME';

DROP TRIGGER IF EXISTS gw_trg_edit_element_pol ON v_edit_element_pol;
DROP VIEW IF EXISTS v_edit_element_pol;
CREATE OR REPLACE VIEW ve_pol_element AS 
 SELECT e.pol_id,
    e.element_id,
    polygon.the_geom
   FROM v_edit_element e
     JOIN polygon USING (pol_id);
     
