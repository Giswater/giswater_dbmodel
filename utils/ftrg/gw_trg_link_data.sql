/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- FUNCTION CODE: 3214


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_link_data() RETURNS trigger AS $BODY$
DECLARE     
    v_projecttype text;
    v_feature_type text;
BEGIN

   -- set search_path
   EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

   -- select config values
    SELECT upper(project_type)  INTO v_projecttype FROM sys_version ORDER BY id DESC LIMIT 1;

    v_feature_type = upper(TG_ARGV[0]);

    IF v_feature_type = 'CONNEC' THEN
        
        UPDATE link SET expl_id2 = NEW.expl_id2 WHERE feature_id = NEW.connec_id;

    ELSIF v_feature_type = 'GULLY' THEN
        UPDATE link SET expl_id2 = NEW.expl_id2  WHERE feature_id = NEW.gully_id;
    ELSIF v_feature_type = 'LINK' THEN
        IF v_projecttype = 'WS' THEN
            UPDATE link SET expl_id2 = c.expl_id2 FROM connec c WHERE feature_id = NEW.feature_id and connec_id = NEW.feature_id;
        ELSE
            UPDATE link SET expl_id2 = c.expl_id2 FROM connec c WHERE feature_id = NEW.feature_id and connec_id = NEW.feature_id;
            UPDATE link SET expl_id2 = c.expl_id2 FROM gully c WHERE feature_id = NEW.feature_id and gully_id = NEW.feature_id;
        END IF;
    END IF;
   RETURN NEW;    
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  




