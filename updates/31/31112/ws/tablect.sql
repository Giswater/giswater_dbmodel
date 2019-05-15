/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--DROP
ALTER TABLE sys_feature_cat DROP CONSTRAINT IF EXISTS sys_feature_cat_unique;
ALTER TABLE cat_feature DROP CONSTRAINT IF EXISTS cat_feature_system_fkey;

-- ADD
ALTER TABLE sys_feature_cat
  ADD CONSTRAINT sys_feature_cat_unique UNIQUE(id, type);
  
ALTER TABLE cat_feature
  ADD CONSTRAINT cat_feature_system_fkey FOREIGN KEY (system_id, feature_type)
      REFERENCES sys_feature_cat (id, type) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
        
