/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1106

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_connec_proximity() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE 
    numConnecs numeric;
    connec_proximity_aux double precision;
    connec_proximity_control_aux boolean;
BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    -- Get connec tolerance from config table
    connec_proximity_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='connec_proximity');
    connec_proximity_control_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='connec_proximity_control');
    
    IF TG_OP = 'INSERT' THEN
        -- Existing connecs  
        numConnecs:= (SELECT COUNT(*) FROM connec WHERE connec.the_geom && ST_Expand(NEW.the_geom, connec_proximity_aux));

    ELSIF TG_OP = 'UPDATE' THEN
        -- Existing connecs  
       numConnecs := (SELECT COUNT(*) FROM connec WHERE ST_DWithin(NEW.the_geom, connec.the_geom, connec_proximity_aux) AND connec.connec_id != NEW.connec_id);
    END IF;

    -- If there is an existing connec closer than 'rec.connec_tolerance' meters --> error
    IF (numConnecs > 0) AND (connec_proximity_control_aux IS TRUE) THEN
        PERFORM audit_function (1044,1106, NEW.connec_id);
        RETURN NULL;
    END IF;

    RETURN NEW;
    
END; 
$$;


DROP TRIGGER IF EXISTS gw_trg_connec_proximity_insert ON "SCHEMA_NAME"."connec";
CREATE TRIGGER gw_trg_connec_proximity_insert BEFORE INSERT ON "SCHEMA_NAME"."connec" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_connec_proximity"();

DROP TRIGGER IF EXISTS gw_trg_connec_proximity_update ON "SCHEMA_NAME"."connec";
CREATE TRIGGER gw_trg_connec_proximity_update AFTER UPDATE OF the_geom ON "SCHEMA_NAME"."connec" 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME"."gw_trg_connec_proximity"();
