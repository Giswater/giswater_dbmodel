/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2234

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_fill_data(varchar);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_pg2epa_fill_data(result_id_var varchar)
RETURNS integer AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_pg2epa_main($${"client":{"device":4, "infoType":1, "lang":"ES","epsg":25831}, "data":{"resultId":"test1", "dumpSubcatch":"true","step":"0"}}$$) -- FULL PROCESS
INSERT INTO SCHEMA_NAME.rpt_cat_result VALUES ('r1');
SELECT "SCHEMA_NAME".gw_fct_pg2epa_fill_data ('r1');

select * from temp_t_arc
	select * from temp_t_node where epa_type = 'DIVIDER'


*/

-- fid: 113

DECLARE

v_rainfall text;
v_isoperative boolean;
v_statetype text;
v_networkmode integer;
v_timeseries record;

BEGIN

	-- Search path
	SET search_path = "SCHEMA_NAME", public;

	-- Delete previous results on temp_t_node & arc tables
	TRUNCATE temp_t_node;
	TRUNCATE temp_t_node_other;
	TRUNCATE temp_t_arc;
	TRUNCATE temp_t_arc_flowregulator;
	TRUNCATE temp_t_gully;
	TRUNCATE temp_rpt_inp_raingage;
	DELETE FROM rpt_inp_raingage WHERE result_id = result_id_var;
	TRUNCATE temp_t_lid_usage;

	-- set all timeseries of raingage using user's value
	v_rainfall:= (SELECT value FROM config_param_user WHERE parameter='inp_options_setallraingages' AND cur_user=current_user);

	v_isoperative = (SELECT value::json->>'onlyIsOperative' FROM config_param_user WHERE parameter='inp_options_debug' AND cur_user=current_user)::boolean;

	v_networkmode = (SELECT value FROM config_param_user WHERE parameter='inp_options_networkmode' AND cur_user=current_user);

	--Use state_type only is operative true or not
	IF v_isoperative THEN
		v_statetype = ' AND value_state_type.is_operative = TRUE ';
	ELSE
		v_statetype = ' AND (value_state_type.is_operative = TRUE OR value_state_type.is_operative = FALSE)';
	END IF;

	-- to do: implement isoperative strategy

	-- Insert on node rpt_inp table
	-- the strategy of selector_sector is not used for nodes. The reason is to enable the posibility to export the sector=-1. In addition using this it's impossible to export orphan nodes
	EXECUTE 'INSERT INTO temp_t_node (result_id, node_id, top_elev, ymax, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, expl_id, y0, ysur, apond, the_geom, age)
	SELECT '||quote_literal(result_id_var)||',
	node.node_id, sys_top_elev, sys_ymax, v_edit_node.sys_elev, node.node_type, node.nodecat_id, node.epa_type, node.sector_id, node.state, 
	node.state_type, node.annotation, node.expl_id, y0, ysur, apond, node.the_geom, (now()::date-node.builtdate)/30
	FROM selector_sector, node
		LEFT JOIN v_edit_node USING (node_id) -- we need to use v_edit_node to work with sys_* fields
		JOIN inp_junction ON node.node_id=inp_junction.node_id
		JOIN (
		SELECT node_1 AS node_id FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||' UNION 
		SELECT node_2 FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||')a ON node.node_id=a.node_id
	UNION
	SELECT '||quote_literal(result_id_var)||',
	node.node_id, sys_top_elev, sys_ymax, v_edit_node.sys_elev, node.node_type, node.nodecat_id, node.epa_type, node.sector_id, node.state, 
	node.state_type, node.annotation, node.expl_id, y0, ysur, apond, node.the_geom, (now()::date-node.builtdate)/30
	FROM selector_sector, node 
		LEFT JOIN v_edit_node USING (node_id) 
		JOIN inp_divider ON node.node_id=inp_divider.node_id
		JOIN (
		SELECT node_1 AS node_id FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||' UNION 
		SELECT node_2 FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||')a ON node.node_id=a.node_id
	UNION
	SELECT '||quote_literal(result_id_var)||',
	node.node_id, sys_top_elev, sys_ymax, v_edit_node.sys_elev, node.node_type, node.nodecat_id, node.epa_type, node.sector_id, 
	node.state, node.state_type, node.annotation, node.expl_id, y0, ysur, node.the_geom, (now()::date-node.builtdate)/30
	FROM selector_sector, node 
		LEFT JOIN v_edit_node USING (node_id) 	
		JOIN inp_storage ON node.node_id=inp_storage.node_id
		JOIN (
		SELECT node_1 AS node_id FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||' UNION 
		SELECT node_2 FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||')a ON node.node_id=a.node_id
	UNION
	SELECT '||quote_literal(result_id_var)||',
	node.node_id, sys_top_elev, sys_ymax, v_edit_node.sys_elev, node.node_type, node.nodecat_id, node.epa_type, node.sector_id, 
	node.state, node.state_type, node.annotation, node.expl_id, null, null, null, node.the_geom, (now()::date-node.builtdate)/30
	FROM selector_sector, node 
		LEFT JOIN v_edit_node USING (node_id)
		JOIN inp_outfall ON node.node_id=inp_outfall.node_id
		JOIN (
		SELECT node_1 AS node_id FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||' UNION 
		SELECT node_2 FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||')a ON node.node_id=a.node_id
	UNION
	SELECT '||quote_literal(result_id_var)||',
	node.node_id, sys_top_elev, sys_ymax, v_edit_node.sys_elev, node.node_type, node.nodecat_id, node.epa_type, node.sector_id, 
	node.state, node.state_type, node.annotation, node.expl_id, y0, ysur, apond, node.the_geom, (now()::date-node.builtdate)/30
	FROM selector_sector, node 
		LEFT JOIN v_edit_node USING (node_id)
		JOIN inp_netgully ON node.node_id=inp_netgully.node_id
		JOIN (
		SELECT node_1 AS node_id FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||' UNION 
		SELECT node_2 FROM selector_sector s, v_edit_arc a JOIN value_state_type ON id=state_type WHERE a.sector_id > 0 AND a.sector_id = s.sector_id and current_user = cur_user AND epa_type !=''UNDEFINED'' '||
		v_statetype ||')a ON node.node_id=a.node_id';


	-- node on the fly transformation of junctions to outfalls (when outfallparam is fill and junction is node sink)
	-- PERFORM gw_fct_anl_node_sink($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{"tableName":"v_edit_node"},"data":{"parameters":{"saveOnDatabase":true}}}$$);

	-- update child param for divider
	UPDATE temp_t_node SET addparam=concat('{"divider_type":"',divider_type,'", "arc_id":"',arc_id,'", "curve_id":"',curve_id,'", "qmin":"',
	qmin,'", "ht":"',ht,'", "cd":"',cd,'"}')
	FROM inp_divider WHERE temp_t_node.node_id=inp_divider.node_id;

	-- update child param for storage
	UPDATE temp_t_node SET addparam=concat('{"storage_type":"',storage_type,'", "curve_id":"',curve_id,'", "a1":"',a1,'", "a2":"',a2,'", "a0":"',a0,'", "fevap":"',fevap,'", "sh":"',sh,'", "hc":"',hc,'", 
	"imd":"',imd,'"}')
	FROM inp_storage WHERE temp_t_node.node_id=inp_storage.node_id;

	-- update child param for outfall
	UPDATE temp_t_node SET addparam=concat('{"outfall_type":"',outfall_type,'", "state":"',state,'", "curve_id":"',curve_id,'", "timser_id":"',timser_id,'", "gate":"',gate,'"}')
	FROM inp_outfall WHERE temp_t_node.node_id=inp_outfall.node_id;

	UPDATE temp_t_node SET epa_type='OUTFALL' FROM anl_node a JOIN inp_junction USING (node_id)
	WHERE outfallparam IS NOT NULL AND fid = 113 AND cur_user=current_user
	AND temp_t_node.node_id=a.node_id;

	INSERT INTO temp_t_node_other (node_id, type, timser_id, other, mfactor, sfactor, base, pattern_id)
	SELECT node_id, 'FLOW', timser_id, 'FLOW', 1, sfactor, base, pattern_id FROM v_edit_inp_inflows;

	INSERT INTO temp_t_node_other (node_id, type, timser_id, poll_id, other, mfactor, sfactor, base, pattern_id)
	SELECT node_id, 'POLLUTANT', timser_id, poll_id, form_type, mfactor, sfactor, base, pattern_id FROM v_edit_inp_inflows_poll;

	INSERT INTO temp_t_node_other (node_id, type, poll_id, other)
	SELECT node_id, 'TREATMENT', poll_id, function FROM v_edit_inp_treatment;

	-- Insert on arc rpt_inp table
	EXECUTE 'INSERT INTO temp_t_arc 
	(result_id, arc_id, node_1, node_2, elevmax1, elevmax2, arc_type, arccat_id, epa_type, sector_id, state, state_type, annotation, length, n, expl_id, the_geom, q0, qmax, barrels, slope,
	culvert, kentry, kexit, kavg, flap, seepage, age)
	SELECT '||quote_literal(result_id_var)||',
	a.arc_id, node_1, node_2, a.sys_elev1, a.sys_elev2, a.arc_type, arccat_id, epa_type, a.sector_id, a.state, 
	a.state_type, a.annotation, 
	CASE
		WHEN custom_length IS NOT NULL THEN custom_length
		ELSE st_length2d(a.the_geom)
	END AS length,
	CASE
		WHEN custom_n IS NOT NULL THEN custom_n
		ELSE n
	END AS n,
	a.expl_id, 
	a.the_geom,
	q0,
	qmax,
	barrels,
	slope,
	culvert, kentry, kexit, kavg, flap, seepage, (now()::date-a.builtdate)/30
	FROM selector_sector, v_edit_arc a
		LEFT JOIN value_state_type ON id=state_type
		LEFT JOIN cat_mat_arc ON matcat_id = cat_mat_arc.id
		LEFT JOIN inp_conduit ON a.arc_id = inp_conduit.arc_id
		WHERE epa_type !=''UNDEFINED'' '||v_statetype||' 
		AND a.sector_id > 0
		AND a.sector_id=selector_sector.sector_id AND selector_sector.cur_user=current_user';

	-- todo: UPDATE childparam for inp_weir, inp_orifice, inp_outlet, inp_pump

	-- fill temp_t_gully in order to work with 1D/2D
	IF v_networkmode = 2 or v_networkmode = 3 THEN

		-- netgully
		EXECUTE 'INSERT INTO temp_t_gully 
		SELECT 
		concat(''NG'',node_id), g.node_type, gullycat_id, null, g.node_id, g.sector_id, g.state, g.state_type, 
		case when custom_top_elev is null then top_elev else custom_top_elev end, 
		units, units_placement, outlet_type,
		case when custom_width is null then total_width else custom_width end, 
		case when custom_length is null then total_length else custom_length end,
		case when custom_depth is null then depth else custom_depth end,
		method, weir_cd, orifice_cd, 
		case when custom_a_param is null then a_param else custom_a_param end,
		case when custom_b_param is null then b_param else custom_b_param end,
		efficiency, the_geom
		FROM v_edit_inp_netgully g 
		LEFT JOIN value_state_type ON id=g.state_type
		WHERE g.sector_id > 0 '||v_statetype||';';

		-- gully
		EXECUTE 'INSERT INTO temp_t_gully 
		SELECT 
		gully_id, g.gully_type, gullycat_id, g.arc_id, 
		case when pjoint_type = ''NODE'' then pjoint_id else a.node_2 END AS node_id, 
		g.sector_id, g.state, g.state_type, 
		case when custom_top_elev is null then top_elev else custom_top_elev end, 
		units, units_placement, outlet_type,
		case when custom_width is null then total_width else custom_width end, 
		case when g.custom_length is null then total_length else g.custom_length end,
		case when custom_depth is null then depth else custom_depth end,
		method, weir_cd, orifice_cd, 
		case when custom_a_param is null then a_param else custom_a_param end,
		case when custom_b_param is null then b_param else custom_b_param end,
		efficiency, g.the_geom
		FROM v_edit_inp_gully g
		LEFT JOIN arc a USING (arc_id)
		LEFT JOIN value_state_type ON id=g.state_type
		WHERE arc_id IS NOT NULL AND g.sector_id > 0 '||v_statetype||';';

	END IF;

	-- orifice
	INSERT INTO temp_t_arc_flowregulator (arc_id, type, ori_type, offsetval, cd, orate, flap, shape, geom1, geom2, geom3, geom4)
	SELECT arc_id, 'ORIFICE', ori_type, offsetval, cd, orate, flap, shape, geom1, geom2, 0, 0
	FROM v_edit_inp_orifice;

	INSERT INTO temp_t_arc_flowregulator (arc_id, type, ori_type, offsetval, cd, orate, flap, shape, geom1, geom2, geom3, geom4)
	SELECT nodarc_id, 'ORIFICE', ori_type, offsetval, cd, orate, flap, shape, geom1, geom2, 0, 0
	FROM v_edit_inp_flwreg_orifice;

	-- outlet
	INSERT INTO temp_t_arc_flowregulator (arc_id, type, outlet_type, offsetval, curve_id, cd1, cd2, flap)
	SELECT arc_id, 'OUTLET', outlet_type, offsetval, curve_id, cd1, cd2, flap
	FROM v_edit_inp_outlet;

	INSERT INTO temp_t_arc_flowregulator (arc_id, type, outlet_type, offsetval, curve_id, cd1, cd2, flap)
	SELECT nodarc_id, 'OUTLET', outlet_type, offsetval,curve_id, cd1, cd2, flap
	FROM v_edit_inp_flwreg_outlet;

	-- pump
	INSERT INTO temp_t_arc_flowregulator (arc_id, type, curve_id, status, startup, shutoff)
	SELECT arc_id, 'PUMP', curve_id, status, startup, shutoff
	FROM v_edit_inp_pump;

	INSERT INTO temp_t_arc_flowregulator (arc_id, type, curve_id, status, startup, shutoff)
	SELECT nodarc_id, 'PUMP', curve_id, status, startup, shutoff
	FROM v_edit_inp_flwreg_pump;

	-- weir
	INSERT INTO temp_t_arc_flowregulator (arc_id, type, weir_type, offsetval, cd, ec, cd2, flap, shape, geom1, geom2, geom3, geom4, road_width,
	road_surf, coef_curve, surcharge)
	SELECT arc_id, 'WEIR', weir_type, offsetval, cd, ec, cd2, flap, inp_typevalue.descript, geom1, geom2, geom3, geom4, road_width,
	road_surf, coef_curve, surcharge
	FROM v_edit_inp_weir
	LEFT JOIN inp_typevalue ON inp_typevalue.id::text = v_edit_inp_weir.weir_type::text
	WHERE inp_typevalue.typevalue::text = 'inp_value_weirs';

	INSERT INTO temp_t_arc_flowregulator (arc_id, type, weir_type, offsetval, cd, ec, cd2, flap, shape, geom1, geom2, geom3, geom4, road_width,
	road_surf, coef_curve, surcharge)
	SELECT nodarc_id, 'WEIR', weir_type, offsetval, cd, ec, cd2, flap, inp_typevalue.descript, geom1, geom2, geom3, geom4, road_width,
	road_surf, coef_curve, surcharge
	FROM v_edit_inp_flwreg_weir
	LEFT JOIN inp_typevalue ON inp_typevalue.id::text = v_edit_inp_flwreg_weir.weir_type::text
	WHERE inp_typevalue.typevalue::text = 'inp_value_weirs';

	-- filling empty values
	UPDATE temp_t_node SET y0=0 where y0 IS NULL;
	UPDATE temp_t_node SET ysur=0 where ysur IS NULL;

	UPDATE temp_t_arc SET q0=0 where q0 IS NULL;

	-- rpt_inp_raingage
	INSERT INTO temp_rpt_inp_raingage
	SELECT result_id_var, * FROM v_edit_raingage;

	-- setting same rainfall for all raingage
	IF v_rainfall IS NOT NULL THEN
		UPDATE temp_rpt_inp_raingage SET timser_id=v_rainfall, rgage_type='TIMESERIES';
	END IF;

	-- setting for date-time parameters if rainfall has addparam values)
	select * into v_timeseries from inp_timeseries where id = v_rainfall;

	IF json_extract_path_text(v_timeseries.addparam,'start_date') IS NOT NULL AND json_extract_path_text(v_timeseries.addparam,'start_date') != '' THEN
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'start_date')
		where cur_user = current_user and parameter = 'inp_options_start_date';
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'start_time')
		where cur_user = current_user and parameter = 'inp_options_start_time';
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'end_date')
		where cur_user = current_user and parameter = 'inp_options_end_date';
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'end_time')
		where cur_user = current_user and parameter = 'inp_options_end_time';
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'start_date')
		where cur_user = current_user and parameter = 'inp_options_report_start_date';
		update config_param_user set value = json_extract_path_text(v_timeseries.addparam,'start_time')
		where cur_user = current_user and parameter = 'inp_options_report_start_time';

	END IF;


	RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;