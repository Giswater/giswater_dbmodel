-- DROP FUNCTION ws_3612_70.gw_fct_check_fprocess(json);

CREATE OR REPLACE FUNCTION ws_3612_70.gw_fct_check_fprocess(p_data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
/*
select gw_fct_check_fprocess($${"data":{"parameters":{"functionFid": '||v_fid||', "checkFid":"103", "prefixTable": "'||v_edit||'"}}}$$)';
*/

DECLARE
v_function_fid integer;
v_check_fid integer;
v_prefix_table text;
--
v_rec record;
v_rec_anl record;
v_count integer;
v_geom_type text;
v_sql text;
v_text_aux text;
v_exc_msg text;

BEGIN

-- get input params
v_function_fid := (((p_data ->>'data')::json->>'parameters')::json->>'functionFid')::integer;
v_check_fid := (((p_data ->> 'data')::json->>'parameters')::json->> 'checkFid')::integer;
v_prefix_table := (((p_data ->> 'data')::json->>'parameters')::json->> 'prefixTable')::text;


-- get fprocess data
select * into v_rec from sys_fprocess where fid = v_check_fid;


-- replace key word by querytable
v_rec.query_text = replace(v_rec.query_text, 'v_prefix_', v_prefix_table);
v_exc_msg = v_rec.except_msg;


-- count events
execute 'select count(*) from ('||v_rec.query_text||')a' into v_count;


-- get text variables according to singular/plural values
if v_count = 1 then 

	v_text_aux = 'There is ';

	v_rec.except_msg =
	concat(
        substring(split_part(except_msg, ' ', 1) FROM 1 FOR length(split_part(except_msg, ' ', 1)) - 1),
        ' ',
        substring(except_msg FROM length(split_part(except_msg, ' ', 1)) + 2)
    );

elsif v_count > 1 then 

	v_text_aux = 'There are ';

end if;


-- manage result (audit_check_data)

IF v_count > 0 then

	INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
	values (v_function_fid, v_rec.except_level, v_check_fid, concat(
	case when v_rec.except_level = 2 then 'ERROR-' when v_rec.except_level = 3 then 'WARNING-' end ,
	v_check_fid, ': ', concat(v_text_aux, v_count, ' ', v_rec.except_msg)), 9999);

ELSE

	INSERT INTO temp_audit_check_data (fid, criticity, result_id, error_message, fcount)
	values (v_function_fid, 3, v_check_fid, concat('INFO: No ', except_msg), 7777);

END IF;


-- manage result (anl_tables)
v_sql = 'select a.*, '||quote_literal(v_exc_msg)||' from ('||v_rec.query_text||') a';

-- geom_type from result
execute 'select distinct st_geometrytype(the_geom) from ('||v_sql||')a limit 1' into v_geom_type;


if v_geom_type = 'ST_LineString' then

	execute '
	insert into anl_arc (arc_id, arccat_id, expl_id, fid, the_geom, descript)
	select arc_id, arccat_id, expl_id, '||v_check_fid||', the_geom, '||quote_literal(v_exc_msg)||' from ('||v_sql||')b';
	
elsif v_geom_type = 'ST_Point' then

	v_table = 'anl_node';
	
end if;


return '{"status": "accepted"}'::json;


END;
$function$
;
