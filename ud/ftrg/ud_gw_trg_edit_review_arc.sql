/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION NUMBER: 2470




CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_review_arc()  RETURNS trigger AS
$BODY$

DECLARE
	v_rev_arc_y1_tol double precision;
	v_rev_arc_y2_tol double precision;
	v_tol_filter_bool boolean;
	v_review_status smallint;
	rec_arc record;


BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	-- getting tolerance parameters
	v_rev_arc_y1_tol :=(SELECT value::json->>'y1' FROM config_param_system WHERE parameter = 'edit_review_arc_tolerance');
	v_rev_arc_y2_tol :=(SELECT value::json->>'y2' FROM config_param_system WHERE parameter = 'edit_review_arc_tolerance');		

--get value from edit_review_auto_field_checked
	IF (SELECT value::boolean FROM config_param_system WHERE parameter = 'edit_review_auto_field_checked') IS TRUE THEN
		NEW.field_checked=TRUE;
	END IF;
	
	--getting original values
	SELECT arc_id,y1,y2,arc_type, arccat_id, matcat_id, 
	annotation, observ, cat_shape, cat_geom1, cat_geom2, the_geom, expl_id INTO rec_arc 
	FROM vu_arc WHERE arc_id=NEW.arc_id;
	
	IF NEW.field_checked=TRUE THEN				

	--looking for insert/update/delete values on audit table
		IF 	abs(rec_arc.y1-NEW.y1)>v_rev_arc_y1_tol OR  (rec_arc.y1 IS NULL AND NEW.y1 IS NOT NULL) OR
			abs(rec_arc.y2-NEW.y2)>v_rev_arc_y2_tol OR  (rec_arc.y2 IS NULL AND NEW.y2 IS NOT NULL) OR
			rec_arc.matcat_id!= NEW.matcat_id OR  (rec_arc.matcat_id IS NULL AND NEW.matcat_id IS NOT NULL) OR
			rec_arc.arccat_id != NEW.arccat_id	OR  (rec_arc.arccat_id IS NULL AND NEW.arccat_id IS NOT NULL) OR
			rec_arc.annotation != NEW.annotation	OR  (rec_arc.annotation IS NULL AND NEW.annotation IS NOT NULL) OR
			rec_arc.observ != NEW.observ	OR  (rec_arc.observ IS NULL AND NEW.observ IS NOT NULL) OR
			rec_arc.the_geom::text<>NEW.the_geom::text THEN
			v_tol_filter_bool=TRUE;
		ELSE
			v_tol_filter_bool=FALSE;
		END IF;

		-- updating review_status parameter value
			-- new element, re-updated after its insert
			IF (SELECT count(arc_id) FROM arc WHERE arc_id=NEW.arc_id)=0 THEN
				v_review_status=1;
			-- only data changes
			ELSIF (v_tol_filter_bool is TRUE) AND ST_OrderingEquals(NEW.the_geom::text, rec_arc.the_geom::text) is TRUE THEN
				v_review_status=3;
			-- geometry changes	
			ELSIF (v_tol_filter_bool is TRUE) AND ST_OrderingEquals(NEW.the_geom::text, rec_arc.the_geom::text) is FALSE THEN
				v_review_status=2;
			--only review comment
			ELSIF (v_tol_filter_bool is FALSE) AND NEW.review_obs IS NOT NULL THEN
				v_review_status=4;	
			-- changes under tolerance
			ELSIF (v_tol_filter_bool is FALSE) THEN
				v_review_status=0;	
			END IF;
			
			IF NEW.field_date IS NULL THEN 
					NEW.field_date = now();
			END IF;
	END IF;

	-- starting process
    IF TG_OP = 'INSERT' THEN
		
		-- arc_id
		IF NEW.arc_id IS NULL THEN
			NEW.arc_id := (SELECT nextval('urn_id_seq'));
		END IF;
		
		-- Exploitation
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='edit_exploitation_vdefault' AND "cur_user"="current_user"());
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT expl_id FROM exploitation WHERE active IS TRUE AND ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"2012", "function":"2470","debug_msg":"'||NEW.arc_id::text||'"}}$$);'; 
				END IF;		
			END IF;
		END IF;
		
				
		-- insert values on review table
		INSERT INTO review_arc (arc_id, y1, y2, arc_type, matcat_id, arccat_id, annotation, observ, review_obs, expl_id, the_geom, field_checked, field_date) 
		VALUES (NEW.arc_id, NEW.y1, NEW.y2, NEW.arc_type, NEW.matcat_id, NEW.arccat_id, NEW.annotation, NEW.observ, NEW.review_obs, NEW.expl_id, NEW.the_geom, 
		NEW.field_checked, NEW.field_date);
		
		
		--looking for insert values on audit table
	  IF NEW.field_checked=TRUE THEN			
			INSERT INTO review_audit_arc(arc_id, old_y1, new_y1, old_y2, new_y2, old_arc_type, new_arc_type, old_matcat_id, new_matcat_id, old_arccat_id ,
				new_arccat_id, old_annotation, new_annotation, old_observ, new_observ, review_obs, expl_id ,the_geom ,review_status_id, field_date, field_user)
				VALUES (NEW.arc_id, rec_arc.y1,  NEW.y1, rec_arc.y2, NEW.y2, rec_arc.arc_type, NEW.arc_type, rec_arc.matcat_id, NEW.matcat_id,
				rec_arc.arccat_id, NEW.arccat_id, rec_arc.annotation, NEW.annotation, rec_arc.observ, NEW.observ, NEW.review_obs, NEW.expl_id,
				NEW.the_geom, v_review_status, NEW.field_date, current_user);
		
		END IF;
			
		RETURN NEW;
	
    ELSIF TG_OP = 'UPDATE' THEN
	
		-- update values on review table
		UPDATE review_arc SET y1=NEW.y1, y2=NEW.y2, arc_type=NEW.arc_type, matcat_id=NEW.matcat_id, arccat_id=NEW.arccat_id,
		annotation=NEW.annotation, observ=NEW.observ, review_obs=NEW.review_obs, expl_id=NEW.expl_id, the_geom=NEW.the_geom, field_checked=NEW.field_checked
		WHERE arc_id=NEW.arc_id;
		
		-- if user finish review visit
		IF (NEW.field_checked is TRUE) THEN
			
			-- upserting values on review_audit_arc arc table	
			IF EXISTS (SELECT arc_id FROM review_audit_arc WHERE arc_id=NEW.arc_id) THEN					
				UPDATE review_audit_arc	SET old_y1=rec_arc.y1, new_y1=NEW.y1, old_y2=rec_arc.y2, new_y2=NEW.y2, old_arc_type=rec_arc.arc_type, 
				new_arc_type=NEW.arc_type, old_matcat_id=rec_arc.matcat_id, new_matcat_id=NEW.matcat_id, old_arccat_id=rec_arc.arccat_id, 
				new_arccat_id=NEW.arccat_id, old_annotation=rec_arc.annotation, new_annotation=NEW.annotation, old_observ=rec_arc.observ,
				new_observ=NEW.observ, review_obs=NEW.review_obs, expl_id=NEW.expl_id, the_geom=NEW.the_geom, 
				review_status_id=v_review_status, field_date=NEW.field_date, field_user=current_user WHERE arc_id=NEW.arc_id;
			ELSE
			
				INSERT INTO review_audit_arc(arc_id, old_y1, new_y1, old_y2, new_y2, old_arc_type, new_arc_type, old_matcat_id, new_matcat_id, old_arccat_id ,
				new_arccat_id, old_annotation, new_annotation, old_observ, new_observ, review_obs, expl_id ,the_geom ,review_status_id, field_date, field_user)
				VALUES (NEW.arc_id, rec_arc.y1,  NEW.y1, rec_arc.y2, NEW.y2, rec_arc.arc_type, NEW.arc_type, rec_arc.matcat_id, NEW.matcat_id,
				rec_arc.arccat_id, NEW.arccat_id, rec_arc.annotation, NEW.annotation, rec_arc.observ, NEW.observ, NEW.review_obs, NEW.expl_id,
				NEW.the_geom, v_review_status, NEW.field_date, current_user);
			END IF;
				
		END IF;
	ELSIF TG_OP = 'DELETE' THEN 
	    DELETE from review_arc WHERE arc_id=OLD.arc_id;
	END IF;

    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;