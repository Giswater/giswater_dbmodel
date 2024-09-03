/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3322

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_setpsectorcostremovedpipes(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setpsectorcostremovedpipes(p_data json)
RETURNS json AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_setpsectorcostremovedpipes('{"data":{"parameters":{"expl":89, "price":"RETIRADA_FIB",
 "observ":"Retirada de fibrocemento", "material":"FIB"}}}');
*/

DECLARE

v_expl  integer;		
v_material text;
v_price	text;
v_version text;
v_fid integer = 523;
v_observ text;

v_error_context text;

v_result json;
v_result_info json;
v_result_line json;

v_sql text;

BEGIN
	-- Search path
	SET search_path = "SCHEMA_NAME", public;
	
	-- select version
	SELECT giswater INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	-- getting input data 	
	v_expl := ((p_data ->>'data')::json->>'parameters')::json->>'expl';
	v_material := ((p_data ->>'data')::json->>'parameters')::json->>'material';
	v_price := ((p_data ->>'data')::json->>'parameters')::json->>'price';
	v_observ := ((p_data ->>'data')::json->>'parameters')::json->>'observ';
	
	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fid=v_fid;
	DELETE FROM audit_check_data WHERE cur_user="current_user"()AND fid=v_fid;	
	
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, concat('SET PSECTOR COST FOR REMOVED PIPES'));
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (v_fid, null, 4, '--------------------------------------------------------');


	v_sql = 'INSERT INTO plan_psector_x_other (price_id, measurement, psector_id, observ)
	SELECT '||quote_literal(v_price)||', sum(gis_length), psector_id, '||quote_literal(v_observ)||' from plan_psector_x_arc JOIN vu_arc USING (arc_id)
	WHERE cat_matcat_id = '||quote_literal(v_material)||' and expl_id = '||v_expl||' group by 3';

	EXECUTE v_sql;

	-- create log
	INSERT INTO anl_arc (arc_id, arccat_id, node_1, node_2, state, expl_id, the_geom, descript, fid)
	SELECT arc_id, arccat_id, node_1, node_2, a.state, expl_id, the_geom, v_observ, v_fid FROM plan_psector_x_arc JOIN vu_arc a USING (arc_id)
	WHERE cat_matcat_id = v_material and expl_id = v_expl;

	-- get results
	--lines
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
	  	SELECT jsonb_build_object(
	     'type',       'Feature',
	    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
	    'properties', to_jsonb(row) - 'the_geom'
	  	) AS feature
	  	FROM (SELECT id, arc_id, arccat_id, state,  node_1, node_2, expl_id, fid, st_length(the_geom) as length, the_geom
	  	FROM  anl_arc WHERE cur_user="current_user"() AND fid=v_fid) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "features":',v_result, '}'); 	
	
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND fid=105 order by  id asc) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 

	--  Return
	RETURN (('{"status":"Accepted", "message":{"level":1, "text":"Analysis done successfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"line":'||v_result_line||
			'}}'||
	    '}')::json, 3322, null, null, null);

	--  Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = pg_exception_context;  
	RETURN ('{"status":"Failed", "SQLERR":' || to_json(SQLERRM) || ',"SQLCONTEXT":' || to_json(v_error_context) || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;