/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2838


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_cat_team()
  RETURNS trigger AS
$BODY$
DECLARE 


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	
    IF TG_OP = 'INSERT' THEN
	
    -- FEATURE INSERT
        INSERT INTO cat_team (idval, descript, active)
		VALUES (NEW."Equip", NEW."Descripcio", NEW."Actiu");

	RETURN NEW;
		
    ELSIF TG_OP = 'UPDATE' THEN
   	-- FEATURE UPDATE
		UPDATE cat_team 
		SET id=NEW.id, idval=NEW."Equip", descript=NEW."Descripcio", active=NEW."Actiu"
		WHERE id=NEW.id;
		
        RETURN NEW;

		
     ELSIF TG_OP = 'DELETE' THEN  
	 -- FEATURE DELETE
		DELETE FROM cat_team WHERE id = OLD.id;		

	RETURN NULL;
     
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


