
--SELECT ws_sample_json.gw_fct_getstyle($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{"layers":[ "v_edit_arc", "v_edit_connec"]}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}}}$$);
CREATE OR REPLACE FUNCTION ws_sample_json.gw_fct_getstyle(p_data json)
  RETURNS json AS
$BODY$

/*
SELECT ws_sample_json.gw_fct_getstyle($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "layers":[ "v_edit_arc", "v_edit_connec"]}}$$);

*/
 
DECLARE

v_layers json;
v_return json;
v_layer text;



BEGIN

	-- Search path
	SET search_path = 'ws_sample_json', public;

	raise notice '-->%',p_data;
	
	
	v_layers = (((p_data ->>'data')::json->>'layers')::json);
	raise notice '-->%',v_layers;
	FOR v_layer IN  SELECT * FROM json_array_elements(v_layers) LOOP
		raise notice'-->%',v_layer;
	END LOOP;

	-- actions
	-- example1: v_actions : '["set_sytle_mapzones"]';
	--v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'actions', v_actions);
	--p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);

	

	 
	-- Return
	--RETURN v_return;
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample_json.gw_fct_getstyle(json)
  OWNER TO postgres;

