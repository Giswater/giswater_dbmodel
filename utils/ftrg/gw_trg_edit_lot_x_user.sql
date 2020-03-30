/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2842


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_lot_x_user()
  RETURNS trigger AS
$BODY$
DECLARE 

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    IF TG_OP = 'UPDATE' THEN
   	-- FEATURE UPDATE
		UPDATE om_visit_lot_x_user 
		SET starttime=NEW."Data inici", endtime=NEW."Data fi"
		WHERE id=NEW.id;
		
        RETURN NEW;
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


