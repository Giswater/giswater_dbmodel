/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1206
   
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_gully()
  RETURNS trigger AS
$BODY$
DECLARE 
	v_sql varchar;
	gully_geometry varchar;
	gully_id_seq int8;
	count_aux integer;
	promixity_buffer_aux double precision;
	link_path_aux varchar;
	v_record_link record;
	v_record_vnode record;
	v_count integer;
	v_doublegeometry boolean;
	v_length float;
	v_width float;
	v_rotation float;
	v_unitsfactor float;
	v_linelocatepoint float;
	v_thegeom public.geometry;
	v_the_geom_pol public.geometry;
	p21x float; 
	p02x float;
	p21y float; 
	p02y float;
	p22x float;
	p22y float;
	p01x float;
	p01y float;
	dx float;
	dy float;
	v_x float;
	v_y float;
	v_new_pol_id varchar(16);
	v_srid integer;
	v_featurecat text;
	v_psector_vdefault integer;
	v_arc_id text;
	v_promixity_buffer float;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	-- get values
	promixity_buffer_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
	IF promixity_buffer_aux IS NULL THEN promixity_buffer_aux=0.5; END IF;

	v_unitsfactor = (SELECT value::float FROM config_param_user WHERE "parameter"='edit_gully_doublegeom' AND cur_user=current_user);
	IF v_unitsfactor IS NULL THEN
		v_doublegeometry = FALSE;
	ELSE 
		v_doublegeometry = TRUE;
	END IF;

	v_srid = (SELECT epsg FROM version limit 1);
	
	IF v_promixity_buffer IS NULL THEN v_promixity_buffer=0.5; END IF;
    
    -- Control insertions ID
    IF TG_OP = 'INSERT' THEN

        -- gully ID
        IF (NEW.gully_id IS NULL) THEN
			PERFORM setval('urn_id_seq', gw_fct_setvalurn(),true);
            NEW.gully_id:= (SELECT nextval('urn_id_seq'));
        END IF;
		
        -- grate Catalog ID
        IF (NEW.gratecat_id IS NULL) THEN
			NEW.gratecat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"='gratecat_vdefault' AND "cur_user"="current_user"()LIMIT 1);
            IF ((SELECT COUNT(*) FROM cat_grate) = 0) THEN
                RETURN audit_function(1024,1206);
			END IF;
        END IF;

        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(1008,1206);  
			END IF;
				SELECT count(*)into count_aux FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;	
			IF (NEW.sector_id IS NULL) THEN
				NEW.sector_id := (SELECT "value" FROM config_param_user WHERE "parameter"='sector_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
			IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(1010,1206,NEW.gully_id);          
            END IF;            
        END IF;
        
	-- Dma ID
        IF (NEW.dma_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM dma) = 0) THEN
                RETURN audit_function(1012,1206);  
            END IF;
				SELECT count(*)into count_aux FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;
			IF (NEW.dma_id IS NULL) THEN
				NEW.dma_id := (SELECT "value" FROM config_param_user WHERE "parameter"='dma_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF; 
            IF (NEW.dma_id IS NULL) THEN
                RETURN audit_function(1014,1206,NEW.gully_id);  
            END IF;            
        END IF;
		
	    -- Verified
        IF (NEW.verified IS NULL) THEN
            NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		-- State
        IF (NEW.state IS NULL) THEN
            NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- State_type
		IF (NEW.state_type IS NULL) THEN
			NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='statetype_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Workcat_id
        IF (NEW.workcat_id IS NULL) THEN
            NEW.workcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='workcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Ownercat_id
        IF (NEW.ownercat_id IS NULL) THEN
            NEW.ownercat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='ownercat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Soilcat_id
        IF (NEW.soilcat_id IS NULL) THEN
            NEW.soilcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='soilcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		--Inventory
        IF (NEW.inventory IS NULL) THEN        
            NEW.inventory := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_inventory_sysvdefault');
        END IF;
        
		--Publish
        IF (NEW.publish IS NULL) THEN
            NEW.publish := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_publish_sysvdefault');
        END IF;
        
		--Uncertain
        IF (NEW.uncertain IS NULL) THEN
            NEW.uncertain := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_uncertain_sysvdefault');		
        END IF;
        
	--Builtdate
	IF (NEW.builtdate IS NULL) THEN
		NEW.builtdate :=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"() LIMIT 1);
	END IF;  
     
	-- Exploitation
	IF (NEW.expl_id IS NULL) THEN
		NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
			IF (NEW.expl_id IS NULL) THEN
				PERFORM audit_function(2012,1206,NEW.gully_id);
			END IF;		
		END IF;
	END IF;

	-- Municipality 
	IF (NEW.muni_id IS NULL) THEN
		NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		IF (NEW.muni_id IS NULL) THEN
			NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
			IF (NEW.muni_id IS NULL) THEN
				PERFORM audit_function(2024,1206,NEW.gully_id);
			END IF;	
		END IF;
	END IF;
		
	-- LINK
	IF (SELECT "value" FROM config_param_system WHERE "parameter"='edit_automatic_insert_link')::boolean=TRUE THEN
		NEW.link=NEW.gully_id;
	END IF;
	
	--set rotation field
	WITH index_query AS(
	SELECT ST_Distance(the_geom, NEW.the_geom) as distance, the_geom FROM arc WHERE state=1 ORDER BY the_geom <-> NEW.the_geom LIMIT 10)
	SELECT St_linelocatepoint(the_geom, St_closestpoint(the_geom, NEW.the_geom)), the_geom INTO v_linelocatepoint, v_thegeom FROM index_query ORDER BY distance LIMIT 1;
	IF v_linelocatepoint < 0.01 THEN
		v_rotation = st_azimuth (st_startpoint(v_thegeom), st_lineinterpolatepoint(v_thegeom,0.01));
	ELSIF v_linelocatepoint > 0.99 THEN
		v_rotation = st_azimuth (st_lineinterpolatepoint(v_thegeom,0.98), st_lineinterpolatepoint(v_thegeom,0.99));
	ELSE
		v_rotation = st_azimuth (st_lineinterpolatepoint(v_thegeom,v_linelocatepoint), st_lineinterpolatepoint(v_thegeom,v_linelocatepoint+0.01));
	END IF;

	NEW.rotation = v_rotation*180/pi();
	v_rotation = -(v_rotation - pi()/2);

	-- double geometry
	IF v_doublegeometry AND NEW.gratecat_id IS NOT NULL THEN

		v_length = (SELECT length FROM cat_grate WHERE id=NEW.gratecat_id);
		v_width = (SELECT width FROM cat_grate WHERE id=NEW.gratecat_id);

		IF v_length*v_width IS NULL THEN
		
			RAISE EXCEPTION 'Selected gratecat_id has NULL width or length. Check catalog data or your custom config values before continue';				
		ELSE 
		
			-- get grate dimensions
			v_unitsfactor = 0.01*v_unitsfactor ; -- using 0.01 to convert from cms of catalog  to meters of the map
			v_length = v_length*v_unitsfactor;
			v_width = v_width*v_unitsfactor;

			-- calculate center coordinates
			v_x = st_x(NEW.the_geom);
			v_y = st_y(NEW.the_geom);
    
			-- calculate dx & dy to fix extend from center
			dx = v_length/2;
			dy = v_width/2;

			-- calculate the extend polygon
			p01x = v_x - dx*cos(v_rotation)-dy*sin(v_rotation);
			p01y = v_y - dx*sin(v_rotation)+dy*cos(v_rotation);
		
			p02x = v_x + dx*cos(v_rotation)-dy*sin(v_rotation);
			p02y = v_y + dx*sin(v_rotation)+dy*cos(v_rotation);
			p21x = v_x - dx*cos(v_rotation)+dy*sin(v_rotation);
			p21y = v_y - dx*sin(v_rotation)-dy*cos(v_rotation); 

			p22x = v_x + dx*cos(v_rotation)+dy*sin(v_rotation);
			p22y = v_y + dx*sin(v_rotation)-dy*cos(v_rotation);
				
			-- generating the geometry
			EXECUTE 'SELECT ST_Multi(ST_makePolygon(St_SetSrid(ST_GeomFromText(''LINESTRING(' || p21x ||' '|| p21y || ',' ||
				p22x ||' '|| p22y || ',' || p02x || ' ' || p02y || ','|| p01x ||' '|| p01y || ',' || p21x ||' '|| p21y || ')''),'||v_srid||')))'
				INTO v_the_geom_pol;
		
			PERFORM setval('urn_id_seq', gw_fct_setvalurn(),true);
			v_new_pol_id:= (SELECT nextval('urn_id_seq'));

			INSERT INTO polygon(sys_type, the_geom,pol_id) VALUES ('GULLY', v_the_geom_pol, v_new_pol_id);

		END IF;
	END IF;
		
	-- FEATURE INSERT
	INSERT INTO gully (gully_id, code, top_elev, "ymax",sandbox, matcat_id, gully_type, gratecat_id, units, groove, connec_arccat_id, connec_length, connec_depth, siphon, arc_id, pol_id, sector_id, "state", state_type, annotation, "observ", "comment",
	dma_id, soilcat_id, function_type, category_type, fluid_type, location_type, workcat_id, workcat_id_end, buildercat_id, builtdate, enddate, ownercat_id, postcode, streetaxis2_id, postnumber2, descript,rotation, link, verified, the_geom,
	undelete,featurecat_id, feature_id,label_x, label_y,label_rotation, expl_id, publish, inventory, muni_id, streetaxis_id, postnumber, postcomplement, postcomplement2, uncertain,num_value)
	VALUES (NEW.gully_id, NEW.code, NEW.top_elev, NEW."ymax",NEW.sandbox, NEW.matcat_id, NEW.gully_type, NEW.gratecat_id, NEW.units, NEW.groove, NEW.connec_arccat_id,  NEW.connec_length, NEW.connec_depth, NEW.siphon, NEW.arc_id, v_new_pol_id,
	NEW.sector_id, NEW."state", NEW.state_type,NEW.annotation, NEW."observ", NEW."comment", NEW.dma_id, NEW.soilcat_id, NEW.function_type, NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, 
	NEW.builtdate, NEW.enddate, NEW.ownercat_id, NEW.postcode, NEW.streetaxis2_id, NEW.postnumber2,  NEW.descript, NEW.rotation, NEW.link, NEW.verified, NEW.the_geom, NEW.undelete,NEW.featurecat_id,
	NEW.feature_id,NEW.label_x, NEW.label_y,NEW.label_rotation,  NEW.expl_id , NEW.publish, NEW.inventory, NEW.muni_id, NEW.streetaxis_id, NEW.postnumber, NEW.postcomplement, NEW.postcomplement2, NEW.uncertain,NEW.num_value);

	-- Control of automatic insert of link and vnode
	IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_automatic_connect2network' AND cur_user=current_user LIMIT 1) IS TRUE THEN
		PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
	END IF;
		
        RETURN NEW;


    ELSIF TG_OP = 'UPDATE' THEN

        -- UPDATE geom
        IF (NEW.the_geom IS DISTINCT FROM OLD.the_geom)THEN   
		UPDATE gully SET the_geom=NEW.the_geom WHERE gully::text=NEW.gully_id::text;	
        END IF;
		
		-- Reconnect arc_id
		IF (NEW.arc_id != OLD.arc_id OR OLD.arc_id IS NULL) AND NEW.arc_id IS NOT NULL THEN
			UPDATE gully SET arc_id=NEW.arc_id where gully_id=NEW.gully_id;
			IF (SELECT link_id FROM link WHERE feature_id=NEW.gully_id AND feature_type='GULLY' LIMIT 1) IS NOT NULL THEN
				UPDATE vnode SET vnode_type='AUTO' WHERE vnode_id=(SELECT exit_id FROM link WHERE feature_id=NEW.gully_id AND exit_type='VNODE' LIMIT 1)::int8;
				PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
			ELSIF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_automatic_connect2network' AND cur_user=current_user LIMIT 1) IS TRUE THEN
				PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
			END IF;
		END IF;
		
		-- State_type
		IF NEW.state=0 AND OLD.state=1 THEN
			IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN
			NEW.state_type=(SELECT "value" FROM config_param_user WHERE parameter='statetype_end_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF NEW.state_type IS NULL THEN
				NEW.state_type=(SELECT id from value_state_type WHERE state=0 LIMIT 1);
					IF NEW.state_type IS NULL THEN
					RETURN audit_function(2110,1318);
					END IF;
				END IF;
			END IF;
			
			-- Control of automatic downgrade of associated link/vnode
			IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_downgrade_linkvnode' 
			AND cur_user=current_user LIMIT 1) IS TRUE THEN	
				UPDATE link SET state=0 WHERE feature_id=OLD.gully_id;
				UPDATE vnode SET state=0 WHERE vnode_id=(SELECT exit_id FROM link WHERE feature_id=OLD.gully_id LIMIT 1)::integer;
			END IF;
		END IF;

        -- Looking for state control
        IF (NEW.state != OLD.state) THEN   
		PERFORM gw_fct_state_control('GULLY', NEW.gully_id, NEW.state, TG_OP);	
		END IF;
	
		-- rotation
		IF NEW.rotation != OLD.rotation THEN
			UPDATE gully SET rotation=NEW.rotation WHERE gully_id = OLD.gully_id;
		END IF;			
		
		--link_path
		SELECT link_path INTO link_path_aux FROM gully_type WHERE id=NEW.gully_type;
		IF link_path_aux IS NOT NULL THEN
			NEW.link = replace(NEW.link, link_path_aux,'');
		END IF;

       -- UPDATE values
       UPDATE gully 
		SET code=NEW.code, top_elev=NEW.top_elev, ymax=NEW."ymax", sandbox=NEW.sandbox, matcat_id=NEW.matcat_id, gully_type=NEW.gully_type, gratecat_id=NEW.gratecat_id, units=NEW.units, groove=NEW.groove, 
		connec_arccat_id=NEW.connec_arccat_id, connec_length=NEW.connec_length, connec_depth=NEW.connec_depth, siphon=NEW.siphon, sector_id=NEW.sector_id, "state"=NEW."state",  state_type=NEW.state_type, 
		annotation=NEW.annotation, "observ"=NEW."observ", "comment"=NEW."comment", dma_id=NEW.dma_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type, category_type=NEW.category_type, 
		fluid_type=NEW.fluid_type, location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end,buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate,
		ownercat_id=NEW.ownercat_id, postcode=NEW.postcode, streetaxis2_id=NEW.streetaxis2_id, postnumber2=NEW.postnumber2, postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2, descript=NEW.descript,
		rotation=NEW.rotation, link=NEW.link, verified=NEW.verified, the_geom=NEW.the_geom,undelete=NEW.undelete,featurecat_id=NEW.featurecat_id, feature_id=NEW.feature_id,
		label_x=NEW.label_x, label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, arc_id=NEW.arc_id,
		muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, postnumber=NEW.postnumber,  expl_id=NEW.expl_id, uncertain=NEW.uncertain, num_value=NEW.num_value
		WHERE gully_id = OLD.gully_id;
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
	
	PERFORM gw_fct_check_delete(OLD.gully_id, 'GULLY');
		
        DELETE FROM gully WHERE gully_id = OLD.gully_id;

	-- delete links & vnode's
	FOR v_record_link IN SELECT * FROM link WHERE feature_type='GULLY' AND feature_id=OLD.gully_id
	LOOP
		-- delete link
		DELETE FROM link WHERE link_id=v_record_link.link_id;
			-- delete vnode if no more links are related to vnode
		SELECT count(exit_id) INTO v_count FROM link WHERE exit_id=v_record_link.exit_id;
						
		IF v_count =0 THEN 
			DELETE FROM vnode WHERE vnode_id=v_record_link.exit_id::integer;
		END IF;
	END LOOP;

	--Delete addfields
	DELETE FROM man_addfields_value WHERE feature_id = OLD.gully_id;

	RETURN NULL;
		   
    END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



