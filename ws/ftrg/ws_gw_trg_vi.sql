/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


-- FUNCTION NUMBER : 2812

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_vi()
  RETURNS trigger AS
$BODY$
DECLARE 
  v_view text;
  v_epsg integer;
  geom_array public.geometry array;
  v_point_geom public.geometry;
  rec_arc record;

  
BEGIN

    --Get schema name
    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    
    -- Get SRID
  SELECT epsg INTO v_epsg FROM sys_version ORDER BY id DESC LIMIT 1;
  
    --Get view name
    v_view = TG_ARGV[0];

    --inserts of data via editable views into corresponding arc, node, man_* and inp_* tables
    --split_part(NEW.other_val,';',1) splitting the values concatenated in a vie in order to put it in separated fields of a view
    --nullif(split_part(NEW.other_val,';',1),'')::numeric in case of trying to split the value that may not exist(optional value),
    --nullif function returns null instead of cast value error in case when there is no value in the inp data
    
   IF TG_OP = 'INSERT' THEN
	    
	  IF v_view='vi_valves' THEN
	    INSERT INTO arc (arc_id, node_1, node_2, arccat_id, epa_type, sector_id, dma_id, expl_id, state, state_type) 
	    VALUES (NEW.arc_id, NEW.node_1, NEW.node_2, concat('ARC',NEW.valv_type),'VIRTUALVALVE',1,1,1,1,(SELECT id FROM value_state_type WHERE state=1 LIMIT 1));
	    INSERT INTO inp_virtualvalve (arc_id, diameter, valv_type, minorloss) VALUES (NEW.arc_id,NEW.diameter, NEW.valv_type, NEW.minorloss);
	      IF NEW.valv_type IN ('PRV','PSV','PBV') THEN
		UPDATE inp_virtualvalve SET pressure=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
	      ELSIF NEW.valv_type='FCV' THEN 
		UPDATE inp_virtualvalve SET flow=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
	      ELSIF NEW.valv_type='TCV' THEN
		UPDATE inp_virtualvalve SET coef_loss=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
	      ELSIF NEW.valv_type='GPV' THEN
		UPDATE inp_virtualvalve SET curve_id=NEW.setting WHERE arc_id=NEW.arc_id;
	      END IF;         
	    	    
	  ELSIF v_view='vi_demands' THEN 
	  	INSERT INTO inp_pattern (pattern_id) VALUES (NEW.pattern_id) ON CONFLICT (pattern_id) DO NOTHING;
	 	 	INSERT INTO cat_dscenario (dscenario_id, name) VALUES (1, 'IMPORTINP') ON CONFLICT (dscenario_id) DO NOTHING;
			INSERT INTO inp_dscenario_demand (dscenario_id, feature_id, demand, pattern_id, demand_type) VALUES (1, NEW.feature_id, NEW.demand, NEW.pattern_id, NEW.other);
      	    
	 
	   
	  ELSIF v_view='vi_emitters' THEN
		--INSERT INTO inp_emitter(node_id, coef) VALUES (NEW.node_id, NEW.coef);
		UPDATE inp_junction SET emitter_coeff = NEW.coef WHERE node_id=NEW.node_id;
	    
	  ELSIF v_view='vi_quality' THEN
		--INSERT INTO inp_quality (node_id,initqual) VALUES (NEW.node_id,NEW.initqual);
		UPDATE inp_junction SET init_quality = NEW.initqual WHERE node_id = NEW.node_id;
		UPDATE inp_tank SET init_quality = NEW.initqual WHERE node_id = NEW.node_id;
		UPDATE inp_reservoir SET init_quality = NEW.initqual WHERE node_id = NEW.node_id;
		UPDATE inp_inlet SET init_quality = NEW.initqual WHERE node_id = NEW.node_id;
	    
	  ELSIF v_view='vi_sources' THEN
		--INSERT INTO inp_source(node_id, sourc_type, quality, pattern_id) VALUES (NEW.node_id, NEW.sourc_type, NEW.quality, NEW.pattern_id);

		UPDATE inp_junction SET source_type = NEW.source_type, source_quality = NEW.source_quality, source_pattern_id = NEW.source_pattern_id WHERE node_id = NEW.node_id;
		UPDATE inp_tank SET source_type = NEW.source_type, source_quality = NEW.source_quality, source_pattern_id = NEW.source_pattern_id WHERE node_id = NEW.node_id;
		UPDATE inp_reservoir SET source_type = NEW.source_type, source_quality = NEW.source_quality, source_pattern_id = NEW.source_pattern_id WHERE node_id = NEW.node_id;
		UPDATE inp_inlet SET source_type = NEW.source_type, source_quality = NEW.source_quality, source_pattern_id = NEW.source_pattern_id WHERE node_id = NEW.node_id;

	  ELSIF v_view='vi_reactions' THEN

	  	/*IF NEW.arc_id IN (SELECT arc_id FROM inp_pipe) THEN
	  		UPDATE inp_pipe SET reactionparam = NEW.idval, reactionvalue = NEW.reactionvalue WHERE arc_id=NEW.arc_id;
	  	ELSE 
	  		INSERT INTO inp_reactions (descript) VALUES (concat(NEW.idval,' ', NEW.arc_id,' ',NEW.reactionvalue));
	  	END IF;*/

	  ELSIF v_view='vi_energy' THEN
	  	IF NEW.pump_id ilike 'PUMP%' THEN
	  		UPDATE inp_virtualpump SET energyvalue = NEW.energyvalue 
	  		WHERE arc_id = REGEXP_REPLACE(LTRIM (NEW.pump_id, 'PUMP '),' ','');
	  	ELSE
	  		INSERT INTO inp_energy(descript) select concat(NEW.pump_id, ' ',NEW.idval); 
	  	END IF;

	  ELSIF v_view='vi_mixing' THEN
	    INSERT INTO inp_mixing(node_id, mix_type, value) VALUES (NEW.node_id, NEW.mix_type, NEW.value);
	    
	  ELSIF v_view='vi_times' THEN 
	    IF NEW.value IS NULL THEN
	      INSERT INTO config_param_user (parameter, value, cur_user) 
	      VALUES (concat('inp_times_',(lower(split_part(NEW.parameter,'_',1)))), split_part(NEW.parameter,'_',2), current_user)
	      ON CONFLICT (parameter,cur_user) DO NOTHING;
	    ELSE
	      INSERT INTO config_param_user (parameter, value, cur_user) 
	      VALUES (concat('inp_times_',(lower(NEW.parameter))), NEW.value, current_user) 
	     ON CONFLICT (parameter,cur_user) DO NOTHING;
	    END IF;
	    
	  ELSIF v_view='vi_report' THEN
	    INSERT INTO config_param_user (parameter, value, cur_user) 
	    SELECT id, vdefault, current_user FROM sys_param_user 
	    WHERE layoutname IN ('lyt_reports_1', 'lyt_reports_2') AND ismandatory=true AND vdefault IS NOT NULL
	    ON CONFLICT (parameter,cur_user) DO NOTHING;
	    
	 
	    
	  ELSIF v_view='vi_options' THEN
	    INSERT INTO config_param_user (parameter, value, cur_user) 
	    VALUES (concat('inp_options_',(lower(NEW.parameter))), NEW.value, current_user) 
	    ON CONFLICT (parameter,cur_user) DO NOTHING;
	  END IF;
	  
	  RETURN NEW; 	
    END IF;

 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
