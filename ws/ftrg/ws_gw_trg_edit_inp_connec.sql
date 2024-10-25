/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION NODE: 2730


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_inp_connec()
RETURNS trigger AS
$BODY$
DECLARE

BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	-- Control insertions ID
	IF TG_OP = 'INSERT' THEN
		EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
		"data":{"message":"1030", "function":"1310","debug_msg":null}}$$);';
	RETURN NEW;


	ELSIF TG_OP = 'UPDATE' THEN

		-- The geom
		IF (ST_equals (NEW.the_geom, OLD.the_geom)) IS FALSE THEN
			UPDATE connec SET the_geom=NEW.the_geom WHERE connec_id = OLD.connec_id;

			--update elevation from raster
			IF (SELECT json_extract_path_text(value::json,'activated')::boolean FROM config_param_system WHERE parameter='admin_raster_dem') IS TRUE
			 AND (NEW.elevation IS NULL) AND
			(SELECT upper(value)  FROM config_param_user WHERE parameter = 'edit_update_elevation_from_dem' and cur_user = current_user) = 'TRUE' THEN
				NEW.elevation = (SELECT ST_Value(rast,1,NEW.the_geom,false) FROM v_ext_raster_dem WHERE id =
					(SELECT id FROM v_ext_raster_dem WHERE
					st_dwithin (ST_MakeEnvelope(
					ST_UpperLeftX(rast),
					ST_UpperLeftY(rast),
					ST_UpperLeftX(rast) + ST_ScaleX(rast)*ST_width(rast),
					ST_UpperLeftY(rast) + ST_ScaleY(rast)*ST_height(rast), st_srid(rast)), NEW.the_geom, 1) LIMIT 1));
			END IF;
		END IF;

		UPDATE inp_connec
			SET demand=NEW.demand, pattern_id=NEW.pattern_id, peak_factor=NEW.peak_factor, custom_roughness = NEW.custom_roughness ,custom_length = NEW.custom_length, custom_dint = NEW.custom_dint,
			status = NEW.status, minorloss = NEW.minorloss, emitter_coeff = NEW.emitter_coeff, init_quality= NEW.init_quality, source_type= NEW.source_type, source_quality= NEW.source_quality,
			source_pattern_id= NEW.source_pattern_id
			WHERE connec_id=OLD.connec_id;

		IF (OLD.elevation::TEXT!=NEW.elevation::TEXT) or (OLD.depth::TEXT!=NEW.depth::TEXT) OR (OLD.conneccat_id!=NEW.conneccat_id) OR (OLD.annotation!=NEW.annotation) THEN
			UPDATE connec
			SET elevation=NEW.elevation, "depth"=NEW."depth", conneccat_id=NEW.conneccat_id, annotation=NEW.annotation
			WHERE connec_id=OLD.connec_id;
		END IF;

		IF quote_nullable(NEW.arc_id) != quote_nullable(OLD.arc_id) THEN
			UPDATE v_edit_connec SET arc_id=NEW.arc_id
			WHERE connec_id=OLD.connec_id;
		END IF;

		RETURN NEW;

	    ELSIF TG_OP = 'DELETE' THEN
		EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
		"data":{"message":"1032", "function":"1310","debug_msg":null}}$$);';
		RETURN NEW;
	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
