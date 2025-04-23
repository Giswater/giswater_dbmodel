/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 1306


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_edit_inp_arc() 
RETURNS trigger AS 
$BODY$
DECLARE 
    v_arc_table varchar;
    v_man_table varchar;
    v_sql varchar;    

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    v_arc_table:= TG_ARGV[0];
    
    IF TG_OP = 'INSERT' THEN
        EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
        "data":{"message":"1026", "function":"1306","parameters":null}}$$);';
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

	-- State
	IF (NEW.state::text != OLD.state::text) THEN
		UPDATE arc SET state=NEW.state WHERE arc_id = OLD.arc_id;
	END IF;
			
	-- The geom
	IF st_equals(NEW.the_geom, OLD.the_geom) IS FALSE  THEN
		UPDATE arc SET the_geom=NEW.the_geom WHERE arc_id = OLD.arc_id;
	END IF;
	
	UPDATE arc 
	SET arccat_id=NEW.arccat_id, sector_id=NEW.sector_id, annotation= NEW.annotation, state_type=NEW.state_type
	WHERE arc_id = OLD.arc_id;

        IF v_arc_table = 'inp_pipe' THEN 
        
	    UPDATE arc SET custom_length=NEW.custom_length WHERE arc_id = OLD.arc_id;
          
            UPDATE inp_pipe SET minorloss=NEW.minorloss, status=NEW.status, custom_roughness=NEW.custom_roughness, custom_dint=NEW.custom_dint,
            bulk_coeff=NEW.bulk_coeff, wall_coeff = NEW.wall_coeff
            WHERE arc_id=OLD.arc_id;
            

        ELSIF v_arc_table = 'inp_virtualvalve' THEN   
            UPDATE inp_virtualvalve SET valve_type=NEW.valve_type, pressure=NEW.pressure, flow=NEW.flow, coef_loss=NEW.coef_loss, curve_id=NEW.curve_id,
            minorloss=NEW.minorloss, status=NEW.status, init_quality=NEW.init_quality
            WHERE arc_id=OLD.arc_id;
           
        ELSIF v_arc_table = 'inp_virtualpump' THEN   
            UPDATE inp_virtualpump  SET power=NEW.power, curve_id=NEW.curve_id, speed=NEW.speed, pattern_id=NEW.pattern_id, status=NEW.status , pump_type=NEW.pump_type,
            effic_curve_id = NEW.effic_curve_id, energy_price = NEW.energy_price, energy_pattern_id = NEW.energy_pattern_id
            WHERE arc_id=OLD.arc_id;

        END IF;

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
    
        EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
        "data":{"message":"1028", "function":"1306","parameters":null}}$$);';
        
        RETURN NEW;
    
    END IF;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;