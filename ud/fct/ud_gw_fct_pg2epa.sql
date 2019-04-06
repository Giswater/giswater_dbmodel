﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2222


CREATE OR REPLACE FUNCTION "ud_sample".gw_fct_pg2epa(result_id_var character varying, p_use_networkgeom boolean, p_dumpsubcatchment boolean, p_isrecursive boolean)  
RETURNS integer AS 
$BODY$

/*example
SELECT "ud_sample".gw_fct_pg2epa('r1', false, false, false)  
*/

DECLARE
	check_count_aux integer; 

BEGIN

--  Search path
    SET search_path = "ud_sample", public;

	RAISE NOTICE 'Starting pg2epa process.';
	
	--Set value default
	UPDATE inp_outfall SET outfall_type=(SELECT value FROM config_param_user WHERE parameter='epa_outfall_type_vdefault' AND cur_user=current_user) WHERE outfall_type IS NULL;
	UPDATE inp_conduit SET q0=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_q0_vdefault' AND cur_user=current_user)::float WHERE q0 IS NULL;
	UPDATE inp_conduit SET barrels=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_barrels_vdefault' AND cur_user=current_user)::integer WHERE barrels IS NULL;
	UPDATE inp_junction SET y0=(SELECT value FROM config_param_user WHERE parameter='epa_junction_y0_vdefault' AND cur_user=current_user)::float WHERE y0 IS NULL;
	UPDATE raingage SET scf=(SELECT value FROM config_param_user WHERE parameter='epa_rgage_scf_vdefault' AND cur_user=current_user)::float WHERE scf IS NULL;
		
	
	IF p_isrecursive IS TRUE THEN
		-- Modify the contourn conditions to dynamic recursive strategy
		
	ELSE
		-- Upsert on rpt_cat_table
		DELETE FROM rpt_cat_result WHERE result_id=result_id_var;
		INSERT INTO rpt_cat_result (result_id) VALUES (result_id_var);
		
		-- Upsert on node rpt_inp result manager table
		DELETE FROM inp_selector_result WHERE cur_user=current_user;
		INSERT INTO inp_selector_result (result_id, cur_user) VALUES (result_id_var, current_user);
		
	END IF;
	
	
	IF p_use_networkgeom IS FALSE THEN

		-- Fill inprpt tables
		PERFORM gw_fct_pg2epa_fill_data(result_id_var);
	
		-- Make virtual arcs (EPA) transparents for hydraulic model
		PERFORM gw_fct_pg2epa_join_virtual(result_id_var);
		
		-- Call nod2arc function
		PERFORM gw_fct_pg2epa_nod2arc_geom(result_id_var);
		
		-- Calling for gw_fct_pg2epa_flowreg_additional function
		PERFORM gw_fct_pg2epa_nod2arc_data(result_id_var);
	
	END IF;
	
	IF p_dumpsubcatchment THEN
		-- Dump subcatchments
		PERFORM gw_fct_pg2epa_dump_subcatch ();
	END IF;
		
	-- Calling for the export function
	PERFORM gw_fct_utils_csv2pg_export_swmm_inp(result_id_var, null);
	
	IF p_isrecursive IS TRUE THEN
		DELETE FROM temp_table WHERE id IN (SELECT id FROM temp_table WHERE fprocesscat_id=35 AND text_column::json->>'result_id'=result_id_var LIMIT 1); 
		IF (SELECT count(*) FROM temp_table WHERE fprocesscat_id=35 AND text_column::json->>'result_id'=result_id_var)>0 THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END IF;
	
RETURN 0;

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;