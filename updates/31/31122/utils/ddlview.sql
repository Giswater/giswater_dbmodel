/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--27/06/2019
CREATE OR REPLACE VIEW v_price_compost AS
SELECT price_compost.id,
   price_compost.unit,
   price_compost.descript,
       CASE
           WHEN price_compost.price IS NOT NULL THEN price_compost.price::numeric(14,2)
           ELSE  sum(a.price * price_compost_value.value)::numeric(14,2)
       END AS price
  FROM wprice_compost
    LEFT JOIN price_compost_value ON price_compost.id::text = price_compost_value.compost_id::text
    LEFT JOIN price_compost a ON a.id::text = price_compost_value.simple_id::text
 GROUP BY price_compost.id, price_compost.unit, price_compost.descript;
