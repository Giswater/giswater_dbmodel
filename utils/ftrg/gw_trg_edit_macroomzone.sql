/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

--FUNCTION CODE: 3418

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_macroomzone()
  RETURNS trigger AS
$BODY$

DECLARE
	v_view_name TEXT; -- EDIT | UI
	v_macroomzone_id INTEGER;
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

		SELECT max(macroomzone_id::integer)+1 INTO v_macroomzone_id FROM macroomzone WHERE macroomzone_id::text ~ '^[0-9]+$';
		IF NEW.code IS NULL THEN
			NEW.code := v_macroomzone_id::text;
		END IF;

		IF NEW.active IS NULL THEN
			NEW.active = TRUE;
		END IF;

	   INSERT INTO macroomzone (macroomzone_id, code, name, descript, active, expl_id, sector_id, muni_id, stylesheet, link, lock_level, addparam, created_at, created_by, updated_at, updated_by)
	   VALUES (v_macroomzone_id, NEW.code, NEW.name, NEW.descript, NEW.active, NEW.expl_id, NEW.sector_id, NEW.muni_id, 
	   NEW.stylesheet::json, NEW.link, NEW.lock_level, NEW.addparam::json, now(), current_user, now(), current_user);

    	IF v_view_name = 'EDIT' THEN
			UPDATE macroomzone SET the_geom = NEW.the_geom WHERE macroomzone_id = NEW.macroomzone_id;
		END IF;

		RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
		UPDATE macroomzone
		SET macroomzone_id=NEW.macroomzone_id, code=NEW.code, name=NEW.name, descript=NEW.descript, active=NEW.active, expl_id=NEW.expl_id, sector_id=NEW.sector_id, 
		muni_id=NEW.muni_id, stylesheet=NEW.stylesheet::json, link=NEW.link, lock_level=NEW.lock_level, addparam=NEW.addparam::json, updated_at=now(), updated_by = current_user
		WHERE macroomzone_id=NEW.macroomzone_id;

		IF v_view_name = 'EDIT' THEN
			UPDATE macroomzone SET the_geom = NEW.the_geom WHERE macroomzone_id = OLD.macroomzone_id;
		END IF;

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

		DELETE FROM macroomzone WHERE macroomzone_id=OLD.macroomzone_id;
        RETURN NULL;

    END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

