/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3002

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_setplan(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setplan(p_data json)
RETURNS json AS
$BODY$

/*+

SELECT gw_fct_setplan($${"client":{"device":4, "infoType":1, "lang":"ES"}, 
"form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{},"psectorId":"1"}}$$);
*/

DECLARE
v_version text;
v_psector integer;
v_query text;
v_count integer;
v_plan_obsolete_state_type integer;
v_uservalues json;

v_audit_result text;
v_level integer;
v_status text;
v_message text;
v_error_context text;

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- select config values
	SELECT giswater INTO v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	v_psector := json_extract_path_text (p_data,'data','psectorId')::integer;
	v_plan_obsolete_state_type:= (SELECT value::json ->> 'plan_obsolete_state_type' FROM config_param_system WHERE parameter='plan_psector_execute_action');


	--set current process as users parameter
    DELETE FROM config_param_user  WHERE  parameter = 'utils_cur_trans' AND cur_user =current_user;

    INSERT INTO config_param_user (value, parameter, cur_user)
    VALUES (txid_current(),'utils_cur_trans',current_user );

	--control psector topology: find arc, that on psector is defined as operative, but its final nodes are defined as obsolete
	IF v_psector IS NOT NULL THEN
		v_query = 'SELECT pa.arc_id, pa.psector_id , node_1 as node FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
		JOIN plan_psector_x_node pn1 ON pn1.node_id = arc.node_1
		WHERE pa.psector_id = pn1.psector_id AND pa.state = 1 AND pn1.state = 0 AND pa.psector_id = '|| v_psector ||' AND arc.state_type<>'|| v_plan_obsolete_state_type ||'
		UNION
		SELECT pa.arc_id, pa.psector_id, node_2 FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
		JOIN plan_psector_x_node pn2 ON pn2.node_id = arc.node_2
		WHERE pa.psector_id = pn2.psector_id AND pa.state = 1 AND pn2.state = 0  AND pa.psector_id = '|| v_psector ||' AND arc.state_type<>'|| v_plan_obsolete_state_type ||'';


		EXECUTE 'SELECT count(*) FROM ('||v_query||')c'
		INTO v_count; 

		IF v_count > 0 THEN

			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3164", "function":"3002","debug_msg":null}}$$)' INTO v_audit_result;

		END IF;		

		--control psector topology: find arc, that on inventory is defined as planified, but on psector it's final nodes are set as obsolete
		v_query = 'SELECT * FROM
		(SELECT pa.arc_id, pa.psector_id , node_1 as node FROM plan_psector_x_arc pa JOIN arc a USING (arc_id)
			JOIN node n ON node_id = node_1 where n.state = 2 AND a.state=2 AND pa.psector_id = '|| v_psector ||'
		EXCEPT
		SELECT pa.arc_id, pa.psector_id , node_1 as node FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
			JOIN plan_psector_x_node pn1 ON pn1.node_id = arc.node_1
			WHERE pa.psector_id = pn1.psector_id and pa.state = 1 AND pn1.state = 1 AND pa.psector_id = '|| v_psector ||')a
		UNION
		SELECT * FROM
		(SELECT pa.arc_id, pa.psector_id , node_2 as node FROM plan_psector_x_arc pa JOIN arc a USING (arc_id)
			JOIN node n ON node_id = node_2 where n.state = 2 AND a.state=2 AND pa.psector_id = '|| v_psector ||'
		EXCEPT
		SELECT pa.arc_id, pa.psector_id , node_2 as node FROM plan_psector_x_arc pa JOIN arc USING (arc_id)
			JOIN plan_psector_x_node pn2 ON pn2.node_id = arc.node_2
			WHERE pa.psector_id = pn2.psector_id AND pa.state = 1 AND pn2.state = 1 AND pa.psector_id = '|| v_psector ||')b';

		EXECUTE 'SELECT count(*) FROM ('||v_query||')c'
		INTO v_count; 

		IF v_count > 0 THEN

			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
			"data":{"message":"3164", "function":"3002","debug_msg":null}}$$)' INTO v_audit_result;

		END IF;		

	END IF;

	 IF v_audit_result is null THEN
        v_status = 'Accepted';
        v_level = 3;
        v_message = 'Process done successfully';
    ELSE

        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

    END IF;

  -- get uservalues
	PERFORM gw_fct_workspacemanager($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{},"data":{"filterFields":{}, "pageInfo":{}, "action":"CHECK"}}$$);
	v_uservalues = (SELECT to_json(array_agg(row_to_json(a))) FROM (SELECT parameter, value FROM config_param_user WHERE parameter IN ('plan_psector_vdefault', 'utils_workspace_vdefault')
	AND cur_user = current_user ORDER BY parameter)a);
	--control nulls
	v_uservalues := COALESCE(v_uservalues, '{}');
		--  Return
	RETURN gw_fct_json_create_return(('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{"userValues":'||v_uservalues||', "info":{}'||
			'}}'||
	    '}')::json, 3002, null, null, null);

	   EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
    RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;