/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX


CREATE OR REPLACE FUNCTION ws_sample.gw_fct_pg2csv(p_pg2csvcat_id integer)
  RETURNS void AS
$BODY$DECLARE

v_query_text text;

 
BEGIN

    -- Search path
    SET search_path = "ws_sample", public;


    --Delete previous
    DELETE FROM ws_sample.temp_pg2csv WHERE user_name=current_user AND csv2pgcat_id=p_pg2csvcat_id;
 
    --node
    FOR rec_table IN SELECT * FROM sys_pg2csv_config WHERE pg2csvcat_id=p_pg2csvcat_id
     LOOP

	-- insert header
	v_query_text = 'INSERT INTO temp_pg2csv SELECT * FROM '||sys_pg2csv_config.header;
	EXECUTE v_query_text;

	-- insert column names
	-- it need to be inverted
	--v_query_text = 'INSERT INTO temp_pg2csv SELECT column_name FROM information_schema.columns WHERE table_schema=''ws_sample'' and table_name=''v_node''

	-- underline
	v_query_text = 'INSERT INTO temp_pg2csv SELECT '';'' FROM '||sys_pg2csv_config.header;
	EXECUTE v_query_text;

	-- insert values
	v_query_text = 'INSERT INTO temp_pg2csv SELECT * FROM '||sys_pg2csv_config.tablename;
	EXECUTE v_query_text;
   		
     END LOOP;

    RETURN;
        
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


