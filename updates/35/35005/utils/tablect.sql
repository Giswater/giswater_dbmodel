/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2021/05/11
ALTER TABLE plan_price ADD CONSTRAINT plan_price_unit_check CHECK (unit::text = ANY (ARRAY['kg','m','m2','m3','pa', 't', 'u']::text[]));

-- 2021/05/22 
ALTER TABLE rpt_cat_result ADD CONSTRAINT rpt_cat_result_status_check CHECK (status = ANY (ARRAY[1, 2]));

ALTER TABLE cat_connec ADD CONSTRAINT cat_connec_matcat_id_fkey FOREIGN KEY (matcat_id)
REFERENCES cat_mat_arc (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

