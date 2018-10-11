/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

-- DROP FUNCTION SCHEMA_NAME.gw_fct_utils_pg2csv(integer, text);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_utils_pg2csv(
    p_pg2csvcat_id integer,
    p_path_aux text)
  RETURNS void AS
$BODY$DECLARE

rec_table record;
column_number integer;
id_last integer;
num_col_rec record;
num_column text;
result_id_aux varchar;
title_aux varchar;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

    IF p_pg2csvcat_id=8 THEN

      --Delete previous
      DELETE FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_pg2csvcat_id;
      
      SELECT result_id INTO result_id_aux FROM inp_selector_result where cur_user=current_user;
      SELECT title INTO title_aux FROM inp_project_id where author=current_user;

      INSERT INTO temp_csv2pg (csv1,csv2pgcat_id) VALUES ('[TITLE]',p_pg2csvcat_id);
      INSERT INTO temp_csv2pg (csv1,csv2pgcat_id) VALUES (';Created by Giswater',p_pg2csvcat_id);
      INSERT INTO temp_csv2pg (csv1,csv2,csv2pgcat_id) VALUES (';Giswater, the open water','management tool.',p_pg2csvcat_id);
      INSERT INTO temp_csv2pg (csv1,csv2,csv2pgcat_id) VALUES (';Project name: ',title_aux, p_pg2csvcat_id);
      INSERT INTO temp_csv2pg (csv1,csv2,csv2pgcat_id) VALUES (';Result name: ',result_id_aux,p_pg2csvcat_id); 
      INSERT INTO temp_csv2pg (csv1,csv2pgcat_id) VALUES (NULL,p_pg2csvcat_id); 

      --node
      FOR rec_table IN SELECT * FROM sys_csv2pg_config WHERE pg2csvcat_id=p_pg2csvcat_id ORDER BY id
       LOOP
       
  -- insert header
          INSERT INTO temp_csv2pg (csv1,csv2pgcat_id) VALUES (NULL,p_pg2csvcat_id); 
          EXECUTE 'INSERT INTO temp_csv2pg(csv2pgcat_id,csv1) VALUES ('||p_pg2csvcat_id||','''|| rec_table.header_text||''');';

    --insert column names for each header/target
        INSERT INTO temp_csv2pg (csv2pgcat_id,source,csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12,csv13,csv14) 
        SELECT p_pg2csvcat_id,rec_table.tablename,concat(';',c1),c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,csv13,csv14
        FROM crosstab('SELECT table_name::text,  data_type::text, column_name::text FROM information_schema.columns WHERE table_schema =''SCHEMA_NAME'' and table_name='''||rec_table.tablename||'''::text') 
        AS rpt(table_name text, c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text, c9 text, c10 text, c11 text, c12 text,csv13 text,csv14 text);

  
    --insert p_pg2csvcat_id value in order to add the underlines later on
          INSERT INTO temp_csv2pg (csv2pgcat_id) VALUES (p_pg2csvcat_id) RETURNING id INTO id_last;

    --count number of column in each header/target
          SELECT count(*)::text INTO num_column from information_schema.columns where table_name=rec_table.tablename AND table_schema='SCHEMA_NAME';

    --add underlines    
          FOR num_col_rec IN 1..num_column
          LOOP
                  IF num_col_rec=1 then
                        EXECUTE 'UPDATE temp_csv2pg set csv1=rpad('';-------'',20) WHERE id='||id_last||';';
                  ELSE
                        EXECUTE 'UPDATE temp_csv2pg SET csv'||num_col_rec||'=rpad(''-------'',20) WHERE id='||id_last||';';
                  END IF;
              END LOOP;

    -- insert values
          EXECUTE 'INSERT INTO temp_csv2pg SELECT nextval(''temp_csv2pg_id_seq''::regclass),'||p_pg2csvcat_id||',current_user,'''||rec_table.tablename::text||''',*  FROM '||rec_table.tablename||';';
 
          --add formating - spaces
          FOR num_col_rec IN 1..num_column::integer
          LOOP
               IF num_col_rec < num_column::integer THEN
              EXECUTE 'UPDATE temp_csv2pg SET csv'||num_col_rec||'=rpad(csv'||num_col_rec||',20) WHERE source='''||rec_table.tablename||''';';
              END IF;
          END LOOP;
          
      END LOOP;

    --export to csv
    EXECUTE 'COPY (SELECT csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12,csv13,csv14 FROM temp_csv2pg WHERE csv2pgcat_id=8 and user_name=current_user order by id) 
    TO '''||p_path_aux||''' WITH (DELIMITER E''\t'', FORMAT CSV);';

    ELSE 
      RAISE EXCEPTION 'In order to export data use parameter 8';

    END IF;

    RETURN;
        
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.gw_fct_utils_pg2csv(integer, text)
  OWNER TO postgres;