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
	-- example how fill column layermanager : 	{"visible":["v_edit_arc","v_edit_node","v_edit_connec"],
	--						"zoom":{"layer":"v_edit_arc","margin":200},
	--						"index":["v_edit_arc","v_edit_node"],
	--						"active":"v_edit_connec",
	--						"snnaping":["v_edit_arc","v_edit_node"]}

	v_layermanager = (SELECT layermanager FROM config_function where id = p_fnumber);
	v_layermanager = gw_fct_json_object_set_key((v_layermanager)::json, 'functionId', p_fnumber);	
	v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'layerManager', v_layermanager);
	p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);
	
	-- actions
	-- The name of the function must match the name of the function in python, and if the python function requires parameters, they must be called as required by that function.
	-- example how fill column actions :	[{"funcName":"test1","params":{"layerName":"v_edit_arc","qmlPath":"C:\\Users\\Nestor\\Desktop\\11111.qml"}},
	--					 {"funcName":"test2"}]
	v_actions = (SELECT actions FROM config_function where id = p_fnumber);
	v_body = gw_fct_json_object_set_key((p_data->>'body')::json, 'actions', v_actions);
	p_data = gw_fct_json_object_set_key((p_data)::json, 'body', v_body);

	
	-- Control nulls
	v_returnmanager := COALESCE(v_returnmanager, '{}');
	v_layermanager := COALESCE(v_layermanager, '{}'); 
	 	

		 
	-- Return
	RETURN p_data;
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample_json.gw_fct_json_create_return(json, integer)
  OWNER TO postgres;