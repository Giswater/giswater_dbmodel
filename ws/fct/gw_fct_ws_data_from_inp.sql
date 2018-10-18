-- Function: SCHEMA_NAME.gw_fct_ws_data_from_inp(integer)

-- DROP FUNCTION SCHEMA_NAME.gw_fct_ws_data_from_inp(integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_ws_data_from_inp(p_csv2pgcat_id_aux integer)
  RETURNS integer AS
$BODY$
	DECLARE
	rpt_rec record;
	epsg_val integer;
	v_point_geom public.geometry;
	schemas_array name[];
	v_target text;
	v_count integer=0;
	project_type_aux varchar;
	geom_array public.geometry array;
	v_data record;
	v_extend_val public.geometry;
	v_rec_table record;
	v_query_fields text;
	v_rec_view record;
	v_sql text;

	
BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- GET'S
    	-- Get schema name
	schemas_array := current_schemas(FALSE);

	-- Get project type
	SELECT wsoftware INTO project_type_aux FROM version LIMIT 1;
	
	-- Get SRID
	SELECT epsg INTO epsg_val FROM version LIMIT 1;
	

	--DELETE'S
	-- delete previous registres on the audit log data table
	DELETE FROM audit_log_project where fprocesscat_id=p_csv2pgcat_id_aux AND user_name=current_user;
 
	--delete previous values
	delete from inp_rules_x_arc cascade;
	delete from inp_rules_x_node cascade;
	delete from arc CASCADE;
	delete from node CASCADE;
	delete from exploitation;
	delete from macroexploitation;
	delete from sector;
	delete from dma;
	delete from inp_curve_id cascade;
	delete from ext_municipality;
	delete from cat_node;
	delete from cat_arc;
	delete from cat_mat_arc;
	delete from cat_mat_node;
	delete from inp_cat_mat_roughness;
	delete from selector_state where cur_user=current_user;
	delete from config_param_user where cur_user=current_user;
	delete from inp_tags;
	delete from inp_report cascade;
	delete from inp_times cascade;
	delete from inp_valve_importinp cascade;
	delete from inp_pump_importinp cascade;
	delete from inp_pattern cascade;
	
	

	-- DISSABLE DATABASE CONSTRAINTS AND PROCEDURES
	-- disabled triggers
	ALTER TABLE node DISABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc DISABLE TRIGGER gw_trg_topocontrol_arc;

	-- dissable (temporary) inp foreign keys
	ALTER TABLE inp_junction DROP CONSTRAINT IF EXISTS inp_junction_pattern_id_fkey;
	ALTER TABLE inp_pattern_value DROP CONSTRAINT inp_pattern_value_pattern_id_fkey;
	ALTER TABLE inp_source DROP CONSTRAINT inp_source_pattern_id_fkey;
	ALTER TABLE inp_tags DROP CONSTRAINT inp_tags_node_id_fkey;
	ALTER TABLE inp_valve_importinp DROP CONSTRAINT inp_valve_importinp_curve_id_fkey;
	ALTER TABLE inp_pump_importinp DROP CONSTRAINT inp_pump_importinp_curve_id_fkey;
	ALTER TABLE inp_reservoir DROP CONSTRAINT inp_reservoir_pattern_id_fkey;
	ALTER TABLE inp_energy_el DROP CONSTRAINT inp_energy_el_pump_id_fkey;

	-- MAPZONES
	INSERT INTO macroexploitation(macroexpl_id,name) VALUES(1,'macroexploitation1');
	INSERT INTO exploitation(expl_id,name,macroexpl_id) VALUES(1,'exploitation1',1);
	INSERT INTO sector(sector_id,name) VALUES(1,'sector1');
	INSERT INTO dma(dma_id,name) VALUES(1,'dma1');
	INSERT INTO ext_municipality(muni_id,name) VALUES(1,'municipality1');

	-- SELECTORS
	--insert values into selector
	INSERT INTO selector_expl(expl_id,cur_user) VALUES (1,current_user);
	INSERT INTO selector_state(state_id,cur_user) VALUES (1,current_user);

	
	-- HARMONIZE THE SOURCE TABLE
	FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux order by id
	LOOP
		-- massive refactor of source field (getting target)
		IF rpt_rec.csv1 LIKE '[%' THEN
			v_target=rpt_rec.csv1;
		END IF;
		UPDATE temp_csv2pg SET source=v_target WHERE rpt_rec.id=temp_csv2pg.id;
 
		-- refactor of [OPTIONS] target
		IF rpt_rec.source ='[OPTIONS]' AND rpt_rec.csv1 ILIKE 'Specific' THEN UPDATE temp_csv2pg SET csv1='specific_gravity', csv2=csv3, csv3=NULL WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[OPTIONS]' AND rpt_rec.csv1 ILIKE 'Demand' THEN UPDATE temp_csv2pg SET csv1='demand_multiplier', csv2=csv3, csv3=NULL WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[OPTIONS]' AND rpt_rec.csv1 ILIKE 'Emitter' THEN UPDATE temp_csv2pg SET csv1='emitter_exponent', csv2=csv3, csv3=NULL WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[OPTIONS]' AND rpt_rec.csv1 ILIKE 'Unbalanced' THEN UPDATE temp_csv2pg SET csv2=concat(csv2,' ',csv3), csv3=NULL WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[TIMES]' AND rpt_rec.csv2 ILIKE 'Clocktime'  THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,'_',csv2), csv2=concat(csv3,' ',csv4), csv3=null,csv4=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[TIMES]' AND (rpt_rec.csv2 ILIKE 'Timestep' OR rpt_rec.csv2 ILIKE 'Start' )THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,'_',csv2), csv2=csv3, csv3=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;

		IF rpt_rec.source ilike '[ENERGY]%' AND rpt_rec.csv1 ILIKE 'PUMP' THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2,' ',csv3), csv2=csv4, csv3=null,  csv4=null WHERE temp_csv2pg.id=rpt_rec.id;
		ELSIF rpt_rec.source ilike '[ENERGY]%' AND (rpt_rec.csv1 ILIKE 'GLOBAL' OR  rpt_rec.csv1 ILIKE 'DEMAND') THEN
			UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2), csv2=csv3, csv3=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[PUMPS]' and rpt_rec.csv4 ILIKE 'Power' THEN 
			UPDATE temp_csv2pg SET csv4=concat(csv5,' ',csv7,' ',csv9,' ',csv11), csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[RULES]' and rpt_rec.csv2 IS NOT NULL THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10 ), 
			csv2=null, csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[CONTROLS]'and rpt_rec.csv2 IS NOT NULL THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10 ), 
			csv2=null, csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE temp_csv2pg.id=rpt_rec.id; END IF;
		IF rpt_rec.source ='[PATTERNS]' and rpt_rec.csv3 IS NOT NULL THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5,';',csv6,';',csv7,';',csv8,';',csv9,';',csv10,';',csv11,';',csv12,';',csv13,
			csv14,';',csv15,';',csv16,';',csv17,';',csv18,';',csv19,';',csv20,';',csv21,';',csv22,';',csv23,';',csv24,';',csv25), 
			csv3=null, csv4=null,csv5=NULL, csv6=null, csv7=null,csv8=null,csv9=null,csv10=null,csv11=null,csv12=null, csv13=null,
			csv14=null,csv15=NULL, csv16=null, csv17=null,csv18=null,csv19=null,csv20=null,csv21=null,csv22=null, csv23=null,csv24=null, csv25=null
			 WHERE temp_csv2pg.id=rpt_rec.id;
		END IF;
	END LOOP;

	-- CATALOGS
	--new epa arc type
	ALTER TABLE SCHEMA_NAME.inp_arc_type DROP CONSTRAINT inp_arc_type_check;
	ALTER TABLE SCHEMA_NAME.inp_arc_type ADD CONSTRAINT inp_arc_type_check 
	CHECK (id::text = ANY (ARRAY['NOT DEFINED'::character varying::text, 'PIPE'::character varying::text, 'EPA-VALVE'::character varying::text, 'EPA-PUMP'::character varying::text]));

	INSERT INTO inp_arc_type VALUES ('EPA-VALVE');
	INSERT INTO inp_arc_type VALUES ('EPA-PUMP');
	--cat_feature
	--node
	INSERT INTO cat_feature VALUES ('EPAJUNCTION','JUNCTION','NODE');
	INSERT INTO cat_feature VALUES ('EPATANK','TANK','NODE');
	INSERT INTO cat_feature VALUES ('EPARESERVOIR','SOURCE','NODE');
	--arc
	INSERT INTO cat_feature VALUES ('EPAPIPE','PIPE','ARC');
	--nodarc
	INSERT INTO cat_feature VALUES ('EPAVALVE','VARC','ARC');
	INSERT INTO cat_feature VALUES ('EPAPUMP','VARC','ARC');
	
	--arc_type
	--arc
	INSERT INTO arc_type VALUES ('EPAPIPE', 'PIPE', 'PIPE', 'man_pipe', 'inp_pipe',TRUE);
	--nodarc
	INSERT INTO arc_type VALUES ('EPAVALVE', 'VARC', 'EPA-VALVE', 'man_varc', 'inp_valve_importinp',TRUE);
	INSERT INTO arc_type VALUES ('EPAPUMP', 'VARC', 'EPA-PUMP', 'man_varc', 'inp_pump_importinp',TRUE);

	--node_type
	--node
	INSERT INTO node_type VALUES ('EPAJUNCTION', 'JUNCTION', 'JUNCTION', 'man_junction', 'inp_junction',TRUE);
	INSERT INTO node_type VALUES ('EPATANK', 'TANK', 'TANK', 'man_tank', 'inp_tank',TRUE);
	INSERT INTO node_type VALUES ('EPARESERVOIR', 'SOURCE', 'RESERVOIR', 'man_source', 'inp_reservoir',TRUE);

	--cat_mat_arc
	--arc
	INSERT INTO cat_mat_arc 
	SELECT DISTINCT csv6 FROM temp_csv2pg WHERE source='[PIPES]' AND csv6 IS NOT NULL;
	--nodarc
	INSERT INTO cat_mat_arc VALUES ('EPAMAT');
		
	--cat_mat_node 
	INSERT INTO cat_mat_node VALUES ('EPAMAT');

	--inp_cat_mat_roughness
	INSERT INTO inp_cat_mat_roughness (matcat_id, period_id, init_age, end_age, roughness)
	SELECT DISTINCT ON (temp_csv2pg.csv6)  csv6, 'GLOBAL PERIOD', 0, 999, csv6::numeric FROM SCHEMA_NAME.temp_csv2pg WHERE source='[PIPES]' AND csv1 not like ';%' and csv6 IS NOT NULL;
	
	--cat_arc
	--pipe w
	INSERT INTO cat_arc( id, arctype_id, matcat_id,  dnom)
	SELECT DISTINCT ON (csv6, csv5) concat(csv6::numeric(10,3),'-',csv5::numeric(10,3))::text, 'EPAPIPE', csv6, csv5 FROM temp_csv2pg WHERE source='[PIPES]' AND csv1 not like ';%' AND csv5 IS NOT NULL;
	--nodarc
	INSERT INTO cat_arc ( id, arctype_id, matcat_id,dnom) SELECT DISTINCT ON (csv5,csv4) concat(csv5,'-',csv4::numeric(10,3))::text, 'EPAVALVE', 'EPAMAT', csv4 from temp_csv2pg WHERE source='[VALVES]' AND csv1 not like ';%' AND csv5 IS NOT NULL ;
	INSERT INTO cat_arc VALUES  ('EPAPUMP-DEF', 'EPAPUMP', 'EPAMAT');

	--cat_node
	INSERT INTO cat_node VALUES ('EPAJUNCTION-DEF', 'EPAJUNCTION', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPATANK-DEF', 'EPATANK', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPARESERVOIR-DEF', 'EPARESERVOIR', 'EPAMAT');


	-- LOOPING THE EDITABLE VIEWS TO INSERT DATA
	FOR v_rec_table IN SELECT * FROM sys_csv2pg_config WHERE reverse_pg2csvcat_id=10
	LOOP
		--identifing the humber of fields of the editable view
		FOR v_rec_view IN SELECT row_number() over (order by v_rec_table.tablename) as rid, column_name, data_type from information_schema.columns where table_name=v_rec_table.tablename AND table_schema='SCHEMA_NAME'
		LOOP
		
			IF v_rec_view.rid=1 THEN
				v_query_fields = concat ('csv',v_rec_view.rid,'::',v_rec_view.data_type);
			ELSE
				v_query_fields = concat (v_query_fields,' , csv',v_rec_view.rid,'::',v_rec_view.data_type);
			END IF;
		END LOOP;
		
		--inserting values on editable view
		v_sql = 'INSERT INTO '||v_rec_table.tablename||' SELECT '||v_query_fields||' FROM temp_csv2pg where source like '||quote_literal(concat('%',v_rec_table.target,'%'))||' 
		AND csv2pgcat_id=10 AND (csv1 NOT LIKE ''[%'' AND csv1 NOT LIKE '';%'') AND user_name='||quote_literal(current_user);

		raise notice 'v_sql %', v_sql;
		EXECUTE v_sql;
		
	END LOOP;
		


	-- CREATE GEOM'S
	--arc
	FOR v_data IN SELECT * FROM arc  LOOP

	--Insert geometry of the start point (node1) from node to the array, add vertices defined in inp file if exist, add geometry of an 
	--end point (node2) from node to the array and create a line out all points.
		SELECT array_agg(the_geom) INTO geom_array FROM node WHERE v_data.node_1=node_id;

		FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux and source='[VERTICES]' AND csv1=v_data.arc_id order by id 
		LOOP	
			v_point_geom=ST_SetSrid(ST_MakePoint(rpt_rec.csv2::numeric,rpt_rec.csv3::numeric),epsg_val);
			geom_array=array_append(geom_array,v_point_geom);
		END LOOP;

		geom_array=array_append(geom_array,(SELECT the_geom FROM node WHERE v_data.node_2=node_id));

		UPDATE arc SET the_geom=ST_MakeLine(geom_array) where arc_id=v_data.arc_id;
		
	end loop;
	
	--mapzones
	--Create the same geometry of all mapzones by making the Convex Hull over all the existing arcs
	EXECUTE 'SELECT ST_Multi(ST_ConvexHull(ST_Collect(the_geom))) FROM arc;'
	into v_extend_val;
	update exploitation SET the_geom=v_extend_val;
	update sector SET the_geom=v_extend_val;
	update dma SET the_geom=v_extend_val;
	update ext_municipality SET the_geom=v_extend_val;


	--ENABLE CONSTRAINTS AND PROCEDURES
	--enable constraints
	IF project_type_aux='WS' THEN
		INSERT INTO inp_pattern SELECT DISTINCT pattern_id FROM inp_pattern_value;
		
		-- enable inp foreign keys
		
		ALTER TABLE inp_junction ADD CONSTRAINT inp_junction_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE "inp_pattern_value" ADD CONSTRAINT "inp_pattern_value_pattern_id_fkey" FOREIGN KEY ("pattern_id") REFERENCES "inp_pattern" ("pattern_id") ON DELETE CASCADE ON UPDATE CASCADE;
		ALTER TABLE "inp_source" ADD CONSTRAINT "inp_source_pattern_id_fkey" FOREIGN KEY ("pattern_id") REFERENCES "inp_pattern" ("pattern_id") ON DELETE CASCADE ON UPDATE CASCADE;
		ALTER TABLE inp_valve_importinp ADD CONSTRAINT inp_valve_importinp_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_pump_importinp ADD CONSTRAINT inp_pump_importinp_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_reservoir ADD CONSTRAINT inp_reservoir_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE "inp_tags" ADD CONSTRAINT "inp_tags_node_id_fkey" FOREIGN KEY ("node_id") REFERENCES "node" ("node_id") ON DELETE CASCADE ON UPDATE CASCADE;
	END IF;

	--enable triggers
	ALTER TABLE node ENABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc ENABLE TRIGGER gw_trg_topocontrol_arc;
	RETURN v_count;
	
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
