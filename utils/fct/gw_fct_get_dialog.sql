/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
This version of Giswater is provided by Giswater Association
*/

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_get_dialog(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_get_dialog(p_data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$

--FUNCTION CODE: 3347

/*EXAMPLE:

SELECT SCHEMA_NAME.gw_fct_get_dialog($${"client":{"device":5, "lang":"es_ES", "cur_user": "bgeo", "infoType":1, "epsg":25831},
"form":{"formName": "generic","formType":"nvo_manager"}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}}}$$);

SELECT SCHEMA_NAME.gw_fct_get_dialog($${"client":{"device":5, "lang":"es_ES", "cur_user": "bgeo", "infoType":1, "epsg":25831},
"form":{"formName": "generic","formType":"nvo_roughness", "tableName":"cat_mat_roughness", "id":"id", "idval":1},
 "feature":{}, "data":{"filterFields":{}, "pageInfo":{}}}$$);

*/

DECLARE

v_array_index integer DEFAULT 0;
v_field_value character varying;
v_aux_json json;
v_form text;
v_device integer;
v_version text;
v_fields_array json[];
v_querystring text;
v_fieldsjson jsonb := '[]';
v_form_tabs_json json;
v_form_tabs_layouts jsonb;
v_cur_user text;
v_formname text;
v_formtype text;
v_layouts text[];
v_layout text;
v_addparam json;
v_error_context text;
v_widget jsonb;
v_tab_name text;
v_tab_names jsonb;
v_tab_data jsonb;
v_tablename text;
v_id text;
v_idval text;
v_values_array json;

BEGIN
    -- Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;

    -- Get api version
    SELECT value INTO v_version FROM config_param_system WHERE parameter='admin_version';

    -- Get parameters from input
    v_device = ((p_data ->>'client')::json->>'device')::integer;
    v_cur_user = ((p_data ->>'client')::json->>'cur_user');
	v_formname = ((p_data ->>'form')::json->>'formName');
	v_formtype = ((p_data ->>'form')::json->>'formType');
	v_tablename = ((p_data ->>'form')::json->>'tableName');
	v_id = ((p_data ->>'form')::json->>'id');
	v_idval = ((p_data ->>'form')::json->>'idval');


    -- Get fields
    SELECT gw_fct_getformfields(
        v_formname,
        v_formtype,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        v_device,
        NULL
    ) INTO v_fields_array;

	IF array_length(v_fields_array, 1) IS NULL THEN
    	RAISE EXCEPTION 'Variable v_fields_array is empty. Check the "formName" or "formType" parameters.';
	END IF;

	IF v_tablename IS NOT NULL AND v_id IS NOT NULL OR v_idval IS NOT NULL THEN

		v_querystring = concat(
		    'SELECT row_to_json(a) FROM (SELECT * FROM ',v_tablename,' WHERE ',v_id,' = ',quote_literal(v_idval),') a;'
		);

	    raise notice 'test v_querystring %', v_querystring;
	    EXECUTE v_querystring INTO v_values_array;
	    raise notice 'test v_values_array %', v_values_array;

		-- looping the array setting values
		FOREACH v_aux_json IN ARRAY v_fields_array
		LOOP
			v_array_index := v_array_index + 1;

			v_field_value := (v_values_array->>(v_aux_json->>'columnname'));

			-- setting values
			IF (v_aux_json->>'widgettype')='combo' THEN
				v_fields_array[v_array_index] := gw_fct_json_object_set_key(v_fields_array[v_array_index], 'selectedId', COALESCE(v_field_value, ''));
			ELSIF (v_aux_json->>'widgettype')='button' and json_extract_path_text(v_aux_json,'widgetcontrols','text') IS NOT NULL THEN
				v_fields_array[v_array_index] := gw_fct_json_object_set_key(v_fields_array[v_array_index], 'value', json_extract_path_text(v_aux_json,'widgetcontrols','text'));
			ELSE
				v_fields_array[v_array_index] := gw_fct_json_object_set_key(v_fields_array[v_array_index], 'value', COALESCE(v_field_value, ''));
			END IF;

		END LOOP;
	END IF;
	-- Create JSON from layouts
	SELECT array_agg(distinct layoutname) into v_layouts FROM config_form_fields  WHERE formtype = v_formtype;


	v_form:= '"layouts": {';

	FOREACH v_layout IN ARRAY v_layouts
	LOOP
		select addparam into v_addparam from config_typevalue where id = v_layout;
		v_form:= concat(v_form,  '"', v_layout, '":',coalesce(v_addparam, '{}'),',');
	END LOOP;

	v_form := left(v_form, length(v_form) - 1);
	v_form:= concat(v_form,'}' );


    -- Loop through widgets
    FOR i IN 1 .. array_length(v_fields_array, 1) LOOP
	    v_widget := v_fields_array[i];

	    -- Check if widgettype is tabwidget
	    IF v_widget->>'widgettype' = 'tabwidget' THEN
	        -- Get the tabs
	        v_tab_names := v_widget->'widgetcontrols'->'tabs';

	        -- Initialize form_tabs_json
	        v_form_tabs_json := '[]';

	        -- Loop through each tab name
	        FOR v_tab_name IN SELECT jsonb_array_elements_text(v_tab_names)
	        LOOP
	            -- Get tab information from config_form_tabs
	           v_querystring := concat(
			    'SELECT row_to_json(a) FROM (',
			    'SELECT DISTINCT ON (tabname, orderby) ',
			    'tabname as "tabName", label as "tabLabel", tooltip as "tooltip", ',
			    'NULL as "tabFunction", NULL AS "tabactions", orderby ',
			    'FROM config_form_tabs WHERE tabname = ''', v_tab_name, ''' ',
			    'AND formname = ''', v_formtype, ''' AND ', v_device,
			    ' = ANY(device) AND orderby IS NOT NULL ',
			    'ORDER BY orderby, tabname) a'
				);

				EXECUTE v_querystring INTO v_tab_data;

	            -- Get tab layouts
	            v_querystring := concat(
	                'SELECT value as layouts FROM config_param_system WHERE parameter = concat(',
	                '''', v_formtype, ''', ''_'', ''', v_tab_name, ''')'
	            );

	            EXECUTE v_querystring INTO v_form_tabs_layouts;

				-- Add layouts to v_tab_data
				IF v_form_tabs_layouts IS NOT NULL THEN
				    v_tab_data := jsonb_set(
				        v_tab_data,
				        '{layouts}',
				        to_jsonb(v_form_tabs_layouts->'layouts'),
				        true
				    );
				END IF;

	            -- Add v_tab_data to form_tabs_json
	            IF v_tab_data IS NOT NULL THEN
	                v_form_tabs_json := jsonb_set(
	                    v_form_tabs_json::jsonb,
	                    concat('{', jsonb_array_length(v_form_tabs_json::jsonb), '}')::text[],
	                    to_jsonb(v_tab_data),
	                    true
	                );
	            END IF;
	        END LOOP;

	        -- Update widget JSON with tabs in form_tabs_json
	        v_widget := jsonb_set(v_widget, '{tabs}', v_form_tabs_json::jsonb);

			-- Remove wdgetcontrols
			v_widget := v_widget - 'widgetcontrols';

	        -- Replace tabwidget json with updated values
	        v_fields_array[i] := v_widget;

	    END IF;

	END LOOP;

	v_fieldsjson := to_jsonb(v_fields_array);

	-- Manage null
	v_version := COALESCE(v_version, '');
 	v_fieldsjson := COALESCE(v_fieldsjson, '[]');

	-- Return JSON
	RETURN gw_fct_json_create_return(('{
        "status": "Accepted",
        "version": ' || to_json(v_version) || ',
        "body": {
			"form":{' || v_form || '
			},
            "data": {
                "fields": ' || v_fieldsjson || '
            }
        }
    }')::json, 3347, null, null, null)::json;


EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
        RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||
            ',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;
END;

$function$
;
