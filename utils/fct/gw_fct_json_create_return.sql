-- Function: ws_sample_json.gw_fct_json_create_return(json, integer)

-- DROP FUNCTION ws_sample_json.gw_fct_json_create_return(json, integer);

CREATE OR REPLACE FUNCTION ws_sample_json.gw_fct_json_create_return(
    p_data json,
    p_fnumber integer)
  RETURNS json AS
$BODY$

/*
anadir 3 campos más a sys_function (layermanager, sytle, actions)
crear nueva tabla sys_style
*/
 
DECLARE

v_actions json;
v_body json;
v_returnmanager json;
v_layermanager json;
v_return json;
v_qml json;



BEGIN

	-- Search path
	SET search_path = 'ws_sample_json', public;

	
	-- returnmanager	
	-- example1: v_style: {["layer":"tablename1", "mode":"Disabled", "parameters": null], ["layer":"tablename2", "mode":"basicRGB", "parameters": [R,G,B, opacidad]], ["layer":"tablename3", "mode":"qml", "parameters": {"id":4}]}
	-- example2: v_style: {["layer":"temp_point", "mode":"Disabled", "parameters": null], ["layer":"temp_line", "mode":"BasicRGB", "parameters": [R,G,B, opacidad]], ["layer":"temp_pol", "mode":"qml", "parameters": {"id":4}]}
	v_returnmanager = (SELECT returnmanager FROM config_function where id = p_fnumber);
	v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'returnManager', v_returnmanager);
	p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);
	
	-- layermanager
	-- example: v_layermanager : "layermanager":   {"addToc":{"v_edit_arc":{"the_geom":"the_geom","field_id":"arc_id","group":"groupTest"},
	--							  "v_edit_connec":{"the_geom":"the_geom","field_id":"connec_id","group":"groupTest"}},
	--						"active":"v_edit_arc",
	--						"zoom":"v_edit_arc",
	--						"visible":["v_edit_arc","v_edit_node"],"index":["v_edit_arc","v_edit_node"]}



	EXECUTE 'SELECT row_to_json(row) FROM (SELECT sytelvalue as qml FROM sys_style WHERE idval='''||p_fnumber||''') row' INTO v_qml;
raise notice 'v_qml-->%',v_qml;
	v_layermanager = (SELECT layermanager FROM config_function where id = p_fnumber);
	raise notice 'v_layermanager-->%',v_layermanager;
	v_layermanager = gw_fct_json_object_set_key((v_layermanager)::json, 'style', v_qml->>'qml');
	--v_layermanager = gw_fct_json_object_set_key((v_layermanager)::json, 'zzzz', v_qml->>'qml');
	
	v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'layerManager', v_layermanager);
	p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);
	
	--v_body = gw_fct_json_object_set_key(((p_data->>'body')::json->>'layerManager')::json, 'qml', v_qml->>'qml');
	

	raise notice 'v_body 1---->%',v_body;
	
	raise notice 'p_data 2---->%',p_data;
	
raise notice 'v_body 3---->%',v_body;
raise notice 'p_data 3---->%',p_data;
	p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);
raise notice 'p_data 4---->%',p_data;


	
	v_actions = (SELECT actions FROM config_function where id = p_fnumber);

	-- Control nulls
	v_returnmanager := COALESCE(v_returnmanager, '{}');
	v_layermanager := COALESCE(v_layermanager, '{}'); 
	v_actions := COALESCE(v_actions, '[]'); 	
	

	
	

	-- actions
	-- example1: v_actions : '["set_sytle_mapzones"]';
	--v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'actions', v_actions);
	--p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);

	

	 
	-- Return
	RETURN p_data;
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample_json.gw_fct_json_create_return(json, integer)
  OWNER TO postgres;
