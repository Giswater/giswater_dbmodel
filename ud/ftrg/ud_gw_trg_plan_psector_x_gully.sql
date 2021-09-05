/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
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
v_arcaux text;

BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    -- control if gully has link
	IF TG_OP = 'INSERT' AND (SELECT link_id FROM link WHERE feature_id = NEW.gully_id) IS NULL THEN
        EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
         "data":{"message":"3138", "function":"2968","debug_msg":null}}$$);';
	END IF;

	-- control if gully exists and it is link_class =  2
	IF (SELECT count(*) FROM plan_psector_x_gully WHERE gully_id = NEW.gully_id) > 0 THEN
		IF (SELECT link_geom FROM plan_psector_x_gully WHERE gully_id = NEW.gully_id ORDER BY link_geom limit 1) IS NULL 
		AND (SELECT state FROM gully WHERE gully_id = NEW.gully_id)=2 THEN
		        EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3082", "function":"2968","debug_msg":null}}$$);';
		END IF;
	END IF;

	SELECT gully.state, gully.arc_id INTO v_stateaux, v_arcaux FROM gully WHERE gully_id=NEW.gully_id;
	
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
		NEW.arc_id=v_arcaux;
		
	ELSIF v_stateaux=2 THEN
		IF NEW.state = 0 THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3182", "function":"2968","debug_msg":""}}$$);';
		END IF;
		NEW.doable=true;
	END IF;

	-- profilactic control of doable
	IF NEW.doable IS NULL THEN
		NEW.doable =  TRUE;
	END IF;

	RETURN NEW;

END;  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
