/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;
-- WARNING: SCHEMA_NAME IS NOT ONLY PRESENT ON THE HEADER OF THIS FILE. IT EXISTS ALSO INTO IT. PLEASE REVIEW IT BEFORE REPLACE....

/*

DROP VIEW IF EXISTS "v_inp_buildup" CASCADE;
CREATE VIEW "v_inp_buildup" AS 
SELECT inp_buildup_land_x_pol.landus_id, 
inp_buildup_land_x_pol.poll_id, 
inp_buildup_land_x_pol.funcb_type, 
inp_buildup_land_x_pol.c1, 
inp_buildup_land_x_pol.c2, 
inp_buildup_land_x_pol.c3, 
inp_buildup_land_x_pol.perunit 
FROM inp_buildup_land_x_pol;




DROP VIEW IF EXISTS "v_inp_controls" CASCADE;
CREATE VIEW "v_inp_controls" AS 
SELECT 
inp_controls_x_arc.id, 
text 
FROM inp_selector_sector, inp_controls_x_arc
	JOIN rpt_inp_arc on inp_controls_x_arc.arc_id=rpt_inp_arc.arc_id
	WHERE rpt_inp_arc.sector_id=(inp_selector_sector.sector_id) AND inp_selector_sector.cur_user="current_user"()
UNION
SELECT 
inp_controls_x_node.id, 
text
FROM inp_selector_sector, inp_controls_x_node 
	JOIN rpt_inp_node on inp_controls_x_node.node_id=rpt_inp_node.node_id
	WHERE rpt_inp_node.sector_id=(inp_selector_sector.sector_id) AND inp_selector_sector.cur_user="current_user"()
ORDER BY id;




DROP VIEW IF EXISTS "v_inp_curve" CASCADE;
CREATE OR REPLACE VIEW "v_inp_curve" AS 
SELECT inp_curve.id, 
inp_curve.curve_id, 
inp_curve.x_value, 
inp_curve.y_value,
(CASE 
	WHEN x_value = (SELECT MIN(x_value) FROM inp_curve AS sub WHERE sub.curve_id = inp_curve.curve_id) THEN inp_curve_id.curve_type 
	ELSE null END) AS curve_type
FROM inp_curve JOIN inp_curve_id ON inp_curve_id.id=inp_curve.curve_id
ORDER BY inp_curve.id;




DROP VIEW IF EXISTS "v_inp_evap_co" CASCADE;
CREATE VIEW "v_inp_evap_co" AS 
SELECT inp_evaporation.evap_type AS type_evco, 
inp_evaporation.evap 
FROM inp_evaporation 
	WHERE inp_evaporation.evap_type='CONSTANT';


	
	
DROP VIEW IF EXISTS "v_inp_evap_do" CASCADE;
CREATE VIEW "v_inp_evap_do" AS 
SELECT 
'DRY_ONLY'::text AS type_evdo,
 inp_evaporation.dry_only 
 FROM inp_evaporation;


 

DROP VIEW IF EXISTS "v_inp_evap_fl" CASCADE;
CREATE VIEW "v_inp_evap_fl" AS 
SELECT 
inp_evaporation.evap_type AS type_evfl, 
inp_evaporation.pan_1, 
inp_evaporation.pan_2, 
inp_evaporation.pan_3, 
inp_evaporation.pan_4, 
inp_evaporation.pan_5, 
inp_evaporation.pan_6, 
inp_evaporation.pan_7, 
inp_evaporation.pan_8, 
inp_evaporation.pan_9, 
inp_evaporation.pan_10, 
inp_evaporation.pan_11, 
inp_evaporation.pan_12 
FROM inp_evaporation 
	WHERE inp_evaporation.evap_type='FILE';

	

	
DROP VIEW IF EXISTS "v_inp_evap_mo" CASCADE;
CREATE VIEW "v_inp_evap_mo" AS 
SELECT 
inp_evaporation.evap_type AS type_evmo, 
inp_evaporation.value_1, 
inp_evaporation.value_2, 
inp_evaporation.value_3,
inp_evaporation.value_4, 
inp_evaporation.value_5, 
inp_evaporation.value_6, 
inp_evaporation.value_7, 
inp_evaporation.value_8, 
inp_evaporation.value_9, 
inp_evaporation.value_10, 
inp_evaporation.value_11, 
inp_evaporation.value_12 
 FROM inp_evaporation 
	WHERE inp_evaporation.evap_type='MONTHLY';

	

	
DROP VIEW IF EXISTS "v_inp_evap_pa" CASCADE;
CREATE VIEW "v_inp_evap_pa" AS 
SELECT 
'RECOVERY'::text AS type_evpa, 
inp_evaporation.recovery 
FROM inp_evaporation 
	WHERE inp_evaporation.recovery > '0';

	

	
DROP VIEW IF EXISTS "v_inp_evap_te" CASCADE;
CREATE VIEW "v_inp_evap_te" AS 
SELECT 
inp_evaporation.evap_type AS type_evte 
FROM inp_evaporation 
	WHERE inp_evaporation.evap_type='TEMPERATURE';

	

	
DROP VIEW IF EXISTS "v_inp_evap_ts" CASCADE;
CREATE VIEW "v_inp_evap_ts" AS 
SELECT 
inp_evaporation.evap_type AS type_evts, 
inp_evaporation.timser_id 
FROM inp_evaporation 
	WHERE inp_evaporation.evap_type='TIMESERIES';


	
	
DROP VIEW IF EXISTS "v_inp_hydrograph" CASCADE;
CREATE VIEW "v_inp_hydrograph" AS 
SELECT 
inp_hydrograph.id, 
inp_hydrograph.text 
FROM inp_hydrograph 
	ORDER BY inp_hydrograph.id;


	
	
DROP VIEW IF EXISTS "v_inp_landuses" CASCADE;
CREATE VIEW "v_inp_landuses" AS 
SELECT 
inp_landuses.landus_id, 
inp_landuses.sweepint, 
inp_landuses.availab, 
inp_landuses.lastsweep 
FROM inp_landuses;




DROP VIEW IF EXISTS "v_inp_lidcontrol" CASCADE;
CREATE VIEW "v_inp_lidcontrol" AS 
SELECT 
inp_lid_control.lidco_id, 
inp_lid_control.lidco_type, 
inp_lid_control.value_2, 
inp_lid_control.value_3, 
inp_lid_control.value_4, 
inp_lid_control.value_5, 
inp_lid_control.value_6, 
inp_lid_control.value_7, 
inp_lid_control.value_8 
FROM inp_lid_control 
	ORDER BY inp_lid_control.id;


	
DROP VIEW IF EXISTS "v_inp_options" CASCADE;
CREATE VIEW "v_inp_options" AS 
SELECT 
inp_options.flow_units,
cat_hydrology.infiltration,
inp_options.flow_routing,
inp_options.link_offsets,
inp_options.force_main_equation,
inp_options.ignore_rainfall,
inp_options.ignore_snowmelt,
inp_options.ignore_groundwater,
inp_options.ignore_routing,
inp_options.ignore_quality,
inp_options.skip_steady_state,
inp_options.start_date,
inp_options.start_time,
inp_options.end_date,
inp_options.end_time,
inp_options.report_start_date,
inp_options.report_start_time,
inp_options.sweep_start,
inp_options.sweep_end,
inp_options.dry_days,
inp_options.report_step,
inp_options.wet_step,
inp_options.dry_step,
inp_options.routing_step,
inp_options.lengthening_step,
inp_options.variable_step,
inp_options.inertial_damping,
inp_options.normal_flow_limited,
inp_options.min_surfarea,
inp_options.min_slope,
inp_options.allow_ponding,
inp_options.tempdir,
inp_options.max_trials,
inp_options.head_tolerance,
inp_options.sys_flow_tol,
inp_options.lat_flow_tol
FROM inp_options, inp_selector_hydrology
   JOIN cat_hydrology ON inp_selector_hydrology.hydrology_id = cat_hydrology.hydrology_id;

   

   
DROP VIEW IF EXISTS "v_inp_pattern_dl" CASCADE;
CREATE VIEW "v_inp_pattern_dl" AS 
SELECT 
inp_pattern.pattern_id, 
inp_pattern.pattern_type AS type_padl, 
inp_pattern.factor_1, 
inp_pattern.factor_2, 
inp_pattern.factor_3, 
inp_pattern.factor_4, 
inp_pattern.factor_5, 
inp_pattern.factor_6, 
inp_pattern.factor_7 
FROM inp_pattern 
	WHERE inp_pattern.pattern_type = 'DAILY';


	
DROP VIEW IF EXISTS "v_inp_pattern_ho" CASCADE;
CREATE VIEW "v_inp_pattern_ho" AS 
SELECT inp_pattern.pattern_id, 
inp_pattern.pattern_type AS type_paho, 
inp_pattern.factor_1, 
inp_pattern.factor_2, 
inp_pattern.factor_3, 
inp_pattern.factor_4, 
inp_pattern.factor_5, 
inp_pattern.factor_6, 
inp_pattern.factor_7, 
inp_pattern.factor_8, 
inp_pattern.factor_9, 
inp_pattern.factor_10, 
inp_pattern.factor_11, 
inp_pattern.factor_12, 
inp_pattern.factor_13, 
inp_pattern.factor_14, 
inp_pattern.factor_15, 
inp_pattern.factor_16, 
inp_pattern.factor_17, 
inp_pattern.factor_18, 
inp_pattern.factor_19, 
inp_pattern.factor_20, 
inp_pattern.factor_21, 
inp_pattern.factor_22, 
inp_pattern.factor_23, 
inp_pattern.factor_24 
FROM inp_pattern 
	WHERE inp_pattern.pattern_type='HOURLY';


	
	
DROP VIEW IF EXISTS "v_inp_pattern_mo" CASCADE;
CREATE VIEW "v_inp_pattern_mo" AS 
SELECT 
inp_pattern.pattern_id, 
inp_pattern.pattern_type AS type_pamo, 
inp_pattern.factor_1, 
inp_pattern.factor_2, 
inp_pattern.factor_3, 
inp_pattern.factor_4, 
inp_pattern.factor_5, 
inp_pattern.factor_6, 
inp_pattern.factor_7, 
inp_pattern.factor_8, 
inp_pattern.factor_9, 
inp_pattern.factor_10, 
inp_pattern.factor_11, 
inp_pattern.factor_12 
FROM inp_pattern 
	WHERE inp_pattern.pattern_type='MONTHLY';

	
	
	
DROP VIEW IF EXISTS "v_inp_pattern_we" CASCADE;
CREATE VIEW "v_inp_pattern_we" AS 
SELECT 
inp_pattern.pattern_id, 
inp_pattern.pattern_type AS type_pawe, 
inp_pattern.factor_1, 
inp_pattern.factor_2, 
inp_pattern.factor_3, 
inp_pattern.factor_4, 
inp_pattern.factor_5, 
inp_pattern.factor_6, 
inp_pattern.factor_7, 
inp_pattern.factor_8, 
inp_pattern.factor_9, 
inp_pattern.factor_10, 
inp_pattern.factor_11, 
inp_pattern.factor_12, 
inp_pattern.factor_13, 
inp_pattern.factor_14, 
inp_pattern.factor_15, 
inp_pattern.factor_16, 
inp_pattern.factor_17, 
inp_pattern.factor_18, 
inp_pattern.factor_19, 
inp_pattern.factor_20, 
inp_pattern.factor_21, 
inp_pattern.factor_22, 
inp_pattern.factor_23, 
inp_pattern.factor_24 
FROM inp_pattern 
	WHERE  inp_pattern.pattern_type ='WEEKEND';


		

DROP VIEW IF EXISTS "v_inp_snowpack" CASCADE;
CREATE VIEW "v_inp_snowpack" AS 
SELECT inp_snowpack.snow_id, 
'PLOWABLE'::text AS type_snpk1, 
inp_snowpack.cmin_1, 
inp_snowpack.cmax_1, 
inp_snowpack.tbase_1, 
inp_snowpack.fwf_1, 
inp_snowpack.sd0_1, 
inp_snowpack.fw0_1, 
inp_snowpack.snn0_1, 
'IMPERVIOUS'::text AS type_snpk2, 
inp_snowpack.cmin_2, 
inp_snowpack.cmax_2, 
inp_snowpack.tbase_2, 
inp_snowpack.fwf_2, 
inp_snowpack.sd0_2, 
inp_snowpack.fw0_2, 
inp_snowpack.sd100_1, 
'PERVIOUS'::text AS type_snpk3, 
inp_snowpack.cmin_3, 
inp_snowpack.cmax_3, 
inp_snowpack.tbase_3, 
inp_snowpack.fwf_3, 
inp_snowpack.sd0_3, 
inp_snowpack.fw0_3, 
inp_snowpack.sd100_2, 
'REMOVAL'::text AS type_snpk4, 
inp_snowpack.sdplow, 
inp_snowpack.fout, 
inp_snowpack.fimp, 
inp_snowpack.fperv, 
inp_snowpack.fimelt, 
inp_snowpack.fsub, 
inp_snowpack.subc_id
FROM inp_snowpack;





DROP VIEW IF EXISTS "v_inp_temp_fl" CASCADE;
CREATE VIEW "v_inp_temp_fl" AS 
SELECT 
inp_temperature.temp_type AS type_tefl, 
inp_temperature.fname, 
inp_temperature.start 
FROM inp_temperature 
	WHERE inp_temperature.temp_type='FILE';

	
	


DROP VIEW IF EXISTS "v_inp_temp_sn" CASCADE;
CREATE VIEW "v_inp_temp_sn" AS 
SELECT 
'SNOWMELT'::text AS type_tesn, 
inp_snowmelt.stemp, 
inp_snowmelt.atiwt, 
inp_snowmelt.rnm, 
inp_snowmelt.elev, 
inp_snowmelt.lat, 
inp_snowmelt.dtlong, 
'ADC IMPERVIOUS'::text AS type_teai, 
inp_snowmelt.i_f0, 
inp_snowmelt.i_f1, 
inp_snowmelt.i_f2, 
inp_snowmelt.i_f3, 
inp_snowmelt.i_f4, 
inp_snowmelt.i_f5, 
inp_snowmelt.i_f6, 
inp_snowmelt.i_f7, 
inp_snowmelt.i_f8, 
inp_snowmelt.i_f9, 
'ADC PERVIOUS'::text AS type_teap, 
inp_snowmelt.p_f0, 
inp_snowmelt.p_f1, 
inp_snowmelt.p_f2, 
inp_snowmelt.p_f3, 
inp_snowmelt.p_f4, 
inp_snowmelt.p_f5, 
inp_snowmelt.p_f6, 
inp_snowmelt.p_f7, 
inp_snowmelt.p_f8, 
inp_snowmelt.p_f9 
FROM inp_snowmelt;





DROP VIEW IF EXISTS "v_inp_temp_ts" CASCADE;
CREATE VIEW "v_inp_temp_ts" AS 
SELECT 
inp_temperature.temp_type AS type_tets, 
inp_temperature.timser_id 
FROM inp_temperature 
	WHERE inp_temperature.temp_type='TIMESERIES';


	
	

DROP VIEW IF EXISTS "v_inp_temp_wf" CASCADE;
CREATE VIEW "v_inp_temp_wf" AS 
SELECT 
'WINDSPEED'::text AS type_tews, 
inp_windspeed.wind_type AS type_tefl, 
inp_windspeed.fname 
FROM inp_windspeed 
	WHERE inp_windspeed.wind_type ='FILE';


	
	

DROP VIEW IF EXISTS "v_inp_temp_wm" CASCADE;
CREATE VIEW "v_inp_temp_wm" AS 
SELECT 
'WINDSPEED'::text AS type_tews, 
inp_windspeed.wind_type AS type_temo, 
inp_windspeed.value_1, 
inp_windspeed.value_2, 
inp_windspeed.value_3, 
inp_windspeed.value_4, 
inp_windspeed.value_5, 
inp_windspeed.value_6, 
inp_windspeed.value_7, 
inp_windspeed.value_8, 
inp_windspeed.value_9, 
inp_windspeed.value_10, 
inp_windspeed.value_11, 
inp_windspeed.value_12 
FROM inp_windspeed 
	WHERE inp_windspeed.wind_type='MONTHLY';


	
	

DROP VIEW IF EXISTS "v_inp_timser_abs" CASCADE;
CREATE VIEW "v_inp_timser_abs" AS 
SELECT 
inp_timeseries.timser_id, 
inp_timeseries.date, 
inp_timeseries.hour, 
inp_timeseries.value 
FROM inp_timeseries 
	JOIN inp_timser_id ON inp_timeseries.timser_id=inp_timser_id.id 
	WHERE inp_timser_id.times_type='ABSOLUTE'
	ORDER BY inp_timeseries.id;



DROP VIEW IF EXISTS "v_inp_timser_fl" CASCADE;
CREATE VIEW "v_inp_timser_fl" AS 
SELECT 
inp_timeseries.timser_id, 
'FILE'::text AS type_times, 
inp_timeseries.fname 
FROM inp_timeseries 
	JOIN inp_timser_id ON inp_timeseries.timser_id=inp_timser_id.id
	WHERE inp_timser_id.times_type='FILE';

	
	

DROP VIEW IF EXISTS "v_inp_timser_rel" CASCADE;
CREATE VIEW "v_inp_timser_rel" AS 
SELECT 
inp_timeseries.timser_id, 
inp_timeseries."time", 
inp_timeseries.value 
FROM inp_timeseries 
	JOIN inp_timser_id ON inp_timeseries.timser_id=inp_timser_id.id
	WHERE inp_timser_id.times_type='RELATIVE'
	ORDER BY inp_timeseries.id;


	

DROP VIEW IF EXISTS "v_inp_transects" CASCADE;
CREATE VIEW "v_inp_transects" AS 
SELECT 
inp_transects.id, 
inp_transects.text 
FROM inp_transects 
	ORDER BY inp_transects.id;



	
DROP VIEW IF EXISTS "v_inp_washoff" CASCADE;
CREATE VIEW "v_inp_washoff" AS 
SELECT 
inp_washoff_land_x_pol.landus_id, 
inp_washoff_land_x_pol.poll_id, 
inp_washoff_land_x_pol.funcw_type, 
inp_washoff_land_x_pol.c1, 
inp_washoff_land_x_pol.c2, 
inp_washoff_land_x_pol.sweepeffic, 
inp_washoff_land_x_pol.bmpeffic 
FROM inp_washoff_land_x_pol;




-- ----------------------------
-- View structure for exploitation entinties (raingage)
-- ----------------------------


DROP VIEW IF EXISTS "v_inp_rgage_fl" CASCADE;
CREATE VIEW "v_inp_rgage_fl" AS 
SELECT 
rg_id, 
form_type, 
intvl, 
scf, 
rgage_type AS type_rgfl, 
fname, 
sta, 
units, 
(st_x(the_geom))::numeric(16,3) AS xcoord, 
(st_y(the_geom))::numeric(16,3) AS ycoord 
FROM v_edit_raingage
	WHERE rgage_type='FILE';



	
DROP VIEW IF EXISTS "v_inp_rgage_ts" CASCADE;
CREATE VIEW "v_inp_rgage_ts" AS 
SELECT rg_id, 
form_type, 
intvl, 
scf, 
rgage_type AS type_rgts, 
timser_id, 
(st_x(the_geom))::numeric(16,3) AS xcoord, 
(st_y(the_geom))::numeric(16,3) AS ycoord 
FROM v_edit_raingage
	WHERE rgage_type ='TIMESERIES';




-- ----------------------------
-- View structure for subcatchments
-- ----------------------------
DROP VIEW IF EXISTS "v_inp_infiltration_cu" CASCADE;
CREATE VIEW "v_inp_infiltration_cu" AS 
SELECT 
subc_id,
curveno,
conduct_2,
drytime_2
FROM v_edit_subcatchment
	JOIN cat_hydrology ON cat_hydrology.hydrology_id=v_edit_subcatchment.hydrology_id
	WHERE cat_hydrology.infiltration='CURVE_NUMBER';



DROP VIEW IF EXISTS "v_inp_infiltration_gr" CASCADE;
CREATE VIEW "v_inp_infiltration_gr" AS 
SELECT
subc_id, 
suction, 
conduct, 
initdef 
FROM v_edit_subcatchment
	JOIN cat_hydrology ON cat_hydrology.hydrology_id=v_edit_subcatchment.hydrology_id
	WHERE cat_hydrology.infiltration='GREEN_AMPT';



DROP VIEW IF EXISTS "v_inp_infiltration_ho" CASCADE;
CREATE VIEW "v_inp_infiltration_ho" AS 
SELECT 
subc_id, 
maxrate, 
minrate, 
decay, 
drytime, 
maxinfil
FROM v_edit_subcatchment
	JOIN cat_hydrology ON cat_hydrology.hydrology_id=v_edit_subcatchment.hydrology_id
	WHERE cat_hydrology.infiltration='MODIFIED_HORTON' 
	OR cat_hydrology.infiltration ='HORTON';



DROP VIEW IF EXISTS "v_inp_subcatch" CASCADE;
CREATE VIEW "v_inp_subcatch" AS 
SELECT 
subc_id, 
node_id, 
rg_id, 
area, 
imperv, 
width, 
slope, 
clength, 
snow_id, 
nimp, 
nperv, 
simp, 
sperv, 
zero, 
routeto, 
rted
FROM v_edit_subcatchment;



DROP VIEW IF EXISTS "v_inp_lidusage" CASCADE;
CREATE VIEW "v_inp_lidusage" AS 
SELECT 
inp_lidusage_subc_x_lidco.subc_id, 
inp_lidusage_subc_x_lidco.lidco_id, 
inp_lidusage_subc_x_lidco."number"::integer, 
inp_lidusage_subc_x_lidco.area, 
inp_lidusage_subc_x_lidco.width, 
inp_lidusage_subc_x_lidco.initsat, 
inp_lidusage_subc_x_lidco.fromimp, 
inp_lidusage_subc_x_lidco.toperv::integer, 
inp_lidusage_subc_x_lidco.rptfile 
FROM v_edit_subcatchment
	JOIN inp_lidusage_subc_x_lidco ON inp_lidusage_subc_x_lidco.subc_id=v_edit_subcatchment.subc_id;




DROP VIEW IF EXISTS "v_inp_groundwater" CASCADE;
CREATE VIEW "v_inp_groundwater" AS 
SELECT 
inp_groundwater.subc_id, 
inp_groundwater.aquif_id, 
inp_groundwater.node_id, 
inp_groundwater.surfel, 
inp_groundwater.a1, 
inp_groundwater.b1, 
inp_groundwater.a2, 
inp_groundwater.b2, 
inp_groundwater.a3, 
inp_groundwater.tw, 
inp_groundwater.h, 
'LATERAL' || ' ' || (inp_groundwater.fl_eq_lat) AS fl_eq_lat, 
'DEEP' || ' ' || (inp_groundwater.fl_eq_lat) AS fl_eq_deep
FROM v_edit_subcatchment
	JOIN inp_groundwater ON inp_groundwater.subc_id=v_edit_subcatchment.subc_id;

	


DROP VIEW IF EXISTS "v_inp_coverages" CASCADE;
CREATE VIEW "v_inp_coverages" AS 
SELECT 
v_edit_subcatchment.subc_id, 
inp_coverage_land_x_subc.landus_id, 
inp_coverage_land_x_subc.percent
FROM inp_coverage_land_x_subc 
	JOIN v_edit_subcatchment ON inp_coverage_land_x_subc.subc_id = v_edit_subcatchment.subc_id;


	

DROP VIEW IF EXISTS "v_inp_loadings" CASCADE;
CREATE VIEW "v_inp_loadings" AS 
SELECT 
inp_loadings_pol_x_subc.poll_id, 
inp_loadings_pol_x_subc.subc_id, 
inp_loadings_pol_x_subc.ibuildup
FROM v_edit_subcatchment 
	JOIN inp_loadings_pol_x_subc ON inp_loadings_pol_x_subc.subc_id=v_edit_subcatchment.subc_id;




-- ------------------------------------------------------------------
-- View structure for arc elements
-- ------------------------------------------------------------------


DROP VIEW IF EXISTS "v_inp_conduit_cu" CASCADE;
CREATE OR REPLACE VIEW v_inp_conduit_cu AS 
SELECT 
rpt_inp_arc.arc_id,
node_1,
node_2,
elevmax1 as z1,
elevmax2 as z2,
cat_arc_shape.epa as shape,
cat_arc_shape.curve_id,
cat_arc.geom1,
cat_arc.geom2,
cat_arc.geom3,
cat_arc.geom4,
n,
length,
inp_conduit.q0,
inp_conduit.qmax,
inp_conduit.barrels,
inp_conduit.culvert,
inp_conduit.seepage
FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id = inp_conduit.arc_id
     JOIN cat_arc ON rpt_inp_arc.arccat_id = cat_arc.id
	 JOIN cat_arc_shape ON cat_arc_shape.id=cat_arc.shape
     WHERE cat_arc_shape.epa = 'CUSTOM'
     AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_conduit_no" CASCADE;
CREATE OR REPLACE VIEW v_inp_conduit_no AS 
SELECT rpt_inp_arc.arc_id,
node_1,
node_2,
elevmax1 as z1,
elevmax2 as z2,
cat_arc_shape.epa as shape,
cat_arc_shape.curve_id,
cat_arc.geom1,
cat_arc.geom2,
cat_arc.geom3,
cat_arc.geom4,
length,
n,
inp_conduit.q0,
inp_conduit.qmax,
inp_conduit.barrels,
inp_conduit.culvert,
inp_conduit.seepage
FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id = inp_conduit.arc_id
     JOIN cat_arc ON rpt_inp_arc.arccat_id = cat_arc.id
	 JOIN cat_arc_shape ON cat_arc_shape.id=cat_arc.shape
     WHERE cat_arc_shape.epa!='CUSTOM' AND cat_arc_shape.epa!='IRREGULAR'
	 AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();



DROP VIEW IF EXISTS "v_inp_conduit_xs" CASCADE;
CREATE OR REPLACE VIEW v_inp_conduit_xs AS 
SELECT
rpt_inp_arc.arc_id,
node_1,
node_2,
elevmax1 as z1,
elevmax2 as z2,
cat_arc_shape.epa as shape,
cat_arc_shape.tsect_id,
cat_arc.geom1,
cat_arc.geom2,
cat_arc.geom3,
cat_arc.geom4,
length,
n,
inp_conduit.q0,
inp_conduit.qmax,
inp_conduit.barrels,
inp_conduit.culvert,
inp_conduit.seepage
FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id = inp_conduit.arc_id
     JOIN cat_arc ON rpt_inp_arc.arccat_id = cat_arc.id
	 JOIN cat_arc_shape ON cat_arc_shape.id=cat_arc.shape
     WHERE cat_arc_shape.epa = 'IRREGULAR'
	 AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();


	 

DROP VIEW IF EXISTS "v_inp_orifice" CASCADE;
CREATE VIEW "v_inp_orifice" AS 
SELECT 
inp_orifice.arc_id, 
node_1,
node_2,
inp_orifice.ori_type, 
inp_orifice."offset", 
inp_orifice.cd, 
inp_orifice.flap, 
inp_orifice.orate, 
inp_orifice.shape, 
inp_orifice.geom1,
inp_orifice.geom2, 
inp_orifice.geom3, 
inp_orifice.geom4
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_orifice ON inp_orifice.arc_id = rpt_inp_arc.arc_id
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_orifice.ori_type, 
inp_flwreg_orifice."offset", 
inp_flwreg_orifice.cd, 
inp_flwreg_orifice.flap, 
inp_flwreg_orifice.orate, 
inp_flwreg_orifice.shape, 
inp_flwreg_orifice.geom1,
inp_flwreg_orifice.geom2, 
inp_flwreg_orifice.geom3, 
inp_flwreg_orifice.geom4
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_orifice ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_ori_', flwreg_id)
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();


	

DROP VIEW IF EXISTS "v_inp_outlet_fcd" CASCADE;
CREATE VIEW "v_inp_outlet_fcd" AS 
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_outlet.outlet_type AS type_oufcd, 
inp_outlet."offset", 
inp_outlet.cd1, 
inp_outlet.cd2, 
inp_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_outlet ON rpt_inp_arc.arc_id = inp_outlet.arc_id
	WHERE inp_outlet.outlet_type = 'FUNCTIONAL/DEPTH'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_outlet.outlet_type AS type_oufcd, 
inp_flwreg_outlet."offset", 
inp_flwreg_outlet.cd1, 
inp_flwreg_outlet.cd2, 
inp_flwreg_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_out_', flwreg_id)
	WHERE inp_flwreg_outlet.outlet_type = 'FUNCTIONAL/DEPTH'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();

	

DROP VIEW IF EXISTS "v_inp_outlet_fch" CASCADE;
CREATE VIEW "v_inp_outlet_fch" AS 
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_outlet.outlet_type AS type_oufch, 
inp_outlet."offset", 
inp_outlet.cd1, 
inp_outlet.cd2, 
inp_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_outlet ON rpt_inp_arc.arc_id = inp_outlet.arc_id
	WHERE inp_outlet.outlet_type='FUNCTIONAL/HEAD'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_outlet.outlet_type AS type_oufch, 
inp_flwreg_outlet."offset", 
inp_flwreg_outlet.cd1, 
inp_flwreg_outlet.cd2, 
inp_flwreg_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_out_', flwreg_id)
	WHERE inp_flwreg_outlet.outlet_type='FUNCTIONAL/HEAD'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();

	

	
DROP VIEW IF EXISTS "v_inp_outlet_tbd" CASCADE;
CREATE VIEW "v_inp_outlet_tbd" AS 
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_outlet.outlet_type AS type_outbd, 
inp_outlet."offset", 
inp_outlet.curve_id, 
inp_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_outlet ON rpt_inp_arc.arc_id = inp_outlet.arc_id
	WHERE inp_outlet.outlet_type='TABULAR/DEPTH'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_outlet.outlet_type AS type_outbd, 
inp_flwreg_outlet."offset", 
inp_flwreg_outlet.curve_id, 
inp_flwreg_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_out_', flwreg_id)
	WHERE inp_flwreg_outlet.outlet_type='TABULAR/DEPTH'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();

	


	

DROP VIEW IF EXISTS "v_inp_outlet_tbh" CASCADE;
CREATE VIEW "v_inp_outlet_tbh" AS 
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_outlet.outlet_type AS type_outbh, 
inp_outlet."offset", 
inp_outlet.curve_id, 
inp_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_outlet ON rpt_inp_arc.arc_id = inp_outlet.arc_id
	WHERE inp_outlet.outlet_type ='TABULAR/HEAD'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_outlet.outlet_type AS type_outbh, 
inp_flwreg_outlet."offset", 
inp_flwreg_outlet.curve_id, 
inp_flwreg_outlet.flap
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_out_', flwreg_id)
	WHERE inp_flwreg_outlet.outlet_type ='TABULAR/HEAD'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();

	

	
	
DROP VIEW IF EXISTS "v_inp_pump" CASCADE;
CREATE VIEW "v_inp_pump" AS 
SELECT 
rpt_inp_arc.arc_id,
rpt_inp_arc.node_1,
rpt_inp_arc.node_2,
inp_pump.curve_id,
inp_pump.status,
inp_pump.startup,
inp_pump.shutoff
FROM inp_selector_result, rpt_inp_arc 
	JOIN inp_pump ON rpt_inp_arc.arc_id::text = inp_pump.arc_id::text	
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id,
rpt_inp_arc.node_1,
rpt_inp_arc.node_2,
inp_flwreg_pump.curve_id,
inp_flwreg_pump.status,
inp_flwreg_pump.startup,
inp_flwreg_pump.shutoff
FROM inp_selector_result, rpt_inp_arc 
	JOIN inp_flwreg_pump ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_pump_', flwreg_id)
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();


	

DROP VIEW IF EXISTS "v_inp_weir" CASCADE;
CREATE VIEW "v_inp_weir" AS 
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_weir.weir_type, 
inp_weir."offset", 
inp_weir.cd, 
inp_weir.flap, 
inp_weir.ec, 
inp_weir.cd2, 
inp_typevalue.idval as shape, 
inp_weir.geom1, 
inp_weir.geom2, 
inp_weir.geom3, 
inp_weir.geom4, 
inp_weir.surcharge
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_weir ON inp_weir.arc_id = rpt_inp_arc.arc_id
	JOIN inp_typevalue ON inp_weir.weir_type = inp_typevalue.id and inp_typevalue.typevalue='inp_value_weirs'
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()
UNION
SELECT 
rpt_inp_arc.arc_id, 
node_1,
node_2,
inp_flwreg_weir.weir_type, 
inp_flwreg_weir."offset", 
inp_flwreg_weir.cd, 
inp_flwreg_weir.flap, 
inp_flwreg_weir.ec, 
inp_flwreg_weir.cd2, 
inp_typevalue.idval as shape,
inp_flwreg_weir.geom1, 
inp_flwreg_weir.geom2, 
inp_flwreg_weir.geom3, 
inp_flwreg_weir.geom4, 
inp_flwreg_weir.surcharge
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_flwreg_weir ON rpt_inp_arc.flw_code = concat(node_id,'_', to_arc,'_weir_', flwreg_id)
	JOIN inp_typevalue ON inp_flwreg_weir.weir_type = inp_typevalue.id and inp_typevalue.typevalue='inp_value_weirs'
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();

	



DROP VIEW IF EXISTS "v_inp_losses" CASCADE;
CREATE VIEW "v_inp_losses" AS 
SELECT 
inp_conduit.arc_id, 
inp_conduit.kentry, 
inp_conduit.kexit, 
inp_conduit.kavg, 
inp_conduit.flap, 
inp_conduit.seepage
FROM inp_selector_result, rpt_inp_arc
	JOIN inp_conduit ON rpt_inp_arc.arc_id = inp_conduit.arc_id
	WHERE inp_conduit.kentry > (0)::numeric OR (inp_conduit.kexit > (0)::numeric) OR (inp_conduit.kavg > (0)::numeric) OR inp_conduit.flap='YES'
	AND rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();





-- ------------------------------------------------------------------
-- View structure for node elements
-- ----------------------------------------------------------------

DROP VIEW IF EXISTS "v_inp_junction" CASCADE;
CREATE VIEW "v_inp_junction" AS 
SELECT 
node_id, 
top_elev,
elev,
ymax,
y0, 
ysur, 
apond,
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	WHERE rpt_inp_node.epa_type='JUNCTION'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_divider_cu" CASCADE;
CREATE VIEW "v_inp_divider_cu" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_divider.arc_id, 
inp_divider.divider_type AS type_dicu, 
inp_divider.qmin, 
inp_divider.y0, 
inp_divider.ysur, 
inp_divider.apond, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_divider ON rpt_inp_node.node_id = inp_divider.node_id 
	WHERE inp_divider.divider_type ='CUTOFF'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_divider_ov" CASCADE;
CREATE VIEW "v_inp_divider_ov" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_divider.divider_type AS type_diov,
inp_divider.y0, 
inp_divider.ysur, 
inp_divider.apond, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_divider ON rpt_inp_node.node_id = inp_divider.node_id
	WHERE inp_divider.divider_type='OVERFLOW'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_divider_tb" CASCADE;
CREATE VIEW "v_inp_divider_tb" AS 
SELECT
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_divider.arc_id, 
inp_divider.divider_type AS type_ditb, 
inp_divider.curve_id, 
inp_divider.y0, 
inp_divider.ysur, 
inp_divider.apond, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_divider ON rpt_inp_node.node_id = inp_divider.node_id
	WHERE inp_divider.divider_type='TABULAR'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_divider_wr" CASCADE;
CREATE VIEW "v_inp_divider_wr" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_divider.arc_id, 
inp_divider.divider_type AS type_diwr,
inp_divider.qmin, 
inp_divider.ht, 
inp_divider.cd, 
inp_divider.y0, 
inp_divider.ysur, 
inp_divider.apond,
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_divider ON rpt_inp_node.node_id = inp_divider.node_id
	WHERE inp_divider.divider_type='WEIR'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_outfall_fi" CASCADE;
CREATE VIEW "v_inp_outfall_fi" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax, 
inp_outfall.outfall_type AS type_otlfi, 
inp_outfall.stage, 
inp_outfall.gate, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_outfall ON inp_outfall.node_id = rpt_inp_node.node_id
	WHERE inp_outfall.outfall_type='FIXED'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_outfall_fr" CASCADE;
CREATE VIEW "v_inp_outfall_fr" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_outfall.outfall_type AS type_otlfr, 
inp_outfall.gate, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_outfall ON rpt_inp_node.node_id = inp_outfall.node_id
	WHERE inp_outfall.outfall_type='FREE'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_outfall_nm" CASCADE;
CREATE VIEW "v_inp_outfall_nm" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_outfall.outfall_type AS type_otlnm, 
inp_outfall.gate, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_outfall ON rpt_inp_node.node_id = inp_outfall.node_id
	WHERE inp_outfall.outfall_type='NORMAL'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_outfall_ti" CASCADE;
CREATE VIEW "v_inp_outfall_ti" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_outfall.outfall_type AS type_otlti, 
inp_outfall.curve_id, 
inp_outfall.gate, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_outfall ON rpt_inp_node.node_id = inp_outfall.node_id
	WHERE inp_outfall.outfall_type='TIDAL'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_outfall_ts" CASCADE;
CREATE VIEW "v_inp_outfall_ts" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_outfall.outfall_type AS type_otlts, 
inp_outfall.timser_id, 
inp_outfall.gate, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_outfall ON rpt_inp_node.node_id = inp_outfall.node_id
	WHERE inp_outfall.outfall_type='TIMESERIES'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_storage_fc" CASCADE;
CREATE VIEW "v_inp_storage_fc" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_storage.y0, 
inp_storage.storage_type AS type_stfc,
inp_storage.a1, 
inp_storage.a2, 
inp_storage.a0, 
inp_storage.apond, 
inp_storage.fevap, 
inp_storage.sh, 
inp_storage.hc, 
inp_storage.imd, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_storage ON rpt_inp_node.node_id = inp_storage.node_id
	WHERE inp_storage.storage_type='FUNCTIONAL'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();



DROP VIEW IF EXISTS "v_inp_storage_tb" CASCADE;
CREATE VIEW "v_inp_storage_tb" AS 
SELECT 
rpt_inp_node.node_id, 
top_elev,
elev,
ymax,
inp_storage.y0, 
inp_storage.storage_type AS type_sttb, 
inp_storage.curve_id, 
inp_storage.apond, 
inp_storage.fevap, 
inp_storage.sh, 
inp_storage.hc, 
inp_storage.imd, 
(st_x(rpt_inp_node.the_geom))::numeric(16,3) AS xcoord, 
(st_y(rpt_inp_node.the_geom))::numeric(16,3) AS ycoord
FROM inp_selector_result, rpt_inp_node
	JOIN inp_storage ON rpt_inp_node.node_id = inp_storage.node_id
	WHERE inp_storage.storage_type='TABULAR'
	AND rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_dwf_flow" CASCADE;
CREATE VIEW "v_inp_dwf_flow" AS 
SELECT 
rpt_inp_node.node_id, 
'FLOW'::text AS type_dwf, 
inp_dwf.value, 
inp_dwf.pat1, 
inp_dwf.pat2, 
inp_dwf.pat3, 
inp_dwf.pat4 
FROM inp_selector_result, rpt_inp_node
	JOIN inp_dwf ON inp_dwf.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_dwf_load" CASCADE;
CREATE VIEW "v_inp_dwf_load" AS 
SELECT 
rpt_inp_node.node_id, 
inp_dwf_pol_x_node.poll_id, 
inp_dwf_pol_x_node.value, 
inp_dwf_pol_x_node.pat1, 
inp_dwf_pol_x_node.pat2, 
inp_dwf_pol_x_node.pat3, 
inp_dwf_pol_x_node.pat4
FROM inp_selector_result, rpt_inp_node
	JOIN inp_dwf_pol_x_node ON inp_dwf_pol_x_node.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();



DROP VIEW IF EXISTS "v_inp_inflows_flow" CASCADE;
CREATE VIEW "v_inp_inflows_flow" AS 
SELECT 
rpt_inp_node.node_id, 
'FLOW'::text AS type_flow1, 
inp_inflows.timser_id, 
'FLOW'::text AS type_flow2, 
'1'::text AS type_n1, 
inp_inflows.sfactor, 
inp_inflows.base, 
inp_inflows.pattern_id
FROM inp_selector_result, rpt_inp_node
	JOIN inp_inflows ON inp_inflows.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();



DROP VIEW IF EXISTS "v_inp_inflows_load" CASCADE;
CREATE VIEW "v_inp_inflows_load" AS 
SELECT 
rpt_inp_node.node_id, 
inp_inflows_pol_x_node.poll_id, 
inp_inflows_pol_x_node.timser_id, 
inp_inflows_pol_x_node.form_type, 
inp_inflows_pol_x_node.mfactor, 
inp_inflows_pol_x_node.sfactor, 
inp_inflows_pol_x_node.base, 
inp_inflows_pol_x_node.pattern_id
FROM inp_selector_result, rpt_inp_node
	JOIN inp_inflows_pol_x_node ON inp_inflows_pol_x_node.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_rdii" CASCADE;
CREATE VIEW "v_inp_rdii" AS 
SELECT 
rpt_inp_node.node_id, 
inp_rdii.hydro_id,
inp_rdii.sewerarea
FROM inp_selector_result, rpt_inp_node
	JOIN inp_rdii ON inp_rdii.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();




DROP VIEW IF EXISTS "v_inp_treatment" CASCADE;
CREATE VIEW "v_inp_treatment" AS 
SELECT 
rpt_inp_node.node_id, 
inp_treatment_node_x_pol.poll_id, 
inp_treatment_node_x_pol.function
FROM inp_selector_result, rpt_inp_node
	JOIN inp_treatment_node_x_pol ON inp_treatment_node_x_pol.node_id = rpt_inp_node.node_id
	WHERE rpt_inp_node.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"();






-- ----------------------------
-- View structure for v_vertice
-- ----------------------------

DROP VIEW IF EXISTS v_inp_vertice CASCADE;
CREATE OR REPLACE VIEW v_inp_vertice AS 
 SELECT 
 nextval('"SCHEMA_NAME".inp_vertice_seq'::regclass) AS id,
 arc.arc_id,
 st_x(arc.point)::numeric(16,3) AS xcoord,
 st_y(arc.point)::numeric(16,3) AS ycoord
 FROM 
	(SELECT (st_dumppoints(rpt_inp_arc.the_geom)).geom AS point,
            st_startpoint(rpt_inp_arc.the_geom) AS startpoint,
            st_endpoint(rpt_inp_arc.the_geom) AS endpoint,
            rpt_inp_arc.sector_id,
	    rpt_inp_arc."state",
            rpt_inp_arc.arc_id
	FROM inp_selector_result, rpt_inp_arc
	WHERE rpt_inp_arc.result_id=inp_selector_result.result_id AND inp_selector_result.cur_user="current_user"()) arc
	WHERE (arc.point < arc.startpoint OR arc.point > arc.startpoint) AND (arc.point < arc.endpoint OR arc.point > arc.endpoint)
	ORDER BY id;



-- ----------------------------
-- Direct views from tables
-- ----------------------------


DROP VIEW IF EXISTS "v_inp_project_id" CASCADE;
CREATE VIEW "v_inp_project_id" AS 
SELECT 
title,
author,
date
FROM inp_project_id
ORDER BY title;


DROP VIEW IF EXISTS "v_inp_backdrop" CASCADE;
CREATE VIEW "v_inp_backdrop" AS 
SELECT 
id,
text
FROM inp_backdrop
ORDER BY id; 



DROP VIEW IF EXISTS "v_inp_label" CASCADE;
CREATE VIEW "v_inp_label" AS 
SELECT 
label,
xcoord,
ycoord,
anchor,
font,
size,
bold,
italic 
FROM inp_label
ORDER BY label;



DROP VIEW IF EXISTS  "v_inp_mapdim" CASCADE;
CREATE VIEW  "v_inp_mapdim" AS 
SELECT 
type_dim,
x1,
y1,
x2,
y2
FROM inp_mapdim
ORDER BY type_dim;


DROP VIEW IF EXISTS  "v_inp_mapunits" CASCADE;
CREATE VIEW  "v_inp_mapunits" AS 
SELECT 
type_units,
map_type
FROM inp_mapunits
ORDER BY type_units;



DROP VIEW IF EXISTS  "v_inp_report" CASCADE;
CREATE VIEW  "v_inp_report" AS 
SELECT 
input,
continuity,
flowstats,
controls,
subcatchments,
nodes,
links
FROM inp_report
ORDER BY input;



DROP VIEW IF EXISTS  "v_inp_files" CASCADE;
CREATE VIEW  "v_inp_files" AS 
SELECT 
id,
actio_type,
file_type,
fname
FROM inp_files
ORDER BY id;



DROP VIEW IF EXISTS  "v_inp_aquifer" CASCADE;
CREATE VIEW  "v_inp_aquifer" AS 
SELECT 
aquif_id,
por,
wp,
fc,
k,
ks,
ps,
uef,
led,
gwr,
be,
wte,
umc,
pattern_id
FROM inp_aquifer
ORDER BY aquif_id;



DROP VIEW IF EXISTS  "v_inp_pollutant" CASCADE;
CREATE VIEW  "v_inp_pollutant" AS 
SELECT 
poll_id,
units_type,
crain,
cgw,
cii,
kd,
sflag,
copoll_id,
cofract,
cdwf
FROM inp_pollutant
ORDER BY poll_id;



DROP VIEW IF EXISTS  "v_inp_adjustments" CASCADE;
CREATE VIEW  "v_inp_adjustments" AS 
SELECT 
id,
adj_type,
value_1,
value_2,
value_3,
value_4,
value_5,
value_6,
value_7,
value_8,
value_9,
value_10,
value_11,
value_12
FROM inp_adjustments
ORDER BY id;




DROP VIEW IF EXISTS  "v_inp_subcatch2node" CASCADE;
CREATE OR REPLACE VIEW v_inp_subcatch2node AS 
SELECT 
subcatchment.subc_id,
st_makeline(st_centroid(subcatchment.the_geom), v_node.the_geom) AS the_geom
FROM v_edit_subcatchment subcatchment
   JOIN v_node ON v_node.node_id = subcatchment.node_id;



   
DROP VIEW IF EXISTS  "v_inp_subcatchcentroid" CASCADE;
CREATE OR REPLACE VIEW v_inp_subcatchcentroid AS 
SELECT 
subcatchment.subc_id,
st_centroid(subcatchment.the_geom) AS the_geom
FROM v_edit_subcatchment subcatchment;


*/


--new inp views

DROP VIEW IF EXISTS vi_title CASCADE;
CREATE OR REPLACE VIEW vi_title AS 
 SELECT inp_project_id.title,
    inp_project_id.date
   FROM inp_project_id
  ORDER BY inp_project_id.title;


DROP VIEW IF EXISTS vi_options CASCADE;
CREATE OR REPLACE VIEW vi_options AS 
SELECT
  unnest(array['flow_units','infiltration','flow_routing','link_offsets','force_main_equation','ignore_rainfall',
 'ignore_snowmelt','ignore_groundwater','ignore_routing','ignore_quality','skip_steady_state','start_date',
 'start_time','end_date','end_time','report_start_date','report_start_time','sweep_start','sweep_end',
 'dry_days','report_step','wet_step','dry_step','routing_step','lengthening_step','variable_step','inertial_damping',
 'normal_flow_limited','min_surfarea','min_slope','allow_ponding','tempdir','max_trials','head_tolerance',
 'sys_flow_tol','lat_flow_tol']) AS "parameter",
  unnest(array[flow_units,cat_hydrology.infiltration,flow_routing,link_offsets,force_main_equation,ignore_rainfall,
  ignore_snowmelt,ignore_groundwater, ignore_routing,ignore_quality,skip_steady_state,start_date,start_time,
  end_date,end_time,report_start_date,report_start_time,sweep_start,sweep_end,dry_days::text,report_step,
  wet_step,dry_step,routing_step,lengthening_step::text,variable_step::text,inertial_damping,
  normal_flow_limited,min_surfarea::text,min_slope::text,allow_ponding,tempdir,max_trials::text,
  head_tolerance::text,sys_flow_tol::text,lat_flow_tol::text]) AS "value"
FROM inp_options, inp_selector_hydrology
     JOIN cat_hydrology ON inp_selector_hydrology.hydrology_id = cat_hydrology.hydrology_id;


DROP VIEW IF EXISTS vi_report CASCADE;
CREATE OR REPLACE VIEW vi_report AS 
SELECT
   unnest(array['input', 'continuity', 'flowstats','controls','subcatchments','nodes','links']) AS "repor_type",
   unnest(array[input, continuity, flowstats, controls,subcatchments,nodes,links]) AS "value"
FROM inp_report;

DROP VIEW IF EXISTS  vi_files CASCADE;
CREATE OR REPLACE VIEW vi_files AS 
 SELECT
    inp_files.actio_type,
    inp_files.file_type,
    inp_files.fname
   FROM inp_files;


DROP VIEW IF EXISTS vi_evaporation CASCADE;
CREATE OR REPLACE VIEW vi_evaporation AS 
SELECT concat(inp_evaporation.evap_type,' ',inp_evaporation.evap) as other_val
   FROM inp_evaporation WHERE inp_evaporation.evap_type::text = 'CONSTANT'::text
 UNION
  SELECT concat('DRY_ONLY ',inp_evaporation.dry_only) as other_val
   FROM inp_evaporation
UNION
 SELECT concat(inp_evaporation.evap_type,' ',inp_evaporation.pan_1,' ',inp_evaporation.pan_2,' ',inp_evaporation.pan_3,' ',
    inp_evaporation.pan_4,' ',inp_evaporation.pan_5,' ',inp_evaporation.pan_6,' ',inp_evaporation.pan_7,' ',
    inp_evaporation.pan_8,' ',inp_evaporation.pan_9,' ',inp_evaporation.pan_10,' ',inp_evaporation.pan_11,' ',
    inp_evaporation.pan_12) as other_val
    FROM inp_evaporation
  WHERE inp_evaporation.evap_type::text = 'FILE'::text
UNION
 SELECT concat(inp_evaporation.evap_type,' ',inp_evaporation.value_1,' ',inp_evaporation.value_2,' ',
 	inp_evaporation.value_3,' ',inp_evaporation.value_4,' ',inp_evaporation.value_5,' ',
 	inp_evaporation.value_6,' ',inp_evaporation.value_7,' ',inp_evaporation.value_8,' ',
 	inp_evaporation.value_9,' ',inp_evaporation.value_10,' ',inp_evaporation.value_11,' ',
    inp_evaporation.value_12)
   FROM inp_evaporation
  WHERE inp_evaporation.evap_type::text = 'MONTHLY'::text
UNION
 SELECT concat('RECOVERY ',inp_evaporation.recovery)as other_val
   FROM inp_evaporation
  WHERE inp_evaporation.recovery::text > '0'::text
UNION
 SELECT inp_evaporation.evap_type as other_val
   FROM inp_evaporation
  WHERE inp_evaporation.evap_type::text = 'TEMPERATURE'::text
UNION
 SELECT concat(inp_evaporation.evap_type,' ',inp_evaporation.timser_id) as other_val
   FROM inp_evaporation
  WHERE inp_evaporation.evap_type::text = 'TIMESERIES'::text
 ORDER BY other_val;


DROP VIEW IF EXISTS  vi_raingages CASCADE;
CREATE OR REPLACE VIEW vi_raingages AS 
SELECT v_edit_raingage.rg_id,
    v_edit_raingage.form_type,
    v_edit_raingage.intvl,
    v_edit_raingage.scf,
    concat(v_edit_raingage.rgage_type,' ',v_edit_raingage.timser_id,' ',v_edit_raingage.fname,' ',
    	v_edit_raingage.sta,' ',v_edit_raingage.units) as other_val
   FROM v_edit_raingage;


DROP VIEW IF EXISTS vi_temperature CASCADE;
CREATE OR REPLACE VIEW vi_temperature AS 
 SELECT concat(inp_temperature.temp_type,' ',inp_temperature.fname,' ',inp_temperature.start) as other_val
   FROM inp_temperature
  WHERE inp_temperature.temp_type::text = 'FILE'::text
 UNION
  SELECT concat('SNOWMELT'::text,' ',inp_snowmelt.stemp,' ',inp_snowmelt.atiwt,' ',
    inp_snowmelt.rnm,' ',inp_snowmelt.elev,' ',inp_snowmelt.lat,inp_snowmelt.dtlong) as other_val
  FROM inp_snowmelt
 UNION
  SELECT concat('ADC IMPERVIOUS ',inp_snowmelt.i_f0,' ',inp_snowmelt.i_f1,' ',inp_snowmelt.i_f2,' ',
    inp_snowmelt.i_f3,' ',inp_snowmelt.i_f4,' ',inp_snowmelt.i_f5,' ',inp_snowmelt.i_f6,' ',
    inp_snowmelt.i_f7,' ',inp_snowmelt.i_f8,' ',inp_snowmelt.i_f9) as other_val
  FROM inp_snowmelt
 UNION
  SELECT concat('ADC PERVIOUS ',inp_snowmelt.p_f0,' ',inp_snowmelt.p_f1,' ',inp_snowmelt.p_f2,' ',
    inp_snowmelt.p_f3,' ',inp_snowmelt.p_f4,' ',inp_snowmelt.p_f5,' ',inp_snowmelt.p_f6,' ',
    inp_snowmelt.p_f7,' ',inp_snowmelt.p_f8,' ',inp_snowmelt.p_f9)as other_val
   FROM inp_snowmelt
 UNION
  SELECT concat(inp_temperature.temp_type,' ',inp_temperature.timser_id) as other_val
   FROM inp_temperature
  WHERE inp_temperature.temp_type::text = 'TIMESERIES'::text
UNION
 SELECT concat('WINDSPEED ',inp_windspeed.wind_type,' ',inp_windspeed.fname)
   FROM inp_windspeed
  WHERE inp_windspeed.wind_type::text = 'FILE'::text
UNION
   SELECT concat('WINDSPEED ',inp_windspeed.wind_type,' ',inp_windspeed.value_1,' ',
    inp_windspeed.value_2,' ',inp_windspeed.value_3,' ',inp_windspeed.value_4,' ',
    inp_windspeed.value_5,' ',inp_windspeed.value_6,' ',inp_windspeed.value_7,' ',
    inp_windspeed.value_8,' ',inp_windspeed.value_9,' ',inp_windspeed.value_10,' ',
    inp_windspeed.value_11,' ',inp_windspeed.value_12) as other_val
    FROM inp_windspeed
  WHERE inp_windspeed.wind_type::text = 'MONTHLY'::text
ORDER BY other_val;



DROP VIEW IF EXISTS  vi_subcatchments CASCADE;
CREATE OR REPLACE VIEW vi_subcatchments AS 
 SELECT v_edit_subcatchment.subc_id,
 	v_edit_subcatchment.rg_id,
    v_edit_subcatchment.node_id,
    v_edit_subcatchment.area,
    v_edit_subcatchment.imperv,
    v_edit_subcatchment.width,
    v_edit_subcatchment.slope,
    v_edit_subcatchment.clength,
	v_edit_subcatchment.snow_id
   FROM v_edit_subcatchment;


DROP VIEW IF EXISTS  vi_subareas CASCADE;
CREATE OR REPLACE VIEW vi_subareas AS 
 SELECT v_edit_subcatchment.subc_id,
    v_edit_subcatchment.nimp,
    v_edit_subcatchment.nperv,
    v_edit_subcatchment.simp,
    v_edit_subcatchment.sperv,
    v_edit_subcatchment.zero,
    v_edit_subcatchment.routeto,
    v_edit_subcatchment.rted
   FROM v_edit_subcatchment;




DROP VIEW IF EXISTS  vi_infiltration CASCADE;
CREATE OR REPLACE VIEW vi_infiltration AS 
 SELECT v_edit_subcatchment.subc_id,concat(v_edit_subcatchment.curveno,' ',v_edit_subcatchment.conduct_2,' ',
 	v_edit_subcatchment.drytime_2) as other_val
   FROM v_edit_subcatchment
     JOIN cat_hydrology ON cat_hydrology.hydrology_id = v_edit_subcatchment.hydrology_id
  WHERE cat_hydrology.infiltration::text = 'CURVE_NUMBER'::text
UNION
  SELECT v_edit_subcatchment.subc_id, concat(v_edit_subcatchment.suction,' ',v_edit_subcatchment.conduct,' ',
  	v_edit_subcatchment.initdef) as other_val
   FROM v_edit_subcatchment
     JOIN cat_hydrology ON cat_hydrology.hydrology_id = v_edit_subcatchment.hydrology_id
  WHERE cat_hydrology.infiltration::text = 'GREEN_AMPT'::text
UNION
 SELECT v_edit_subcatchment.subc_id,concat(v_edit_subcatchment.maxrate,' ',v_edit_subcatchment.minrate,' ',
 	v_edit_subcatchment.decay,' ', v_edit_subcatchment.drytime,' ',v_edit_subcatchment.maxinfil) as other_val
   FROM v_edit_subcatchment
     JOIN cat_hydrology ON cat_hydrology.hydrology_id = v_edit_subcatchment.hydrology_id
  WHERE cat_hydrology.infiltration::text = 'MODIFIED_HORTON'::text OR cat_hydrology.infiltration::text = 'HORTON'::text
 ORDER BY other_val;


DROP VIEW IF EXISTS vi_aquifers CASCADE;
CREATE OR REPLACE VIEW vi_aquifers AS 
 SELECT inp_aquifer.aquif_id,
    inp_aquifer.por,
    inp_aquifer.wp,
    inp_aquifer.fc,
    inp_aquifer.k,
    inp_aquifer.ks,
    inp_aquifer.ps,
    inp_aquifer.uef,
    inp_aquifer.led,
    inp_aquifer.gwr,
    inp_aquifer.be,
    inp_aquifer.wte,
    inp_aquifer.umc,
    inp_aquifer.pattern_id
   FROM inp_aquifer
  ORDER BY inp_aquifer.aquif_id;


DROP VIEW IF EXISTS  vi_groundwater CASCADE;
CREATE OR REPLACE VIEW vi_groundwater AS 
 SELECT inp_groundwater.subc_id,
    inp_groundwater.aquif_id,
    inp_groundwater.node_id,
    inp_groundwater.surfel,
    inp_groundwater.a1,
    inp_groundwater.b1,
    inp_groundwater.a2,
    inp_groundwater.b2,
    inp_groundwater.a3,
    inp_groundwater.tw,
    inp_groundwater.h
   FROM v_edit_subcatchment
     JOIN inp_groundwater ON inp_groundwater.subc_id::text = v_edit_subcatchment.subc_id::text;


DROP VIEW IF EXISTS  vi_gwf CASCADE;
CREATE OR REPLACE VIEW vi_gwf AS 
 SELECT inp_groundwater.subc_id,
    ('LATERAL'::text || ' '::text) || inp_groundwater.fl_eq_lat::text AS fl_eq_lat,
    ('DEEP'::text || ' '::text) || inp_groundwater.fl_eq_lat::text AS fl_eq_deep
 FROM v_edit_subcatchment
 JOIN inp_groundwater ON inp_groundwater.subc_id::text = v_edit_subcatchment.subc_id::text;



DROP VIEW IF EXISTS  vi_snowpacks CASCADE;
CREATE OR REPLACE VIEW vi_snowpacks AS 
 SELECT inp_snowpack.snow_id,
    'PLOWABLE'::text AS type,
    concat(inp_snowpack.cmin_1,' ',inp_snowpack.cmax_1,' ',inp_snowpack.tbase_1,' ',
    inp_snowpack.fwf_1,' ',inp_snowpack.sd0_1,' ',inp_snowpack.fw0_1,' ',inp_snowpack.snn0_1) as other_val
   FROM inp_snowpack 
 UNION
 SELECT inp_snowpack.snow_id,
    'IMPERVIOUS'::text AS type,
    concat(inp_snowpack.cmin_2,' ',inp_snowpack.cmax_2,' ',inp_snowpack.tbase_2,' ',inp_snowpack.fwf_2,' ',
    	inp_snowpack.sd0_2,' ',inp_snowpack.fw0_2,' ',inp_snowpack.sd100_1) as other_val
   FROM inp_snowpack
 UNION
 SELECT inp_snowpack.snow_id,
    'PERVIOUS'::text AS type,
    concat(inp_snowpack.cmin_3,' ',inp_snowpack.cmax_3,' ',inp_snowpack.tbase_3,' ',inp_snowpack.fwf_3,' ',
    	inp_snowpack.sd0_3,' ',inp_snowpack.fw0_3,' ',inp_snowpack.sd100_2) as other_val
   FROM inp_snowpack
 UNION
 SELECT inp_snowpack.snow_id,
    'REMOVAL'::text AS type,
    concat(inp_snowpack.sdplow,' ',inp_snowpack.fout,' ',inp_snowpack.fimp,' ',inp_snowpack.fperv,' ',
    	inp_snowpack.fimelt,' ',inp_snowpack.fsub,' ',inp_snowpack.subc_id)
   FROM inp_snowpack
 ORDER BY 1,2;


DROP VIEW IF EXISTS  vi_junction CASCADE;
CREATE OR REPLACE VIEW vi_junction AS 
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    rpt_inp_node.ymax,
    rpt_inp_node.y0,
    rpt_inp_node.ysur,
    rpt_inp_node.apond
   FROM inp_selector_result,rpt_inp_node
   WHERE rpt_inp_node.epa_type::text = 'JUNCTION'::text 
   AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
   AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_outfalls CASCADE;
CREATE OR REPLACE VIEW vi_outfalls AS 
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_outfall.outfall_type,
    concat(inp_outfall.stage,' ', inp_outfall.gate) AS other_val
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_outfall ON inp_outfall.node_id::text = rpt_inp_node.node_id::text
  WHERE inp_outfall.outfall_type::text = 'FIXED'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_outfall.outfall_type,
    inp_outfall.gate AS other_val	
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_outfall ON rpt_inp_node.node_id::text = inp_outfall.node_id::text
  WHERE inp_outfall.outfall_type::text = 'FREE'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_outfall.outfall_type,
    inp_outfall.gate AS other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_outfall ON rpt_inp_node.node_id::text = inp_outfall.node_id::text
  WHERE inp_outfall.outfall_type::text = 'NORMAL'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_outfall.outfall_type,
    concat(inp_outfall.curve_id,' ',inp_outfall.gate) AS other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_outfall ON rpt_inp_node.node_id::text = inp_outfall.node_id::text
  WHERE inp_outfall.outfall_type::text = 'TIDAL'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
  SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_outfall.outfall_type,
    concat(inp_outfall.timser_id,' ',inp_outfall.gate) AS other_val
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_outfall ON rpt_inp_node.node_id::text = inp_outfall.node_id::text
  WHERE inp_outfall.outfall_type::text = 'TIMESERIES'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_dividers CASCADE;
CREATE OR REPLACE VIEW vi_dividers AS 
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_divider.arc_id,
    inp_divider.divider_type,
    concat(inp_divider.qmin,' ',inp_divider.y0,' ',inp_divider.ysur,' ',inp_divider.apond) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_divider ON rpt_inp_node.node_id::text = inp_divider.node_id::text
  WHERE inp_divider.divider_type::text = 'CUTOFF'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_divider.arc_id,
    inp_divider.divider_type,
    concat(inp_divider.y0,' ',inp_divider.ysur,' ',inp_divider.apond) as other_val
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_divider ON rpt_inp_node.node_id::text = inp_divider.node_id::text
  WHERE inp_divider.divider_type::text = 'OVERFLOW'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
  SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_divider.arc_id,
    inp_divider.divider_type,
    concat(inp_divider.curve_id,' ',inp_divider.y0,' ',inp_divider.ysur,' ',inp_divider.apond) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_divider ON rpt_inp_node.node_id::text = inp_divider.node_id::text
  WHERE inp_divider.divider_type::text = 'TABULAR'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    inp_divider.arc_id,
    inp_divider.divider_type,
    concat(inp_divider.qmin,' ',inp_divider.ht,' ',inp_divider.cd,' ',inp_divider.y0,' ',inp_divider.ysur,' ',
    	inp_divider.apond) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_divider ON rpt_inp_node.node_id::text = inp_divider.node_id::text
  WHERE inp_divider.divider_type::text = 'WEIR'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_storage CASCADE;
CREATE OR REPLACE VIEW vi_storage AS 
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    rpt_inp_node.ymax,
    inp_storage.y0,
    inp_storage.storage_type,
    concat(inp_storage.a1,' ',inp_storage.a2,' ',inp_storage.a0,' ',inp_storage.apond,' ',
    	inp_storage.fevap,' ',inp_storage.sh,' ',inp_storage.hc,' ',inp_storage.imd) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_storage ON rpt_inp_node.node_id::text = inp_storage.node_id::text
  WHERE inp_storage.storage_type::text = 'FUNCTIONAL'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    rpt_inp_node.elev,
    rpt_inp_node.ymax,
    inp_storage.y0,
    inp_storage.storage_type,
    concat(inp_storage.curve_id,' ',inp_storage.apond,' ',inp_storage.fevap,' ',inp_storage.sh,' ',
    	inp_storage.hc,' ',inp_storage.imd) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_storage ON rpt_inp_node.node_id::text = inp_storage.node_id::text
  WHERE inp_storage.storage_type::text = 'TABULAR'::text 
  AND rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_conduits CASCADE;
CREATE OR REPLACE VIEW vi_conduits AS 
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    rpt_inp_arc.length,
    rpt_inp_arc.n,
    rpt_inp_arc.elevmax1 AS z1,
    rpt_inp_arc.elevmax2 AS z2,
    inp_conduit.q0,
    inp_conduit.qmax
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id::text = inp_conduit.arc_id::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_pumps CASCADE;
CREATE OR REPLACE VIEW vi_pumps AS 
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_pump.curve_id,
    inp_pump.status,
    inp_pump.startup,
    inp_pump.shutoff
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_pump ON rpt_inp_arc.arc_id::text = inp_pump.arc_id::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_pump.curve_id,
    inp_flwreg_pump.status,
    inp_flwreg_pump.startup,
    inp_flwreg_pump.shutoff
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_flwreg_pump ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_pump.node_id, '_', inp_flwreg_pump.to_arc, '_pump_', inp_flwreg_pump.flwreg_id)
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_orifices CASCADE;
CREATE OR REPLACE VIEW vi_orifices AS 
 SELECT inp_orifice.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_orifice.ori_type,
    inp_orifice."offset",
    inp_orifice.cd,
    inp_orifice.flap,
    inp_orifice.orate
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_orifice ON inp_orifice.arc_id::text = rpt_inp_arc.arc_id::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_orifice.ori_type,
    inp_flwreg_orifice."offset",
    inp_flwreg_orifice.cd,
    inp_flwreg_orifice.flap,
    inp_flwreg_orifice.orate
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_flwreg_orifice ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_orifice.node_id, '_', inp_flwreg_orifice.to_arc, '_ori_', inp_flwreg_orifice.flwreg_id)
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_weirs CASCADE;
CREATE OR REPLACE VIEW vi_weirs AS 
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_weir.weir_type,
    inp_weir."offset",
    inp_weir.cd,
    inp_weir.flap,
    inp_weir.ec,
    inp_weir.cd2,
    inp_weir.surcharge
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_weir ON inp_weir.arc_id::text = rpt_inp_arc.arc_id::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_weir.weir_type,
    inp_flwreg_weir."offset",
    inp_flwreg_weir.cd,
    inp_flwreg_weir.flap,
    inp_flwreg_weir.ec,
    inp_flwreg_weir.cd2,
    inp_flwreg_weir.surcharge
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_flwreg_weir ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_weir.node_id, '_', inp_flwreg_weir.to_arc, '_weir_', inp_flwreg_weir.flwreg_id)
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_outlets CASCADE;
CREATE OR REPLACE VIEW vi_outlets AS 
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_outlet."offset",
    inp_outlet.outlet_type,
    concat(inp_outlet.cd1,' ',inp_outlet.cd2,' ',inp_outlet.flap) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_outlet ON rpt_inp_arc.arc_id::text = inp_outlet.arc_id::text
  WHERE inp_outlet.outlet_type::text = 'FUNCTIONAL/DEPTH'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_outlet."offset",
    inp_flwreg_outlet.outlet_type,
    concat(inp_flwreg_outlet.cd1,' ',inp_flwreg_outlet.cd2,' ',inp_flwreg_outlet.flap) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_outlet.node_id, '_', inp_flwreg_outlet.to_arc, '_out_', inp_flwreg_outlet.flwreg_id)
  WHERE inp_flwreg_outlet.outlet_type::text = 'FUNCTIONAL/DEPTH'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
  SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_outlet."offset",
    inp_outlet.outlet_type,
    concat(inp_outlet.cd1,' ',inp_outlet.cd2,' ',inp_outlet.flap) as other_val
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_outlet ON rpt_inp_arc.arc_id::text = inp_outlet.arc_id::text
  WHERE inp_outlet.outlet_type::text = 'FUNCTIONAL/HEAD'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_outlet."offset",
    inp_flwreg_outlet.outlet_type,
    concat(inp_flwreg_outlet.cd1,' ',inp_flwreg_outlet.cd2,' ',inp_flwreg_outlet.flap) as other_val
   FROM inp_selector_result,  rpt_inp_arc
     JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_outlet.node_id, '_', inp_flwreg_outlet.to_arc, '_out_', inp_flwreg_outlet.flwreg_id)
  WHERE inp_flwreg_outlet.outlet_type::text = 'FUNCTIONAL/HEAD'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_outlet."offset",
    inp_outlet.outlet_type,
    concat(inp_outlet.curve_id,' ',inp_outlet.flap) as other_val
   FROM inp_selector_result,
    rpt_inp_arc
     JOIN inp_outlet ON rpt_inp_arc.arc_id::text = inp_outlet.arc_id::text
  WHERE inp_outlet.outlet_type::text = 'TABULAR/DEPTH'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_outlet."offset",
    inp_flwreg_outlet.outlet_type,
    concat(inp_flwreg_outlet.curve_id,' ',inp_flwreg_outlet.flap) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_outlet.node_id, '_', inp_flwreg_outlet.to_arc, '_out_', inp_flwreg_outlet.flwreg_id)
  WHERE inp_flwreg_outlet.outlet_type::text = 'TABULAR/DEPTH'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_outlet."offset",
    inp_outlet.outlet_type,
    concat(inp_outlet.curve_id,' ',inp_outlet.flap) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_outlet ON rpt_inp_arc.arc_id::text = inp_outlet.arc_id::text
  WHERE inp_outlet.outlet_type::text = 'TABULAR/HEAD'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    rpt_inp_arc.node_1,
    rpt_inp_arc.node_2,
    inp_flwreg_outlet."offset",
    inp_flwreg_outlet.outlet_type,
    concat(inp_flwreg_outlet.curve_id,' ',inp_flwreg_outlet.flap) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_flwreg_outlet ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_outlet.node_id, '_', inp_flwreg_outlet.to_arc, '_out_', inp_flwreg_outlet.flwreg_id)
  WHERE inp_flwreg_outlet.outlet_type::text = 'TABULAR/HEAD'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_xsections CASCADE;
CREATE OR REPLACE VIEW vi_xsections AS 
SELECT rpt_inp_arc.arc_id,
    cat_arc_shape.epa AS shape,
    concat(cat_arc_shape.curve_id,' ',cat_arc.geom1,' ',cat_arc.geom2,' ',cat_arc.geom3,' ',
    	cat_arc.geom4,' ',inp_conduit.barrels,' ',inp_conduit.culvert) as other_val
  FROM inp_selector_result,rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id::text = inp_conduit.arc_id::text
     JOIN cat_arc ON rpt_inp_arc.arccat_id::text = cat_arc.id::text
     JOIN cat_arc_shape ON cat_arc_shape.id::text = cat_arc.shape::text
  WHERE cat_arc_shape.epa::text <> 'IRREGULAR'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    cat_arc_shape.epa AS shape,
    concat(cat_arc_shape.tsect_id,' ',cat_arc.geom1,' ',cat_arc.geom2,' ',cat_arc.geom3,' ',
    	cat_arc.geom4,' ',inp_conduit.barrels,' ',inp_conduit.culvert) as other_val
  FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id::text = inp_conduit.arc_id::text
     JOIN cat_arc ON rpt_inp_arc.arccat_id::text = cat_arc.id::text
     JOIN cat_arc_shape ON cat_arc_shape.id::text = cat_arc.shape::text
  WHERE cat_arc_shape.epa::text = 'IRREGULAR'::text 
  AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
SELECT inp_orifice.arc_id,
    inp_orifice.shape,
    concat(inp_orifice.geom1,' ',inp_orifice.geom2,' ',inp_orifice.geom3,' ',inp_orifice.geom4) as other_val
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_orifice ON inp_orifice.arc_id::text = rpt_inp_arc.arc_id::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    inp_flwreg_orifice.shape,
    concat(inp_flwreg_orifice.geom1,' ',inp_flwreg_orifice.geom2,' ',inp_flwreg_orifice.geom3,' ',
    	inp_flwreg_orifice.geom4) as other_val
   FROM inp_selector_result,
    rpt_inp_arc
     JOIN inp_flwreg_orifice ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_orifice.node_id, '_', inp_flwreg_orifice.to_arc, '_ori_', inp_flwreg_orifice.flwreg_id)
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
SELECT rpt_inp_arc.arc_id,
    inp_typevalue.descript as shape,
    concat(inp_weir.geom1,' ',inp_weir.geom2,' ',inp_weir.geom3,' ',inp_weir.geom4) as other_val
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_weir ON inp_weir.arc_id::text = rpt_inp_arc.arc_id::text
     JOIN inp_typevalue ON inp_weir.weir_type::text = inp_typevalue.idval::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_arc.arc_id,
    inp_typevalue.descript as shape,
    concat(inp_flwreg_weir.geom1,' ',inp_flwreg_weir.geom2,' ',inp_flwreg_weir.geom3) as other_val
   FROM inp_selector_result,rpt_inp_arc
     JOIN inp_flwreg_weir ON rpt_inp_arc.flw_code::text = 
     concat(inp_flwreg_weir.node_id, '_', inp_flwreg_weir.to_arc, '_weir_', inp_flwreg_weir.flwreg_id)
     JOIN inp_typevalue ON inp_flwreg_weir.weir_type::text = inp_typevalue.idval::text
  WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS  vi_losses CASCADE;
CREATE OR REPLACE VIEW vi_losses AS 
 SELECT inp_conduit.arc_id,
    inp_conduit.kentry,
    inp_conduit.kexit,
    inp_conduit.kavg,
    inp_conduit.flap,
    inp_conduit.seepage
   FROM inp_selector_result, rpt_inp_arc
     JOIN inp_conduit ON rpt_inp_arc.arc_id::text = inp_conduit.arc_id::text
  WHERE inp_conduit.kentry > 0::numeric OR inp_conduit.kexit > 0::numeric OR inp_conduit.kavg > 0::numeric OR inp_conduit.flap::text = 'YES'::text AND rpt_inp_arc.result_id::text = inp_selector_result.result_id::text AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS vi_transects CASCADE;
CREATE OR REPLACE VIEW vi_transects AS 
 SELECT inp_transects.text
   FROM inp_transects;


DROP VIEW IF EXISTS vi_controls CASCADE;
CREATE OR REPLACE VIEW vi_controls AS 
 SELECT inp_controls_x_arc.text
   FROM inp_selector_sector,inp_controls_x_arc
     JOIN rpt_inp_arc ON inp_controls_x_arc.arc_id::text = rpt_inp_arc.arc_id::text
  WHERE rpt_inp_arc.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text
UNION
 SELECT inp_controls_x_node.text
   FROM inp_selector_sector, inp_controls_x_node
     JOIN rpt_inp_node ON inp_controls_x_node.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text
  ORDER BY 1;


DROP VIEW IF EXISTS  vi_pollutants CASCADE;
CREATE OR REPLACE VIEW vi_pollutants AS 
 SELECT inp_pollutant.poll_id,
    inp_pollutant.units_type,
    inp_pollutant.crain,
    inp_pollutant.cgw,
    inp_pollutant.cii,
    inp_pollutant.kd,
    inp_pollutant.sflag,
    inp_pollutant.copoll_id,
    inp_pollutant.cofract,
    inp_pollutant.cdwf
   FROM inp_pollutant
  ORDER BY inp_pollutant.poll_id;


DROP VIEW IF EXISTS  vi_landuses CASCADE;
CREATE OR REPLACE VIEW vi_landuses AS 
 SELECT inp_landuses.landus_id,
    inp_landuses.sweepint,
    inp_landuses.availab,
    inp_landuses.lastsweep
   FROM inp_landuses;


DROP VIEW IF EXISTS  vi_coverages CASCADE;
CREATE OR REPLACE VIEW vi_coverages AS 
 SELECT v_edit_subcatchment.subc_id,
    inp_coverage_land_x_subc.landus_id,
    inp_coverage_land_x_subc.percent
   FROM inp_coverage_land_x_subc
     JOIN v_edit_subcatchment ON inp_coverage_land_x_subc.subc_id::text = v_edit_subcatchment.subc_id::text;

DROP VIEW IF EXISTS  vi_buildup CASCADE;
CREATE OR REPLACE VIEW vi_buildup AS 
 SELECT inp_buildup_land_x_pol.landus_id,
    inp_buildup_land_x_pol.poll_id,
    inp_buildup_land_x_pol.funcb_type,
    inp_buildup_land_x_pol.c1,
    inp_buildup_land_x_pol.c2,
    inp_buildup_land_x_pol.c3,
    inp_buildup_land_x_pol.perunit
   FROM inp_buildup_land_x_pol;

DROP VIEW IF EXISTS  vi_washoff CASCADE;
CREATE OR REPLACE VIEW vi_washoff AS 
 SELECT inp_washoff_land_x_pol.landus_id,
    inp_washoff_land_x_pol.poll_id,
    inp_washoff_land_x_pol.funcw_type,
    inp_washoff_land_x_pol.c1,
    inp_washoff_land_x_pol.c2,
    inp_washoff_land_x_pol.sweepeffic,
    inp_washoff_land_x_pol.bmpeffic
   FROM inp_washoff_land_x_pol;

DROP VIEW IF EXISTS  vi_treatment CASCADE;
CREATE OR REPLACE VIEW vi_treatment AS 
 SELECT rpt_inp_node.node_id,
    inp_treatment_node_x_pol.poll_id,
    inp_treatment_node_x_pol.function
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_treatment_node_x_pol ON inp_treatment_node_x_pol.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text
   AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_dwf CASCADE;
CREATE OR REPLACE VIEW vi_dwf AS 
 SELECT rpt_inp_node.node_id,
    'FLOW'::text AS type_dwf,
    inp_dwf.value,
    inp_dwf.pat1,
    inp_dwf.pat2,
    inp_dwf.pat3,
    inp_dwf.pat4
   FROM inp_selector_result,
    rpt_inp_node
     JOIN inp_dwf ON inp_dwf.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text AND inp_selector_result.cur_user = "current_user"()::text
UNION
  SELECT rpt_inp_node.node_id,
    inp_dwf_pol_x_node.poll_id AS type_dwf,
    inp_dwf_pol_x_node.value,
    inp_dwf_pol_x_node.pat1,
    inp_dwf_pol_x_node.pat2,
    inp_dwf_pol_x_node.pat3,
    inp_dwf_pol_x_node.pat4
   FROM inp_selector_result,
    rpt_inp_node
     JOIN inp_dwf_pol_x_node ON inp_dwf_pol_x_node.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_pattern CASCADE;
CREATE OR REPLACE VIEW vi_pattern AS 
SELECT inp_pattern.pattern_id,
    inp_pattern.pattern_type,
    concat(inp_pattern.factor_1,' ',inp_pattern.factor_2,' ',inp_pattern.factor_3,' ',inp_pattern.factor_4,' ',
    	inp_pattern.factor_5,' ',inp_pattern.factor_6,' ',inp_pattern.factor_7) as other_val
   FROM inp_pattern
  WHERE inp_pattern.pattern_type::text = 'DAILY'::text
UNION
  SELECT inp_pattern.pattern_id,
    inp_pattern.pattern_type,
    concat(inp_pattern.factor_1,' ',inp_pattern.factor_2,' ',inp_pattern.factor_3,' ',inp_pattern.factor_4,' ',
    	inp_pattern.factor_5,' ',inp_pattern.factor_6,' ',inp_pattern.factor_7,' ',inp_pattern.factor_8,' ', 
    	inp_pattern.factor_9,' ',inp_pattern.factor_10,' ',inp_pattern.factor_11,' ',inp_pattern.factor_12,' ',
    	inp_pattern.factor_13,' ',inp_pattern.factor_14,' ',inp_pattern.factor_15,' ',inp_pattern.factor_16,' ',
    	inp_pattern.factor_17,' ',inp_pattern.factor_18,' ',inp_pattern.factor_19,' ',inp_pattern.factor_20,' ',
    	inp_pattern.factor_21,' ',inp_pattern.factor_22,' ',inp_pattern.factor_23,' ',inp_pattern.factor_24) as other_val
   FROM inp_pattern
  WHERE inp_pattern.pattern_type::text = 'HOURLY'::text
UNION
 SELECT inp_pattern.pattern_id,
    inp_pattern.pattern_type AS type_pamo,
    concat(inp_pattern.factor_1,' ',inp_pattern.factor_2,' ',inp_pattern.factor_3,' ',inp_pattern.factor_4,' ',
    	inp_pattern.factor_5,' ',inp_pattern.factor_6,' ',inp_pattern.factor_7,' ',inp_pattern.factor_8,' ', 
    	inp_pattern.factor_9,' ',inp_pattern.factor_10,' ',inp_pattern.factor_11,' ',inp_pattern.factor_12) as other_val	
   FROM inp_pattern
  WHERE inp_pattern.pattern_type::text = 'MONTHLY'::text
UNION
SELECT inp_pattern.pattern_id,
    inp_pattern.pattern_type AS type_pawe,
    concat(inp_pattern.factor_1,' ',inp_pattern.factor_2,' ',inp_pattern.factor_3,' ',inp_pattern.factor_4,' ',
    	inp_pattern.factor_5,' ',inp_pattern.factor_6,' ',inp_pattern.factor_7,' ',inp_pattern.factor_8,' ', 
    	inp_pattern.factor_9,' ',inp_pattern.factor_10,' ',inp_pattern.factor_11,' ',inp_pattern.factor_12,' ',
    	inp_pattern.factor_13,' ',inp_pattern.factor_14,' ',inp_pattern.factor_15,' ',inp_pattern.factor_16,' ',
    	inp_pattern.factor_17,' ',inp_pattern.factor_18,' ',inp_pattern.factor_19,' ',inp_pattern.factor_20,' ',
    	inp_pattern.factor_21,' ',inp_pattern.factor_22,' ',inp_pattern.factor_23,' ',inp_pattern.factor_24) as other_val
   FROM inp_pattern
  WHERE inp_pattern.pattern_type::text = 'WEEKEND'::text;


DROP VIEW IF EXISTS  vi_inflows CASCADE;
CREATE OR REPLACE VIEW vi_inflows AS 
 SELECT rpt_inp_node.node_id,
    'FLOW'::text AS type_flow,
    inp_inflows.timser_id,
    concat('FLOW'::text,' ','1'::text,' ',inp_inflows.sfactor,' ',inp_inflows.base,' ',
    	inp_inflows.pattern_id) as other_val
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_inflows ON inp_inflows.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text
UNION
 SELECT rpt_inp_node.node_id,
    inp_inflows_pol_x_node.poll_id AS type_flow,
    inp_inflows_pol_x_node.timser_id,
    concat(inp_inflows_pol_x_node.form_type,' ',inp_inflows_pol_x_node.mfactor,' ',
    	inp_inflows_pol_x_node.sfactor,' ',inp_inflows_pol_x_node.base,' ',inp_inflows_pol_x_node.pattern_id)
   FROM inp_selector_result,rpt_inp_node
     JOIN inp_inflows_pol_x_node ON inp_inflows_pol_x_node.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS vi_loadings CASCADE;
CREATE OR REPLACE VIEW vi_loadings AS 
 SELECT inp_loadings_pol_x_subc.subc_id,
 	inp_loadings_pol_x_subc.poll_id,
    inp_loadings_pol_x_subc.ibuildup
   FROM v_edit_subcatchment
     JOIN inp_loadings_pol_x_subc ON inp_loadings_pol_x_subc.subc_id::text = v_edit_subcatchment.subc_id::text;



DROP VIEW IF EXISTS  vi_rdii CASCADE;
CREATE OR REPLACE VIEW vi_rdii AS 
 SELECT rpt_inp_node.node_id,
    inp_rdii.hydro_id,
    inp_rdii.sewerarea
   FROM inp_selector_result, rpt_inp_node
     JOIN inp_rdii ON inp_rdii.node_id::text = rpt_inp_node.node_id::text
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS  vi_hydrographs CASCADE;
CREATE OR REPLACE VIEW vi_hydrographs AS 
 SELECT inp_hydrograph.text
   FROM SCHEMA_NAME.inp_hydrograph;


DROP VIEW IF EXISTS  vi_curves CASCADE;
CREATE OR REPLACE VIEW vi_curves AS 
 SELECT inp_curve.curve_id,
    CASE
       WHEN inp_curve.x_value = (( SELECT min(sub.x_value) AS min
          FROM inp_curve sub
          WHERE sub.curve_id::text = inp_curve.curve_id::text)) THEN inp_curve_id.curve_type
       ELSE NULL::character varying
     END AS curve_type,
    inp_curve.x_value,
    inp_curve.y_value
   FROM inp_curve
     JOIN inp_curve_id ON inp_curve_id.id::text = inp_curve.curve_id::text
  ORDER BY inp_curve.id;


DROP VIEW IF EXISTS  vi_timeseries CASCADE;
CREATE OR REPLACE VIEW vi_timeseries AS 
 SELECT inp_timeseries.timser_id,
    concat(inp_timeseries.date,' ',inp_timeseries.hour,' ',inp_timeseries.value)
   FROM inp_timeseries
     JOIN inp_timser_id ON inp_timeseries.timser_id::text = inp_timser_id.id::text
  WHERE inp_timser_id.times_type::text = 'ABSOLUTE'::text
UNION
 SELECT inp_timeseries.timser_id,
    concat('FILE',' ',inp_timeseries.fname)
   FROM inp_timeseries
     JOIN inp_timser_id ON inp_timeseries.timser_id::text = inp_timser_id.id::text
  WHERE inp_timser_id.times_type::text = 'FILE'::text
UNION
 SELECT inp_timeseries.timser_id,
    concat(inp_timeseries."time",' ',inp_timeseries.value)
   FROM inp_timeseries
     JOIN inp_timser_id ON inp_timeseries.timser_id::text = inp_timser_id.id::text
  WHERE inp_timser_id.times_type::text = 'RELATIVE'::text
ORDER BY 1,2;


DROP VIEW IF EXISTS vi_lid_controls CASCADE;
CREATE OR REPLACE VIEW vi_lid_controls AS 
 SELECT inp_lid_control.lidco_id,
    inp_lid_control.lidco_type,
    concat(inp_lid_control.value_2,' ',inp_lid_control.value_3,' ',inp_lid_control.value_4,' ',
      inp_lid_control.value_5,' ',inp_lid_control.value_6,' ',inp_lid_control.value_7,' ',
      inp_lid_control.value_8) as other_val
   FROM inp_lid_control
  ORDER BY inp_lid_control.id;


DROP VIEW IF EXISTS vi_lid_usage CASCADE;
CREATE OR REPLACE VIEW vi_lid_usage AS 
 SELECT inp_lidusage_subc_x_lidco.subc_id,
    inp_lidusage_subc_x_lidco.lidco_id,
    inp_lidusage_subc_x_lidco.number::integer AS number,
    inp_lidusage_subc_x_lidco.area,
    inp_lidusage_subc_x_lidco.width,
    inp_lidusage_subc_x_lidco.initsat,
    inp_lidusage_subc_x_lidco.fromimp,
    inp_lidusage_subc_x_lidco.toperv::integer AS toperv,
    inp_lidusage_subc_x_lidco.rptfile
   FROM v_edit_subcatchment
     JOIN inp_lidusage_subc_x_lidco ON inp_lidusage_subc_x_lidco.subc_id::text = v_edit_subcatchment.subc_id::text;



DROP VIEW IF EXISTS vi_adjustments CASCADE;
CREATE OR REPLACE VIEW vi_adjustments AS 
 SELECT inp_adjustments.adj_type,
    concat(inp_adjustments.value_1,' ',inp_adjustments.value_2,' ',inp_adjustments.value_3,' ',
    	inp_adjustments.value_4,' ',inp_adjustments.value_5,' ',inp_adjustments.value_6,' ',
    	inp_adjustments.value_7,' ',inp_adjustments.value_8,' ',inp_adjustments.value_9,' ',
    	inp_adjustments.value_10,' ',inp_adjustments.value_11,' ',inp_adjustments.value_12) as monthly_adj
   FROM inp_adjustments
  ORDER BY inp_adjustments.adj_type;


DROP VIEW IF EXISTS vi_map CASCADE;
CREATE OR REPLACE VIEW vi_map AS 
 SELECT inp_mapdim.type_dim,
    concat(inp_mapdim.x1,' ',inp_mapdim.y1,' ',inp_mapdim.x2,' ',inp_mapdim.y2)as other_val
   FROM inp_mapdim
UNION
 SELECT inp_mapunits.type_units,
    inp_mapunits.map_type as other_val
   FROM inp_mapunits;


DROP VIEW IF EXISTS vi_backdrop CASCADE;
CREATE OR REPLACE VIEW vi_backdrop AS 
 SELECT inp_backdrop.text
   FROM inp_backdrop;


DROP VIEW IF EXISTS vi_symbols CASCADE;
CREATE OR REPLACE VIEW vi_symbols AS 
 SELECT v_edit_raingage.rg_id,
    st_x(v_edit_raingage.the_geom)::numeric(16,3) AS xcoord,
    st_y(v_edit_raingage.the_geom)::numeric(16,3) AS ycoord
   FROM v_edit_raingage;


DROP VIEW IF EXISTS vi_labels CASCADE;
CREATE OR REPLACE VIEW vi_labels AS 
 SELECT inp_label.xcoord,
 	inp_label.ycoord,
 	inp_label.label,
    inp_label.anchor,
    inp_label.font,
    inp_label.size,
    inp_label.bold,
    inp_label.italic
   FROM inp_label
  ORDER BY inp_label.label;



DROP VIEW IF EXISTS vi_coordinates CASCADE;
CREATE OR REPLACE VIEW vi_coordinates AS 
 SELECT rpt_inp_node.node_id,
    st_x(rpt_inp_node.the_geom)::numeric(16,3) AS xcoord,
    st_y(rpt_inp_node.the_geom)::numeric(16,3) AS ycoord
   FROM inp_selector_result,
    rpt_inp_node
  WHERE rpt_inp_node.result_id::text = inp_selector_result.result_id::text 
  AND inp_selector_result.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS vi_vertices CASCADE;
CREATE OR REPLACE VIEW vi_vertices AS 
 SELECT
    arc.arc_id,
    st_x(arc.point)::numeric(16,3) AS xcoord,
    st_y(arc.point)::numeric(16,3) AS ycoord
   FROM ( SELECT (st_dumppoints(rpt_inp_arc.the_geom)).geom AS point,
            st_startpoint(rpt_inp_arc.the_geom) AS startpoint,
            st_endpoint(rpt_inp_arc.the_geom) AS endpoint,
            rpt_inp_arc.sector_id,
            rpt_inp_arc.state,
            rpt_inp_arc.arc_id
           FROM inp_selector_result,
            rpt_inp_arc
          WHERE rpt_inp_arc.result_id::text = inp_selector_result.result_id::text 
          AND inp_selector_result.cur_user = "current_user"()::text) arc
  WHERE (arc.point < arc.startpoint OR arc.point > arc.startpoint) 
  AND (arc.point < arc.endpoint OR arc.point > arc.endpoint);
