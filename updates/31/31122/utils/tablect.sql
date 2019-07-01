/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

-- DROP
ALTER TABLE audit_price_simple DROP CONSTRAINT audit_price_simple_pkey;
ALTER TABLE price_compost_value DROP CONSTRAINT price_compost_value_simple_id_fkey;


-- ADD
ALTER TABLE price_compost ADD CONSTRAINT price_compost_pricecat_id_fkey FOREIGN KEY (pricecat_id)
REFERENCES price_cat_simple (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE audit_price_simple ADD CONSTRAINT audit_price_simple_pkey PRIMARY KEY (id, pricecat_id);

--ALTER TABLE price_compost_value ADD CONSTRAINT price_compost_value_compost_id2_fkey FOREIGN KEY (simple_id)
--REFERENCES price_compost (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;