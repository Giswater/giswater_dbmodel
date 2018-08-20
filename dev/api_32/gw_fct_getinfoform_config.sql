-- Function: ws_sample.gw_fct_getinfoform_config(integer)

-- DROP FUNCTION ws_sample.gw_fct_getinfoform_config(integer);

CREATE OR REPLACE FUNCTION ws_sample.gw_fct_getinfoform_config(p_device integer)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    formAdmin json;    
    formTabs text;
    combo_json json;
    fieldsJson json;
    api_version json;
    rec_tab record;
    v_firsttab boolean;
    v_active boolean;
    fields json;
    fields_array json[];
    fields_admin_array json[];
    v_querytext_result text[];
    aux_json json;
    v_project_type text;
    tabUser json;
    combo_json_parent json;
    combo_json_child json;
    combo_rows json[];
    combo_rows_child json[];
    v_selected_id text;
    query_text text;
    aux_json_child json;
    fields_admin json; 

BEGIN

-- Set search path to local schema
    SET search_path = "ws_sample", public;

--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;
        
--  Get project type
    SELECT wsoftware INTO v_project_type FROM version LIMIT 1;

-- Create tabs array
    formTabs := '[';

-- basic_tab
-------------------------
    SELECT * INTO rec_tab FROM config_api_tabs WHERE layer_id='F51' AND formtab='tabUser';
    IF rec_tab.formtab IS NOT NULL THEN

	-- Get all parameters from audit_cat param_user
	EXECUTE 'SELECT (array_agg(row_to_json(a))) FROM (
		SELECT form_label as label, audit_cat_param_user.id as name,  sys_api_cat_datatype_id as datatype, sys_api_cat_widgettype_id as widgettype, layout_id,layout_order, sys_role_id, row_number()over(ORDER BY layout_id, layout_order) AS orderby, (CASE WHEN value is not null THEN 1 ELSE 0 END) AS checked, value, project_type, dv_querytext
		FROM audit_cat_param_user LEFT JOIN (SELECT * FROM config_param_user WHERE cur_user=current_user) a ON a.parameter=audit_cat_param_user.id 
		WHERE sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))
		AND (project_type =''utils'' or project_type='||quote_literal(LOWER(v_project_type))||')
		AND sys_role_id != ''role_admin''
		AND isenabled IS TRUE ORDER by orderby)a'
			INTO fields_array ;

        RAISE NOTICE 'current_user %', current_user;

        EXECUTE 'SELECT (array_agg(row_to_json(a))) FROM (
		SELECT form_label as label, audit_cat_param_user.id as name,  audit_cat_param_user.sys_api_cat_datatype_id as datatype, audit_cat_param_user.sys_api_cat_widgettype_id as widgettype, audit_cat_param_user.layout_id,audit_cat_param_user.layout_order, audit_cat_param_user.sys_role_id, row_number()over(ORDER BY audit_cat_param_user.layout_id, audit_cat_param_user.layout_order) AS orderby, (CASE WHEN value is not null THEN 1 ELSE 0 END) AS checked, value, audit_cat_param_user.project_type, audit_cat_param_user.dv_querytext
		FROM audit_cat_param_user LEFT JOIN (SELECT * FROM config_param_system) a ON a.parameter=audit_cat_param_user.id 
		WHERE sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))
		AND (audit_cat_param_user.project_type =''utils'' or audit_cat_param_user.project_type='||quote_literal(LOWER(v_project_type))||')
		AND sys_role_id = ''role_admin''
		AND audit_cat_param_user.isenabled IS TRUE ORDER by orderby)a'
			INTO fields_admin_array ;

        RAISE NOTICE 'fields_admin_array %', fields_admin_array;

	--  Combo rows
/*	EXECUTE 'SELECT (array_agg(row_to_json(a))) FROM (
		 SELECT form_label as label, audit_cat_param_user.id as name,  sys_api_cat_datatype_id as datatype, sys_api_cat_widgettype_id as widgettype, 
		 layout_id, layout_order, orderby, value, dv_querytext
		 FROM audit_cat_param_user LEFT JOIN (SELECT * FROM config_param_user WHERE cur_user=current_user) a ON a.parameter=audit_cat_param_user.id 
		 WHERE sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))
		 AND (project_type =''utils'' or project_type='||quote_literal(LOWER(v_project_type))||')
		 AND isenabled IS TRUE AND dv_parent_id IS NULL ORDER BY orderby) a WHERE widgettype = 2'
			INTO combo_rows;
			combo_rows := COALESCE(combo_rows, '{}');

        RAISE NOTICE 'combo_rows %', combo_rows;*/

	FOREACH aux_json IN ARRAY fields_array
	LOOP
		IF (aux_json->>'widgettype') = '2' THEN
			raise notice 'aux_json %', aux_json;
		
		-- Get combo id's
		EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json->>'dv_querytext')||' ORDER BY idval)a'
			INTO combo_json;


		-- Update array
		fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboIds', COALESCE(combo_json, '[]'));
		fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'selectedId', combo_json->>'value');

		-- Get combo values
		EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json->>'dv_querytext')||' ORDER BY idval)a'
			INTO combo_json; 
			combo_json := COALESCE(combo_json, '[]');

		-- Update array
		fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboNames', combo_json);
		
		IF (aux_json->>'dv_isparent') IS NOT NULL THEN

			--  Combo rows child
			EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype,
				dv_querytext, dv_isparent, dv_parent_id, orderby , dv_querytext_filterc
				FROM config_api_layer_field WHERE table_id = $1 AND dv_parent_id='||quote_literal(aux_json->>'column_id')||' ORDER BY orderby) a WHERE widgettype = 2'
				INTO combo_rows_child
				USING p_table_id, p_device;
				combo_rows_child := COALESCE(combo_rows_child, '{}');
			
			FOREACH aux_json_child IN ARRAY combo_rows_child
			LOOP

				SELECT (json_array_elements(array_to_json(fields_array[(aux_json->> 'orderby')::INT:(aux_json->> 'orderby')::INT])))->>'selectedId' INTO v_selected_id;

				-- Get combo id's
				IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND v_selected_id IS NOT NULL THEN		
					query_text= 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(v_selected_id)||' ORDER BY idval) a';
					execute query_text INTO combo_json_child;
				ELSE 	
					EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a' INTO combo_json_child;
				END IF;
					
				-- Update array
				fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboIds', COALESCE(combo_json_child, '[]'));
				fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'selectedId', combo_json_child->>'value');      
				
				-- Get combo values
				IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND (aux_json->> 'selectedId') IS NOT NULL THEN
					query_text= 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(v_selected_id)||' ORDER BY idval) a';
					execute query_text INTO combo_json_child;
				ELSE 	
					EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a'
						INTO combo_json_child;
				END IF;

				combo_json_child := COALESCE(combo_json_child, '[]');
			
				-- Update array
				fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboNames', combo_json_child);
			END LOOP;
		END IF;
		END IF;
	END LOOP;
	
--     Convert to json
       fields := array_to_json(fields_array);
       
        -- Add tab name to json
        tabUser := ('{"fields":' || tabUser || '}')::json;
        tabUser := gw_fct_json_object_set_key(tabUser, 'tabName', 'tabuser'::TEXT);
        tabUser := gw_fct_json_object_set_key(tabUser, 'tabLabel', 'Valors usuari'::TEXT);
        tabUser := gw_fct_json_object_set_key(tabUser, 'tabIdName', 'id'::TEXT);
        tabUser := gw_fct_json_object_set_key(tabUser, 'active', v_active::TEXT);

        -- Create tabs array
        formTabs := formTabs || tabUser::text;

        v_firsttab := TRUE;
        v_active :=FALSE;

    END IF;


-- Admin tab
--------------
  /*  SELECT * INTO rec_tab FROM config_api_tabs WHERE layer_id='F51' AND formtab='tabAdmin' ;
    IF rec_tab.formtab IS NOT NULL AND 'role_admin' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member'))THEN

	-- Get fields
	EXECUTE 'SELECT (array_agg(row_to_json(a))) FROM (SELECT field_label, parameter AS field_name, value as field_value, 
		sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype, orderby 
		FROM config_param_system WHERE isenabled=TRUE ORDER BY orderby) a'
		INTO fields_array;

	-- Convert to json
	fields := array_to_json(fields_array);
        fields := COALESCE(fields, '[]');    

        -- Create network tab form
        formAdmin := json_build_object('tabName','Admin','tabLabel',rec_tab.tablabel);
        formAdmin := gw_fct_json_object_set_key(formAdmin, 'fields', fields);

        formTabs := formTabs || formAdmin::text;

     END IF;*/
    
--    Finish the construction of formtabs
    formTabs := formtabs ||']';

--    Check null
    formTabs := COALESCE(formTabs, '[]');    

    --    Convert to json
    fields := array_to_json(fields_array);
    fields_admin := array_to_json(fields_admin_array);

--    Return
    RETURN ('{"status":"Accepted"' ||
        ', "formTabs":' || formTabs ||
        ', "fields":' || fields ||
        ', "fields_admin":' || fields_admin ||
        '}')::json;
        

--    Exception handling
--    EXCEPTION WHEN OTHERS THEN 
        --RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_fct_getinfoform_config(integer)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_fct_getinfoform_config(integer) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_fct_getinfoform_config(integer) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_fct_getinfoform_config(integer) TO rol_dev;
