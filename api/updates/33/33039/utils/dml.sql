/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/02/13
UPDATE config_api_form_fields SET formname  ='v_edit_dimensions' WHERE formname = 'dimensioning';

INSERT INTO ud.config_api_typevalue VALUES ('formtemplate_typevalue', 'dimensioning', 'dimensioning')
ON CONFLICT (typevalue, id) DO NOTHING;

INSERT INTO ud.config_api_layer VALUES ('v_edit_dimensions', false, null, true, null, 'dimensioning', 'Dimensions', 5)
ON CONFLICT (layer_id) DO NOTHING;
