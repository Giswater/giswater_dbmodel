/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3062


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_inp_pattern() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE 
v_table text;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
   
   v_table = TG_ARGV[0];

	-- Control insertions ID
	IF TG_OP = 'INSERT' THEN
		
		IF v_table = 'inp_pattern' THEN
			INSERT INTO inp_pattern (pattern_id, observ, pattern_type, tsparameters,expl_id, active) 
			VALUES (NEW.pattern_id, NEW.observ, NEW.pattern_type, NEW.tsparameters::json, NEW.expl_id, NEW.active) ;
		
		ELSIF v_table = 'inp_pattern_value' THEN
			INSERT INTO inp_pattern_value (pattern_id,factor_1,factor_2,factor_3,factor_4,factor_5,factor_6,factor_7,factor_8,factor_9,
			factor_10,factor_11,factor_12,factor_13,factor_14,factor_15,factor_16,factor_17,
			factor_18, factor_19, factor_20, factor_21, factor_22, factor_23, factor_24) 
			VALUES (NEW.pattern_id,NEW.factor_1,NEW.factor_2,NEW.factor_3,NEW.factor_4,NEW.factor_5,NEW.factor_6,NEW.factor_7,NEW.factor_8,NEW.factor_9,
			NEW.factor_10, NEW.factor_11,NEW.factor_12, NEW.factor_13,NEW.factor_14,NEW.factor_15,NEW.factor_16,NEW.factor_17,
			NEW.factor_18, NEW.factor_19, NEW.factor_20, NEW.factor_21, NEW.factor_22,NEW.factor_23, NEW.factor_24);
			
		END IF;
		
		RETURN NEW;

	ELSIF TG_OP = 'UPDATE' THEN
		
		IF v_table = 'inp_pattern' THEN
			UPDATE inp_pattern SET pattern_id=NEW.pattern_id, observ=NEW.observ, pattern_type=NEW.pattern_type, tsparameters=NEW.tsparameters::json, expl_id=NEW.expl_id,
			active=NEW.active
			WHERE pattern_id=OLD.pattern_id;
		END IF;

		IF v_table = 'inp_pattern_value' THEN
			UPDATE inp_pattern_value SET 
			factor_1=NEW.factor_1,factor_2=NEW.factor_2,factor_3=NEW.factor_3,factor_4=NEW.factor_4,factor_5=NEW.factor_5,factor_6=NEW.factor_6,
			factor_7=NEW.factor_7,factor_8=NEW.factor_8,factor_9=NEW.factor_9,factor_10=NEW.factor_10, factor_11=NEW.factor_11,factor_12=NEW.factor_12, 
			factor_13=NEW.factor_13,factor_14=NEW.factor_14,factor_15=NEW.factor_15,factor_16=NEW.factor_16,factor_17=NEW.factor_17,
			factor_18=NEW.factor_18, factor_19=NEW.factor_19, factor_20=NEW.factor_20, factor_21=NEW.factor_21, factor_22=NEW.factor_22, factor_23=NEW.factor_23, factor_24=NEW.factor_24
			WHERE pattern_id=OLD.pattern_id;
		END IF;

		RETURN NEW;
        
	ELSIF TG_OP = 'DELETE' THEN
		IF v_table = 'inp_pattern' THEN
			DELETE FROM inp_pattern WHERE pattern_id=OLD.pattern_id;

		ELSIF v_table = 'inp_pattern_value' THEN
			DELETE FROM inp_pattern_value WHERE pattern_id=OLD.pattern_id;
		END IF;

		RETURN OLD;
   
	END IF;
       
END;
$$;
  