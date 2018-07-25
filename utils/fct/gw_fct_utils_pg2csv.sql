/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2csv(p_pg2csvcat_id integer)
  RETURNS void AS
$BODY$DECLARE

v_query_text text;
rec_table record;
p_sys_csv2pg_config record;
schemat text;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;


    --Delete previous
    DELETE FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_pg2csvcat_id;
 
    --node
    FOR rec_table IN SELECT * FROM sys_csv2pg_config WHERE pg2csvcat_id=p_pg2csvcat_id
     LOOP
  -- insert header
  v_query_text = 'INSERT INTO temp_csv2pg(csv2pgcat_id,csv1) VALUES ('||p_pg2csvcat_id||','''|| rec_table.header_text||''');';
  EXECUTE v_query_text;

  INSERT INTO temp_csv2pg (csv2pgcat_id,csv1) VALUES (p_pg2csvcat_id,';');
  --EXECUTE v_query_text;
  
  INSERT INTO temp_csv2pg (csv2pgcat_id,csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12) SELECT p_pg2csvcat_id,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12
  FROM crosstab('SELECT table_name::text,  data_type::text, column_name::text FROM information_schema.columns WHERE table_schema =''SCHEMA_NAME'' and table_name='''||rec_table.tablename||'''::text') 
  AS rpt(table_name text, c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text, c9 text, c10 text, c11 text, c12 text);

  INSERT INTO temp_csv2pg (csv2pgcat_id,csv1) VALUES (p_pg2csvcat_id,';');

  -- insert values
  v_query_text = 'INSERT INTO temp_csv2pg SELECT nextval(''SCHEMA_NAME.temp_csv2pg_id_seq''::regclass),4,current_user,*  FROM '||rec_table.tablename;
  EXECUTE v_query_text;
      
     END LOOP;

    RETURN;
        
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;






