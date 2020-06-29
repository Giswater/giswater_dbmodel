/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2592

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_getlist(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE:

TOC
----------
-- attribute table using custom filters
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_edit_man_pipe", "idName":"arc_id"},
"data":{"filterFields":{"arccat_id":"PVC160-PN10", "limit":5},"filterFeatureField":{"arc_id":"2001},
        "pageInfo":{"orderBy":"arc_id", "orderType":"DESC", "currentPage":3}}}$$)

-- attribute table using canvas filter
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"ve_arc_pipe", "idName":"arc_id"},"filterFeatureField":{"arc_id":"2001},
"data":{"canvasExtend":{"canvascheck":true, "x1coord":12131313,"y1coord":12131313,"x2coord":12131313,"y2coord":12131313},
        "pageInfo":{"orderBy":"arc_id", "orderType":"DESC", "currentPage":1}}}$$)

VISIT
----------
-- Visit -> visites
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"om_visit_x_arc" ,"idName":"id"},
"data":{"filterFields":{"arc_id":2001, "limit":10},"filterFeatureField":{"arc_id":"2001},
    "pageInfo":{"orderBy":"visit_id", "orderType":"DESC", "offsset":"10", "currentPage":null}}}$$)


-- Visit -> events
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_ui_om_event" ,"idName":"id"},
"data":{"filterFields":{"visit_id":232, "limit":10},"filterFeatureField":{"arc_id":"2001},
    "pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3}}}$$)

-- Visit -> files
-- first call
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"om_visit_file"},
"data":{"filterFields":{},
	"pageInfo":{}}}$$)
	
-- not first call
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"om_visit_file"},
"data":{"filterFields":{"filetype":"jpg","limit":15, "visit_id":1135},"filterFeatureField":{"arc_id":"2001},
	"pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3}}}$$)

SELECT SCHEMA_NAME.gw_api_getlist($$
{"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"featureType":"visit","tableName":"ve_visit_arc_insp","idname":"visit_id","id":10002},
"form":{"tabData":{"active":false}, "tabFiles":{"active":true}},
"data":{"relatedFeature":{"type":"arc"},
	"pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3},
	"filterFields":{"filetype":"doc","limit":10,"visit_id":"10002"}}}$$)


FEATURE FORMS
-------------
-- Arc -> elements
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_ui_element_x_arc", "idName":"id"},
"data":{"filterFields":{"arc_id":"2001"},
    "pageInfo":{"orderBy":"element_id", "orderType":"DESC", "currentPage":3}}}$$)


MANAGER FORMS
-------------
-- Lots
SELECT SCHEMA_NAME.gw_api_getlist($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"om_visit_lot"},
"data":{"filterFields":{"limit":10},
	"pageInfo":{"currentPage":null}}}$$)
*/


DECLARE
	v_apiversion text;
	v_filter_fields  json[];
	v_filter_fields_  json[];
	v_footer_fields json[];
	v_filter_feature json;
	v_fields_json json;
	v_fields_json_ json;
	v_filter_values  json;
	v_schemaname text;
	aux_json json;
	v_result_list json;
	v_query_result text;
	v_id  varchar;
	v_device integer;
	v_infotype integer;
	v_idname varchar;
	v_column_type varchar;
	v_field varchar;
	v_value text;
	v_orderby varchar;
	v_ordertype varchar;
	v_limit integer;
	v_filterlot integer;
	v_filterteam integer;
	v_offset integer;
	v_currentpage integer;
	v_lastpage integer;
	v_text text[];
	v_json_field json;
	text text;
	i integer=1;
	v_tabname text;
	v_tablename text;
	v_formactions json;
	v_x1 float;
	v_y1 float;
	v_x2 float;
	v_y2 float;
	v_canvas public.geometry;
	v_the_geom text;
	v_canvasextend json;
	v_canvascheck boolean;
	v_srid integer;
	v_i integer;
	v_buttonname text;
	v_featuretype text;
	v_pageinfo json;
	v_vdefault text;
	v_listclass text;
	v_sign text;
	v_data json;
	v_default json;
	v_startdate text;
	v_columntype text;
	v_isattribute boolean;
	v_attribute_filter text;

BEGIN

-- Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;
    v_schemaname := 'SCHEMA_NAME';
  
--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO v_apiversion;

	-- fix diferent ways to say null on client
	p_data = REPLACE (p_data::text, '"NULL"', 'null');
	p_data = REPLACE (p_data::text, '"null"', 'null');
	p_data = REPLACE (p_data::text, '""', 'null');
	p_data = REPLACE (p_data::text, '''''', 'null');


    SELECT epsg INTO v_srid FROM version LIMIT 1;

-- Get input parameters:
	v_device := (p_data ->> 'client')::json->> 'device';
	v_infotype := (p_data ->> 'client')::json->> 'infoType';
	v_tabname := (p_data ->> 'form')::json->> 'tabName';
	v_buttonname := (p_data ->> 'form')::json->> 'buttonName';
	v_tablename := (p_data ->> 'feature')::json->> 'tableName';
	v_featuretype:= (p_data ->> 'feature')::json->> 'featureType';
	v_canvasextend := (p_data ->> 'data')::json->> 'canvasExtend';
	v_canvascheck := ((p_data ->> 'data')::json->> 'canvasExtend')::json->>'canvasCheck';
	v_orderby := ((p_data ->> 'data')::json->> 'pageInfo')::json->>'orderBy';
	v_filter_values := (p_data ->> 'data')::json->> 'filterFields';
	v_ordertype := ((p_data ->> 'data')::json->> 'pageInfo')::json->>'orderType';
	v_currentpage := ((p_data ->> 'data')::json->> 'pageInfo')::json->>'currentPage';
	v_filter_feature := (p_data ->> 'data')::json->> 'filterFeatureField';
	v_startdate = ((p_data ->>'data')::json->>'fields')::json->>'startdate'::text;
	v_limit = ((p_data ->>'data')::json->>'fields')::json->>'limit'::text;
	v_filterlot = ((p_data ->>'data')::json->>'fields')::json->>'lot_id'::text;
	v_filterteam = ((p_data ->>'data')::json->>'fields')::json->>'team_id'::text;
	v_isattribute := (p_data ->> 'data')::json->> 'isAttribute';

	
	IF v_tabname IS NULL THEN
		v_tabname = 'data';
	END IF;

	-- control nulls
	IF v_tablename IS NULL THEN
		RAISE EXCEPTION 'The config table is bad configured. v_tablename is null';
	END IF;

	RAISE NOTICE 'gw_api_getlist - Init Values: v_tablename %  v_filter_values  % v_filter_feature %', v_tablename, v_filter_values, v_filter_feature;


-- setting value default for filter fields
-------------------------------------
	IF v_filter_values::text IS NULL OR v_filter_values::text = '{}' THEN 
	
		v_data = '{"client":{"device":9, "infoType":100, "lang":"ES"},"data":{"formName": "'||v_tablename||'"}}';
		
		SELECT gw_api_get_filtervaluesvdef(v_data) INTO v_filter_values;

		RAISE NOTICE 'gw_api_getlist - Init Values setted by default %', v_filter_values;

	END IF;

--  Create filter if is attribute table list
----------------------------
	IF v_isattribute THEN
		v_attribute_filter = ' AND listtype = ''attributeTable''';
	ELSE
		v_attribute_filter = '';
	END IF;
	
--  Creating the list fields
----------------------------
	-- control not existing table
	IF v_tablename IN (SELECT table_name FROM information_schema.tables WHERE table_schema = v_schemaname) THEN

		-- Get idname column
		EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
			INTO v_idname
			USING v_tablename;
        
		-- For views it suposse pk is the first column
		IF v_idname ISNULL THEN
			EXECUTE 'SELECT a.attname FROM pg_attribute a   JOIN pg_class t on a.attrelid = t.oid  JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0   AND NOT a.attisdropped
				AND t.relname = $1 
				AND s.nspname = $2
				ORDER BY a.attnum LIMIT 1'
					INTO v_idname
					USING v_tablename, v_schemaname;
		END IF;

		-- Get column type
		EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
		JOIN pg_class t on a.attrelid = t.oid
		JOIN pg_namespace s on t.relnamespace = s.oid
		WHERE a.attnum > 0 
		AND NOT a.attisdropped
		AND a.attname = $3
		AND t.relname = $2 
		AND s.nspname = $1
		ORDER BY a.attnum'
			USING v_schemaname, v_tablename, v_idname
			INTO v_column_type;

		-- Getting geometry column
		EXECUTE 'SELECT attname FROM pg_attribute a        
		JOIN pg_class t on a.attrelid = t.oid
		JOIN pg_namespace s on t.relnamespace = s.oid
		WHERE a.attnum > 0 
		AND NOT a.attisdropped
		AND t.relname = $1
		AND s.nspname = $2
		AND left (pg_catalog.format_type(a.atttypid, a.atttypmod), 8)=''geometry''
		ORDER BY a.attnum' 
			USING v_tablename, v_schemaname
			INTO v_the_geom;

		--  get querytext
		EXECUTE concat('SELECT query_text FROM config_api_list WHERE tablename = $1 AND device = $2', v_attribute_filter)
			INTO v_query_result
			USING v_tablename, v_device;

		-- if v_device is not configured on config_api_list table
		IF v_query_result IS NULL THEN
			EXECUTE concat('SELECT query_text FROM config_api_list WHERE tablename = $1 LIMIT 1', v_attribute_filter)
				INTO v_query_result
				USING v_tablename;
		END IF;	

		-- if v_tablename is not configured on config_api_list table
		IF v_query_result IS NULL THEN
			v_query_result = 'SELECT * FROM '||v_tablename||' WHERE '||v_idname||' IS NOT NULL ';
		END IF;

	ELSE
		--  get querytext
		EXECUTE concat('SELECT query_text, vdefault FROM config_api_list WHERE tablename = $1 AND device = $2', v_attribute_filter)
			INTO v_query_result, v_default
			USING v_tablename, v_device;

		-- if v_device is not configured on config_api_list table
		IF v_query_result IS NULL THEN
			EXECUTE concat('SELECT query_text, vdefault FROM config_api_list WHERE tablename = $1 LIMIT 1', v_attribute_filter)
				INTO v_query_result, v_default
				USING v_tablename;
		END IF;	
	END IF;

	--  add filters (fields)
	SELECT array_agg(row_to_json(a)) into v_text from json_each(v_filter_values) a;
	
	IF v_text IS NOT NULL THEN
		FOREACH text IN ARRAY v_text
		LOOP
			-- Get field and value from json
			SELECT v_text [i] into v_json_field;
			v_field:= (SELECT (v_json_field ->> 'key')) ;
			v_value:= (SELECT (v_json_field ->> 'value')) ;
			i=i+1;

			raise notice 'v_field % v_value %', v_field, v_value;
	
			-- Getting the sign of the filter
			SELECT listfilterparam->>'sign' INTO v_sign FROM config_api_form_fields WHERE formname=v_tablename  AND column_id=v_field;
			IF v_sign IS NULL THEN
				v_sign = '=';
			END IF;

		    
		    -- Get column type
		    
		    EXECUTE FORMAT ('SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = %s AND column_name = $2', quote_literal(v_tablename))
			USING v_schemaname, v_field
			INTO v_columntype;
			
			-- creating the query_text
			
			IF v_field='limit' THEN
				IF v_limit IS NULL THEN
					v_limit := v_value;
				END IF;
			ELSIF v_field='lot_id' THEN
				IF v_filterlot IS NULL THEN
					v_filterlot := v_value;
				END IF;
				v_query_result := v_query_result || ' AND '||v_field||'::text '||v_sign||' '||quote_literal(v_filterlot) ||'::text';
			ELSIF v_field='team_id' and ((p_data ->>'feature')::json->>'tableName')::text != 'om_visit' THEN
				IF v_filterteam IS NULL THEN
					v_filterteam := v_value;
				END IF;
				IF v_filterteam IS NOT NULL THEN
					v_query_result := v_query_result || ' AND '||v_field||'::text '||v_sign||' '||quote_literal(v_filterteam) ||'::text';
				END IF;
			ELSIF v_value IS NOT NULL  THEN
				IF v_startdate IS NULL THEN
					v_startdate := v_value;			
				END IF;
				v_query_result := v_query_result || ' AND '||v_field||'::'||COALESCE(v_columntype, 'text')||' '||v_sign||' '||quote_literal(v_startdate) ||'::'||COALESCE(v_columntype, 'text');
			END IF;
		END LOOP;
		
	END IF;
	
	-- add feature filter
	SELECT array_agg(row_to_json(a)) into v_text from json_each(v_filter_feature) a;
	
	IF v_text IS NOT NULL THEN
		FOREACH text IN ARRAY v_text
		LOOP
			-- Get field and value from json
			SELECT v_text [1] into v_json_field;
			v_field:= (SELECT (v_json_field ->> 'key')) ;
			v_value:= (SELECT (v_json_field ->> 'value')) ;
				
			-- creating the query_text
			v_query_result := v_query_result || ' AND '||v_field||'::text = '||quote_literal(v_value) ||'::text';
		END LOOP;
	END IF;
	
	-- add extend filter
	IF v_the_geom IS NOT NULL AND v_canvasextend IS NOT NULL THEN
		
		-- getting coordinates values
		v_x1 = v_canvasextend->>'x1coord';
		v_y1 = v_canvasextend->>'y1coord';
		v_x2 = v_canvasextend->>'x2coord';
		v_y2 = v_canvasextend->>'y2coord';	

		-- adding on the query text the extend filter
		v_query_result := v_query_result || ' AND ST_dwithin ( '|| v_tablename || '.' || v_the_geom || ',' || 
		'ST_MakePolygon(ST_GeomFromText(''LINESTRING ('||v_x1||' '||v_y1||', '||v_x1||' '||v_y2||', '||v_x2||' '||v_y2||', '||v_x2||' '||v_y1||', '||v_x1||' '||v_y1||')'','||v_srid||')),1)';
	END IF;
	
	-- add orderby
	IF v_orderby IS NULL THEN

		v_orderby = v_default->>'orderBy';
		v_ordertype = v_default->>'orderType';
	END IF;


	IF v_orderby IS NOT NULL THEN
		v_query_result := v_query_result || ' ORDER BY '||v_orderby::integer;
	END IF;

	-- adding ordertype
	IF v_ordertype IS NOT NULL THEN
		v_query_result := v_query_result ||' '||v_ordertype;
	END IF;

	raise notice 'query - %', v_query_result;

	-- add limit
	
	IF v_limit IS NULL THEN
		v_limit = 15;
	END IF;
	
	EXECUTE 'SELECT count(*)/'||v_limit||' FROM (' || v_query_result || ') a'
        INTO v_lastpage;
    
	    -- add limit
	    v_query_result := v_query_result || ' LIMIT '|| v_limit;


	-- calculating current page
	IF v_currentpage IS NULL THEN 
		v_currentpage=1;
	END IF;

	-- add offset
	v_offset := (v_currentpage-1)*v_limit;
	IF v_offset IS NOT NULL THEN
		v_query_result := v_query_result || ' OFFSET '|| v_offset;
	END IF;

	RAISE NOTICE '--- gw_api_getlist - Query Result: % ---', v_query_result;

	-- Execute query result
	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (' || v_query_result || ') a'
		INTO v_result_list;

	RAISE NOTICE '--- gw_api_getlist - List: % ---', v_result_list;

	-- building pageinfo
	v_pageinfo := json_build_object('orderBy',v_orderby, 'orderType', v_ordertype, 'currentPage', v_currentpage, 'lastPage', v_lastpage);

	-- getting filter fields
	SELECT gw_api_get_formfields(v_tablename, 'listHeader', v_tabname, null, null, null, null,'INSERT', null, v_device)
		INTO v_filter_fields;

		--  setting values of filter fields
		
		SELECT array_agg(row_to_json(a)) into v_text from json_each(v_filter_values) a;
		i=1;
		IF v_text IS NOT NULL THEN
			FOREACH text IN ARRAY v_text
			LOOP
				-- get value
				SELECT v_text [i] into v_json_field;
				v_value:= (SELECT (v_json_field ->> 'value')) ;

				-- set value (from v_value)
				IF v_filter_fields[i] IS NOT NULL THEN
					
					IF (v_filter_fields[i]->>'column_id')='limit' AND v_limit IS NOT NULL THEN
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'value', COALESCE(v_limit));
					ELSIF (v_filter_fields[i]->>'column_id')='startdate' AND v_startdate IS NOT NULL THEN
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'value', COALESCE(v_startdate));
					ELSIF (v_filter_fields[i]->>'column_id')='lot_id' AND v_filterlot IS NOT NULL THEN
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'selectedId', v_filterlot::text);
					ELSIF (v_filter_fields[i]->>'column_id')='team_id' AND v_filterteam IS NOT NULL THEN
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'selectedId', v_filterteam::text);	
					ELSIF (v_filter_fields[i]->>'widgettype')='combo' THEN
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'selectedId', v_value);
					ELSE
						v_filter_fields[i] := gw_fct_json_object_set_key(v_filter_fields[i], 'value', v_value);
					END IF;
				END IF;
				
				--raise notice 'v_value % v_filter_fields %', v_value, v_filter_fields[i];
				
				i=i+1;			
			
			END LOOP;
			
		END IF;

	-- adding the widget of list
	v_i = cardinality(v_filter_fields) ;
	
	EXECUTE concat('SELECT listclass FROM config_api_list WHERE tablename = $1', v_attribute_filter, ' LIMIT 1')
		INTO v_listclass
		USING v_tablename;

	IF v_listclass IS NULL THEN
		v_listclass = 'tableView';
	END IF;
	
	-- setting new element	
	IF v_device =9 THEN
		v_filter_fields[v_i+1] := json_build_object('widgettype',v_listclass,'widgetfunction','gw_api_open_rpt_result','label','','stylesheet','','layout_order',0,'layout_name','rpt_layout1','widgetname','tableview_rpt','datatype','tableView','column_id','fileList','orderby', v_i+3, 'position','body', 'value', v_result_list);
	ELSE
		v_filter_fields[v_i+1] := json_build_object('type',v_listclass,'dataType','list','name','list','orderby', v_i+3, 'position','body', 'value', v_result_list);
	END IF;

	-- getting footer buttons
	SELECT gw_api_get_formfields(v_tablename, 'listFooter', v_tabname, null, null, null, null,'INSERT', null, v_device)
		INTO v_footer_fields;

	FOREACH aux_json IN ARRAY v_footer_fields
	LOOP
		v_filter_fields[v_i+2] := json_build_object('type','button','label', aux_json->>'label' ,'widgetAction',  aux_json->>'widgetfunction', 'position','footer');
		v_i=v_i+1;

	END LOOP;


	raise notice 'v_tablename -->> %',v_tablename;
   	SELECT gw_api_get_formfields(v_tablename, 'listfilter', v_tabname, null, null, null, null,'INSERT', null, v_device)
		INTO v_filter_fields_;
		
		
	-- adding common widgets
	FOREACH aux_json IN ARRAY v_filter_fields_
	LOOP
		--identifing the dimension of array
		v_i = cardinality(v_filter_fields) ;

		-- adding spacer
		IF v_device=9 THEN
			v_filter_fields[v_i+1] := aux_json;
			v_i=v_i+1;
		END IF;
	END LOOP;


-- converting to json
	v_fields_json = array_to_json (v_filter_fields);
	v_fields_json_ = array_to_json (v_filter_fields_);

--    Control NULL's
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_featuretype := COALESCE(v_featuretype, '');
	v_tablename := COALESCE(v_tablename, '');
	v_idname := COALESCE(v_idname, '');	
	v_fields_json := COALESCE(v_fields_json, '{}');
	v_pageinfo := COALESCE(v_pageinfo, '{}');

--    Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "apiVersion":'||v_apiversion||
             ',"body":{"form":{}'||
		     ',"feature":{"featureType":"' || v_featuretype || '","tableName":"' || v_tablename ||'","idName":"'|| v_idname ||'"}'||
		     ',"data":{"fields":' || v_fields_json ||
			     ',"pageInfo":' || v_pageinfo ||
			     '}'||
		       '}'||
	    '}')::json;
       
--    Exception handling
--    EXCEPTION WHEN OTHERS THEN 
        --RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| v_apiversion || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

