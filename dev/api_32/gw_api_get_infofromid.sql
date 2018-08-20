-- Function: ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer)

-- DROP FUNCTION ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_get_infofromid(
    p_table_id character varying,
    p_id character varying,
    p_reduced_geometry geometry,
    p_editable boolean,
    p_device integer,
    p_info_type integer)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    form_info json;    
    form_tabs varchar[];
    form_tablabel varchar[];
    form_tabtext varchar[];
    form_tabs_json json;
    form_tablabel_json json;
    form_tabtext_json json;
    v_fields json;
    info_data json;
    field_wms json[2];
    feature_cat_arg text;
    formid_arg text;
    table_id_parent_arg text;
    tableparent_id_arg text;
    parent_child_relation boolean;
    link_id_aux text;
    v_idname text;
    link_path json;
    column_type text;
    schemas_array name[];
    api_version json;
    v_geometry json;
    v_geometry_reduced json;
    v_the_geom text;
    v_the_geom_reduced text;
    v_coherence boolean = false;
    v_table_return varchar = p_table_id;
    v_editable boolean;
    v_tg_op varchar;

    

BEGIN

--    Reset parameters
------------------------
    parent_child_relation = false;

--    Set search path to local schema
-------------------------------------
    SET search_path = "ws_sample", public;
    schemas_array := current_schemas(FALSE);

  
--      Get api version
------------------------
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

raise notice 'Get api version: %', api_version;


--      Get editability
------------------------
	 IF (SELECT id FROM audit_cat_table where sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) AND id=p_table_id LIMIT 1) IS NOT NULL THEN
		v_editable := TRUE;
	 ELSE
		v_editable := FALSE;
	 END IF;

	v_editable := TRUE;

	raise notice 'v_editable %', v_editable;

--    Get id column
---------------------
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

    -- Get id column type
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
        INTO column_type;


raise notice 'v_idname: %  column_type: %', v_idname, column_type;


--     Get geometry_column
------------------------------------------
        EXECUTE 'SELECT attname FROM pg_attribute a        
            JOIN pg_class t on a.attrelid = t.oid
            JOIN pg_namespace s on t.relnamespace = s.oid
            WHERE a.attnum > 0 
            AND NOT a.attisdropped
            AND t.relname = $1
            AND s.nspname = $2
            AND left (pg_catalog.format_type(a.atttypid, a.atttypmod), 8)=''geometry''
            ORDER BY a.attnum' 
            INTO v_the_geom
            USING p_table_id, schemas_array[1];


--      Get link (if exists) for the layer
------------------------------------------
    link_id_aux := (SELECT link_id FROM config_api_layer WHERE layer_id=p_table_id);

    IF  link_id_aux IS NOT NULL THEN 
        
        -- Get link field value
        EXECUTE 'SELECT row_to_json(row) FROM (SELECT '||link_id_aux||' FROM '||p_table_id||' WHERE '||v_idname||' = CAST('||quote_literal(p_id)||' AS '||column_type||'))row'
        INTO link_path;

    END IF;

raise notice 'Layer link path: % ', link_path;
            

--      Get form (if exists) for the layer 
------------------------------------------
        -- to build json
        EXECUTE 'SELECT row_to_json(row) FROM (SELECT formname AS "formName", formid AS "formId" 
            FROM config_api_layer WHERE layer_id = $1 LIMIT 1) row'
            INTO form_info
            USING p_table_id; 
            
raise notice 'Form number: %', form_info;

            
--     Get geometry (to feature response)
------------------------------------------
    IF v_the_geom IS NOT NULL THEN
        EXECUTE 'SELECT row_to_json(row) FROM (SELECT St_AsText('||v_the_geom||') FROM '||p_table_id||' WHERE '||v_idname||' = CAST('||quote_literal(p_id)||' AS '||column_type||'))row'
            INTO v_geometry;
    END IF;

raise notice 'Feature geometry: % ', v_geometry;


         
--        Get tabs for the layer
--------------------------------
        EXECUTE 'SELECT array_agg(formtab) FROM (SELECT formtab FROM config_api_tabs WHERE layer_id = $1 order by id desc) a'
            INTO form_tabs
            USING p_table_id;

raise notice 'form_tabs; %', form_tabs;

--        Get tab label for tabs form
--------------------------------
        EXECUTE 'SELECT array_agg(tablabel) FROM (SELECT tablabel FROM config_api_tabs WHERE layer_id = $1 order by id desc) a'
            INTO form_tablabel
            USING p_table_id;

raise notice 'form_tablabel; %', form_tablabel;

--        Get header text for tabs form
--------------------------------
        EXECUTE 'SELECT array_agg(tabtext) FROM (SELECT tabtext FROM config_api_tabs WHERE layer_id = $1 order by id desc) a'
            INTO form_tabtext
            USING p_table_id;

raise notice 'form_tabtext; %', form_tabtext;


--        Check if it is parent table 
-------------------------------------
        IF p_table_id IN (SELECT layer_id FROM config_api_layer WHERE is_parent IS TRUE) THEN

        -- parent-child relation exits    
        parent_child_relation:=true;

        -- check parent_view
        EXECUTE 'SELECT tableparent_id from config_api_layer WHERE layer_id=$1'
                INTO tableparent_id_arg
                USING p_table_id;
                
raise notice'Parent-Child. Table parent: %' , tableparent_id_arg;


        -- Identify tableinforole_id 
        EXECUTE' SELECT tableinforole_id FROM config_api_layer_child
        JOIN config_api_tableinfo_x_inforole ON config_api_layer_child.tableinfo_id=config_api_tableinfo_x_inforole.tableinfo_id 
        WHERE featurecat_id= (SELECT custom_type FROM '||tableparent_id_arg||' WHERE nid::text=$1) 
        AND inforole_id=$2'
            INTO p_table_id
            USING p_id, p_info_type;

raise notice'Parent-Child. Table: %' , p_table_id;

    -- Check if it is not p_editable layer (is_p_editable is false)
        ELSIF p_table_id IN (SELECT layer_id FROM config_api_layer WHERE is_editable IS FALSE) THEN

raise notice'No parent-child and no editable table: %' , p_table_id;


        -- Identify tableinforole_id 
        EXECUTE 'SELECT tableinforole_id FROM config_api_layer
        JOIN config_api_tableinfo_x_inforole ON config_api_layer.tableinfo_id=config_api_tableinfo_x_inforole.tableinfo_id 
        WHERE layer_id=$1 AND inforole_id=$2'
                INTO p_table_id
            USING p_table_id, p_info_type;

raise notice'No parent-child and inforole table: %' , p_table_id;

        END IF;

            
--    Check generic
-------------------
    IF form_info ISNULL THEN
        form_info := json_build_object('formName','F16','formId','GENERIC');
        formid_arg := 'F16';
    END IF;

--    Add default tab
---------------------
      form_tabs_json := array_to_json(array_append(form_tabs, 'tabInfo'));
      form_tablabel_json := array_to_json(array_append(form_tablabel, 'Data'));
      form_tabtext_json := array_to_json(array_append(form_tabtext, ''));


--    Join json
     form_info := gw_fct_json_object_set_key(form_info, 'formTabs', form_tabs_json);
     form_info := gw_fct_json_object_set_key(form_info, 'tabLabel', form_tablabel_json);
     form_info := gw_fct_json_object_set_key(form_info, 'tabText', form_tabtext_json);


    IF p_id IS NULL THEN
	v_tg_op = 'INSERT';
    ELSE 
	v_tg_op = 'UPDATE';
    END IF;

-- call function
-------------------
	IF v_editable THEN
	raise notice'edgarrrrrr:0000 %' , p_table_id;
		-- call editable form using table information
		EXECUTE 'SELECT gw_api_get_upsertfeature($1, $2, $3, $4, $5, $6)'
		INTO v_fields
		
		USING p_table_id, p_id, p_reduced_geometry, p_device, p_info_type, v_tg_op ;
		raise notice'v_fields:11111 %' , v_fields;
	ELSE
		-- call getinfoform using table information
		EXECUTE 'SELECT gw_api_get_infofeature($1, $2, $3, $4)'
		INTO v_fields
		USING p_table_id, p_id, p_device, p_info_type;
		raise notice'v_fields:11111 %' , v_fields;
	END IF;


	p_table_id:= (to_json(p_table_id));
	v_table_return:= (to_json(v_table_return));


--    Control NULL's
----------------------
    api_version := COALESCE(api_version, '{}');
    form_info := COALESCE(form_info, '{}');
    v_table_return := COALESCE(v_table_return, '{}');
    p_table_id := COALESCE(p_table_id, '{}');
    v_idname := COALESCE(v_idname, '{}');
    v_geometry := COALESCE(v_geometry, '{}');
    link_path := COALESCE(link_path, '{}');
    v_fields := COALESCE(v_fields, '{}');

    
--    Return
-----------------------
    RETURN ('{"status":"Accepted"' ||
        ', "apiVersion":'|| api_version ||
        ', "formTabs":' || form_info ||
	', "table_id":' || v_table_return ||
        ', "tableName":'|| p_table_id ||
        ', "idName": "' || v_idname ||'"'||
        ', "geometry":' || v_geometry ||
        ', "linkPath":' || link_path ||
        ', "editData":' || v_fields ||
        '}')::json;


--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","message":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromid(character varying, character varying, geometry, boolean, integer, integer) TO rol_dev;
