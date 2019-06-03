/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--03/06/2019
UPDATE config_param_system SET value='{"status":"TRUE" , "field":"id"}' WHERE parameter='customer_code_autofill';
UPDATE config_param_system SET descript='If status is TRUE, when insert a new connec, customer_code will be the same as field (id or code)' WHERE parameter='customer_code_autofill';

