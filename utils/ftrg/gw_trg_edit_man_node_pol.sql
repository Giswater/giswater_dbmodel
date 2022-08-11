/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
*/

--FUNCTION CODE: 2462


-- DROP FUNCTION "SCHEMA_NAME".gw_trg_edit_man_node_pol();

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_man_node_pol()  RETURNS trigger AS
$BODY$

DECLARE 
    man_table varchar;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	man_table:= TG_ARGV[0];
		
	
	-- INSERT
	IF TG_OP = 'INSERT' THEN
	
		-- Pol ID	
		IF (NEW.pol_id IS NULL) THEN
			NEW.pol_id:= (SELECT nextval('urn_id_seq'));
		END IF;
		
		-- Node ID	
	IF (NEW.feature_id IS NULL) THEN
			NEW.feature_id:= (SELECT node_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom,0.001) 
			ORDER BY ST_distance(ST_centroid(NEW.the_geom),v_edit_node.the_geom) ASC LIMIT 1);
			IF (NEW.feature_id IS NULL) THEN
				EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
	       		"data":{"message":"2052", "function":"2462","debug_msg":null}}$$);';
			END IF;	
		END IF;	
		
		-- Insert into polygon table
		INSERT INTO polygon (pol_id, sys_type, the_geom, feature_id, featurecat_id) 
		SELECT NEW.pol_id, sys_type, NEW.the_geom, NEW.feature_id, node_type
		FROM v_edit_node WHERE node_id=NEW.feature_id 
		ON CONFLICT (feature_id) DO UPDATE SET the_geom=NEW.the_geom;
		

		RETURN NEW;
		
	-- UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
	
		UPDATE polygon SET pol_id=NEW.pol_id, the_geom=NEW.the_geom WHERE pol_id=OLD.pol_id;
		
		IF (NEW.feature_id != OLD.feature_id) THEN
			UPDATE polygon SET feature_id=NEW.feature_id, featurecat_id =node_type 
			FROM v_edit_node WHERE node_id=OLD.feature_id AND pol_id=NEW.pol_id;
		END IF;
		
		RETURN NEW;
    
	-- DELETE
    ELSIF TG_OP = 'DELETE' THEN

		DELETE FROM polygon WHERE pol_id=OLD.pol_id;
				
		RETURN NULL;
   
    END IF;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
