/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2526

DROP FUNCTION IF EXISTS  SCHEMA_NAME.gw_fct_utils_csv2pg_export_epanet_inp(character varying, text);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_export_inp(p_data json)
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_pg2epa_main($${"client":{"device":4, "infoType":1, "lang":"ES", "epsg":25831}, "data":{"resultId":"test1", "useNetworkGeom":"false"}}$$)
SELECT SCHEMA_NAME.gw_fct_pg2epa_export_inp($${"client":{"device":4, "infoType":1, "lang":"ES", "epsg":25831}, "data":{"resultId":"test1"}}$$)

-- fid:141

*/

DECLARE

rec_table record;

column_number integer;
id_last integer;
num_col_rec record;
num_column text;
v_result varchar;
title_aux varchar;
v_fid integer=141;
v_patternmethod	integer;
v_networkmode integer;
v_valvemode integer;
v_patternmethodval text;
v_valvemodeval text;
v_networkmodeval text;
v_return json;
v_client_epsg integer;

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get input parameters
	v_result = (p_data->>'data')::json->>'resultId';
	v_client_epsg = (p_data->>'client')::json->>'epsg'; 

	--Delete previous
	TRUNCATE temp_csv;

	-- get parameters to put on header
	SELECT title INTO title_aux FROM inp_project_id where author=current_user;
	SELECT value INTO v_patternmethod FROM config_param_user WHERE parameter = 'inp_options_patternmethod' AND cur_user=current_user;
	SELECT value INTO v_valvemode FROM config_param_user WHERE parameter = 'inp_options_valve_mode' AND cur_user=current_user;
	SELECT value INTO v_networkmode FROM config_param_user WHERE parameter = 'inp_options_networkmode' AND cur_user=current_user;
	SELECT idval INTO v_patternmethodval FROM inp_typevalue WHERE id=v_patternmethod::text AND typevalue ='inp_value_patternmethod';
	SELECT idval INTO v_valvemodeval FROM inp_typevalue WHERE id=v_valvemode::text AND typevalue ='inp_value_opti_valvemode';
	SELECT idval INTO v_networkmodeval FROM inp_typevalue WHERE id=v_networkmode::text AND typevalue ='inp_options_networkmode';

	--writing the header
	INSERT INTO temp_csv (source, csv1,fid) VALUES ('header','[TITLE]',v_fid);
	INSERT INTO temp_csv (source, csv1,fid) VALUES ('header',concat(';Created by Giswater'),v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Giswater version: ',(SELECT giswater FROM sys_version ORDER BY id DESC LIMIT 1), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Project name: ',title_aux, v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Result name: ',v_result,v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Export mode: ', v_networkmodeval, v_fid );
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Pattern method: ', v_patternmethodval, v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Valve mode: ', v_valvemodeval, v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Default values: ',
	(SELECT value::json->>'status' FROM config_param_user WHERE parameter = 'inp_options_vdefault' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Advanced settings: ',
	(SELECT value::json->>'status' FROM config_param_user WHERE parameter = 'inp_options_advancedsettings' AND cur_user = current_user), v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';Datetime: ',left((date_trunc('second'::text, now()))::text, 19),v_fid);
	INSERT INTO temp_csv (source, csv1,csv2,fid) VALUES ('header',';User: ',current_user, v_fid);

	--node
	FOR rec_table IN SELECT * FROM config_fprocess WHERE fid=v_fid order by orderby
	LOOP
		-- insert header
		INSERT INTO temp_csv (csv1,fid) VALUES (NULL,v_fid);
		EXECUTE 'INSERT INTO temp_csv(fid,csv1) VALUES ('||v_fid||','''|| rec_table.target||''');';

		-- insert fieldnames
		IF rec_table.tablename = 'vi_patterns' THEN
			INSERT INTO temp_csv (fid,csv1,csv2) VALUES (141, ';ID', 'Multipliers');
			num_column = 2;
		ELSE 
			INSERT INTO temp_csv (fid,csv1,csv2,csv3,csv4,csv5,csv6,csv7,csv8,csv9,csv10,csv11,csv12,csv13)
			SELECT v_fid,rpad(concat(';',c1),22),rpad(c2,22),rpad(c3,22),rpad(c4,22),rpad(c5,22),rpad(c6,22),rpad(c7,22),rpad(c8,22),rpad(c9,22),rpad(c10,22),
			rpad(c11,22),rpad(c12,22),rpad(c13,22)
			FROM crosstab('SELECT table_name::text,  data_type::text, column_name::text FROM information_schema.columns WHERE table_schema =''SCHEMA_NAME'' and table_name='''||
			rec_table.tablename||'''::text') 
			AS rpt(table_name text, c1 text, c2 text, c3 text, c4 text, c5 text, c6 text, c7 text, c8 text, c9 text, c10 text, c11 text, c12 text, c13 text);

			SELECT count(*)::text INTO num_column from information_schema.columns where table_name=rec_table.tablename AND table_schema='SCHEMA_NAME';
		END IF;
	
		INSERT INTO temp_csv (fid) VALUES (141) RETURNING id INTO id_last;
  
		--add underlines    
		FOR num_col_rec IN 1..num_column
		LOOP
			IF num_col_rec=1 then
				EXECUTE 'UPDATE temp_csv set csv1=rpad('';----------'',22) WHERE id='||id_last||';';
			ELSE
				EXECUTE 'UPDATE temp_csv SET csv'||num_col_rec||'=rpad(''----------'',22) WHERE id='||id_last||';';
			END IF;
		END LOOP;

		-- insert values
		CASE WHEN rec_table.tablename='vi_options' and (SELECT value FROM vi_options WHERE parameter='hydraulics') is null THEN
			EXECUTE 'INSERT INTO temp_csv SELECT nextval(''temp_csv_id_seq''::regclass),'||v_fid||',current_user,'''||rec_table.tablename::text||''',*  FROM '||
			rec_table.tablename||' WHERE parameter!=''hydraulics'';';

		WHEN rec_table.tablename = 'vi_coordinates' THEN
			-- on the fly transformation of epsg
			INSERT INTO temp_csv SELECT nextval('temp_csv_id_seq'::regclass), v_fid, current_user,'vi_coordinates', 
			node_id, ROUND(ST_x(ST_transform(the_geom, v_client_epsg))::numeric, 3), ROUND(ST_y(ST_transform(the_geom, v_client_epsg))::numeric, 3)  FROM vi_coordinates;

		WHEN rec_table.tablename = 'vi_vertices' THEN
			-- on the fly transformation of epsg
			INSERT INTO temp_csv SELECT nextval('temp_csv_id_seq'::regclass), v_fid, current_user,'vi_vertices', 
			arc_id, ROUND(ST_x(ST_transform(the_geom, v_client_epsg))::numeric, 3), ROUND(ST_y(ST_transform(the_geom, v_client_epsg))::numeric, 3)  FROM vi_vertices;
		ELSE
			EXECUTE 'INSERT INTO temp_csv SELECT nextval(''temp_csv_id_seq''::regclass),'||v_fid||',current_user,'''||rec_table.tablename::text||''',*  FROM '||
			rec_table.tablename||';';
		END CASE;
  
	END LOOP;

	-- build return
	select (array_to_json(array_agg(row_to_json(row))))::json 
	into v_return 
		from ( select text from (
			select id, concat(rpad(csv1,20), ' ', rpad(csv2,20), ' ', rpad(csv3,20), ' ', rpad(csv4,20), ' ', rpad(csv5,20), ' ', rpad(csv6,20), ' ', rpad(csv7,20), ' ', 
			rpad(csv8,20), ' ' , rpad(csv9,20), ' ', rpad(csv10,20), ' ', rpad(csv11,20), ' ', rpad(csv12,20)) 
			as text from temp_csv where fid = 141 and cur_user = current_user and source is null
		union
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_junctions')
		union
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_demands')
		union
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_reservoirs')
		union
			select id, concat(rpad(csv1,21),rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),
			' ',rpad(coalesce(csv6,''),20),' ', rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20),' ',rpad(coalesce(csv9,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_tanks')
		union
			select id, concat(rpad(csv1,21),rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),
			' ',rpad(coalesce(csv6,''),20),' ', rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20),' ',rpad(coalesce(csv9,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_pipes')
		union
			select id, concat(rpad(csv1,21),rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),
			' ',rpad(coalesce(csv6,''),20),' ', rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_pumps')
		union
			select id, concat(rpad(csv1,21),rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),
			' ',rpad(coalesce(csv6,''),20),' ', rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),500))
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_valves')
		union
			select id, concat(rpad(csv1,22), ' ', csv2)as text from temp_csv where fid  = 141 and cur_user = current_user and source in ('header')
		union
			select id, csv1 as text from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_controls','vi_rules', 'vi_backdrop', 'vi_reactions')
		union
			-- spacer-19 it's used because a rare bug reading epanet when spacer=20 on target [PATTERNS]????
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),19),' ', rpad(coalesce(csv3,''),19),' ',rpad(coalesce(csv4,''),19),' ',rpad(coalesce(csv5,''),19),
			' ',rpad(coalesce(csv6,''),19),	' ',rpad(coalesce(csv7,''),19),' ',rpad(coalesce(csv8,''),19),' ',rpad(coalesce(csv9,''),19),' ',rpad(coalesce(csv10,''),19),
			' ',rpad(coalesce(csv11,''),19),' ',rpad(coalesce(csv12,''),19),' ',rpad(csv13,19),' ',rpad(csv14,19),' ',rpad(csv15,19),' ',rpad(csv16,19),' ',rpad(csv17,19)
			,' ',rpad(csv18,19),' ',rpad(csv19,19),' ',rpad(csv20,19)) as text
			from temp_csv where fid  = 141 and cur_user = current_user and source in ('vi_patterns')
		union
			select id, concat(rpad(csv1,20),' ',rpad(coalesce(csv2,''),20),' ', rpad(coalesce(csv3,''),20),' ',rpad(coalesce(csv4,''),20),' ',rpad(coalesce(csv5,''),20),
			' ',rpad(coalesce(csv6,''),20),	' ',rpad(coalesce(csv7,''),20),' ',rpad(coalesce(csv8,''),20),' ',rpad(coalesce(csv9,''),20),' ',rpad(coalesce(csv10,''),20),
			' ',rpad(coalesce(csv11,''),20),' ',rpad(coalesce(csv12,''),20),' ',rpad(csv13,20),' ',rpad(csv14,20),' ',rpad(csv15,20),' ', rpad(csv15,20),' ',
			rpad(csv16,20),	' ',rpad(csv17,20),' ', rpad(csv20,20), ' ', rpad(csv19,20),' ',rpad(csv20,20)) as text
			from temp_csv where source not in ('header','vi_controls','vi_rules', 'vi_backdrop','vi_patterns', 'vi_reactions','vi_junctions', 'vi_tanks', 
			'vi_valves','vi_reservoirs','vi_pipes','vi_pumps', 'vi_demands')
		order by id)a )row;
	
	RETURN v_return;
    
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


