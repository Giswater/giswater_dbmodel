/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX




CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2csv(p_pg2csvcat_id integer, p_path_aux text)
  RETURNS void AS
$BODY$DECLARE

v_query_text text;
rec_table record;
column_number integer;
id_last integer;
num_col_rec record;
num_column text;
result_id_aux varchar;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;


    --Delete previous
    DELETE FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_pg2csvcat_id;
    
    SELECT result_id INTO result_id_aux FROM inp_selector_result where cur_user=current_user;

    INSERT INTO temp_csv2pg (csv1) VALUES ('[TITLE]');
    INSERT INTO temp_csv2pg (csv1) VALUES (';Created by Giswater');
    INSERT INTO temp_csv2pg (csv1) VALUES (';Giswater, the open water management tool.');
    INSERT INTO temp_csv2pg (csv1) VALUES (';Project name: ');
    INSERT INTO temp_csv2pg (csv1) VALUES (concat(';Result name: ',result_id_aux)); 
    INSERT INTO temp_csv2pg (csv1) VALUES (NULL); 

    --node
    FOR rec_table IN SELECT * FROM sys_csv2pg_config WHERE pg2csvcat_id=p_pg2csvcat_id
     LOOP
  -- insert header
        v_query_text = 'INSERT INTO temp_csv2pg(csv2pgcat_id,csv1) VALUES ('||p_pg2csvcat_id||','''|| rec_table.header_text||''');';
        EXECUTE v_query_text;

        --INSERT INTO temp_csv2pg (csv2pgcat_id,csv1) VALUES (p_pg2csvcat_id,';');
  --EXECUTE v_query_text;
  
        INSERT INTO temp_csv2pg (csv2pgcat_id,csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12) 
        SELECT p_pg2csvcat_id,concat(';',c1),c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12
        FROM crosstab('SELECT table_name::text,  data_type::text, column_name::text FROM information_schema.columns WHERE table_schema =''SCHEMA_NAME'' and table_name='''||rec_table.tablename||'''::text') 
        AS rpt(table_name text, c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text, c9 text, c10 text, c11 text, c12 text);

        INSERT INTO temp_csv2pg (csv2pgcat_id,csv1) VALUES (p_pg2csvcat_id,';'); 

        SELECT count(*) INTO column_number from information_schema.columns where table_name='vi_junctions';
        INSERT INTO temp_csv2pg (csv2pgcat_id) VALUES (8) RETURNING id INTO id_last;

        SELECT count(*) INTO num_column from information_schema.columns where table_name=rec_table.tablename;

        FOR num_col_rec IN 1..regexp_replace(num_column, '[()]', '','g')
        LOOP
            EXECUTE 'UPDATE temp_csv2pg SET csv'||num_col_rec||'=''----'' WHERE id='||id_last||';';
        END LOOP;


  -- insert values
        v_query_text = 'INSERT INTO temp_csv2pg SELECT nextval(''SCHEMA_NAME.temp_csv2pg_id_seq''::regclass),4,current_user,*  FROM '||rec_table.tablename;
        EXECUTE v_query_text;
      
    END LOOP;

  --export to csv
  --v_query_text='COPY SCHEMA_NAME.temp_csv2pg(csv1) FROM '''||path_aux||''' WITH (FORMAT text);';
      v_query_text='COPY (SELECT csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12 FROM SCHEMA_NAME.temp_csv2pg) 
      TO '''||p_path_aux||'''DELIMITER '||''' '''||' CSV;';
      EXECUTE v_query_text;
    RETURN;
        
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




