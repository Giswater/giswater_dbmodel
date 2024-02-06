/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:3166

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_import_scada_x_data(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_import_scada_values(p_data json)
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_import_scada_values($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},"data":{}}$$)

-- fid 469 for generic import scada values 
       502 for specific flowmeter_daily_values wich has an own fid but uses this function to work with.
  
*/


DECLARE

v_addfields record;
v_result_id text= 'import scada values';
v_result json;
v_result_info json;
v_project_type text;
v_version text;
v_fid integer = 0;
i integer = 0;
v_count integer;

BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	v_fid = (p_data ->>'data')::json->>'fid';
	if v_fid is null then v_fid = (SELECT fid FROM temp_csv where cur_user = current_user order by id desc limit 1); end if;

	-- get system parameters
	SELECT project_type, giswater  INTO v_project_type, v_version FROM sys_version ORDER BY id DESC LIMIT 1;


	-- manage log (fid: v_fid)
	DELETE FROM audit_check_data WHERE fid = v_fid AND cur_user=current_user;
	IF v_fid = 469 THEN
		INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('IMPORT SCADA VALUES FILE'));
	ELSIF v_fid = 502 THEN
		INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('IMPORT FLOWMETER DAILY VALUES FILE'));
	END IF;
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('-------------------------------------'));
   
 	-- starting process
	FOR v_addfields IN SELECT * FROM temp_csv WHERE cur_user=current_user AND fid = v_fid
	LOOP
		i = i+1;
		INSERT INTO ext_rtc_scada_x_data (scada_id, node_id, value_date, value, value_status, annotation) VALUES
		(v_addfields.csv1, v_addfields.csv2, v_addfields.csv3::date, v_addfields.csv4::float, v_addfields.csv5::integer, v_addfields.csv6);			
	END LOOP;

	SELECT count(*) INTO v_count FROM (SELECT DISTINCT csv1 FROM temp_csv WHERE cur_user=current_user AND fid = v_fid)a;

	-- manage log (fid: v_fid)
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('Reading values from temp_csv table -> Done'));
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('Inserting values on ext_rtc_scada_x_data table -> Done'));
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('Deleting values from temp_csv -> Done'));
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('Process finished with ',i, ' rows inserted.'));
	INSERT INTO audit_check_data (fid, result_id, error_message) VALUES (v_fid, v_result_id, concat('Data from ',v_count, ' scada tags have been imported.'));

	-- get log (fid: v_fid)
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message AS message FROM audit_check_data WHERE cur_user="current_user"() AND fid = v_fid) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
		
	-- Control nulls
	v_version := COALESCE(v_version, '{}'); 
	v_result_info := COALESCE(v_result_info, '{}'); 
 
	-- Return
	RETURN ('{"status":"Accepted", "message":{"level":0, "text":"Process executed"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||'}}'||
	    '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
