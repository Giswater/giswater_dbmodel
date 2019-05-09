CREATE OR REPLACE FUNCTION "SCHEMA_NAME"."gw_fct_updateprint"(p_data json, p_x1 float8, p_y1 float8, p_x2 float8, p_y2 float8, p_istilemap bool, p_device int4) RETURNS pg_catalog.json AS 
$BODY$
/*
SELECT SCHEMA_NAME.gw_fct_updateprint($${"composer":"mincutA3","scale":"10000","ComposerTemplates":
[{"ComposerTemplate":"mincutA4","ComposerMap":[{"width":"179.414","height":"140.826","name":"map0"},
{"width":"77.729","height":"55.9066","name":"map7"}]},{"ComposerTemplate":"mincutA3","ComposerMap":
[{"width":"53.44","height":"55.9066","name":"map7"},{"width":"337.865","height":"275.914","name":"map6"}]}],
"extent":"418284.06010078074,4576197.139572782,419429.332014571,4576756.056126544"}$$,418284.06010078074,4576197.139572782,419429.332014571,4576756.056126544,False,3)

SELECT SCHEMA_NAME.gw_fct_updateprint($${"composer":"mincutA3","scale":"10000","ComposerTemplates":
[{"ComposerTemplate":"mincutA4","ComposerMap":[{"width":"179.414","height":"140.826","name":"map0"},
{"width":"77.729","height":"55.9066","name":"map7"}]},{"ComposerTemplate":"mincutA3","ComposerMap":
[{"width":"53.44","height":"55.9066","name":"map7"},{"width":"337.865","height":"275.914","name":"map6"}]}],
"extent":"418284.06010078074,4576197.139572782,419429.332014571,4576756.056126544"}$$,418284.06010078074,4576197.139572782,419429.332014571,4576756.056126544,True,3)
*/
DECLARE

--    Variables
        p21x float; 
    p02x float;
    p21y float; 
    p02y float;
    p22x float;
    p22y float;
    p01x float;
    p01y float;
    dx float;
    dy float;
    api_version text;
        v_text text[];
        json_field json;
        text text;
    v_field text;
    v_value text;
        i integer=1;
        sql_query text;
        v_publish_user text;
        v_composer text;
    v_width float;
    v_height float;
    v_scale integer;
    v_x float;
    v_y float;
    v_json1 json;
    v_json2 json;
    v_json3 json;
    v_extent json;
    v_geometry text;
    v_array_width float[];
    v_mapcomposer_name text;
    v_tiled_layers json;

BEGIN

    --    Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;


    --  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

    -- get publish user 
    SELECT value FROM config_param_system WHERE parameter='api_publish_user' 
    INTO v_publish_user;

    -- get layers of tilemap
    IF p_istilemap IS TRUE THEN
    
	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(row))) FROM (SELECT layer_id FROM config_web_layer WHERE is_tiled=TRUE ORDER BY (is_tiled_add->>''printOrderBy'')::integer ) row'
		INTO v_tiled_layers ;
	RAISE NOTICE 'v_tiled_layers %', v_tiled_layers;
	END IF;  

    -- Get composer
    v_composer := p_data->>'composer';

    -- Get scale
    v_scale := p_data->>'scale';

    raise notice ' % %', v_composer, v_scale;

    -- Get composer info
    v_json1 := p_data->'ComposerTemplates';
    SELECT * INTO v_json2 FROM json_array_elements(v_json1) AS a WHERE a->>'ComposerTemplate' = v_composer;
       raise notice 'v_json2 %', v_json2;

    -- Get maps from composer
    v_json3 := v_json2->'ComposerMap';
    raise notice 'v_json3 %', v_json3;

    -- select map with maximum width
    SELECT array_agg(a->>'width') INTO v_array_width FROM json_array_elements(v_json3) AS a;
    SELECT max (a) INTO v_width FROM unnest(v_array_width) AS a;
    SELECT a->>'name' INTO v_mapcomposer_name FROM json_array_elements(v_json3) AS a WHERE (a->>'width')::float = v_width::float;
    SELECT a->>'height' INTO v_height FROM json_array_elements(v_json3) AS a WHERE a->>'name' = v_mapcomposer_name;  

    -- loop for fields
    select array_agg(row_to_json(a)) into v_text from json_each(p_data)a;
    FOREACH text IN ARRAY v_text
    LOOP
	-- Get field and value from json
	SELECT v_text [i] into json_field;
	v_field:= (SELECT (json_field ->> 'key')) ;
	v_value:= (SELECT (json_field ->> 'value'));
 
	i=i+1;
  
	IF v_field!='ComposerTemplates' THEN

		-- Upsert values
		EXECUTE 'DELETE FROM selector_composer WHERE field_id = $1 AND user_name = '||quote_literal(current_user)
			USING v_field;
 
		EXECUTE'DELETE FROM selector_composer WHERE field_id = $1 AND user_name = '||quote_literal(v_publish_user)
			USING v_field;
 
		EXECUTE 'INSERT INTO selector_composer (field_id, field_value, user_name) VALUES ($1,$2,'||quote_literal(current_user)||')'
			USING v_field, quote_nullable(v_value);
         
		EXECUTE 'INSERT INTO selector_composer (field_id, field_value, user_name) VALUES ($1,$2,'||quote_literal(v_publish_user)||')'
			USING v_field, quote_nullable(v_value);
	END IF;
    END LOOP;

--calulate the extend

    -- calculate center coordinates
    v_x = (p_x1+p_x2)/2;
    v_y = (p_y1+p_y2)/2;
    
    -- calculate dx & dy to fix extend from center
    dx = v_scale*v_width/(1000*2);
    dy = v_scale*v_height/(1000*2);

    -- calculate the extend    
    p21x = v_x - dx;
    p21y = v_y - dy;

    p22x = p21x + 2*dx;
    p22y = p21y;

    p02x = v_x + dx;
    p02y = v_y + dy;

    p01x = p02x - 2*dx;
    p01y = p02y;

    v_geometry = '{"st_astext":"POLYGON(('  || p21x ||' '|| p21y || ',' || p22x ||' '|| p22y || ',' || p02x || ' ' || p02y || ','|| p01x ||' '|| p01y || ',' || p21x ||' '|| p21y || '))"}';
    v_extent = '"[' || p21x || ',' || p21y || ',' || p02x || ',' || p02y || ']"';
   
--    Control NULL's
    api_version := COALESCE(api_version, '{}');
    v_tiled_layers := COALESCE(v_tiled_layers, '{}');
    v_geometry := COALESCE(v_geometry, '{}');
    v_mapcomposer_name := COALESCE(v_mapcomposer_name, '{}');
    v_extent := COALESCE(v_extent, '{}');

  --Return
    RETURN ('{"status":"Accepted",'||
     '"apiVersion":'|| api_version ||
     ',"tiledLayers":'|| v_tiled_layers ||
     ',"data":{'||
         '"geometry":'|| v_geometry ||
        ',"map":"' || v_mapcomposer_name || '"'
        ',"extent":'||v_extent ||'}}')::json;

--    Exception handling
    EXCEPTION WHEN OTHERS THEN 
        RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;    
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

