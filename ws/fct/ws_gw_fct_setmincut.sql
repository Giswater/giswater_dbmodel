/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2980

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_setmincut(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setmincut(p_data json)
RETURNS json AS
$BODY$

/*
-- Button networkMincut on mincut dialog
SELECT gw_fct_setmincut('{"data":{"action":"mincutNetwork", "arcId":"2001", "mincutId":"3", "usePsectors":false}}');

-- Button valveUnaccess on mincut dialog
SELECT gw_fct_setmincut('{"data":{"action":"mincutValveUnaccess", "nodeId":1001, "mincutId":"3", "usePsectors":false}}');

-- Button Accept on mincut dialog
SELECT gw_fct_setmincut('{"data":{"action":"mincutAccept", "mincutClass":1, "mincutId":"3", "status":"check", "usePsectors":false}}');

-- Button Accept on mincut conflict dialog
SELECT gw_fct_setmincut('{"data":{"action":"mincutAccept", "mincutClass":1, "mincutId":"3", "status":"continue"}}');

-- Button Accept when is mincutClass = 2
SELECT gw_fct_setmincut('{"data":{"action":"mincutAccept", "mincutClass":2, "mincutId":"3"}}');

-- Button Accept when is mincutClass = 3
SELECT gw_fct_setmincut('{"data":{"action":"mincutAccept", "mincutClass":3, "mincutId":"3"}}');

fid = 216

*/

DECLARE

v_arc integer;
v_id integer;
v_node integer;
v_mincut integer;
v_status boolean;
v_valveunaccess json;
v_action text;
v_mincut_class integer;
v_version text;
v_error_context text;
v_usepsectors boolean;
v_days integer;

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;
	SELECT giswater INTO v_version FROM sys_version order by id desc limit 1;

	-- delete previous
	DELETE FROM audit_check_data WHERE fid = 216 and cur_user=current_user;

	-- get input parameters
	v_action := (p_data ->>'data')::json->>'action';
	v_mincut := ((p_data ->>'data')::json->>'mincutId')::integer;
	v_mincut_class := ((p_data ->>'data')::json->>'mincutClass')::integer;
	v_node := ((p_data ->>'data')::json->>'nodeId')::integer;
	v_arc := ((p_data ->>'data')::json->>'arcId')::integer;
	v_usepsectors := ((p_data ->>'data')::json->>'usePsectors')::boolean;
	

	IF v_action = 'mincutNetwork' THEN

		--check if arc exists in database or look for a new arc_id in the same location
		IF (SELECT arc_id FROM arc WHERE arc_id::integer=v_arc) IS NULL THEN
			SELECT arc_id::integer INTO v_arc FROM arc a, om_mincut om WHERE ST_DWithin(a.the_geom, om.anl_the_geom,0.1) AND state=1 and om.id=v_mincut;

			IF v_arc IS NULL AND v_usepsectors is true then
				SELECT arc_id::integer INTO v_arc FROM arc a, om_mincut om WHERE ST_DWithin(a.the_geom, om.anl_the_geom,0.1) AND state=2;
			end if;
		END IF;

		RETURN gw_fct_mincut(v_arc::text, 'arc'::text, v_mincut, v_usepsectors);
	
	ELSIF v_action = 'startMincut' THEN

		IF (SELECT json_extract_path_text(value::json, 'redoOnStart','status')::boolean FROM config_param_system WHERE parameter='om_mincut_settings') is true THEN
			--reexecuting mincut on clicking start
			SELECT json_extract_path_text(value::json, 'redoOnStart','days')::integer INTO v_days FROM config_param_system WHERE parameter='om_mincut_settings';

			IF (SELECT date(anl_tstamp) + v_days FROM om_mincut WHERE id=v_mincut) <= date(now()) THEN 

				--check if arc exists in database or look for a new arc_id in the same location
				IF (SELECT arc_id FROM arc WHERE arc_id::integer=v_arc) IS NULL THEN
					SELECT arc_id::integer INTO v_arc FROM arc a, om_mincut om WHERE ST_DWithin(a.the_geom, om.anl_the_geom,0.1) AND state=1 and om.id=v_mincut;

					IF v_arc IS NULL AND v_usepsectors is true then
						SELECT arc_id::integer INTO v_arc FROM arc a, om_mincut om WHERE ST_DWithin(a.the_geom, om.anl_the_geom,0.1) AND state=2;
					end if;
				END IF;

				RETURN gw_fct_mincut(v_arc::text, 'arc'::text, v_mincut, v_usepsectors);
			ELSE
				RETURN ('{"status":"Accepted", "message":{"level":3, "text":"Start mincut"}, "version":"'||v_version||'","body":{"form":{},"data":{ "info":null,"geometry":null, "mincutDetails":null}}}}')::json;
			END IF;
		ELSE
		    --  Return
	    RETURN ('{"status":"Accepted", "message":{"level":3, "text":"Start mincut"}, "version":"'||v_version||'","body":{"form":{},"data":{ "info":null,"geometry":null, "mincutDetails":null}}}')::json;
		END IF;

	ELSIF v_action = 'mincutValveUnaccess' THEN

		RETURN gw_fct_json_create_return(gw_fct_mincut_valve_unaccess(p_data), 2980, null, null, null);
		
	ELSIF v_action = 'mincutAccept' THEN

		IF v_mincut_class = 1 THEN

			UPDATE config_param_user SET value = v_mincut::text WHERE parameter = 'inp_options_valve_mode_mincut_result' AND cur_user = current_user;
		
			RETURN gw_fct_mincut_result_overlap(p_data);

		ELSIF v_mincut_class IN (2, 3) THEN
		
			RETURN gw_fct_mincut_connec(p_data);
		
		END IF;

	END IF;
	
	--  Exception handling
	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = pg_exception_context;  
	RETURN ('{"status":"Failed", "SQLERR":' || to_json(SQLERRM) || ',"SQLCONTEXT":' || to_json(v_error_context) || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;