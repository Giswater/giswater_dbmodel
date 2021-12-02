/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2732


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_connect_update() RETURNS trigger LANGUAGE plpgsql AS $$

/*
This trigger updates mapzone connect columns ( if that connecs are connected) and redraw link geometry if end connect geometry is also updated
As updateable links only must be class 2 (wich geometry is stored on link table, it is not need to work with v_edit_link, and as a result this trigger works with table link)
*/

DECLARE 

linkrec Record; 
querystring text;
connecRecord1 record; 
connecRecord2 record;
connecRecord3 record;
v_projectype text;
v_move_polgeom boolean = true;
v_featuretype text;
gullyRecord1 record;
gullyRecord2 record;
gullyRecord3 record;
v_link record;
xvar float;
yvar float;
v_autoupdate_dma boolean;
v_autoupdate_fluid boolean;
v_pol_id text;
BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    v_featuretype:= TG_ARGV[0];

	v_move_polgeom = (SELECT value FROM config_param_user WHERE parameter='edit_gully_autoupdate_polgeom' AND cur_user=current_user);

	v_projectype = (SELECT project_type FROM sys_version ORDER BY id DESC LIMIT 1);

	-- control autoupdate_dma and fluid
	SELECT value::boolean INTO v_autoupdate_dma FROM config_param_system WHERE parameter='edit_connect_autoupdate_dma';
	SELECT value::boolean INTO v_autoupdate_fluid FROM config_param_system WHERE parameter='edit_connect_autoupdate_fluid';
	
	
	IF v_featuretype='connec' THEN
	
		-- updating links geom
		IF st_equals (NEW.the_geom, OLD.the_geom) IS FALSE THEN

			--Select links with start on the updated connec
			querystring := 'SELECT * FROM link WHERE (link.feature_id = ' || quote_literal(NEW.connec_id) || ' AND feature_type=''CONNEC'')';
			FOR linkrec IN EXECUTE querystring
			LOOP
				EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, 0, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") USING linkrec.the_geom, NEW.the_geom; 
			END LOOP;

			--Select links with end on the updated connec
			querystring := 'SELECT * FROM link WHERE (link.exit_id = ' || quote_literal(NEW.connec_id) || ' AND exit_type=''CONNEC'')';
			FOR linkrec IN EXECUTE querystring
			LOOP
				EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, ST_NumPoints($1) - 1, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") 
				USING linkrec.the_geom, NEW.the_geom; 
			END LOOP;		
		END IF;
		
		-- update the rest of the feature parameters
		FOR v_link IN SELECT * FROM link WHERE (exit_type='CONNEC' AND exit_id=OLD.connec_id)
		LOOP

			IF v_link.feature_type='CONNEC' THEN
				IF v_autoupdate_dma IS FALSE THEN
					-- update connec, mandatory to use v_edit_connec because it's identified and managed when arc_id comes from plan psector tables
					UPDATE v_edit_connec SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE connec_id=v_link.feature_id;
				ELSE
					UPDATE v_edit_connec SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, dma_id= NEW.dma_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE connec_id=v_link.feature_id;
				END IF;
							
			
			ELSIF v_link.feature_type='GULLY' THEN
				IF v_autoupdate_dma IS FALSE THEN
					-- update gully, mandatory to use v_edit_gully because it's identified and managed when arc_id comes from plan psector tables
					UPDATE v_edit_gully SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE gully_id=v_link.feature_id;
				ELSE
					UPDATE v_edit_gully SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, dma_id= NEW.dma_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE gully_id=v_link.feature_id;
				END IF;
				
			END IF;
			
		END LOOP;
		-- update fields that inherit values from arc
		IF v_projectype = 'WS' AND NEW.arc_id IS NOT NULL AND (NEW.arc_id != OLD.arc_id) THEN
			UPDATE connec SET presszone_id=a.presszone_id, dqa_id=a.dqa_id, minsector_id=a.minsector_id
			FROM (SELECT connec_id, a.presszone_id, a.dqa_id, a.minsector_id FROM v_edit_connec JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
			WHERE a.connec_id=connec.connec_id;
            
			IF v_autoupdate_fluid IS TRUE THEN
                UPDATE connec SET fluid_type = a.fluid_type
                FROM (SELECT connec_id, a.fluid_type FROM v_edit_connec JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
                WHERE a.connec_id=connec.connec_id;
			END IF;
		END IF;
		
		IF v_projectype = 'UD' AND v_autoupdate_fluid IS TRUE AND NEW.arc_id IS NOT NULL AND (NEW.arc_id != OLD.arc_id) THEN
			UPDATE connec SET fluid_type = a.fluid_type
			FROM (SELECT connec_id, a.fluid_type FROM v_edit_connec JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
			WHERE a.connec_id=connec.connec_id;

			UPDATE gully SET fluid_type = a.fluid_type
			FROM (SELECT gully_id, a.fluid_type FROM v_edit_gully JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
			WHERE a.gully_id=gully.gully_id;
		END IF;

		-- Updating polygon geometry in case of exists it
		v_pol_id:= (SELECT pol_id FROM polygon WHERE feature_id=OLD.connec_id);
		IF st_equals (NEW.the_geom, OLD.the_geom) IS FALSE AND (v_pol_id IS NOT NULL) THEN
			xvar= (st_x(NEW.the_geom)-st_x(OLD.the_geom));
			yvar= (st_y(NEW.the_geom)-st_y(OLD.the_geom));		
			UPDATE polygon SET the_geom=ST_translate(the_geom, xvar, yvar) WHERE pol_id=v_pol_id;
		END IF;      
				

	ELSIF v_featuretype='gully' THEN
		v_pol_id:= (SELECT pol_id FROM polygon WHERE feature_id=OLD.gully_id);
		-- Updating polygon geometry in case of exists it
		IF st_equals (NEW.the_geom, OLD.the_geom) IS FALSE AND v_move_polgeom IS TRUE AND (v_pol_id IS NOT NULL) THEN   
			xvar= (st_x(NEW.the_geom)-st_x(OLD.the_geom));
			yvar= (st_y(NEW.the_geom)-st_y(OLD.the_geom));		
			UPDATE polygon SET the_geom=ST_translate(the_geom, xvar, yvar) WHERE pol_id=v_pol_id;
		END IF;
		
		-- updating links geom
		IF st_equals (NEW.the_geom, OLD.the_geom) IS FALSE THEN
	
			--Select links with start on the updated gully
			querystring := 'SELECT * FROM link WHERE (link.feature_id = ' || quote_literal(NEW.gully_id) || ' AND feature_type=''GULLY'')';
			FOR linkrec IN EXECUTE querystring
			LOOP
				EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, 0, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") USING linkrec.the_geom, NEW.the_geom; 
			END LOOP;

			--Select links with end on the updated gully
			querystring := 'SELECT * FROM link WHERE (link.exit_id = ' || quote_literal(NEW.gully_id) || ' AND exit_type=''GULLY'')';
			FOR linkrec IN EXECUTE querystring
			LOOP
				EXECUTE 'UPDATE link SET the_geom = ST_SetPoint($1, ST_NumPoints($1) - 1, $2) WHERE link_id = ' || quote_literal(linkrec."link_id") 
				USING linkrec.the_geom, NEW.the_geom; 
			END LOOP;
		END IF;
		
		-- update the rest of feature parameters
		FOR v_link IN SELECT * FROM link WHERE (exit_type='GULLY' AND exit_id=OLD.gully_id)
		LOOP
			IF v_link.feature_type='CONNEC' THEN
				IF v_autoupdate_dma IS FALSE THEN			
					UPDATE v_edit_connec SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE connec_id=v_link.feature_id;
				ELSE
					UPDATE v_edit_connec SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, dma_id= NEW.dma_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE connec_id=v_link.feature_id;
				END IF;
			
			ELSIF v_link.feature_type='GULLY' THEN
				IF v_autoupdate_dma IS FALSE THEN		
					UPDATE v_edit_gully SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE gully_id=v_link.feature_id;
				ELSE
					UPDATE v_edit_gully SET arc_id=NEW.arc_id, expl_id=NEW.expl_id, dma_id= NEW.dma_id, sector_id=NEW.sector_id, pjoint_id=NEW.pjoint_id, pjoint_type=NEW.pjoint_type
					WHERE gully_id=v_link.feature_id;
				END IF;
				
			END IF;

		END LOOP;
        
        -- update fields that inherit values from arc
        IF v_autoupdate_fluid IS TRUE AND NEW.arc_id IS NOT NULL AND (NEW.arc_id != OLD.arc_id) THEN
			UPDATE connec SET fluid_type = a.fluid_type
			FROM (SELECT connec_id, a.fluid_type FROM v_edit_connec JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
			WHERE a.connec_id=connec.connec_id;

			UPDATE gully SET fluid_type = a.fluid_type
			FROM (SELECT gully_id, a.fluid_type FROM v_edit_gully JOIN arc a USING (arc_id) WHERE a.arc_id = NEW.arc_id)a
			WHERE a.gully_id=gully.gully_id;
		END IF;
		
	END IF;
		
    RETURN NEW;
    
END; 
$$;
