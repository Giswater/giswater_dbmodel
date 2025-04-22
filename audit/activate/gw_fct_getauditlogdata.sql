/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- DROP FUNCTION audit.gw_fct_getauditlogdata(json);

CREATE OR REPLACE FUNCTION audit.gw_fct_getauditlogdata(p_data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$

DECLARE

v_schemaname text;
v_version text;
v_error_context text;
v_log_id integer;
v_feature_id text;
v_table_name text;
v_date date;
v_olddata json;
v_newdata json;
v_idname text;
v_tstamp timestamp;
v_geometry_type text;
v_the_geom jsonb;
v_geometry text;

BEGIN
	-- search path
	SET search_path = "audit", public;
	v_schemaname = 'audit';

	-- Get api version
    SELECT value INTO v_version FROM ws.config_param_system WHERE parameter = 'admin_version';

	v_log_id = ((p_data ->>'form')::json->>'logId');
	v_date = ((p_data ->>'form')::json->>'date');
	v_feature_id = ((p_data ->>'form')::json->>'featureId');
	v_table_name = ((p_data ->>'form')::json->>'tableName');

	IF v_log_id IS NOT NULL THEN
		-- Get data from specific log
		SELECT olddata, newdata INTO v_olddata, v_newdata
		FROM log WHERE id = v_log_id;

	ELSE
		SELECT newdata, tstamp, id_name
		INTO v_newdata, v_tstamp, v_idname
		FROM log
		WHERE feature_id = v_feature_id
       	AND table_name = v_table_name
		ORDER BY tstamp DESC LIMIT 1;

		SELECT newdata INTO v_olddata
		FROM log
        WHERE feature_id = v_feature_id
		AND table_name = v_table_name
        AND tstamp::date <= v_date
		AND tstamp < v_tstamp
        ORDER BY tstamp DESC LIMIT 1;

		IF v_olddata IS NULL THEN

			EXECUTE format(
                'SELECT row_to_json(t)  
                 FROM (SELECT * FROM %I 
                 WHERE %I = %L 
                 AND date <= %L 
                 ORDER BY date DESC LIMIT 1) t',
                'ws_' || v_table_name,
                v_idname,
                v_feature_id,
                v_date
            ) INTO v_olddata;

			v_geometry_type := CASE
								WHEN v_table_name ILIKE '%node%'
								OR v_table_name ILIKE '%connec%'
							  	THEN 'Point'
								ELSE 'LineString' END;

            v_the_geom := (v_olddata::jsonb)->'the_geom';

            IF v_geometry_type = 'Point' THEN
				    v_geometry := 'POINT (' ||
				            array_to_string(
				                ARRAY[
				                    (v_the_geom->'coordinates'->0)::text,
				                    (v_the_geom->'coordinates'->1)::text
				                ], ' '
				            ) || ')';
            ELSE
                v_geometry := 'LINESTRING (' ||
                        array_to_string(
                            ARRAY[
                                replace((v_the_geom->'coordinates'->0)::text,',',''),
                                replace((v_the_geom->'coordinates'->1)::text,',','')
                            ], ', '
                        ) || ')';
                v_geometry = regexp_replace(v_geometry, '[\[\]]', '', 'g');
            END IF;

			v_olddata := jsonb_set(v_olddata::jsonb, '{the_geom}', to_jsonb(v_geometry))::json;

		END IF;
	END IF;

	-- Return JSON
	RETURN jsonb_build_object(
	        'status', 'Accepted',
	        'version', to_jsonb(v_version),
	        'olddata', COALESCE(v_olddata, '{}'),
			'newdata', COALESCE(v_newdata, '{}')
	    );

	EXCEPTION
		WHEN OTHERS THEN
			GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
			RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||
				',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;

$function$
;
