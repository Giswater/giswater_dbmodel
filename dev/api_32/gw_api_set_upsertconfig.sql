-- Function: ws_sample.gw_api_set_upsertconfig(json)

-- DROP FUNCTION ws_sample.gw_api_set_upsertconfig(json);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_set_upsertconfig(p_fields json)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    schemas_array name[];
    api_version json;
    v_text text[];
    json_field json;
    v_project_type text;
    v_widget text;
    v_chk text;
    v_value text;
    v_isChecked text;
    v_json json;
    result text;
    v_table text;
    
v_return text;


BEGIN


--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

--  Get project type
    SELECT wsoftware INTO v_project_type FROM version LIMIT 1;

--    Get schema name
    schemas_array := current_schemas(FALSE);



    --FOREACH field IN p_fields
    FOR v_json IN SELECT * FROM json_array_elements(p_fields) as v_text
    LOOP
    
	-- Get values from json
	v_widget:= (SELECT (v_json ->> 'widget')) ;
	v_chk:= (SELECT (v_json ->> 'chk')) ;
	v_value:= (SELECT (v_json ->> 'value')) ;
	v_isChecked:= (SELECT (v_json ->> 'isChecked')) ;

	IF v_json ->> 'sys_role_id' = 'role_admin' THEN
		v_table:= 'config_param_system';

		
		EXECUTE 'SELECT * FROM '|| quote_ident(v_table) ||' WHERE parameter = $1' 
		INTO result
		USING v_widget;
		RAISE NOTICE 'result: %',result;
		
		-- Perform INSERT
		IF v_isChecked = 'True' THEN

			IF result IS NOT NULL THEN

			EXECUTE 'UPDATE '|| quote_ident(v_table) ||' SET value = $1 WHERE parameter = $2'
			USING  v_value, v_widget;
			
			ELSE

			EXECUTE 'INSERT INTO '|| quote_ident(v_table) ||' (parameter, value) VALUES ($1, $2)'
			USING  v_widget, v_value;
			END IF;
			
		ELSIF v_isChecked = 'False' THEN

			IF result IS NOT NULL THEN

			EXECUTE 'DELETE FROM '|| quote_ident(v_table) ||' WHERE parameter = $1'
			USING v_widget;
			
			END IF;

		END IF;
	ELSE
		v_table:= 'config_param_user';

		EXECUTE 'SELECT * FROM '|| quote_ident(v_table) ||' WHERE parameter = $1 AND cur_user=current_user' 
		INTO result
		USING v_widget;
		RAISE NOTICE 'result: %',result;
		
		-- Perform INSERT
		IF v_isChecked = 'True' THEN

			IF result IS NOT NULL THEN

			EXECUTE 'UPDATE '|| quote_ident(v_table) ||' SET value = $1 WHERE parameter = $2 AND cur_user=current_user'
			USING  v_value, v_widget;
			
			ELSE

			EXECUTE 'INSERT INTO '|| quote_ident(v_table) ||' (parameter, value, cur_user) VALUES ($1, $2, current_user)'
			USING  v_widget, v_value;
			END IF;
			
		ELSIF v_isChecked = 'False' THEN

			IF result IS NOT NULL THEN

			EXECUTE 'DELETE FROM '|| quote_ident(v_table) ||' WHERE parameter = $1 AND cur_user=current_user'
			USING v_widget;
			
			END IF;

		END IF;
	END IF;
	
	RAISE NOTICE 'v_table: %',v_table;
	--RAISE NOTICE 'v_widget: %',v_widget;
	--RAISE NOTICE 'v_chk: %',v_chk;
	--RAISE NOTICE 'v_value: %',v_value;
	--RAISE NOTICE 'v_isChecked: %',v_isChecked;
	
   END LOOP;

--    Return
    RETURN ('{"status":"Accepted", "apiVersion":'|| api_version ||'}')::json;    

--    Exception handling
   -- EXCEPTION WHEN OTHERS THEN 
    --    RETURN ('{"status":"Failed","message":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_api_set_upsertconfig(json)
  OWNER TO geoadmin;
