-- Function: ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer)

-- DROP FUNCTION ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_get_infofromcoordinates(
    p_x double precision,
    p_y double precision,
    p_epsg integer,
    p_active_layer text,
    p_visible_layer text,
    p_editable_layer text,
    p_zoom_ratio double precision,
    p_device integer,
    p_info_type integer)
  RETURNS json AS
$BODY$
DECLARE

--    Variables
    v_point geometry;
    v_sensibility float;
    v_sensibility_f float;
    v_id varchar;
    v_layer text;
    v_alias text;
    v_sql text;
    v_sql2 text;
    v_iseditable boolean;
    v_return json;
    v_idname text;
    schemas_array text[];
    v_count int2=0;
    v_geometrytype text;
    api_version text;
    v_the_geom text;
    v_config_layer text;
BEGIN


--  Set search path to local schema
    SET search_path = "ws_sample", public;
    schemas_array := current_schemas(FALSE);

--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

-- Sensibility factor
    IF p_device=1 OR p_device=2 THEN
        EXECUTE 'SELECT value::float FROM config_param_system WHERE parameter=''api_sensibility_factor_web'''
            INTO v_sensibility_f;
                -- 10 pixels of base sensibility
		v_sensibility = (p_zoom_ratio * 10 * v_sensibility_f);
		v_config_layer='config_web_layer';
		
    ELSIF  p_device=3 THEN
        EXECUTE 'SELECT value::float FROM config_param_system WHERE parameter=''api_sensibility_factor_mobile'''
            INTO v_sensibility_f;     
                -- 10 pixels of base sensibility
		v_sensibility = (p_zoom_ratio * 10 * v_sensibility_f);
		v_config_layer='config_web_layer';

    ELSIF  p_device=9 THEN
	EXECUTE 'SELECT value::float FROM config_param_system WHERE parameter=''api_sensibility_factor_web'''
		INTO v_sensibility_f;
		-- ESCALE 1:5000 as base sensibility
		v_sensibility = ((p_zoom_ratio/5000) * 10 * v_sensibility_f);
		v_config_layer='config_api_layer';
		RAISE NOTICE 'v_sensibility 11111 %', v_sensibility;


	END IF;

--   Make point
     SELECT ST_SetSRID(ST_MakePoint(p_x,p_y),p_epsg) INTO v_point;
     RAISE NOTICE 'v_point 22222 %', v_point;

--  Get element
     v_sql := 'SELECT layer_id, 0 as orderby FROM  '||v_config_layer||' WHERE layer_id= '||quote_literal(p_active_layer)||' UNION 
          SELECT layer_id, orderby FROM  '||v_config_layer||' WHERE layer_id = any('''||p_visible_layer||'''::text[]) ORDER BY orderby';
    RAISE NOTICE 'v_sql %', v_sql;
    FOR v_layer IN EXECUTE v_sql 
    LOOP
    RAISE NOTICE 'v_layer 3333 %', v_layer;
        v_count=v_count+1;
            --    Get id column
        EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
            INTO v_idname
            USING v_layer;
        RAISE NOTICE 'v_idname 4444 %', v_idname;
        --    For views it suposse pk is the first column
        IF v_idname IS NULL THEN
            EXECUTE '
            SELECT a.attname FROM pg_attribute a   JOIN pg_class t on a.attrelid = t.oid  JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0   AND NOT a.attisdropped
            AND t.relname = $1 
            AND s.nspname = $2
            ORDER BY a.attnum LIMIT 1'
                INTO v_idname
                USING v_layer, schemas_array[1];

                RAISE NOTICE 'v_idname 5555 %', v_idname;
        END IF;

        --     Get geometry_column
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
            USING v_layer, schemas_array[1];
            RAISE NOTICE 'v_the_geom 6666 %', v_the_geom;
	

        --  Indentify geometry type
        EXECUTE 'SELECT st_geometrytype ('||v_the_geom||') FROM '||v_layer||';' 
        INTO v_geometrytype;
        RAISE NOTICE 'v_geometrytype 7777 %', v_geometrytype;

        IF v_geometrytype = 'ST_Polygon'::text OR v_geometrytype= 'ST_Multipolygon'::text THEN

            --  Get element from active layer, using the area of the elements to order possible multiselection (minor as first)
            v_sql2 := 'SELECT '||v_idname||' FROM '||v_layer||' WHERE st_dwithin ($1, '||v_layer||'.'||v_the_geom||', $2) 
            ORDER BY  ST_area('||v_layer||'.'||v_the_geom||') asc LIMIT 1';
            RAISE NOTICE 'v_sql2 ??? %', v_sql2;
            EXECUTE 'SELECT '||v_idname||' FROM '||v_layer||' WHERE st_dwithin ($1, '||v_layer||'.'||v_the_geom||', $2) 
            ORDER BY  ST_area('||v_layer||'.'||v_the_geom||') asc LIMIT 1'
                INTO v_id
                USING v_point, v_sensibility;
                
                
        ELSE
            v_sql2 := 'SELECT '||v_idname||' FROM '||v_layer||' WHERE st_dwithin ($1, '||v_layer||'.'||v_the_geom||', $2) 
            ORDER BY  ST_Distance('||v_layer||'.'||v_the_geom||', $1) asc LIMIT 1';
            RAISE NOTICE 'v_sql2 ??? %', v_sql2;
            --  Get element from active layer, using the distance from the clicked point to order possible multiselection (minor as first)
            EXECUTE 'SELECT '||v_idname||' FROM '||v_layer||' WHERE st_dwithin ($1, '||v_layer||'.'||v_the_geom||', $2) 
            ORDER BY  ST_Distance('||v_layer||'.'||v_the_geom||', $1) asc LIMIT 1'
                INTO v_id
                USING v_point, v_sensibility;
                
	RAISE NOTICE 'v_id 8888 %', v_id;
	
        END IF;

        IF v_id IS NOT NULL THEN 
            exit;
        ELSE 
            RAISE NOTICE 'Searching for layer....loop number: % layer: % ,idname: %, id: %', v_count, v_layer, v_idname, v_id;    
        END IF;

    END LOOP;

    RAISE NOTICE 'Founded (loop number: %):  Layer: % ,idname: %, id: %', v_count, v_layer, v_idname, v_id;
    
--    Control NULL's
    IF v_id IS NULL THEN
    RAISE NOTICE '1 %', 1;
     RETURN ('{"status":"Accepted", "apiVersion":'|| api_version ||', "formTabs":[] , "tableName":"", "idName": "", "geometry":"", "linkPath":"", "editData":[] }')::json;


    END IF;
RAISE NOTICE 'he llegado al final %', 1;
--   Get editability of layer
    EXECUTE 'SELECT (CASE WHEN is_editable=TRUE AND layer_id = any('''||p_visible_layer||'''::text[]) THEN TRUE ELSE FALSE END) 
            FROM  '||v_config_layer||' WHERE layer_id='||quote_literal(v_layer)||';'
        INTO v_iseditable;

    
--   Call gw_api_get_infofromid
    SELECT gw_api_get_infofromid(v_layer, v_id, null, v_iseditable, p_device, p_info_type) INTO v_return;

--    Return
      RETURN v_return;

--    Exception handling
 --     RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_get_infofromcoordinates(double precision, double precision, integer, text, text, text, double precision, integer, integer) TO rol_dev;
