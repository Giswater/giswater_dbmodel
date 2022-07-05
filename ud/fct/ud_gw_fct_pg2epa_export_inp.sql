/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2528

DROP FUNCTION IF EXISTS  SCHEMA_NAME.gw_fct_utils_csv2pg_export_swmm_inp(character varying);
DROP FUNCTION IF EXISTS  SCHEMA_NAME.gw_fct_utils_csv2pg_export_swmm_inp(character varying, text);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_export_inp(p_data json)
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_pg2epa_main($${"client":{"device":4, "infoType":1, "lang":"ES", "epsg":25831}, "data":{"resultId":"test1", "useNetworkGeom":"false", "dumpSubcatch":"true"}}$$)
SELECT SCHEMA_NAME.gw_fct_pg2epa_export_inp($${"client":{"device":4, "infoType":1, "lang":"ES", "epsg":25831}, "data":{"resultId":"test1"}}$$)

--fid:141
*/

DECLARE
rec_table record;
column_number integer;
id_last integer;
num_col_rec record;
num_column text;
v_result varchar;
v_fid integer = 141;
v_return json;
v_client_epsg integer;
v_exportmode integer;


BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get input parameters
	v_result = (p_data->>'data')::json->>'resultId';
	v_client_epsg = (p_data->>'client')::json->>'epsg'; 

	-- get user parameters
	v_exportmode = (SELECT value FROM config_param_user WHERE parameter = 'inp_options_networkmode' and cur_user = current_user);
	IF v_exportmode IS NULL THEN v_exportmode = 1; END IF;
	
	--Delete previous
	TRUNCATE temp_csv;
	
      
	-- build header of inp file
	INSERT INTO temp_csv (source, csv1,fid) VALUES ('header','[TITLE]',v_fid);
	INSERT INTO temp_csv (source, csv1,fid) VALUES ('header',concat(';Created by Giswater'),v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Giswater version: ',(SELECT giswater FROM sys_version ORDER BY id DESC LIMIT 1), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Project name: ',(SELECT title FROM inp_project_id where author=current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Result name: ',v_result, v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Export mode: ',
	(SELECT idval FROM config_param_user, inp_typevalue WHERE id = value AND typevalue = 'inp_options_networkmode' and cur_user = current_user and parameter = 'inp_options_networkmode')
	, v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Hydrology scenario: ',(SELECT name 
	FROM config_param_user JOIN cat_hydrology ON value = hydrology_id::text WHERE parameter = 'inp_options_hydrology_scenario' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';DWF scenario: ',(SELECT idval 
	FROM config_param_user JOIN cat_dwf_scenario c ON value = c.id::text WHERE parameter = 'inp_options_dwfscenario' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Default values: ',(SELECT value::json->>'status' 
	FROM config_param_user WHERE parameter = 'inp_options_vdefault' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Advanced settings: ',(SELECT value::json->>'status' 
	FROM config_param_user WHERE parameter = 'inp_options_advancedsettings' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Datetime: ',left((date_trunc('second'::text, now()))::text, 19),v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';User: ',current_user, v_fid);

	--node
	FOR rec_table IN SELECT * FROM config_fprocess WHERE fid=v_fid order by orderby
	LOOP
		-- insert header
		IF rec_table.tablename IN ('vi_gully','vi_grate','vi_link','vi_lxsections') AND v_exportmode = 1 THEN
			-- nothing because this targets does not to be exported

		ELSE
		
			INSERT INTO temp_csv (csv1,fid) VALUES (NULL,v_fid);
			EXECUTE 'INSERT INTO temp_csv(fid,csv1) VALUES ('||v_fid||','''|| rec_table.target||''');';
		
			INSERT INTO temp_csv (fid,csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12,csv13,csv14,csv15,csv16,csv17,csv18,csv19,csv20,csv21,csv22,csv23,csv24,csv25,csv26, csv27, csv28, csv29, csv30)
			SELECT v_fid,rpad(concat(';;',c1),20),rpad(c2,20),rpad(c3,20),rpad(c4,20),rpad(c5,20),rpad(c6,20),rpad(c7,20),rpad(c8,20),rpad(c9,20),rpad(c10,20),rpad(c11,20),rpad(c12,20)
			,rpad(c13,20),rpad(c14,20),rpad(c15,20),rpad(c16,20),rpad(c17,20),rpad(c18,20),rpad(c19,20),rpad(c20,20),rpad(c21,20),rpad(c22,20),rpad(c23,20),rpad(c24,20),rpad(c25,20),rpad(c26,20)
			,rpad(c27,20),rpad(c28,20),rpad(c29,20),rpad(c30,20)
			FROM crosstab('SELECT table_name::text,  data_type::text, column_name::text FROM information_schema.columns WHERE table_schema =''SCHEMA_NAME'' and table_name='''||rec_table.tablename||'''::text') 
			AS rpt(table_name text, c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text, c9 text, c10 text, c11 text, c12 text, c13 text, c14 text, c15 text, 
			c16 text, c17 text, c18 text, c19 text, c20 text, c21 text, c22 text, c23 text, c24 text, c25 text, c26 text, c27 text, c28 text, c29 text, c30 text);
		
			INSERT INTO temp_csv (fid) VALUES (141) RETURNING id INTO id_last;
		
			SELECT count(*)::text INTO num_column from information_schema.columns where table_name=rec_table.tablename AND table_schema='SCHEMA_NAME';
		
			--add underlines    
			FOR num_col_rec IN 1..num_column
			LOOP
				IF num_col_rec=1 then
					EXECUTE 'UPDATE temp_csv set csv1=rpad('';;----------'',20) WHERE id='||id_last||';';
				ELSE
					EXECUTE 'UPDATE temp_csv SET csv'||num_col_rec||'=rpad(''----------'',20) WHERE id='||id_last||';';
				END IF;
			END LOOP;
		
			-- insert values		
			CASE WHEN rec_table.tablename = 'vi_coordinates' THEN
				-- on the fly transformation of epsg
				INSERT INTO temp_csv SELECT nextval('temp_csv_id_seq'::regclass), v_fid, current_user,'vi_coordinates', 
				node_id, ROUND(ST_x(ST_transform(the_geom, v_client_epsg))::numeric, 3), ROUND(ST_y(ST_transform(the_geom, v_client_epsg))::numeric, 3)  FROM vi_coordinates;

			WHEN rec_table.tablename = 'vi_vertices' THEN
				-- on the fly transformation of epsg
				INSERT INTO temp_csv SELECT nextval('temp_csv_id_seq'::regclass), v_fid, current_user,'vi_vertices', 
				arc_id, ROUND(ST_x(ST_transform(the_geom, v_client_epsg))::numeric, 3), ROUND(ST_y(ST_transform(the_geom, v_client_epsg))::numeric, 3)  FROM vi_vertices;

			WHEN rec_table.tablename = 'vi_symbols' THEN
				-- on the fly transformation of epsg
				INSERT INTO temp_csv SELECT nextval('temp_csv_id_seq'::regclass), v_fid, current_user,'vi_symbols', 
				rg_id, ROUND(ST_x(ST_transform(the_geom, v_client_epsg))::numeric, 3), ROUND(ST_y(ST_transform(the_geom, v_client_epsg))::numeric, 3)  FROM vi_symbols;
			ELSE 
				EXECUTE 'INSERT INTO temp_csv SELECT nextval(''temp_csv_id_seq''::regclass),'||v_fid||',current_user,'''||rec_table.tablename::text||''',*  FROM '||rec_table.tablename||';';
			END CASE;
		END IF;	
	END LOOP;

	-- build return
	select (array_to_json(array_agg(row_to_json(row))))::json
	into v_return 
		from ( select text from (
		select id, concat(rpad(csv1,20), ' ', rpad(csv2,20), ' ', rpad(csv3,20), ' ', rpad(csv4,20), ' ', rpad(csv5,20), ' ', rpad(csv6,20), ' ', rpad(csv7,20), ' ', rpad(csv8,20), ' ', rpad(csv9,20), ' ', rpad(csv10,20), 
		' ', rpad(csv11,20), ' ', rpad(csv12,20), ' ', rpad(csv13,20), ' ', rpad(csv14,20), ' ', rpad(csv15,20), ' ', rpad(csv16,20), ' ', rpad(csv17,20), ' ', rpad(csv18,20), ' ', rpad(csv19,20), ' ', rpad(csv20,20), 
		' ', rpad(csv21,20), ' ', rpad(csv22,20), ' ', rpad(csv23,20), ' ', rpad(csv24,20), ' ', rpad(csv25,20), ' ', rpad(csv26,20), ' ', rpad(csv27,20), ' ', rpad(csv28,20), ' ', rpad(csv29,20), ' ', rpad(csv30,20)) as text 
			from temp_csv where fid = 141 and cur_user = current_user and source is null
		union
			select id, csv1 as text from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_transects','vi_controls','vi_rules', 'vi_backdrop', 'vi_hydrographs','vi_polygons') 
		union
			select id, concat(rpad(csv1,20), ' ', rpad(coalesce(csv2,''),20), ' ', rpad(coalesce(csv3,''),20), ' ', rpad(coalesce(csv4,''),20), ' ', rpad(coalesce(csv5,''),20), ' ', rpad(coalesce(csv6,''),20), ' ', csv7) as text
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_junctions') 
		union
			select id, concat(rpad(csv1,20), ' ', rpad(coalesce(csv2,''),20), ' ', rpad(coalesce(csv3,''),20), ' ', rpad(coalesce(csv4,''),20), ' ', rpad(coalesce(csv5,''),20), ' ', rpad(coalesce(csv6,''),20),
			' ', rpad(coalesce(csv7,''),20) , ' ', rpad(coalesce(csv8,''),20), ' ', rpad(coalesce(csv8,''),20), ' ',
			csv10) as text from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_conduits') 
		union
			select id, concat(rpad(csv1,20), ' ', csv2)as text from temp_csv where fid = 141 and cur_user = current_user and source in ('header', 'vi_evaporation','vi_temperature', 'vi_report', 'vi_map')
		union
			select id, concat(rpad(csv1,20), ' ', rpad(coalesce(csv2,''),20), ' ', csv3)as text from temp_csv where fid = 141 and cur_user = current_user and source in ('vi_files', 'vi_adjustments')
		union
			select id, 
			case when  substring(csv2,0,5) = 'FILE' THEN concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),length(csv2)+2))
			ELSE concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20), rpad(coalesce(csv4,''),20),' ', rpad(coalesce(csv5,''),20)) END 
			from temp_csv where fid = 141 and cur_user = current_user and source in ('vi_timeseries')	
		union
			select id, 
			case when csv5 = 'FILE' THEN concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),' ',rpad(coalesce(csv6,''),length(csv6)+2),
					' ',rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20)) 
					ELSE concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),' ',rpad(coalesce(csv6,''),20),
					' ',rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20)) END 
			from temp_csv where fid = 141 and cur_user = current_user and source in ('vi_raingages')	
		union
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),' ',rpad(coalesce(csv6,''),20),
			' ',rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20),' ',rpad(coalesce(csv9,''),20),' ',rpad(coalesce(csv10,''),20),' ',rpad(coalesce(csv11,''),20),' ',rpad(coalesce(csv12,''),20),
			' ',rpad(coalesce(csv13,''),20),' ',rpad(coalesce(csv14,''),20),' ',rpad(coalesce(csv15,''),20),' ', rpad(coalesce(csv16,''),20),' ',rpad(coalesce(csv17,''),20),' ',rpad(coalesce(csv18,''),20),
			' ', rpad(coalesce(csv19,''),20), ' ',rpad(coalesce(csv20,''),20),' ',rpad(coalesce(csv21,''),20),' ',rpad(coalesce(csv22,''),20),' ',rpad(coalesce(csv23,''),20),' ',rpad(coalesce(csv24,''),20),
			' ', rpad(coalesce(csv25,''),20),' ',rpad(coalesce(csv26,''),20),' ',rpad(coalesce(csv27,''),20),' ', rpad(coalesce(csv28,''),20), ' ', rpad(coalesce(csv29,''),20),' ',rpad(coalesce(csv30,''),20)) as text
			from temp_csv where fid  = 141 and cur_user = current_user and source not in
			('header','vi_controls','vi_rules', 'vi_backdrop', 'vi_adjustments','vi_evaporation', 'vi_files','vi_hydrographs','vi_polygons','vi_temperature','vi_transects',
			'vi_raingages','vi_timeseries','vi_transects', 'vi_report', 'vi_map', 'vi_junctions', 'vi_conduits')
		order by id
		)a )row;
	
	RETURN v_return;
        
END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;