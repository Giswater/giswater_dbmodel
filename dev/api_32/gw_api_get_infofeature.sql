-- Function: ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer)

-- DROP FUNCTION ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_get_infofeature(
    table_id character varying,
    p_id character varying,
    p_device integer,
    p_infotype integer)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    column_type character varying;
    query_result character varying;
    position json;
    fields json;
    fields_array json[];
    position_row integer;
    combo_rows json[];
    aux_json json;    
    combo_json json;
    project_type character varying;
    table_pkey varchar;
    schemas_array name[];
    array_index integer DEFAULT 0;
    field_value character varying;
    class_id_var text;
    api_version json;



BEGIN


--    Set search path to local schema
    SET search_path = "ws_sample", public;
    
--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

--    Get schema name
    schemas_array := current_schemas(FALSE);
    

   raise notice 'table_id %, id %', table_id, p_id;
        
--    Get form fields
    EXECUTE 'SELECT array_agg(row_to_json(a)) FROM 
    (SELECT a.attname as label, a.attname as name, 
     ''text'' as type, ''string'' as "dataType", ''''::TEXT as placeholder, true as "disabled" 
   FROM pg_attribute a
  JOIN pg_class t on a.attrelid = t.oid
  JOIN pg_namespace s on t.relnamespace = s.oid
WHERE a.attnum > 0 
  AND NOT a.attisdropped
  AND t.relname = $1 
  AND s.nspname = $2
  AND a.atttypid != 150381
ORDER BY a.attnum) a'
        INTO fields_array
        USING table_id, schemas_array[1]; 

     raise notice    'fields_array %', fields_array;

--    Get id column
    EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
        INTO table_pkey
        USING table_id;


--    For views it suposse pk is the first column
    IF table_pkey ISNULL THEN
        EXECUTE '
 SELECT a.attname FROM pg_attribute a   JOIN pg_class t on a.attrelid = t.oid  JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0   AND NOT a.attisdropped
  AND t.relname = $1 
  AND s.nspname = $2
ORDER BY a.attnum LIMIT 1'

        INTO table_pkey
        USING table_id, schemas_array[1];
    END IF;


--    Get column type
    EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
  JOIN pg_class t on a.attrelid = t.oid
  JOIN pg_namespace s on t.relnamespace = s.oid
WHERE a.attnum > 0 
  AND NOT a.attisdropped
  AND a.attname = $3
  AND t.relname = $2 
  AND s.nspname = $1
ORDER BY a.attnum'
        USING schemas_array[1], table_id, table_pkey
        INTO column_type;
        
raise notice 'Layer pkey: % ; Column_type %', table_pkey, column_type;


--    Fill every value
    FOREACH aux_json IN ARRAY fields_array
    LOOP
--        Index
        array_index := array_index + 1;

--        Get field values
        EXECUTE 'SELECT ' || quote_ident(aux_json->>'name') || ' FROM ' || (table_id) || ' WHERE ' || (table_pkey) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')'  
       INTO field_value; 
          
        field_value := COALESCE(field_value, '');
        
--        Update array
          fields_array[array_index] := gw_fct_json_object_set_key(fields_array[array_index], 'value', field_value);

    END LOOP;

   
--    Convert to json
    fields := array_to_json(fields_array);

    raise notice 'fields %', fields;

--    Control NULL's
    api_version := COALESCE(api_version, '[]');    
    fields := COALESCE(fields, '[]');    
    position := COALESCE(position, '[]');


--    Return
    RETURN ('{"status":"Accepted"' ||
        ', "apiVersion":'|| api_version ||
        ', "fields":' || fields ||
        '}')::json;

--    Exception handling
  --  EXCEPTION WHEN OTHERS THEN 
  --     RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofeature(character varying, character varying, integer, integer) TO rol_dev;
