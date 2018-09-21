-- Function: SCHEMA_NAME.gw_fct_utils_data_from_inp(integer)

-- DROP FUNCTION SCHEMA_NAME.gw_fct_utils_data_from_inp(integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_utils_data_from_inp(p_csv2pgcat_id_aux integer)
  RETURNS integer AS
$BODY$
	DECLARE
	rpt_rec record;
	epsg_val integer;
	v_point_geom public.geometry;
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
	project_type_aux varchar;
	v_xcoord numeric;
	v_ycoord numeric;
	geom_array public.geometry array;
	v_data record;
	id_last text;
	v_typevalue text;
	v_extend_val public.geometry;
	
	BEGIN
	--  Search path
	SET search_path = "SCHEMA_NAME", public;

    	--    Get schema name
	schemas_array := current_schemas(FALSE);

	-- delete previous registres on the audit log data table
	DELETE FROM audit_log_project where fprocesscat_id=p_csv2pgcat_id_aux AND user_name=current_user;
   
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
	delete from inp_tags;
	delete from inp_pattern cascade;
	delete from inp_report cascade;
	delete from inp_times cascade;
	delete from inp_valve_importinp cascade;
	delete from inp_pump_importinp cascade;

	--dissable (temporary) inp foreign keys
	ALTER TABLE inp_junction DROP CONSTRAINT IF EXISTS inp_junction_pattern_id_fkey;
	ALTER TABLE inp_pattern_value DROP CONSTRAINT inp_pattern_value_pattern_id_fkey;
	ALTER TABLE inp_source DROP CONSTRAINT inp_source_pattern_id_fkey;
	--ALTER TABLE inp_tags DROP CONSTRAINT inp_tags_node_id_fkey;
	
	--insert basic data necessary to import data
	INSERT INTO macroexploitation(macroexpl_id,name) VALUES(1,'macroexploitation1');
	INSERT INTO exploitation(expl_id,name,macroexpl_id) VALUES(1,'exploitation1',1);
	INSERT INTO sector(sector_id,name) VALUES(1,'sector1');
	INSERT INTO dma(dma_id,name) VALUES(1,'dma1');
	INSERT INTO ext_municipality(muni_id,name) VALUES(1,'municipality1');
	
	IF NOT EXISTS (SELECT id FROM cat_feature WHERE id = 'VALVE_PIPE')THEN
		INSERT INTO cat_feature VALUES ('VALVE_PIPE','PIPE','ARC');
	ELSIF NOT EXISTS (SELECT id FROM arc_type WHERE id = 'VALVE_PIPE')THEN
		INSERT INTO arc_type (id, type, epa_default, man_table, epa_table,active) VALUES ('VALVE_PIPE', 'PIPE', 'PIPE', 'man_valve', 'inp_valve_importinp',TRUE);
	ELSIF NOT EXISTS (SELECT id FROM cat_feature WHERE id = 'PUMP_PIPE')THEN
		INSERT INTO cat_feature VALUES ('PUMP_PIPE','PIPE','ARC');
	ELSIF NOT EXISTS (SELECT id FROM arc_type WHERE id = 'PUMP_PIPE')THEN
		INSERT INTO arc_type (id, type, epa_default, man_table, epa_table,active) VALUES ('PUMP_PIPE', 'PIPE', 'PIPE', 'man_pump', 'inp_pump_importinp',TRUE);
	END IF;


	INSERT INTO cat_node(id,nodetype_id) VALUES ('JUNCTION','JUNCTION');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('TANK','TANK');
	INSERT INTO cat_node(id,nodetype_id) VALUES ('RESERVOIR','WATERWELL');
	INSERT INTO cat_arc(id,arctype_id) VALUES ('PIPE','PIPE');
	INSERT INTO cat_arc(id,arctype_id) VALUES ('PUMP','PUMP_PIPE');

	--disabled triggers
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
	INSERT INTO config_param_user(parameter,value,cur_user) VALUES ('arccat_vdefault','PIPE',current_user);
	

	--check srid
	SELECT epsg INTO epsg_val FROM version LIMIT 1;

	--insert values into selector
	INSERT INTO selector_expl(expl_id,cur_user) VALUES (1,current_user);
	INSERT INTO selector_state(state_id,cur_user) VALUES (1,current_user);

	--insert other previous values from data
	SELECT wsoftware INTO project_type_aux FROM version LIMIT 1;


	FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux order by id
	LOOP
		
		-- getting the target value
		IF rpt_rec.csv1 LIKE '[%' THEN
			v_target=rpt_rec.csv1;
		END IF;
		
		UPDATE temp_csv2pg SET source=v_target WHERE rpt_rec.id=temp_csv2pg.id;

	end loop;

	-- select for the whole user's importation
	FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux AND source!='[VERTICES]' order by id
	LOOP
		
		-- getting the target value
		IF rpt_rec.csv1 LIKE '[%' THEN
			v_target=rpt_rec.csv1;
		END IF;
		
		-- filter if the row it's a valid row to import or not		
		IF rpt_rec.csv1 NOT LIKE ';%' AND rpt_rec.csv1 NOT LIKE '[%' AND rpt_rec.csv1 IS NOT NULL THEN
		 RAISE NOTICE 'rpt_rec.csv1,%',rpt_rec.csv1;
			-- Manage the insert/update for the whole table
			FOR v_tablename IN SELECT DISTINCT tablename FROM sys_csv2pg_import_config_fields WHERE header_text = v_target AND pg2csvcat_id=p_csv2pgcat_id_aux order by tablename desc
			LOOP
				IF v_tablename is not null then 
				raise notice 'v_tablename,%',v_tablename;
				--Getting parameters of table
				--Get id column
				EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
					INTO v_table_pkey
					USING v_tablename;	
				
				--For views is the first column
				IF v_table_pkey IS NULL THEN
					EXECUTE 'SELECT column_name FROM information_schema.columns WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND ordinal_position = 1'
					INTO v_table_pkey
					USING schemas_array[1];
				END IF;
				
				-- Get column type of primary key
				EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND column_name = $2'
					USING schemas_array[1], v_table_pkey
					INTO v_pkey_column_type;
					raise notice 'v_table_pkey,%',v_table_pkey;
					
				-- Looking for the whole fields of looped table
			
				FOR v_fields IN SELECT * FROM sys_csv2pg_import_config_fields WHERE header_text = rpt_rec.source AND pg2csvcat_id=p_csv2pgcat_id_aux AND tablename=v_tablename 
				ORDER BY id 
				LOOP
					IF v_fields.header_text='[TANKS]'THEN
						UPDATE config_param_user SET value='TANK',cur_user=current_user WHERE parameter='nodecat_vdefault';
					ELSIF v_fields.header_text='[RESERVOIRS]'THEN
						UPDATE config_param_user SET value='RESERVOIR',cur_user=current_user WHERE parameter='nodecat_vdefault';
					END IF;
						-- Getting the value
					IF v_fields.csv_field IS NOT NULL THEN
							v_query_text = 'SELECT '||v_fields.csv_value||' FROM temp_csv2pg WHERE '||v_fields.csv_field_column||' like '''||v_fields.csv_field||''';';
						raise notice 'v_query_text_new,%',v_query_text;
						EXECUTE v_query_text INTO v_value;
						raise notice 'v_value,%',v_value;
					ELSE
						v_query_text = 'SELECT '||v_fields.csv_value||' FROM temp_csv2pg WHERE id='||rpt_rec.id;
						EXECUTE v_query_text INTO v_value;
					END IF;
					
					--Capture the coordinates of nodes
					IF (v_fields.header_text='[COORDINATES]') AND v_fields.table_field='the_geom.x' THEN
						v_xcoord=v_value::numeric;
					ELSIF (v_fields.header_text='[COORDINATES]') AND v_fields.table_field='the_geom.y' THEN
						v_ycoord=v_value::numeric;
					END IF;
					--RAISE NOTICE 'v_xcoord,v_ycoord,%,%',v_xcoord,v_ycoord;
					
					-- Get column type 
					EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND column_name = $2'
						USING schemas_array[1], v_fields.table_field
						INTO v_column_type;							
					RAISE NOTICE 'v_column_type,%',v_column_type;
					
					-- control of data type, only for numeric values
					IF v_column_type='bigint' OR v_column_type='integer' OR v_column_type='numeric' OR v_column_type='smallint' THEN
						IF (SELECT (v_value::varchar~ '^-?[0-9]*.?[0-9]*$') is_numeric) IS FALSE THEN
							INSERT INTO audit_log_project (fprocesscat_id, table_id, column_id, log_message) 
							VALUES (p_csv2pgcat_id_aux, v_tablename, v_fields.table_field, Concat ('Error during import. The received value not match as numeric type : ',v_value));
							v_count=v_count+1;
							EXIT;
						END IF;
					END IF;			
					
					-- In case of insert
					IF v_fields.tg_op='I' THEN
					
						-- inserting data
						IF v_fields.pk_field_value IS NULL THEN
							v_query_text = 'INSERT INTO '||v_fields.tablename ||' ('||v_table_pkey||') VALUES ('''||v_value||''')';
							raise notice 'insert query_text %', v_query_text;
							EXECUTE v_query_text;
						ELSE 
							--insert for tables where id is not inserted from the data
							v_query_text = 'INSERT INTO '||v_fields.tablename ||' ('||v_fields.table_field||') VALUES ('''||v_value||''');';
							raise notice 'insert query_text %', v_query_text;
							EXECUTE v_query_text;
							--v_table_pkey not null =pk_field_value
						END IF;
						
					-- In case of udate
					ELSIF v_fields.tg_op='U' THEN
						
						-- Getting the primary key value
						IF v_fields.pk_field_value IS NOT NULL THEN
						EXECUTE 'SELECT '||v_fields.pk_field_value||' FROM temp_csv2pg WHERE id = '||rpt_rec.id
							INTO v_pkey_value;
						END IF;
						
				
						--updating data
						IF v_value IS NOT NULL AND v_fields.header_text!='[COORDINATES]' THEN
								v_typevalue:=  v_fields.tablename || '.'||v_fields.table_field;

				
								IF v_typevalue IN (SELECT foreign_table FROM inp_typevalue) THEN

									EXECUTE 'SELECT id FROM inp_typevalue WHERE foreign_table='''||v_typevalue||''' AND idval='''||v_value||''';'
									INTO v_value;
								
								END IF;
								
							IF v_fields.pk_field_value IS NOT NULL THEN

								
								v_query_text = 'UPDATE '|| quote_ident(v_fields.tablename)||' SET '|| quote_ident(v_fields.table_field)||' =  CAST('||quote_literal(v_value)||' AS '||
								v_column_type ||') WHERE '||quote_ident(v_table_pkey)||' =  CAST('||quote_literal(v_pkey_value)||' AS '||v_pkey_column_type||')';
								raise notice 'update query_text %', v_query_text;
								EXECUTE v_query_text;
							ELSE 
							
							--update for tables where id is not inserted from the data
							EXECUTE 'SELECT max('||v_table_pkey||') FROM '||v_fields.tablename||';'
							INTO v_pkey_value;
							raise notice 'update v_table_pkey ,%,%', v_table_pkey,v_pkey_value;
							
								v_query_text = 'UPDATE '|| quote_ident(v_fields.tablename)||' SET '|| quote_ident(v_fields.table_field)||' =  CAST('||quote_literal(v_value)||' AS '||
								v_column_type ||') WHERE '||quote_ident(v_table_pkey)||' =  CAST('||quote_literal(v_pkey_value)||' AS '||v_pkey_column_type||')';
								raise notice 'update query_text %', v_query_text;
								EXECUTE v_query_text;
							END IF;

						ELSIF v_xcoord IS NOT NULL AND v_ycoord IS NOT NULL AND v_fields.header_text='[COORDINATES]' THEN
							v_query_text = 'UPDATE '|| quote_ident(v_fields.tablename)||' SET the_geom=ST_SetSrid(ST_MakePoint('|| v_xcoord||','|| v_ycoord||'),'||epsg_val||')
							WHERE '||quote_ident(v_table_pkey)||' =  CAST('||quote_literal(v_pkey_value)||' AS '||v_pkey_column_type||');';
							raise notice 'update query_text %', v_query_text;
							EXECUTE v_query_text;
							
						END IF;

						
					END IF;
					
				END LOOP;
				END IF;
			END LOOP;
		
		END IF;

	END LOOP;
	
	--Draw arc geometry
	FOR rpt_rec IN SELECT * FROM arc  LOOP

		--Insert start point, add vertices if exist, add end point

		SELECT array_agg(the_geom) INTO geom_array FROM node WHERE rpt_rec.node_1=node_id;

		FOR v_data IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux and source='[VERTICES]' AND csv1=rpt_rec.arc_id order by id 
		LOOP	
				v_point_geom=ST_SetSrid(ST_MakePoint(v_data.csv2::numeric,v_data.csv3::numeric),epsg_val);
				geom_array=array_append(geom_array,v_point_geom);
		END LOOP;

		geom_array=array_append(geom_array,(SELECT the_geom FROM node WHERE rpt_rec.node_2=node_id));

		UPDATE arc SET the_geom=ST_MakeLine(geom_array) where arc_id=rpt_rec.arc_id;
		
	end loop;
	
	--update arc catalogs
	INSERT INTO cat_arc(id, arctype_id, dint) SELECT DISTINCT CONCAT('PIPE_',custom_dint),'PIPE',custom_dint FROM inp_pipe WHERE custom_dint is not null;
	UPDATE arc SET arccat_id=CONCAT('PIPE_',custom_dint) FROM inp_pipe WHERE inp_pipe.arc_id=arc.arc_id AND custom_dint is not null;
	INSERT INTO cat_arc(id, arctype_id, dint) SELECT DISTINCT CONCAT('VALVE_',valv_type,diameter),'PIPE',diameter FROM inp_valve_importinp;
	UPDATE arc SET arccat_id=concat('VALVE_',valv_type,diameter)FROM inp_valve_importinp WHERE arc.arc_id IN (SELECT arc_id FROM inp_valve_importinp);
	UPDATE arc SET arccat_id='PUMP' WHERE arc.arc_id IN (SELECT arc_id FROM inp_pump_importinp);
	
	--create polygon geometry
	EXECUTE 'SELECT ST_Multi(ST_ConvexHull(ST_Collect(the_geom))) FROM arc;'
	into v_extend_val;
	update exploitation SET the_geom=v_extend_val;
	update sector SET the_geom=v_extend_val;
	update dma SET the_geom=v_extend_val;
	update ext_municipality SET the_geom=v_extend_val;
	
	IF project_type_aux='WS' THEN
		INSERT INTO inp_pattern SELECT DISTINCT pattern_id FROM inp_pattern_value;
		-- enable inp foreign keys
		ALTER TABLE inp_junction ADD CONSTRAINT inp_junction_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE "inp_pattern_value" ADD CONSTRAINT "inp_pattern_value_pattern_id_fkey" FOREIGN KEY ("pattern_id") REFERENCES "inp_pattern" ("pattern_id") ON DELETE CASCADE ON UPDATE CASCADE;
		ALTER TABLE "inp_source" ADD CONSTRAINT "inp_source_pattern_id_fkey" FOREIGN KEY ("pattern_id") REFERENCES "inp_pattern" ("pattern_id") ON DELETE CASCADE ON UPDATE CASCADE;
		--ALTER TABLE "inp_tags" ADD CONSTRAINT "inp_tags_node_id_fkey" FOREIGN KEY ("node_id") REFERENCES "node" ("node_id") ON DELETE CASCADE ON UPDATE CASCADE;
	END IF;
	
	--enable triggers
	ALTER TABLE node ENABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc ENABLE TRIGGER gw_trg_topocontrol_arc;
	RETURN v_count;
	
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.gw_fct_utils_data_from_inp(integer)
  OWNER TO postgres;
