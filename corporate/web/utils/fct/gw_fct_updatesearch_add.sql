/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


CREATE OR REPLACE FUNCTION "SCHEMA_NAME"."gw_fct_updatesearch_add"(search_data json) RETURNS pg_catalog.json AS 
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_updatesearch_add($${"tabName":"address","add_muni":{"id":1,"name":"Sant Boi del Llobregat"},"add_street":{"text":"Avenida del General Prim"},"add_postnumber":{"text":"1"}}$$)
SELECT SCHEMA_NAME.gw_fct_updatesearch_add($${"tabName":"address","add_muni":{"id":8113,"name":"Manresa"},"add_street":{"text":"Carrer de Barcelona"},"add_postnumber":{"text":"3"}}$$)
*/

DECLARE

--    Variables
    response_json json;
    name_arg varchar;
    id_arg varchar;
    text_arg varchar;
    search_json json;
    tab_arg varchar;
    combo1 json;
    edit1 json;
    edit2 json;
    id_column varchar;
    catid varchar;
    states varchar[];
    api_version json;
    project_type_aux character varying;
    v_count integer;
    query_text text;
     
    -- Street
    v_street_layer varchar;
    v_street_id_field varchar;
    v_street_display_field varchar;
    v_street_muni_id_field varchar;
    v_street_geom_id_field varchar;

    -- address
    v_address_layer varchar;
    v_address_id_field varchar;
    v_address_display_field varchar;
    v_address_street_id_field varchar;
    v_address_geom_id_field varchar;
    v_querytext text;

    v_muni integer;

BEGIN

--    Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;

--      get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

--     get project type
    SELECT SCHEMA_NAMEoftware INTO project_type_aux FROM version LIMIT 1;

--    Get tab
    tab_arg := search_data->>'tabName';


-- address
---------
IF tab_arg = 'address' THEN

    -- Parameters of the street layer
    SELECT ((value::json)->>'sys_table_id') INTO v_street_layer FROM SCHEMA_NAME.config_param_system WHERE parameter='api_search_street';
    SELECT ((value::json)->>'sys_id_field') INTO v_street_id_field FROM SCHEMA_NAME.config_param_system WHERE parameter='api_search_street';
    SELECT ((value::json)->>'sys_search_field') INTO v_street_display_field FROM SCHEMA_NAME.config_param_system WHERE parameter='api_search_street';
    SELECT ((value::json)->>'sys_parent_field') INTO v_street_muni_id_field FROM SCHEMA_NAME.config_param_system WHERE parameter='api_search_street';
    SELECT ((value::json)->>'sys_geom_field') INTO v_street_geom_id_field FROM SCHEMA_NAME.config_param_system WHERE parameter='api_search_street';

    -- Parameters of the postnumber layer
    SELECT ((value::json)->>'sys_table_id') INTO v_address_layer FROM config_param_system WHERE parameter='api_search_postnumber';
    SELECT ((value::json)->>'sys_id_field') INTO v_address_id_field FROM config_param_system WHERE parameter='api_search_postnumber';
    SELECT ((value::json)->>'sys_search_field') INTO v_address_display_field FROM config_param_system WHERE parameter='api_search_postnumber';
    SELECT ((value::json)->>'sys_parent_field') INTO v_address_street_id_field FROM config_param_system WHERE parameter='api_search_postnumber';
    SELECT ((value::json)->>'sys_geom_field') INTO v_address_geom_id_field FROM config_param_system WHERE parameter='api_search_postnumber';

    --Text to search
    v_muni := (search_data->>'add_muni')::json->>'id';
    combo1 := search_data->>'add_street';
    id_arg := combo1->>'text';
    edit1 := search_data->>'add_postnumber';
    edit2 := edit1->>'text';
    text_arg := concat('%', edit2 ,'%');

    raise notice 'name_arg %', id_arg;
    raise notice 'text_arg %', text_arg;


    
    -- Get address 
	v_querytext = 'SELECT array_to_json(array_agg(row_to_json(a))) 
        FROM (SELECT a.'||quote_ident(v_address_display_field)||' as display_name, st_x (a.'||quote_ident(v_address_geom_id_field)||') as sys_x
        ,st_y (a.'||quote_ident(v_address_geom_id_field)||') as sys_y, (SELECT concat(''EPSG:'',epsg) FROM version LIMIT 1) AS srid
        FROM '||quote_ident(v_address_layer)||' a
        JOIN '||quote_ident(v_street_layer)||' b ON b.'||quote_ident(v_street_id_field)||' = a.'||quote_ident(v_address_street_id_field) ||'
        WHERE b.'||quote_ident(v_street_display_field)||' = $1 
        AND a.muni_id=$3
        AND a.'||quote_ident(v_address_display_field)||' ILIKE $2
        ORDER BY regexp_replace('||quote_ident(v_address_display_field)||',''[^0-9]+'','''',''g'')::integer 
        LIMIT 10 )a';

        RAISE NOTICE ' v_querytext %',  v_querytext;

       EXECUTE v_querytext
        USING id_arg, text_arg, v_muni
        INTO response_json;

END IF;

  --    Control NULL's
    response_json := COALESCE(response_json, '{}');

--    Return
    RETURN ('{"status":"Accepted"' ||
        ', "apiVersion":'|| api_version ||
        ', "data":' || response_json ||    
        '}')::json;

--    Exception handling
      --EXCEPTION WHEN OTHERS THEN 
       -- RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;
