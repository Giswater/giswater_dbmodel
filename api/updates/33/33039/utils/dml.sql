/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/02/13
UPDATE config_api_form_fields SET formname  ='v_edit_dimensions' WHERE formname = 'dimensioning';

INSERT INTO config_api_layer ('v_edit_dimensions', false, null, true, 'dimensioning', Dimensions, 5);