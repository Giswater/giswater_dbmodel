/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION CODE: XXXX

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_anl_inletflowtrace()
RETURNS integer AS
$BODY$
DECLARE

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

		
RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
