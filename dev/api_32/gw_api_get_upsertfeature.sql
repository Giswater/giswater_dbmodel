-- Function: ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying)

-- DROP FUNCTION ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_get_upsertfeature(
    p_table_id character varying,
    p_id character varying,
    p_reduced_geometry geometry,
    p_device integer,
    p_info_type integer,
    p_tg_op character varying)
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
    combo_rows_child json[];
    aux_json json;    
    aux_json_child json;    
    combo_json json;
    combo_json_parent json;
    combo_json_child json;
    project_type character varying;
    formToDisplayName character varying;
    table_pkey varchar := 'node_id';
    schemas_array name[];
    array_index integer DEFAULT 0;
    field_value character varying;
    field_value_parent text;
    formtodisplay text;
    api_version json;
    v_notice text;
    v_selected_id text;
    query_text text;
    v_vdefault text;
    v_the_geom text;
    v_sequence text;
    v_query_text text;
    v_id int8;
    v_sector integer;
    v_dma integer;
    v_muni integer;
    v_expl integer;
    p_the_geom public.geometry;
    v_code_autofill boolean;
    v_numnodes integer;
    v_node1 varchar;
    v_node2 varchar;
    v_idname text;
    rec record;
    state_topocontrol_bool boolean;
    v_feature_type text;
    count_aux integer;
    v_sector_id integer;
    v_expl_id integer;
    v_dma_id integer;
    v_muni_id integer;
    v_project_type varchar;
    v_cat_feature_id varchar;
    v_code int8;
    v_return json;
    v_node_proximity double precision;
    v_node_proximity_control boolean;
    v_arc_searchnodes double precision;
    v_samenode_init_end_control boolean;
    v_arc_searchnodes_control boolean;
    v_sql2 text;


BEGIN

-- get basic parameters
-----------------------

--   Set search path to local schema
     SET search_path = "ws_sample", public;

--   Get schema name
     schemas_array := current_schemas(FALSE);

--   get api version
     EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
	INTO api_version;

-- Get project type
    SELECT wsoftware INTO v_project_type FROM version LIMIT 1;

--  Get parameters
    --SELECT * INTO rec FROM config;
    SELECT value INTO v_node_proximity FROM config_param_system WHERE parameter = 'node_proximity';
    SELECT value INTO v_node_proximity_control FROM config_param_system WHERE parameter = 'node_proximity_control';
    SELECT value INTO v_arc_searchnodes FROM config_param_system WHERE parameter = 'arc_searchnodes';
    SELECT value INTO v_samenode_init_end_control FROM config_param_system WHERE parameter = 'samenode_init_end_control';
    SELECT value INTO v_arc_searchnodes_control FROM config_param_system WHERE parameter = 'arc_searchnodes_control';

    SELECT value::boolean INTO state_topocontrol_bool FROM config_param_system WHERE parameter='state_topocontrol';
      

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
        
        
        INTO column_type;


--   Get cat_feature_id
-------------------------
   IF v_project_type= 'WS' THEN
	SELECT custom_type INTO v_cat_feature_id FROM (SELECT v_edit_node.node_id AS nid, v_edit_node.nodetype_id AS custom_type FROM v_edit_node UNION
						SELECT v_edit_arc.arc_id AS nid,v_edit_arc.cat_arctype_id AS custom_type FROM v_edit_arc UNION
						SELECT v_edit_connec.connec_id AS nid, v_edit_connec.connectype_id AS custom_type FROM v_edit_connec)a WHERE nid=p_id;
   ELSE
	SELECT custom_type INTO v_cat_feature_id FROM (SELECT v_edit_node.node_id AS nid, v_edit_node.node_type AS custom_type FROM v_edit_node UNION
						SELECT v_edit_arc.arc_id AS nid,v_edit_arc.arc_type AS custom_type FROM v_edit_arc UNION
						SELECT v_edit_connec.connec_id AS nid, v_edit_connec.connec_type AS custom_type FROM v_edit_connec UNION
						SELECT v_edit_gully.gully_id AS nid, v_edit_gully.gully_type AS custom_type FROM v_edit_gully)a WHERE nid=p_id;
   END IF;


-- urn_id assingment
--------------------
   IF p_tg_op = 'INSERT' THEN
	v_id = (SELECT nextval('urn_id_seq'));
	v_code = v_id;
   END IF;



--  Starting control process
----------------------------

   IF p_tg_op = 'INSERT' OR p_tg_op = 'UPSERTGEOM' THEN

    -- topology control
    ---------------------
	IF (ST_GeometryType(p_reduced_geometry) = 'ST_Point') THEN

		v_feature_type='NODE';
		v_numnodes := (SELECT COUNT(*) FROM node WHERE ST_DWithin(p_reduced_geometry, node.the_geom, v_node_proximity) AND node.node_id != p_id AND node.state!=0);
		
		IF (v_numnodes >1) AND (v_node_proximity_control IS TRUE) THEN
			PERFORM audit_function(1096,1334);
		END IF;

	ELSIF (ST_GeometryType(p_reduced_geometry) = 'ST_Linestring') THEN
    
		v_feature_type='ARC';

		SELECT node_id INTO v_node1 FROM v_edit_node WHERE ST_DWithin(ST_startpoint(p_reduced_geometry), node.the_geom, v_arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_startpoint(p_reduced_geometry)) LIMIT 1;

		SELECT node_id INTO v_node2 FROM v_edit_node WHERE ST_DWithin(ST_endpoint(p_reduced_geometry), node.the_geom, v_arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_endpoint(p_reduced_geometry)) LIMIT 1;

		IF (v_node1 IS NOT NULL) AND (v_node2 IS NOT NULL) THEN
    
			-- Control of same node initial and final
			IF (v_node1.node_id = v_node2) AND (v_samenode_init_end_control IS TRUE) THEN
				RETURN audit_function (1040, 1344, v_node1);
			END IF;
			
		--Error, no existing nodes
		ELSIF ((v_node1 IS NULL) OR (v_node2 IS NULL)) AND (v_arc_searchnodes_control IS TRUE) THEN
			PERFORM audit_function (1042,1344,NEW.arc_id);
		END IF;

	ELSE
		PERFORM audit_function (1042,1344,NEW.arc_id);
	END IF;

    -- map zones controls
    -----------------------

     -- Sector ID
	SELECT count(*)into count_aux FROM sector WHERE ST_DWithin(p_the_geom, sector.the_geom,0.001);
	IF count_aux = 1 THEN
		v_sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(p_reduced_geometry, sector.the_geom,0.001) LIMIT 1);
	ELSIF count_aux > 1 THEN
		v_sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(p_reduced_geometry, v_edit_node.the_geom, promixity_buffer_aux) 
		order by ST_Distance (p_the_geom, v_edit_node.the_geom) LIMIT 1);
	END IF;	
      
	-- Dma ID
	SELECT count(*)into count_aux FROM dma WHERE ST_DWithin(p_reduced_geometry, dma.the_geom,0.001);
	IF count_aux = 1 THEN
		v_dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(p_reduced_geometry, dma.the_geom,0.001) LIMIT 1);
	ELSIF count_aux > 1 THEN
		v_dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(p_reduced_geometry, v_edit_node.the_geom, promixity_buffer_aux) 
		order by ST_Distance (p_the_geom, v_edit_node.the_geom) LIMIT 1);
	END IF;
			
	-- Exploitation
	v_expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(p_reduced_geometry, exploitation.the_geom,0.001) LIMIT 1);

	-- Municipality 
	v_muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(p_reduced_geometry, ext_municipality.the_geom,0.001) LIMIT 1); 

   END IF;


   IF p_tg_op = 'UPSERTGEOM' THEN
	IF v_feature_type='ARC' THEN
		RETURN ('{"expl_id":"' || v_expl_id ||'";"dma_id":"' || v_dma_id ||'";"sector_id":"' || v_sector_id ||'";"muni_id":"' || v_muni_id ||'"node_1":"' || v_node1 ||'";"node_2":"' || v_node2 ||'}')::json;
	ELSIF v_feature_type='NODE' THEN
		RETURN ('{"expl_id":"' || v_expl_id ||'";"dma_id":"' || v_dma_id ||'";"sector_id":"' || v_sector_id ||'";"muni_id":"' || v_muni_id ||'}')::json;
	END IF;
   END IF;


-- Get fields
   EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT form_label, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype ,
	placeholder, iseditable, isclickable, orderby, layout_id, layout_order, dv_parent_id, dv_isparent, mz_parent_layer, python_func_name
	FROM config_api_layer_field WHERE table_id   = $1  ORDER BY orderby) a'
	INTO fields_array
	USING p_table_id;
RAISE NOTICE '1 -> %', 1;

-- combo rows & child rows

	--  Get combo not child rows
	EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype,
			dv_querytext, dv_isparent, dv_parent_id, orderby, feature_type
			FROM config_api_layer_field WHERE table_id = $1 AND dv_parent_id IS NULL ORDER BY orderby) a WHERE widgettype = 2'
			INTO combo_rows
			USING p_table_id, p_device;
			combo_rows := COALESCE(combo_rows, '{}');

	FOREACH aux_json IN ARRAY combo_rows
	LOOP
		
		-- Get combo id's
		EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json->>'dv_querytext')||' ORDER BY idval)a'
			INTO combo_json;
		fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboIds', COALESCE(combo_json, '[]'));

		-- Get combo values
		EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json->>'dv_querytext')||' ORDER BY idval)a'
			INTO combo_json; 
		fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'comboNames', COALESCE(combo_json, '[]'));


		-- Get selected value for the combo
		IF p_tg_op ='UPDATE' THEN
				v_sql2 := 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(v_idname) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')' ;
            RAISE NOTICE 'v_sql2 ??? %', v_sql2;
            RAISE NOTICE 'v_idname ??? %', v_idname;
			-- Get feature values
			EXECUTE 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(v_idname) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')' 
				INTO field_value_parent; 
				
		ELSE 
			-- Get vdefault values
			v_vdefault:=quote_ident(aux_json->>'column_id');
						
			EXECUTE 'SELECT value::text FROM audit_cat_param_user JOIN config_param_user ON audit_cat_param_user.id=parameter WHERE cur_user=current_user AND feature_field_id='||quote_literal(v_vdefault)
				INTO field_value_parent;

		END IF;
		
		field_value_parent := COALESCE(field_value_parent, '');

		-- INSERT COMBO
                IF field_value_parent IS NULL THEN
			fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'selectedId', combo_json->0);
		-- UPDATE COMBO
		ELSE
			fields_array[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json->>'orderby')::INT], 'selectedId', field_value_parent);
		END IF;


		-- Get childs (combo and not combo). Example of non-combo childs: stardate & endadate. Startdate it's a child of state (1) as well as enddate it's child of state (0)
		IF (aux_json->>'dv_isparent') IS NOT NULL THEN

			--  Child rows (combo and not combo)
			EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, sys_api_cat_widgettype_id AS widgettype, sys_api_cat_datatype_id AS datatype,
				dv_querytext, dv_isparent, dv_parent_id, orderby , dv_querytext_filterc
				FROM config_api_layer_field WHERE table_id = $1 AND dv_parent_id='||quote_literal(aux_json->>'column_id')||' ORDER BY orderby) a'
				INTO combo_rows_child
				USING p_table_id, p_device;
				combo_rows_child := COALESCE(combo_rows_child, '{}');
			
			FOREACH aux_json_child IN ARRAY combo_rows_child
			LOOP

				SELECT (json_array_elements(array_to_json(fields_array[(aux_json->> 'orderby')::INT:(aux_json->> 'orderby')::INT])))->>'selectedId' INTO v_selected_id;

				-- Manage combos
				IF (aux_json_child->>'widgettype')::integer = 2 THEN		
				
					-- Get combo id's
					IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND v_selected_id IS NOT NULL THEN		
						query_text= 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(v_selected_id)||' ORDER BY idval) a';
						execute query_text INTO combo_json_child;
					ELSE 	
						EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a' INTO combo_json_child;
					END IF;
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboIds', COALESCE(combo_json_child, '[]'));

					
					-- Get combo values
					IF (aux_json_child->>'dv_querytext_filterc') IS NOT NULL THEN
						query_text= 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||(aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(v_selected_id)||' ORDER BY idval) a';
						execute query_text INTO combo_json_child;
					ELSE 	
						EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(aux_json_child->>'dv_querytext')||' ORDER BY idval)a'
							INTO combo_json_child;
					END IF;
	
					combo_json_child := COALESCE(combo_json_child, '[]');
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'comboNames', combo_json_child);

				END IF;

				-- Get selected value (for combos and not combos)
				IF p_tg_op='UPDATE' THEN

					-- Get feature values
					EXECUTE 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(v_idname) || ' = CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')' 
						INTO field_value; 
				ELSE 
					
					-- Get EPA TYPE default values
					IF (aux_json_child->>'column_id')='epa_type' THEN
						EXECUTE 'SELECT epa_default FROM '||(aux_json->>'feature_type')||'_type WHERE id ='||quote_literal(field_value_parent)
							INTO field_value;
					END IF;
					
					-- Get rest of vdefault values
					EXECUTE 'SELECT feature_dv_parent_value FROM audit_cat_param_user WHERE feature_field_id='||quote_literal(aux_json_child->>'column_id')
						INTO v_query_text;
						
					IF v_query_text IS NOT NULL THEN 
						EXECUTE 'SELECT value::text FROM audit_cat_param_user JOIN config_param_user ON audit_cat_param_user.id=parameter WHERE cur_user=current_user 
							AND feature_field_id='||quote_literal(aux_json_child->>'column_id')||' AND feature_dv_parent_value = '||quote_literal(field_value_parent)
							INTO field_value;
					ELSE 
						
						EXECUTE 'SELECT value::text FROM audit_cat_param_user JOIN config_param_user ON audit_cat_param_user.id=parameter WHERE cur_user=current_user 
							AND feature_field_id='||quote_literal(aux_json->>'column_id')
							INTO field_value;
					END IF;
				END IF;

				--INSERT combo
				IF field_value IS NULL AND (aux_json_child->>'widgettype')::integer = 2 THEN	
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'selectedId', combo_json_child->0);      
				-- INSERT child
				ELSIF field_value IS NULL AND (aux_json_child->>'widgettype')::integer != 2 THEN
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'value', COALESCE(field_value, ''));
				-- UPDATE combo
				ELSIF  field_value IS NOT NULL AND (aux_json_child->>'widgettype')::integer = 2 THEN
					field_value := COALESCE(field_value, '');
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'selectedId', field_value);      
				-- UPDATE child
				ELSIF field_value IS NOT NULL AND (aux_json_child->>'widgettype')::integer != 2 THEN
					field_value := COALESCE(field_value, '');
					fields_array[(aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(fields_array[(aux_json_child->>'orderby')::INT], 'value', field_value);      
				END IF;
			END LOOP;
		END IF;		
	END LOOP;

-- Fill values
	FOREACH aux_json IN ARRAY fields_array 
        LOOP          
        	--  Index
		array_index := array_index + 1;
		field_value :=null;

		-- feature values on INSERT for non (combo/child)
		IF p_tg_op='INSERT' AND (aux_json->>'widgettype') != '2' AND (aux_json->>'dv_parent_id') IS NULL THEN

			-- values for primary key and code
			IF (aux_json->>'column_id') = quote_literal(p_key) THEN
				field_value = v_id;
			ELSIF (aux_json->>'column_id') = 'code' AND v_code_autofill IS TRUE THEN
				field_value = v_id;
			END IF;
		
			v_vdefault:=quote_ident(aux_json->>'column_id');
			EXECUTE 'SELECT value::text FROM audit_cat_param_user JOIN config_param_user ON audit_cat_param_user.id=parameter WHERE cur_user=current_user AND feature_field_id='||quote_literal(v_vdefault)
				INTO field_value;
			
		-- feature values on UPDATE for non (combo/child)
		ELSIF p_tg_op='UPDATE' AND (aux_json->>'widgettype') != '2' AND (aux_json->>'dv_parent_id') IS NULL THEN	
			-- Get existing values
			v_sql2 := 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(v_idname) || ' = 
				CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')'   ;
            RAISE NOTICE '/////////////////////------ ??? %', v_sql2;
			EXECUTE 'SELECT ' || quote_ident(aux_json->>'column_id') || ' FROM ' || quote_ident(p_table_id) || ' WHERE ' || quote_ident(v_idname) || ' = 
				CAST(' || quote_literal(p_id) || ' AS ' || column_type || ')' 
				INTO field_value; 
		END IF;

		-- NOTE: feature values for (combos/childs) on INSERT and UPDATE have been update before

		-- Update json values with not null field values
		IF field_value IS NOT NULL THEN
			field_value := COALESCE(field_value, '');
			fields_array[array_index] := gw_fct_json_object_set_key(fields_array[array_index], 'value', field_value);
		END IF;
		
		-- re-update the mapzones values (for insert or update) using the real geometry position
		IF (aux_json->>'column_id')='sector_id' THEN

		ELSIF (aux_json->>'column_id')='dma_id' THEN

		ELSIF (aux_json->>'column_id')='expl_id' THEN

		ELSIF (aux_json->>'column_id')='muni_id' THEN

		END IF;

		/*IF field_value IS NOT NULL THEN
			field_value := COALESCE(field_value, '');
			fields_array[array_index] := gw_fct_json_object_set_key(fields_array[array_index], 'selectedId', field_value);
		END IF;*/

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
ALTER FUNCTION ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_upsertfeature(character varying, character varying, geometry, integer, integer, character varying) TO rol_dev;
