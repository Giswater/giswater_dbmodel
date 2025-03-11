/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1312

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_macrodma()
  RETURNS trigger AS
$BODY$

DECLARE

	v_view_name TEXT; -- EDIT | UI

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	-- Get parameters
	v_view_name = UPPER(TG_ARGV[0]);

	-- Validate parameters
	IF v_view_name IS NULL THEN
		RAISE EXCEPTION 'Param ''v_view_name'' is requiered';
	END IF;

	IF v_view_name NOT IN ('EDIT', 'UI') THEN
		RAISE EXCEPTION 'Param ''v_view_name'' is wrong, need to be: ''EDIT'' or ''UI''.';
	END IF;

   	IF TG_OP = 'INSERT' THEN
    	-- expl_id
    	IF v_view_name = 'EDIT' THEN
			IF NEW.the_geom IS NOT NULL THEN
				IF NEW.expl_id IS NULL THEN
            		IF ((SELECT COUNT(*) FROM exploitation WHERE active IS TRUE ) = 0) THEN
                  		EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
                  		"data":{"message":"1110", "function":"1312","parameters":null}}$$);';
               			RETURN NULL;
               		END IF;
					NEW.expl_id := (SELECT expl_id FROM exploitation WHERE active IS TRUE AND ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
               		IF (NEW.expl_id IS NULL) THEN
				      	NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='edit_exploitation_vdefault' AND "cur_user"="current_user"());
               		END IF;
				END IF;
			END IF;
		END IF;

		IF v_view_name = 'UI' THEN
			IF NEW.active IS NULL THEN
				NEW.active = TRUE;
			END IF;
		END IF;

	   INSERT INTO macrodma (macrodma_id, name, descript, expl_id, lock_level) VALUES (NEW.macrodma_id, NEW.name, NEW.descript, NEW.expl_id, NEW.lock_level);

    	IF v_view_name = 'UI' THEN
			UPDATE macrodma SET active = NEW.active WHERE macrodma_id = NEW.macrodma_id;
		ELSIF v_view_name = 'EDIT' THEN
			UPDATE macrodma SET the_geom = NEW.the_geom WHERE macrodma_id = NEW.macrodma_id;
		END IF;

		RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
		UPDATE macrodma
		SET macrodma_id=NEW.macrodma_id, name=NEW.name, descript=NEW.descript, expl_id=NEW.expl_id, lock_level=NEW.lock_level
		WHERE macrodma_id=NEW.macrodma_id;

		IF v_view_name = 'UI' THEN
			UPDATE macrodma SET active = NEW.active WHERE macrodma_id = OLD.macrodma_id;
		ELSIF v_view_name = 'EDIT' THEN
			UPDATE macrodma SET the_geom = NEW.the_geom WHERE macrodma_id = OLD.macrodma_id;
		END IF;

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

		DELETE FROM macrodma WHERE macrodma_id=OLD.macrodma_id;
        RETURN NULL;

    END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

