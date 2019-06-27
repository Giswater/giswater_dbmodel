/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


UPDATE audit_cat_table SET isdeprecated=true WHERE id='price_simple';

UPDATE sys_csv2pg_cat SET readheader=TRUE;
UPDATE sys_csv2pg_cat SET readheader=FALSE where id=1; -- importdbprices

