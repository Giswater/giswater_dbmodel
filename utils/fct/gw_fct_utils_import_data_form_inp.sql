	/*
	This file is part of Giswater 3
	The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
	This version of Giswater is provided by Giswater Association
	*/

-- Function: ws_inp.gw_fct_utils_data_from_inp(integer)

-- DROP FUNCTION ws_inp.gw_fct_utils_data_from_inp(integer);

CREATE OR REPLACE FUNCTION ws_inp.gw_fct_utils_data_from_inp(p_csv2pgcat_id_aux integer)
  RETURNS integer AS
$BODY$
	DECLARE
	rpt_rec record;
	type_array text array;
	type_count integer;
	type_aux text;
	epsg_val integer;
	extend_val text;
	cat_arc_aux text;
	node_1_aux varchar;
	node_2_aux varchar;
	id_last varchar;
	point_aux geometry;
	value_aux text;
	column_aux text;
	i record;
	header_aux text;
	v_value text;
	v_config_fields record;
	v_query_text text;
	schemas_array name[];
	v_table_pkey text;
	v_column_type text;
	v_pkey_column_type text;
	v_pkey_value text;
	v_tablename text;
	v_fields record;
	v_target text;
	v_count integer=0;

	
	BEGIN
	--  Search path
	SET search_path = "ws_inp", public;

    	--    Get schema name
	schemas_array := current_schemas(FALSE);

	-- delete previous registres on the audit log data table
	DELETE FROM audit_log_project where fprocesscat_id=10 AND user_name=current_user;
   
	--delete previous values
	delete from arc CASCADE;
	delete from node CASCADE;
	delete from exploitation;
	delete from macroexploitation;
	delete from sector;
	delete from dma;
	delete from ext_municipality;
	delete from cat_node;
	delete from cat_arc;
	delete from selector_state where cur_user=current_user;
	delete from config_param_user where cur_user=current_user;

	--dissable (temporary) inp foreign keys
	ALTER TABLE ws_inp.inp_junction DROP CONSTRAINT IF EXISTS inp_junction_pattern_id_fkey;

	
	--insert basic data necessary to import data
	INSERT INTO macroexploitation(macroexpl_id,name) VALUES(1,'macroexploitation1');
	INSERT INTO exploitation(expl_id,name,macroexpl_id) VALUES(1,'exploitation1',1);
	INSERT INTO sector(sector_id,name) VALUES(1,'sector1');
	INSERT INTO dma(dma_id,name) VALUES(1,'dma1');
	INSERT INTO ext_municipality(muni_id,name) VALUES(1,'municipality1');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('JUNCTION','JUNCTION');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('TANK','TANK');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('PUMP','PUMP');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('VALVE','PR-REDUC.VALVE');
	INSERT INTO cat_arc(id,arctype_id) VALUES ('PIPE','PIPE');
	ALTER TABLE node DISABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc DISABLE TRIGGER gw_trg_topocontrol_arc;
	
	--insert vdefault values
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('exploitation_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('municipality_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('dma_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('sector_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('state_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('state_type_vdefault',1,current_user);
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('nodecat_vdefault','JUNCTION',current_user);

	--check srid
	SELECT epsg INTO epsg_val FROM version LIMIT 1;

	--insert values into selector
	INSERT INTO selector_expl(expl_id,cur_user) VALUES (1,current_user);
	INSERT INTO selector_state(state_id,cur_user) VALUES (1,current_user);

	--insert other previous values from data
/*
	IF project type='WS' THEN
		patterns (inp_junction)
	
	ELSIF 

	END IF;
*/

	-- select for the whole user's importation
	FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=10 order by id
	LOOP
		-- getting the target value
		IF rpt_rec.csv1 LIKE '[%' THEN
			v_target=rpt_rec.csv1;
		END IF;

		-- filter if the row it's a valid row to import or not		
		IF rpt_rec.csv1 NOT LIKE ';%' AND rpt_rec.csv1 NOT LIKE '[%' THEN
		 
			-- Manage the insert/update for the whole table
			FOR v_tablename IN SELECT DISTINCT tablename FROM sys_csv2pg_config_fields WHERE header_text = v_target AND pg2csvcat_id=10
			LOOP
				--Getting parameters of table
				--Get id column
				EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
					INTO v_table_pkey
					USING v_tablename;	

				--For views is the first column
				IF v_table_pkey ISNULL THEN
					EXECUTE 'SELECT column_name FROM information_schema.columns WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND ordinal_position = 1'
					INTO v_table_pkey
					USING schemas_array[1];
				END IF;

				-- Get column type of primary key
				EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND column_name = $2'
					USING schemas_array[1], v_table_pkey
					INTO v_pkey_column_type;

				-- Looking for the whole fields of looped table
				FOR v_fields IN SELECT * FROM sys_csv2pg_config_fields WHERE header_text = rpt_rec.source AND pg2csvcat_id=10 AND tablename=v_tablename ORDER BY order_by
				LOOP
					-- Getting the value
					v_query_text = 'SELECT '||v_fields.csv_field||' FROM temp_csv2pg WHERE id='||rpt_rec.id;
					--raise notice 'query_text %', v_query_text;
					EXECUTE v_query_text INTO v_value;
					raise notice 'v_value %', v_value;

					-- Get column type 
					EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND column_name = $2'
						USING schemas_array[1], v_fields.table_field
						INTO v_column_type;							

					-- control of data type, only for numeric values
					IF v_column_type='bigint' OR v_column_type='integer' OR v_column_type='numeric' OR v_column_type='smallint' THEN
						IF (SELECT (v_value::varchar~ '^-?[0-9]*.?[0-9]*$') is_numeric) IS FALSE THEN
							INSERT INTO audit_log_project (fprocesscat_id, table_id, column_id, log_message) 
							VALUES (10, v_tablename, v_fields.table_field, Concat ('Error during import. The received value not match as numeric type : ',v_value));
							v_count=v_count+1;
							EXIT;
						END IF;
					END IF;			

					-- In case of insert
					IF v_fields.tg_op='I' THEN

						-- inserting data
						v_query_text = 'INSERT INTO '||v_fields.tablename ||' ('||v_table_pkey||') VALUES ('||v_value||')';
						raise notice 'insert query_text %', v_query_text;
						EXECUTE v_query_text;

					-- In case of udate
					ELSIF v_fields.tg_op='U' THEN

						-- Getting the primary key value
						EXECUTE 'SELECT '||v_fields.pk_field_value||' FROM temp_csv2pg WHERE id = '||rpt_rec.id
							INTO v_pkey_value;
						raise notice 'v_pkey_value %', v_pkey_value;

						--updating data
						v_query_text = 'UPDATE '|| quote_ident(v_fields.tablename)||' SET '|| quote_ident(v_fields.table_field)||' =  CAST('||quote_literal(v_value)||' AS '||
						v_column_type ||') WHERE '||quote_ident(v_table_pkey)||' =  CAST('||quote_literal(v_pkey_value)||' AS '||v_pkey_column_type||')';
						raise notice 'update query_text %', v_query_text;
						EXECUTE v_query_text;
						
					END IF;


				END LOOP;

			END LOOP;
		
		END IF;

	END LOOP;


	-- enable inp foreign keys
	--ALTER TABLE ws_inp.inp_junction ADD CONSTRAINT inp_junction_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES ws_inp.inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;


	RETURN v_count;

	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_inp.gw_fct_utils_data_from_inp(integer)
  OWNER TO postgres;
