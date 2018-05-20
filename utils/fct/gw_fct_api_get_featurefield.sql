
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_api_get_featurefield(
    p_table_id character varying,
    p_id character varying,
    p_client integer)
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
    formToDisplayName character varying;
    table_pkey varchar;
    schemas_array name[];
    array_index integer DEFAULT 0;
    field_value character varying;
    formtodisplay text;
    api_version json;


BEGIN


--    Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;

--    Get schema name
    schemas_array := current_schemas(FALSE);

--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

    --  Take form_id 
--    EXECUTE 'SELECT formid FROM config_web_layer WHERE layer_id = $1 LIMIT 1'
 --       INTO formtodisplay
  --      USING p_table_id; 
  
--    Check generic
    IF formtodisplay ISNULL THEN
        formtodisplay := 'F16';
    END IF;

-----------------------------------------
/*TO DO : USE THE dv_querytext strategy
----------------------------------------
   
--    Get fields
    EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT form_label, column_id, sys_api_cat_widgettype.idval AS widgettype, sys_api_cat_datatype.idval AS datatype, 
			placeholder FROM config_api_layer_field 
			JOIN sys_api_cat_widgettype ON sys_api_cat_widgettype_id=sys_api_cat_widgettype.id JOIN sys_api_cat_datatype ON sys_api_cat_datatype_id=sys_api_cat_datatype.id
			WHERE table_id = $1 AND sys_api_cat_widgettype.client_id=$2 ORDER BY orderby) a'
        INTO fields_array
        USING p_table_id, p_client;    


--    Get combo rows
    EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT config_api_layer_field.id, column_id, sys_api_cat_widgettype.idval AS widgettype, sys_api_cat_datatype.idval AS datatype, 
			dv_table, dv_id_column, dv_name_column, dv_querytext, dv_filterbyfield, ROW_NUMBER() OVER() AS rownum, sys_api_cat_datatype.client_id FROM config_api_layer_field 
			JOIN sys_api_cat_widgettype ON sys_api_cat_widgettype_id=sys_api_cat_widgettype.id JOIN sys_api_cat_datatype ON sys_api_cat_datatype_id=sys_api_cat_datatype.id
			WHERE table_id = $1 AND sys_api_cat_widgettype_id=2 AND sys_api_cat_widgettype.client_id=$2 ORDER BY rownum)a'
    INTO combo_rows
    USING p_table_id, p_client;
    combo_rows := COALESCE(combo_rows, '{}');

*/
--    Get fields
    EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT form_label, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype ,placeholder, orderby 
		FROM config_api_layer_field WHERE table_id = $1 ORDER BY orderby) a'
        INTO fields_array
        USING p_table_id, p_client; 

--    Get combo rows
    EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype,
			dv_table, dv_id_column, dv_name_column, dv_querytext, dv_filterbyfield, orderby 
			FROM config_api_layer_field WHERE table_id = $1 ORDER BY orderby) a WHERE widgettype = 2'
    INTO combo_rows
    USING p_table_id, p_client;
    combo_rows := COALESCE(combo_rows, '{}');



--    Update combos
    FOREACH aux_json IN ARRAY combo_rows
    LOOP
    
-----------------------------
/*  TODO DO FILTER BY FILTER
-----------------------------

-- For filtered combos
	IF (aux_json->>'dv_filterbyfield') IS NOT NULL THEN 

		-- Get vdefault values of parent filter
		EXECUTE 'SELECT config_param_vdefault FROM config_web_fields WHERE table_id=$1 AND name='|| quote_ident(aux_json->>'filterby')
		INTO config_param_vdefault_var
		USING table_id, filterby;

		-- Get filter
		IF config_param_vdefault_var IS NOT NULL THEN 
			EXECUTE 'SELECT value FROM config_param_user WHERE parameter=$1 cur_user=$2'
			INTO filter_val
			USING config_param_vdefault_var, current_user;
		END IF;

		-- Get combo id's using filtered values
		IF filter_val IS NOT NULL THEN
			EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'id') || ')) FROM ('|| quote_ident(aux_json->>'query_text')||' AND '
			||quote_ident(aux_json->>'onfilter')||' = '||filter_val||') a'
			INTO combo_json;
		END IF;

		EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'id') || ')) FROM ('|| quote_ident(aux_json->>'query_text')') a'
		INTO combo_json;

		-- Update array
		fields_array[(aux_json->>'rownum')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'rownum')::INT], 'comboIds', COALESCE(combo_json, '[]'));

		-- Set selected id
		IF combo_json IS NOT NULL THEN
			fields_array[(aux_json->>'rownum')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'rownum')::INT], 'selectedId', combo_json->0);
		ELSE
			fields_array[(aux_json->>'rownum')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'rownum')::INT], 'selectedId', to_json('Fred said "Hi."'::text));        
		END IF;

		-- Get combo values using filtered values
		IF filter_val IS NOT NULL THEN
			EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'name') || ')) FROM ('|| quote_ident(aux_json->>'query_text')||' AND '
			||quote_ident(aux_json->>'onfilter')||' = '||filter_val||') a'
			INTO combo_json;
		END IF;

		EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'name') || ')) FROM ('|| quote_ident(aux_json->>'query_text')') a'
		INTO combo_json; 
		
		combo_json := COALESCE(combo_json, '[]');

--        	Update array
		fields_array[(aux_json->>'rownum')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'rownum')::INT], 'comboNames', combo_json);

*/
	
--      Get combo id's
	    EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'dv_id_column') || ')) FROM (SELECT ' || quote_ident(aux_json->>'dv_id_column') || ' FROM ' 
		|| quote_ident(aux_json->>'dv_table') || ' ORDER BY '||quote_ident(aux_json->>'dv_name_column') || ') a'
        INTO combo_json; 


--        Update array
        fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboIds', COALESCE(combo_json, '[]'));

        raise notice' fields_array %', fields_array;

        
        IF combo_json IS NOT NULL THEN
            fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'selectedId', combo_json->0);
        ELSE
            fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'selectedId', to_json('Fred said "Hi."'::text));        
        END IF;


--        Get combo values
        EXECUTE 'SELECT array_to_json(array_agg(' || quote_ident(aux_json->>'dv_name_column') || ')) FROM (SELECT ' || quote_ident(aux_json->>'dv_name_column') ||  ' FROM '
		|| quote_ident(aux_json->>'dv_table') || ' ORDER BY '||quote_ident(aux_json->>'dv_name_column') || ') a'
        INTO combo_json; 
        combo_json := COALESCE(combo_json, '[]');


--      Update array
        fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboNames', combo_json);

     --  END IF;

    END LOOP;



--    Get existing values for the element
    IF p_id IS NOT NULL THEN

--        Get id column
        EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
            INTO table_pkey
            USING p_table_id;


--        For views is the first column
        IF table_pkey ISNULL THEN
            EXECUTE 'SELECT column_name FROM information_schema.columns WHERE table_schema = $1 AND table_name = ' || quote_literal(p_table_id) || ' AND ordinal_position = 1'
            INTO table_pkey
            USING schemas_array[1];
        END IF;

	raise notice' table_pkey %', table_pkey;


--        Get column type
        EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(p_table_id) || ' AND column_name = $2'
            USING schemas_array[1], table_pkey
            INTO column_type;

	raise notice' column_type %', column_type;


--        Fill every value
        FOREACH aux_json IN ARRAY fields_array
        LOOP

--            Index
            array_index := array_index + 1;

--            Get  values
            EXECUTE 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(table_pkey) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')' 
                INTO field_value; 
            field_value := COALESCE(field_value, '');
            

--            Update array
            IF aux_json->>'widgettype' = '2' THEN
                fields_array[array_index] := gw_fct_json_object_set_key(fields_array[array_index], 'selectedId', field_value);
            ELSE            
                fields_array[array_index] := gw_fct_json_object_set_key(fields_array[array_index], 'value', field_value);
            END IF;
            
        END LOOP;

    END IF;    

    
--    Convert to json
    fields := array_to_json(fields_array);


--    Control NULL's
	api_version := COALESCE(api_version, '[]');
    fields := COALESCE(fields, '[]');    
    
	
--    Return
    RETURN ('{"status":"Accepted"' ||
       ', "apiVersion":'|| api_version ||
        ', "fields":' || fields ||
        '}')::json;

--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
