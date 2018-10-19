-- Function: SCHEMA_NAME.gw_fct_ud_data_from_inp(integer)

-- DROP FUNCTION SCHEMA_NAME.gw_fct_ud_data_from_inp(integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_ud_data_from_inp(p_csv2pgcat_id_aux integer)
  RETURNS integer AS
$BODY$
	DECLARE
	rpt_rec record;
	epsg_val integer;
	v_point_geom public.geometry;
	v_line_geom public.geometry;
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
 
	-- DISSABLE DATABASE CONSTRAINTS AND PROCEDURES
	-- disabled triggers in order to be able to insert all the data without checking its topology
	ALTER TABLE node DISABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc DISABLE TRIGGER gw_trg_topocontrol_arc;

	-- dissable (temporary) inp foreign keys (they are all added back at the end of the function)
	ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS subcatchment_node_id_fkey;
	ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS subcatchment_rg_id_fkey;
	ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS subcatchment_snow_id_fkey;
	ALTER TABLE inp_groundwater DROP CONSTRAINT IF EXISTS inp_groundwater_subc_id_fkey;
	ALTER TABLE inp_groundwater DROP CONSTRAINT IF EXISTS inp_groundwater_aquif_id_fkey;
	ALTER TABLE inp_groundwater DROP CONSTRAINT IF EXISTS inp_groundwater_node_id_fkey;
	ALTER TABLE inp_pump DROP CONSTRAINT IF EXISTS inp_pump_curve_id_fkey;
	ALTER TABLE inp_outlet DROP CONSTRAINT IF EXISTS inp_outlet_curve_id_fkey;
	ALTER TABLE inp_coverage_land_x_subc DROP CONSTRAINT IF EXISTS inp_coverage_land_x_subc_landus_id_fkey;
	ALTER TABLE inp_coverage_land_x_subc DROP CONSTRAINT IF EXISTS inp_coverage_land_x_subc_subc_id_fkey;
	ALTER TABLE inp_dwf DROP CONSTRAINT IF EXISTS inp_dwf_pat1_fkey;
	ALTER TABLE inp_dwf DROP CONSTRAINT IF EXISTS inp_dwf_pat2_fkey;
	ALTER TABLE inp_dwf DROP CONSTRAINT IF EXISTS inp_dwf_pat3_fkey;
	ALTER TABLE inp_dwf DROP CONSTRAINT IF EXISTS inp_dwf_pat4_fkey;
	ALTER TABLE inp_curve DROP CONSTRAINT IF EXISTS inp_curve_curve_id_fkey;
	ALTER TABLE inp_inflows_pol_x_node DROP CONSTRAINT IF EXISTS inp_inflows_pol_x_node_pattern_id_fkey;
	ALTER TABLE inp_inflows_pol_x_node DROP CONSTRAINT IF EXISTS inp_inflows_pol_x_node_timser_id_fkey;
	ALTER TABLE inp_inflows DROP CONSTRAINT IF EXISTS inp_inflows_pattern_id_fkey;
	ALTER TABLE inp_inflows DROP CONSTRAINT IF EXISTS inp_inflows_timser_id_fkey;
	ALTER TABLE inp_divider DROP CONSTRAINT IF EXISTS inp_divider_node_id_fkey;
	ALTER TABLE inp_storage DROP CONSTRAINT IF EXISTS inp_storage_curve_id_fkey;
	ALTER TABLE inp_divider DROP CONSTRAINT IF EXISTS inp_divider_curve_id_fkey;
	ALTER TABLE inp_divider DROP CONSTRAINT IF EXISTS inp_divider_arc_id_fkey;

	-- MAPZONES - create basic map zones neccessary for working of a project
	INSERT INTO macroexploitation(macroexpl_id,name) VALUES(1,'macroexploitation1');
	INSERT INTO exploitation(expl_id,name,macroexpl_id) VALUES(1,'exploitation1',1);
	INSERT INTO sector(sector_id,name) VALUES(1,'sector1');
	INSERT INTO dma(dma_id,name) VALUES(1,'dma1');
	INSERT INTO ext_municipality(muni_id,name) VALUES(1,'municipality1');

	-- SELECTORS
	--insert values into selector
	INSERT INTO selector_expl(expl_id,cur_user) VALUES (1,current_user);
	INSERT INTO selector_state(state_id,cur_user) VALUES (1,current_user);

		-- CATALOGS
	--all the names of the features and materials starts with 'EPA' and are created only for correct functioning of this function, no metter which language version of giswater is used
	--cat_feature
	--node
	INSERT INTO cat_feature VALUES ('EPAMANHOLE','JUNCTION','NODE');
	INSERT INTO cat_feature VALUES ('EPAOUTFALL','OUTFALL','NODE');
	INSERT INTO cat_feature VALUES ('EPASTORAGE','STORAGE','NODE');
	
	--arc
	INSERT INTO cat_feature VALUES ('EPACONDUIT','CONDUIT','ARC');
	--nodarc
	INSERT INTO cat_feature VALUES ('EPAWEIR','VARC','ARC');
	INSERT INTO cat_feature VALUES ('EPAPUMP','VARC','ARC');
	INSERT INTO cat_feature VALUES ('EPAORIFICE','VARC','ARC');
	INSERT INTO cat_feature VALUES ('EPAOUTLET','VARC','ARC');
	
	--arc_type
	--arc
	INSERT INTO arc_type VALUES ('EPACONDUIT', 'CONDUIT', 'CONDUIT', 'man_conduit', 'inp_conduit',TRUE);
	--nodarc
	INSERT INTO arc_type VALUES ('EPAWEIR', 'VARC', 'WEIR', 'man_varc', 'inp_weir',TRUE);
	INSERT INTO arc_type VALUES ('EPAORIFICE', 'VARC', 'ORIFICE', 'man_varc', 'inp_orifice',TRUE);
	INSERT INTO arc_type VALUES ('EPAPUMP', 'VARC', 'PUMP', 'man_varc', 'inp_pump',TRUE);
	INSERT INTO arc_type VALUES ('EPAOUTLET', 'VARC', 'OUTLET', 'man_varc', 'inp_outlet',TRUE);

	--node_type
	--node
	INSERT INTO node_type VALUES ('EPAMANHOLE', 'MANHOLE', 'JUNCTION', 'man_manhole', 'inp_junction',TRUE);
	INSERT INTO node_type VALUES ('EPAOUTFALL', 'OUTFALL', 'OUTFALL', 'man_outfall', 'inp_outfall',TRUE);
	INSERT INTO node_type VALUES ('EPASTORAGE', 'STORAGE', 'STORAGE', 'man_storage', 'inp_storage',TRUE);

	--cat_mat_arc
	--arc
	INSERT INTO cat_mat_arc 
	SELECT DISTINCT csv6 FROM temp_csv2pg WHERE source='[XSECTIONS]' AND csv2 not like ';%' AND csv6 IS NOT NULL;

	--nodarc
	INSERT INTO cat_mat_arc VALUES ('EPAMAT');	
		
	--cat_mat_node 
	INSERT INTO cat_mat_node VALUES ('EPAMAT');

	--cat_arc
	--pipe 
	INSERT INTO cat_arc( id, matcat_id, shape, geom1,geom2,geom3,geom4)
	SELECT DISTINCT ON (concat(csv2,'_',csv3::numeric(4,2),'x',csv4::numeric(4,2))) concat(csv2,'_',csv3::numeric(4,2),'x',csv4::numeric(4,2)),
	'EPAMAT',csv2,csv3::numeric,csv4::numeric,csv5::numeric,csv6::numeric FROM SCHEMA_NAME.temp_csv2pg 
	WHERE source='[XSECTIONS]' AND csv1 not like ';%';
	INSERT INTO cat_arc( id,matcat_id) VALUES ('EPACONDUIT-DEF', 'EPAMAT');
	INSERT INTO cat_arc( id,matcat_id) VALUES ('EPAPUMP-DEF', 'EPAMAT');
	INSERT INTO cat_arc( id,matcat_id) VALUES ('EPAORIFICE-DEF', 'EPAMAT');
	INSERT INTO cat_arc( id,matcat_id) VALUES ('EPAOUTLET-DEF', 'EPAMAT');
	INSERT INTO cat_arc( id,matcat_id) VALUES ('EPAWEIR-DEF', 'EPAMAT');
	
	--cat_node
	INSERT INTO cat_node VALUES ('EPAMANHOLE-DEF', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPAOUTFALL-DEF', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPASTORAGE-DEF', 'EPAMAT');

	
	-- HARMONIZE THE SOURCE TABLE
	FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux order by id
	LOOP
		-- massive refactor of source field (getting target)
		--Fill in the fields source with the name of the target in order to refactor and read data correctly
		IF rpt_rec.csv1 LIKE '[%' THEN
			v_target=rpt_rec.csv1;
		END IF;
		
		UPDATE temp_csv2pg SET source=v_target WHERE rpt_rec.id=temp_csv2pg.id;

		-- refactor of [OPTIONS] 
		--Target in order to insert them to the tables using editable views, which have different values concatenated into one field. 
		--Those values are later separated using the trigger in order to put it in corresponding fields if necessary.
		--Concatenation is made using ';' when the values need the separation in the next step (trigger) and by ' ' when they are inserted into the same field.

		IF rpt_rec.source ='[TEMPERATURE]' AND rpt_rec.csv3 is not null THEN 
			IF rpt_rec.csv1 LIKE 'TIMESERIES' OR rpt_rec.csv1 LIKE 'FILE' OR rpt_rec.csv1 LIKE 'SNOWMELT' THEN
				UPDATE temp_csv2pg SET csv2=concat(csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13,' ',csv14,' ',csv15,' ',csv16 ),
				csv3=null, csv4=null,csv5=null,csv6=null,csv7=null, csv8=null, csv9=null,csv10=null,csv11=null,csv12=null, csv13=null, csv14=null,csv15=null,csv16=null WHERE temp_csv2pg.id=rpt_rec.id;
			ELSE
				UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2),csv2=concat(csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13,' ',csv14,' ',csv15,' ',csv16 ),
				csv3=null, csv4=null,csv5=null,csv6=null,csv7=null, csv8=null, csv9=null,csv10=null,csv11=null,csv12=null, csv13=null, csv14=null,csv15=null,csv16=null WHERE temp_csv2pg.id=rpt_rec.id;
			END IF;
		END IF;
		
		IF rpt_rec.source ILIKE'[OUTFALL]' AND rpt_rec.csv5 is not null THEN 
			UPDATE temp_csv2pg SET csv4=concat(csv4,' ',csv5), csv5=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE'[DIVIDERS]' AND rpt_rec.csv6 is not null THEN 
			UPDATE temp_csv2pg SET csv5=concat(csv5,';',csv6,';',csv7,';',csv8,';',csv9,';',csv10,';',csv11),
			csv6=null,csv7=null,csv8=null,csv9=null,csv10=null,csv11=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%STORAGE%'  AND rpt_rec.csv7 is not null THEN 
			UPDATE temp_csv2pg SET csv6=concat(csv6,';',csv7,';',csv8,';',csv9,';',csv10,';',csv11,';',csv12,';',csv13),
			csv7=null,csv8=null,csv9=null,csv10=null,csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%STORAGE%'  AND rpt_rec.csv7 is not null THEN 
			UPDATE temp_csv2pg SET csv6=concat(csv6,';',csv7,';',csv8),csv7=null,csv8=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%OUTLETS%'  AND rpt_rec.csv7 is not null THEN 
			UPDATE temp_csv2pg SET csv6=concat(csv6,';',csv7,';',csv8),csv7=null,csv8=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%XSECTIONS%'  AND rpt_rec.csv3 is not null and rpt_rec.csv1 NOT LIKE ';%'THEN 
			UPDATE temp_csv2pg SET csv2=(concat(csv2,'_',csv3::numeric(4,2),'x',csv4::numeric(4,2))), csv3=null, csv4=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%TRANSECTS%'  AND rpt_rec.csv2 is not null THEN 
			UPDATE temp_csv2pg SET csv1=(concat(csv1,' ',csv2,'',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13)), 
			csv2=null,csv3=null, csv4=null, csv5=null, csv6=null, csv7=null,csv8=null, csv9=null,csv10=null, csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;		
		IF rpt_rec.source ILIKE '[CONTROLS%'  AND rpt_rec.csv2 is not null THEN 
			UPDATE temp_csv2pg SET csv1=(concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13)), 
			csv2=null, csv3=null, csv4=null, csv5=null, csv6=null, csv7=null, csv8=null, csv9=null, csv10=null, csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;		
		IF rpt_rec.source ILIKE '%TREATMENT%'  AND rpt_rec.csv2 is not null THEN 
			UPDATE temp_csv2pg SET csv3=(concat(csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13)), 
			csv4=null, csv5=null, csv6=null, csv7=null, csv8=null, csv9=null, csv10=null, csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;		
		IF rpt_rec.source ILIKE '%HYDROGRAPH%'  AND rpt_rec.csv2 is not null THEN 
			UPDATE temp_csv2pg SET csv1=(concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13)), 
			csv2=null, csv3=null,csv4=null, csv5=null, csv6=null, csv7=null, csv8=null, csv9=null, csv10=null, csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%ADJUSTMENT%'  AND rpt_rec.csv3 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5,';',csv6,';',csv7,';',csv8,';',csv9,';',csv10,';',csv11,';',csv12,';',csv13),
			csv3=null,csv4=null,csv5=null,csv6=null,csv7=null,csv8=null,csv9=null,csv10=null,csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%MAP%'  AND rpt_rec.csv3 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5),csv3=null,csv4=null,csv5=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;		
		IF rpt_rec.source ILIKE '%RAINGAGE%' AND rpt_rec.csv6 is not null THEN 
			UPDATE temp_csv2pg SET csv5=concat(csv5,';',csv6,';',csv7,';',csv8),csv6=null,csv7=null,csv8=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%GWF%' AND rpt_rec.csv4 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3),csv3=concat(csv4,';',csv5),csv4=null,csv5=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%TIMESERIES%' AND rpt_rec.csv3 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5,';',csv6,';',csv7,';',csv8),
			csv3=null,csv4=null,csv5=null,csv6=null, csv7=null, csv8=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;
		IF rpt_rec.source ILIKE '%LID_CONTROLS%' AND rpt_rec.csv4 is not null THEN 
			UPDATE temp_csv2pg SET csv3=concat(csv3,';',csv4,';',csv5,';',csv6,';',csv7,';',csv8,';',csv9),
			csv4=null,csv5=null,csv6=null, csv7=null, csv8=null,csv9=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%BACKDROP%' AND rpt_rec.csv2 is not null THEN 
			UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6),
			csv2=null, csv3=null,csv4=null, csv5=null,csv6=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%PATTERNS%' AND rpt_rec.csv4 is not null THEN 
			UPDATE temp_csv2pg SET csv3=concat(csv3,';',csv4,';',csv5,';',csv6,';',csv7,';',csv8,';',csv9,';',csv10,';',csv11,';',csv12,';',csv13,';',
			csv14,';',csv15,';',csv16,';',csv17,';',csv18,';',csv19,';',csv20,';',csv21,';',csv22,';',csv23,';',csv24,';',csv25,';',csv26,';',csv27),
			csv4=null,csv5=null,csv6=null,csv7=null,csv8=null,csv9=null,csv10=null,csv11=null,csv12=null,csv13=null,csv14=null,csv15=null,csv16=null,csv17=null,
			csv18=null,csv19=null,csv20=null,csv21=null,csv22=null,csv23=null,csv24=null,csv25=null,csv26=null,csv27=null
			WHERE temp_csv2pg.id=rpt_rec.id;
		END IF;	
		IF rpt_rec.source ILIKE '%INFILTRATION%' AND rpt_rec.csv3 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5,';',csv6),
			csv3=null,csv4=null, csv5=null,csv6=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	
		IF rpt_rec.source ILIKE '%EVAPORATION%' AND rpt_rec.csv3 is not null THEN 
			UPDATE temp_csv2pg SET csv2=concat(csv2,';',csv3,';',csv4,';',csv5,';',csv6,csv7,';',csv8,';',csv9,';',csv10,';',csv11,';',csv12,';',csv13),
			csv3=null,csv4=null, csv5=null,csv6=null,csv7=null,csv8=null,csv9=null,csv10=null,csv11=null,csv12=null,csv13=null WHERE temp_csv2pg.id=rpt_rec.id; 
		END IF;	

	END LOOP;

	-- LOOPING THE EDITABLE VIEWS TO INSERT DATA
	FOR v_rec_table IN SELECT * FROM sys_csv2pg_config WHERE reverse_pg2csvcat_id=10 order by id
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
	--ARC
	--Insert geometry of the start point (node1) from node to the array, add vertices defined in inp file if exist, add geometry of an 
	--end point (node2) from node to the array and create a line out all points.

	FOR v_data IN SELECT * FROM arc  LOOP

		
		SELECT array_agg(the_geom) INTO geom_array FROM node WHERE v_data.node_1=node_id;

		FOR rpt_rec IN SELECT * FROM temp_csv2pg WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux and source='[VERTICES]' AND csv1=v_data.arc_id order by id 
		LOOP	
			v_point_geom=ST_SetSrid(ST_MakePoint(rpt_rec.csv2::numeric,rpt_rec.csv3::numeric),epsg_val);
			geom_array=array_append(geom_array,v_point_geom);
		END LOOP;

		geom_array=array_append(geom_array,(SELECT the_geom FROM node WHERE v_data.node_2=node_id));

		UPDATE arc SET the_geom=ST_MakeLine(geom_array) where arc_id=v_data.arc_id;
		
	end loop;

	-- CREATE subcatchments
		--Create points out of vertices defined in inp file create a line out all points and transform it into a polygon.
	/*FOR v_data IN SELECT * FROM subcatchment LOOP
	
		FOR rpt_rec IN SELECT * FROM temp_csv2pg 
		WHERE user_name=current_user AND csv2pgcat_id=p_csv2pgcat_id_aux and source ilike '[Polygons]' AND csv1=v_data.subc_id order by id 
		LOOP	
			v_point_geom=ST_SetSrid(ST_MakePoint(rpt_rec.csv2::numeric,rpt_rec.csv3::numeric),epsg_val);
			geom_array=array_append(geom_array,v_point_geom);
		END LOOP;
			v_line_geom=ST_MakeLine(geom_array);
			raise notice 'geom_arra,%,%',v_data.subc_id,geom_array;
		UPDATE subcatchment SET the_geom=ST_Multi(ST_Polygon(v_line_geom,epsg_val)) where subc_id=v_data.subc_id;
		INSERT INTO temp_table (text_column,geom_line) VALUES (v_data.subc_id,v_line_geom);
	END LOOP;*/
		
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
	IF project_type_aux='UD' THEN
	-- enable inp foreign keys
		ALTER TABLE subcatchment ADD CONSTRAINT subcatchment_node_id_fkey FOREIGN KEY (node_id) REFERENCES node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE subcatchment ADD CONSTRAINT subcatchment_rg_id_fkey FOREIGN KEY (rg_id) REFERENCES raingage (rg_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE subcatchment ADD CONSTRAINT subcatchment_snow_id_fkey FOREIGN KEY (snow_id) REFERENCES inp_snowpack (snow_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_groundwater ADD CONSTRAINT inp_groundwater_subc_id_fkey FOREIGN KEY (subc_id) REFERENCES subcatchment (subc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_groundwater ADD CONSTRAINT inp_groundwater_aquif_id_fkey FOREIGN KEY (aquif_id) REFERENCES inp_aquifer (aquif_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_groundwater ADD CONSTRAINT inp_groundwater_node_id_fkey FOREIGN KEY (node_id) REFERENCES node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_pump ADD CONSTRAINT inp_pump_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_outlet ADD CONSTRAINT inp_outlet_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_coverage_land_x_subc ADD CONSTRAINT inp_coverage_land_x_subc_landus_id_fkey FOREIGN KEY (landus_id) REFERENCES inp_landuses (landus_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_coverage_land_x_subc ADD CONSTRAINT inp_coverage_land_x_subc_subc_id_fkey FOREIGN KEY (subc_id) REFERENCES subcatchment (subc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_dwf ADD CONSTRAINT inp_dwf_pat1_fkey FOREIGN KEY (pat1) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_dwf ADD CONSTRAINT inp_dwf_pat2_fkey FOREIGN KEY (pat2) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_dwf ADD CONSTRAINT inp_dwf_pat3_fkey FOREIGN KEY (pat3) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_dwf ADD CONSTRAINT inp_dwf_pat4_fkey FOREIGN KEY (pat4) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		ALTER TABLE inp_curve ADD CONSTRAINT inp_curve_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_inflows_pol_x_node ADD CONSTRAINT inp_inflows_pol_x_node_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_inflows ADD CONSTRAINT inp_inflows_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_inflows ADD CONSTRAINT inp_inflows_timser_id_fkey FOREIGN KEY (timser_id) REFERENCES inp_timser_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_inflows_pol_x_node ADD CONSTRAINT inp_inflows_pol_x_node_timser_id_fkey FOREIGN KEY (timser_id) REFERENCES inp_timser_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_storage ADD CONSTRAINT inp_storage_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_divider ADD CONSTRAINT inp_divider_curve_id_fkey FOREIGN KEY (curve_id) REFERENCES inp_curve_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		ALTER TABLE inp_divider ADD CONSTRAINT inp_divider_arc_id_fkey FOREIGN KEY (arc_id) REFERENCES arc (arc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;


	END IF;

	--enable triggers
	ALTER TABLE node ENABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc ENABLE TRIGGER gw_trg_topocontrol_arc;
	RETURN v_count;
	
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


--THINGS TO SOLVE: import of controls; remaping z1/z2 values in function of [OPTIONS]-link_offset parameter;
