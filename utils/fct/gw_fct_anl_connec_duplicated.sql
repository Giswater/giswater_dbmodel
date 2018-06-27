/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2106


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_connec_duplicated() RETURNS void AS $BODY$ 
DECLARE
    rec_connec record;
    connec_duplicated_tolerance_aux double precision;

BEGIN

    SET search_path = "SCHEMA_NAME", public;

    -- Get data from config table
    connec_duplicated_tolerance_aux=(SELECT "value" FROM config_param_system WHERE "parameter"='connec_duplicated_tolerance');

    -- Reset values
	DELETE FROM anl_connec WHERE cur_user="current_user"() AND fprocesscat_id=5;
		
    -- Computing process
    INSERT INTO anl_connec (connec_id, connecat_id,state, connec_id_aux, connecat_id_aux, state_aux, expl_id, fprocesscat_id, the_geom)
    SELECT DISTINCT t1.connec_id, t1.connecat_id,  t1.state, t2.connec_id, t2.connecat_id, t2.state, t1.expl_id, 5, t1.the_geom
    FROM connec AS t1 JOIN connec AS t2 ON ST_Dwithin(t1.the_geom, t2.the_geom,(connec_duplicated_tolerance_aux)) 
    WHERE t1.connec_id != t2.connec_id  
    ORDER BY t1.connec_id;
    
    RETURN;  
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
