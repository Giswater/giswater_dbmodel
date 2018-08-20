-- Function: ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_get_combochilds(
    p_table_id character varying,
    p_id character varying,
    p_idname character varying,
    p_comboparent character varying,
    p_combovalue character varying)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    fields json;
    fields_array json[];
    combo_rows_child json[];
    aux_json_child json;    
    combo_json_child json;
    project_type character varying;
    table_pkey varchar;
    schemas_array name[];
    field_value character varying;
    api_version json;
    v_notice text;
    v_selected_id text;
    query_text text;
    v_current_value text;
    v_column_type varchar;
    test_text text;


BEGIN

	-- Set search path to local schema
	SET search_path = "ws_sample", public;

	-- Get schema name
	schemas_array := current_schemas(FALSE);

	-- get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO api_version;
		
	-- get column type of idname
        EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(p_table_id) || ' AND column_name = $2'
            USING schemas_array[1], p_idname
            INTO v_column_type;

	--  Combo rows child
	EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype,
		dv_querytext, dv_isparent, dv_parent_id, orderby , dv_querytext_filterc
		FROM config_api_layer_field WHERE column_id = $1 AND dv_parent_id='||quote_literal(p_comboparent)||' ORDER BY orderby) a WHERE widgettype = 2'
		INTO combo_rows_child
		USING p_idname;
		combo_rows_child := COALESCE(combo_rows_child, '{}');

	raise notice 'combo_rows_child %', combo_rows_child;
			
	FOREACH aux_json_child IN ARRAY combo_rows_child
	LOOP
		raise notice 'aux_json_child %', aux_json_child;

		test_text := 'SELECT ' || quote_ident(aux_json_child->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(p_idname) || ' = 
			CAST(' || quote_literal(p_id) || ' AS ' || v_column_type || ')' ;
		raise notice 'test_text %', test_text;
		-- Get current value
		EXECUTE 'SELECT ' || quote_ident(aux_json_child->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(p_idname) || ' = 
			CAST(' || quote_literal(p_id) || ' AS ' || v_column_type || ')' 
			INTO v_current_value; 	
			v_current_value := COALESCE(v_current_value, '');
		raise notice 'v_current_value % ',v_current_value;
		-- Get combo id's
		IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND p_combovalue IS NOT NULL THEN
			query_text= 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(p_combovalue)||'
			 ORDER BY idval) a';
			 raise notice 'query_text %', query_text;
			execute query_text INTO combo_json_child;
			raise notice 'combo_json_child %', combo_json_child;
		ELSE 	
			EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a' INTO combo_json_child;
		END IF;
			
		combo_json_child := COALESCE(combo_json_child, '[]');
		fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboIds', COALESCE(combo_json_child, '[]'));

		-- Set current value
		IF p_id IS NULL THEN
			-- to do: get vdefault values
			fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'selectedId', combo_json_child->0);
		ELSE
			--to do: check if v_current_value is in combo_json_child or not
			fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'selectedId', v_current_value);           		
		END IF;
		
		-- Get combo value's
		IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND p_combovalue IS NOT NULL THEN
			query_text= 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(p_combovalue)||' ORDER BY idval) a';
			execute query_text INTO combo_json_child;
		ELSE 	
			EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a'
				INTO combo_json_child;
		END IF;
		combo_json_child := COALESCE(combo_json_child, '[]');
		fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboNames', combo_json_child);

	END LOOP;
  
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
ALTER FUNCTION ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying) TO rol_dev;
