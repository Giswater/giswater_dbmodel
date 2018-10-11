-- Function: SCHEMA_NAME.gw_fct_ud_data_from_inp(integer)

-- DROP FUNCTION SCHEMA_NAME.gw_fct_ud_data_from_inp(integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_ud_data_from_inp(p_csv2pgcat_id_aux integer)
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

	delete from arc CASCADE;
	delete from subcatchment CASCADE;
	delete from inp_aquifer CASCADE;
	delete from node CASCADE;
	delete from exploitation;
	delete from macroexploitation;
	delete from sector;
	delete from dma;
	delete from ext_municipality;
	delete from cat_node;
	delete from cat_arc;
	delete from cat_mat_arc;
	delete from cat_mat_node;
	delete from inp_groundwater	;
	delete from selector_state where cur_user=current_user;
	delete from config_param_user where cur_user=current_user;

	
	

	-- DISSABLE DATABASE CONSTRAINTS AND PROCEDURES
	-- disabled triggers
	ALTER TABLE node DISABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc DISABLE TRIGGER gw_trg_topocontrol_arc;

	-- dissable (temporary) inp foreign keys
	--  ALTER TABLE SCHEMA_NAME.subcatchment DROP CONSTRAINT subcatchment_node_id_fkey;
	--  ALTER TABLE SCHEMA_NAME.subcatchment DROP CONSTRAINT subcatchment_rg_id_fkey;
	--  ALTER TABLE SCHEMA_NAME.subcatchment DROP CONSTRAINT subcatchment_snow_id_fkey;
	--ALTER TABLE SCHEMA_NAME.inp_groundwater DROP CONSTRAINT inp_groundwater_subc_id_fkey;
--	ALTER TABLE SCHEMA_NAME.inp_groundwater DROP CONSTRAINT inp_groundwater_aquif_id_fkey;
--	ALTER TABLE SCHEMA_NAME.inp_groundwater DROP CONSTRAINT inp_groundwater_node_id_fkey;
	
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
		IF rpt_rec.source ='[TEMPERATURE]' AND rpt_rec.csv3 is not null THEN 
			IF rpt_rec.csv1 LIKE 'TIMESERIES' OR rpt_rec.csv1 LIKE 'FILE' OR rpt_rec.csv1 LIKE 'SNOWMELT' THEN
				UPDATE temp_csv2pg SET csv2=concat(csv2,' ',csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13,' ',csv14,' ',csv15,' ',csv16 ),
				csv3=null, csv4=null,csv5=null,csv6=null,csv7=null, csv8=null, csv9=null,csv10=null,csv11=null,csv12=null, csv13=null, csv14=null,csv15=null,csv16=null WHERE temp_csv2pg.id=rpt_rec.id;
			ELSE
				UPDATE temp_csv2pg SET csv1=concat(csv1,' ',csv2),csv2=concat(csv3,' ',csv4,' ',csv5,' ',csv6,' ',csv7,' ',csv8,' ',csv9,' ',csv10,' ',csv11,' ',csv12,' ',csv13,' ',csv14,' ',csv15,' ',csv16 ),
				csv3=null, csv4=null,csv5=null,csv6=null,csv7=null, csv8=null, csv9=null,csv10=null,csv11=null,csv12=null, csv13=null, csv14=null,csv15=null,csv16=null WHERE temp_csv2pg.id=rpt_rec.id;
			END IF;
		END IF;
		
			
		-- other refactors if we need
		-- todo
	END LOOP;

	-- CATALOGS
	--cat_feature
	--node
	/*INSERT INTO cat_feature VALUES ('EPAJUNCTION','JUNCTION','NODE');
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
	INSERT INTO node_type VALUES ('EPAJUNCTION', 'MANHOLE', 'JUNCTION', 'man_manhole', 'inp_junction',TRUE);
	INSERT INTO node_type VALUES ('EPAOUTFALL', 'OUTFALL', 'OUTFALL', 'man_outfall', 'inp_outfall',TRUE);
	INSERT INTO node_type VALUES ('EPASTORAGE', 'STORAGE', 'STORAGE', 'man_storage', 'inp_storage',TRUE);
*/
	--cat_mat_arc
	--arc
	INSERT INTO cat_mat_arc 
	SELECT DISTINCT csv6 FROM temp_csv2pg WHERE source='[XSECTIONS]' AND csv6 IS NOT NULL;
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
	
	--cat_node
	INSERT INTO cat_node VALUES ('EPAMANHOLE-DEF', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPAOUTFALL-DEF', 'EPAMAT');
	INSERT INTO cat_node VALUES ('EPASTORAGE-DEF', 'EPAMAT');


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

		--Insert start point, add vertices if exist, add end point

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
		--ALTER TABLE SCHEMA_NAME.subcatchment ADD CONSTRAINT subcatchment_node_id_fkey FOREIGN KEY (node_id) REFERENCES SCHEMA_NAME.node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		--ALTER TABLE SCHEMA_NAME.subcatchment ADD CONSTRAINT subcatchment_rg_id_fkey FOREIGN KEY (rg_id) REFERENCES SCHEMA_NAME.raingage (rg_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		--ALTER TABLE SCHEMA_NAME.subcatchment ADD CONSTRAINT subcatchment_snow_id_fkey FOREIGN KEY (snow_id) REFERENCES SCHEMA_NAME.inp_snowpack (snow_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
		--ALTER TABLE SCHEMA_NAME.inp_groundwater ADD CONSTRAINT inp_groundwater_subc_id_fkey FOREIGN KEY (subc_id) REFERENCES SCHEMA_NAME.subcatchment (subc_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		--ALTER TABLE SCHEMA_NAME.inp_groundwater ADD CONSTRAINT inp_groundwater_aquif_id_fkey FOREIGN KEY (aquif_id) REFERENCES SCHEMA_NAME.inp_aquifer (aquif_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
		--ALTER TABLE SCHEMA_NAME.inp_groundwater ADD CONSTRAINT inp_groundwater_node_id_fkey FOREIGN KEY (node_id) REFERENCES SCHEMA_NAME.node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

	END IF;

	--enable triggers
	ALTER TABLE node ENABLE TRIGGER gw_trg_node_update;
	ALTER TABLE arc ENABLE TRIGGER gw_trg_topocontrol_arc;
	RETURN v_count;
	
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.gw_fct_ud_data_from_inp(integer)
  OWNER TO postgres;
