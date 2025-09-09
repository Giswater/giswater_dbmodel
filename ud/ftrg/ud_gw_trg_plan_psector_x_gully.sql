/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 2968

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_plan_psector_x_gully()
  RETURNS trigger AS
$BODY$

/*
This trigger controls if connect has link and wich class of link it has as well as sets some values for states
*/

DECLARE 
v_stateaux smallint;
v_explaux smallint;
v_psector_expl smallint;
v_link_id integer;

BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
  
    SELECT expl_id INTO v_psector_expl FROM plan_psector WHERE psector_id=NEW.psector_id;
	SELECT gully.state, gully.expl_id INTO v_stateaux, v_explaux FROM gully WHERE gully_id=NEW.gully_id;
    
    -- do not allow to insert features with expl diferent from psector expl
	IF v_explaux<>v_psector_expl THEN
		EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
		"data":{"message":"3234", "function":"1130","parameters":null}}$$);';
	END IF;
	
	IF NEW.state IS NULL AND v_stateaux=1 THEN
		NEW.state=0;
	ELSIF NEW.state IS NULL AND v_stateaux=2 THEN
		NEW.state=1;
	END IF;
	
	IF NEW.state = 1 AND v_stateaux = 1 THEN
		NEW.doable=false;
        -- looking for arc_id state=2 closest
	
	ELSIF NEW.state = 0 AND v_stateaux=1 THEN
		NEW.doable=false;
		
	ELSIF v_stateaux=2 THEN
		IF NEW.state = 0 THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3182", "function":"2968","parameters":null}}$$);';
		END IF;
		NEW.doable=true;
	END IF;

	-- profilactic control of doable
	IF NEW.doable IS NULL THEN
		NEW.doable =  TRUE;
	END IF;

	SELECT link_id INTO v_link_id FROM ve_link WHERE feature_id = NEW.gully_id LIMIT 1;

	IF TG_OP = 'INSERT' THEN
		IF v_link_id IS NOT NULL THEN
			NEW.link_id = v_link_id;
		END IF;
	END IF;

	RETURN NEW;

END;  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
