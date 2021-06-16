/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2021/06/15
DROP TRIGGER IF EXISTS gw_trg_config_control ON cat_brand;
CREATE TRIGGER gw_trg_config_control AFTER INSERT OR UPDATE OF featurecat_id ON cat_brand
FOR EACH ROW EXECUTE PROCEDURE gw_trg_config_control('cat_brand');

DROP TRIGGER IF EXISTS gw_trg_config_control ON cat_brand_model;
CREATE TRIGGER gw_trg_config_control AFTER INSERT OR UPDATE OF featurecat_id ON cat_brand_model
FOR EACH ROW EXECUTE PROCEDURE gw_trg_config_control('cat_brand_model');