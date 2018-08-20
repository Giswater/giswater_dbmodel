-- Function: ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json)

-- DROP FUNCTION ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_set_upsertfields(
    p_table_id character varying,
    p_id character varying,
    p_reduced_geometry geometry,
    p_device integer,
    p_info_type integer,
    p_fields json)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    column_type character varying;
    schemas_array name[];
    sql_query varchar;
    v_idname varchar;
    column_type_id character varying;
    api_version json;
    v_text text[];
    json_field json;
    text text;
    rec record;
    i integer=1;
    v_field text;
    v_value text;
v_return text;


BEGIN


--    Set search path to local schema
    SET search_path = "ws_sample", public;
RAISE NOTICE 'p_fields %',p_fields;    
	select array_agg(row_to_json(a)) into v_text from json_each(p_fields)a;

--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

--    Get schema name
    schemas_array := current_schemas(FALSE);

--    Call for upsert control
      --SELECT gw_api_get_upsertfeature(p_table_id, p_id, p_reduced_geometry, p_device, p_info_type, 'UPSERTGEOM') INTO v_return;
	

--    Get id column, for tables is the key column
    EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
        INTO v_idname
        USING p_table_id;
        
    -- For views it suposse pk is the first column
    IF v_idname ISNULL THEN
        EXECUTE '
        SELECT a.attname FROM pg_attribute a   JOIN pg_class t on a.attrelid = t.oid  JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0   AND NOT a.attisdropped
        AND t.relname = $1 
        AND s.nspname = $2
        ORDER BY a.attnum LIMIT 1'
        INTO v_idname
        USING p_table_id, schemas_array[1];
    END IF;

--   Get id column type
-------------------------
    EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
    JOIN pg_class t on a.attrelid = t.oid
    JOIN pg_namespace s on t.relnamespace = s.oid
    WHERE a.attnum > 0 
    AND NOT a.attisdropped
    AND a.attname = $3
    AND t.relname = $2 
    AND s.nspname = $1
    ORDER BY a.attnum'
        USING schemas_array[1], p_table_id, v_idname
        INTO column_type_id;
 RAISE NOTICE 'v_text %',v_text;            
    FOREACH text IN ARRAY v_text 
    LOOP

	-- Get field and value from json
	SELECT v_text [i] into json_field;
	v_field:= (SELECT (json_field ->> 'key')) ;
	v_value:= (SELECT (json_field ->> 'value')) ;

	RAISE NOTICE 'v_field: % v_value %',v_field, v_value;
	i=i+1;

	-- Get column type
	EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(p_table_id) || ' AND column_name = $2'
		USING schemas_array[1], v_field
		INTO column_type;
		
	raise notice '%' ,p_table_id;

	IF v_field='state' THEN
		PERFORM gw_fct_state_control(v_feature_type, p_id, v_value, 'UPDATE');
	END IF;

	--    Value update
	sql_query := 'UPDATE ' || quote_ident(p_table_id) || ' SET ' || quote_ident(v_field) || ' = CAST(' || quote_literal(v_value) || ' AS ' 
	|| column_type || ') WHERE ' || quote_ident(v_idname) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type_id || ')';

	EXECUTE sql_query;
	
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
ALTER FUNCTION ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertfields(character varying, character varying, geometry, integer, integer, json) TO rol_dev;
