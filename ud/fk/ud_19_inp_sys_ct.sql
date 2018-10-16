/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


--DROP CHECK
ALTER TABLE inp_typevalue DROP CONSTRAINT IF EXISTS inp_typevalue_check;
ALTER TABLE "inp_options" DROP CONSTRAINT IF EXISTS "inp_options_check";


ALTER TABLE "inp_arc_type" DROP CONSTRAINT IF EXISTS "inp_arc_type_check";
ALTER TABLE "inp_node_type" DROP CONSTRAINT IF EXISTS "inp_node_type_check";
ALTER TABLE "inp_flwreg_pump" DROP CONSTRAINT IF EXISTS "inp_flwreg_pump_check";
ALTER TABLE "inp_flwreg_orifice" DROP CONSTRAINT IF EXISTS "inp_flwreg_orifice_check";
ALTER TABLE "inp_flwreg_weir" DROP CONSTRAINT IF EXISTS "inp_flwreg_weir_check" ;
ALTER TABLE "inp_flwreg_outlet" DROP CONSTRAINT IF EXISTS "inp_flwreg_outlet_check" ;


ALTER TABLE raingage DROP CONSTRAINT IF EXISTS raingage_form_type_check;
ALTER TABLE raingage DROP CONSTRAINT IF EXISTS raingage_rgage_type_check;

ALTER TABLE inp_timser_id DROP CONSTRAINT IF EXISTS inp_timser_id_check;

ALTER TABLE subcatchment DROP CONSTRAINT IF EXISTS subcatchment_routeto_check;

ALTER TABLE inp_pollutant DROP CONSTRAINT IF EXISTS inp_pollutant_units_type_check;

ALTER TABLE cat_hydrology DROP CONSTRAINT IF EXISTS cat_hydrology_infiltration_check;
ALTER TABLE inp_curve_id DROP CONSTRAINT IF EXISTS inp_curve_id_curve_type_check;
ALTER TABLE inp_inflows_pol_x_node DROP CONSTRAINT IF EXISTS inp_inflows_pol_x_node_form_type_check;
ALTER TABLE inp_lid_control DROP CONSTRAINT IF EXISTS inp_lid_control_lidco_type_check;

ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_allow_ponding_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_normal_flow_limited_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_inertial_damping_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_skip_steady_state_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_ignore_quality_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_ignore_routing_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_ignore_groundwater_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_ignore_snowmelt_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_ignore_rainfall_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_force_main_equation_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_link_offsets_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_flow_routing_check;
ALTER TABLE inp_options DROP CONSTRAINT IF EXISTS inp_options_flow_units_check;

ALTER TABLE inp_orifice DROP CONSTRAINT IF EXISTS inp_orifice_shape_check;
ALTER TABLE inp_orifice DROP CONSTRAINT IF EXISTS inp_orifice_ori_type_check;

ALTER TABLE inp_pump DROP CONSTRAINT IF EXISTS inp_pump_status_check;

ALTER TABLE inp_washoff_land_x_pol DROP CONSTRAINT IF EXISTS inp_washoff_land_x_pol_funcw_type_check;

ALTER TABLE inp_files DROP CONSTRAINT IF EXISTS inp_files_actio_type_check;
ALTER TABLE inp_files DROP CONSTRAINT IF EXISTS inp_files_file_type_check;

ALTER TABLE inp_report DROP CONSTRAINT IF EXISTS inp_report_controls_check;
ALTER TABLE inp_report DROP CONSTRAINT IF EXISTS inp_report_input_check;
ALTER TABLE inp_report DROP CONSTRAINT IF EXISTS inp_report_continuity_check;
ALTER TABLE inp_report DROP CONSTRAINT IF EXISTS inp_report_flowstats_check;

ALTER TABLE inp_temperature	 DROP CONSTRAINT IF EXISTS inp_temperature_temp_type_check;

ALTER TABLE inp_timser_id DROP CONSTRAINT IF EXISTS inp_timser_id_timser_type_check;
ALTER TABLE inp_timser_id DROP CONSTRAINT IF EXISTS inp_timser_id_times_type_check;

ALTER TABLE inp_weir DROP CONSTRAINT IF EXISTS inp_weir_weir_type_check;
ALTER TABLE inp_weir DROP CONSTRAINT IF EXISTS inp_weir_flap_check;

ALTER TABLE inp_buildup_land_x_pol DROP CONSTRAINT IF EXISTS inp_buildup_land_x_pol_funcb_type_check;

--ALTER TABLE inp_treatment_node_x_pol DROP CONSTRAINT IF EXISTS inp_treatment_node_x_pol_function_check;


ALTER TABLE inp_flwreg_pump DROP CONSTRAINT IF EXISTS inp_flwreg_pump_status_check;
ALTER TABLE inp_flwreg_weir DROP CONSTRAINT IF EXISTS inp_flwreg_weir_weir_type_check;
ALTER TABLE inp_flwreg_weir DROP CONSTRAINT IF EXISTS inp_flwreg_weir_flap_check;
ALTER TABLE inp_flwreg_orifice DROP CONSTRAINT IF EXISTS inp_flwreg_orifice_ori_type_check;
ALTER TABLE inp_flwreg_orifice DROP CONSTRAINT IF EXISTS inp_flwreg_orifice_shape_check;
ALTER TABLE inp_flwreg_outlet DROP CONSTRAINT IF EXISTS inp_flwreg_outlet_outlet_type_check;

ALTER TABLE inp_divider DROP CONSTRAINT IF EXISTS inp_divider_divider_type_check;
ALTER TABLE inp_evaporation DROP CONSTRAINT IF EXISTS inp_evaporation_evap_type_check;
ALTER TABLE inp_outfall DROP CONSTRAINT IF EXISTS inp_outfall_outfall_type_check;
ALTER TABLE inp_outlet DROP CONSTRAINT IF EXISTS inp_outlet_outlet_type_check;
ALTER TABLE inp_pattern DROP CONSTRAINT IF EXISTS inp_pattern_pattern_type_check;
ALTER TABLE inp_storage DROP CONSTRAINT IF EXISTS inp_storage_storage_type_check;
ALTER TABLE inp_windspeed DROP CONSTRAINT IF EXISTS inp_windspeed_wind_type_check;

ALTER TABLE inp_snowpack DROP CONSTRAINT inp_snowpack_snow_type_check

-- DROP UNIQUE
ALTER TABLE "inp_flwreg_pump" DROP CONSTRAINT IF EXISTS "inp_flwreg_pump_unique";
ALTER TABLE "inp_flwreg_orifice" DROP CONSTRAINT IF EXISTS "inp_flwreg_orifice_unique";
ALTER TABLE "inp_flwreg_weir" DROP CONSTRAINT IF EXISTS "inp_flwreg_weir_unique";
ALTER TABLE "inp_flwreg_outlet" DROP CONSTRAINT IF EXISTS "inp_flwreg_outlet_unique";




-- ADD CHECK
ALTER TABLE inp_timser_id ADD CONSTRAINT inp_timser_id_check CHECK (id IN ('T10-5m','T5-5m'));

ALTER TABLE inp_timser_id ADD CONSTRAINT inp_timser_id_timser_type_check CHECK (timser_type IN ('Evaporation','Inflow_Hydrograph','Inflow_Pollutograph','Rainfall', 'Temperature_time'));
ALTER TABLE inp_timser_id ADD CONSTRAINT inp_timser_id_times_type_check CHECK (times_type IN ('ABSOLUTE','FILE_TIME','RELATIVE'));


ALTER TABLE inp_options ADD CONSTRAINT inp_options_check CHECK (id IN (1));

ALTER TABLE inp_arc_type ADD CONSTRAINT inp_arc_type_check CHECK (id IN ('CONDUIT','NOT DEFINED','ORIFICE','OUTLET','PUMP','VIRTUAL','WEIR'));
ALTER TABLE inp_node_type ADD CONSTRAINT inp_node_type_check CHECK (id IN ('DIVIDER','JUNCTION','NOT DEFINED','OUTFALL','STORAGE'));
ALTER TABLE inp_flwreg_pump ADD CONSTRAINT inp_flwreg_pump_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_orifice ADD CONSTRAINT inp_flwreg_orifice_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_weir ADD CONSTRAINT inp_flwreg_weir_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_outlet ADD CONSTRAINT inp_flwreg_outlet_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));



ALTER TABLE inp_typevalue ADD CONSTRAINT inp_typevalue_check CHECK 
((typevalue='inp_typevalue_divider' AND id IN ('CUTOFF','OVERFLOW','TABULAR_DIVIDER','WEIR')) OR
(typevalue='inp_typevalue_evap' AND id IN ('CONSTANT','FILE_EVAP','MONTHLY_EVAP','RECOVERY','TEMPERATURE_EVAP','TIMESERIES_EVAP')) OR
(typevalue='inp_typevalue_orifice' AND id IN ('BOTTOM','SIDE')) OR
(typevalue='inp_typevalue_outfall' AND id IN  ('FIXED','FREE','NORMAL','TIDAL_OUTFALL','TIMESERIES_OUTFALL')) OR
(typevalue='inp_typevalue_outlet' AND id IN ('FUNCTIONAL/DEPTH','FUNCTIONAL/HEAD','TABULAR/DEPTH','TABULAR/HEAD')) OR
(typevalue='inp_typevalue_pattern' AND id IN ('DAILY','HOURLY','MONTHLY_PATTERN','WEEKEND')) OR
(typevalue='inp_typevalue_raingage' AND id IN ('FILE_RAIN','TIMESERIES_RAIN')) OR
(typevalue='inp_typevalue_storage' AND id IN ('FUNCTIONAL','TABULAR_STORAGE')) OR
(typevalue='inp_typevalue_temp' AND id IN ('FILE_TEMP','TIMESERIES_TEMP')) OR
(typevalue='inp_typevalue_timeseries' AND id IN ('ABSOLUTE','FILE_TIME','RELATIVE')) OR
(typevalue='inp_typevalue_windsp' AND id IN ('FILE_WINDSP','MONTHLY_WINDSP')) OR
(typevalue='inp_value_allnone' AND id IN ('ALL','NONE')) OR
(typevalue='inp_value_buildup' AND id IN ('EXP_BUILDUP','EXT_BUILDUP','POW','SAT')) OR
(typevalue='inp_value_catarc' AND id IN ('ARCH','BASKETHANDLE','CIRCULAR','CUSTOM','DUMMY','EGG','FILLED_CIRCULAR','FORCE_MAIN','HORIZ_ELLIPSE','HORSESHOE',
	'IRREGULAR','MODBASKETHANDLE','PARABOLIC','POWER','RECT_CLOSED','RECT_OPEN','RECT_ROUND','RECT_TRIANGULAR','SEMICIRCULAR','SEMIELLIPTICAL','TRAPEZOIDAL','TRIANGULAR','VIRTUAL')) OR
(typevalue='inp_value_curve' AND id IN ('CONTROL','DIVERSION','PUMP1','PUMP2','PUMP3','PUMP4','RATING','SHAPE','STORAGE_CURVE','TIDAL_CURVE')) OR
(typevalue='inp_value_files_actio' AND id IN ('SAVE','USE')) OR
(typevalue='inp_value_files_type' AND id IN ('HOTSTART','INFLOWS','OUTFLOWS','RAINFALL','RDII','RUNOFF')) OR
(typevalue='inp_value_inflows' AND id IN ('CONCEN_INFLOWS','MASS')) OR
(typevalue='inp_value_lidcontrol' AND id IN ('BC','DRAIN','DRAINMAT','GR','IT','PAVEMENT','PP','RB','SOIL','STORAGE_LID','SURFACE_LID','VS')) OR
(typevalue='inp_value_mapunits' AND id IN ('DEGREES','FEET','METERS','NONE_MAP')) OR
(typevalue='inp_value_options_fme' AND id IN ('D-W','H-W')) OR
(typevalue='inp_value_options_fr' AND id IN ('DYNWAVE','KINWAVE','STEADY')) OR
(typevalue='inp_value_options_fu' AND id IN ('CFS','CMS','GPM','LPS','MGD','MLD')) OR
(typevalue='inp_value_options_id' AND id IN ('FULL','NONE_OPTION','PARTIAL')) OR
(typevalue='inp_value_options_in' AND id IN ('CURVE_NUMBER','GREEN_AMPT','HORTON','GREEN_AMPT','MODIFIED_HORTON')) OR
(typevalue='inp_value_options_lo' AND id IN ('DEPTH','ELEVATION')) OR
(typevalue='inp_value_options_nfl' AND id IN ('BOTH','FROUD','SLOPE')) OR
(typevalue='inp_value_orifice' AND id IN ('CIRCULAR_ORIFICE','RECT-CLOSED_ORIFICE')) OR
(typevalue='inp_value_pollutants' AND id IN ('#/L','MG/L','UG/L')) OR
(typevalue='inp_value_raingage' AND id IN ('CUMULATIVE','INTENSITY','VOLUME')) OR
(typevalue='inp_value_routeto' AND id IN ('IMPERVIOUS','OUTLET','PERVIOUS')) OR
(typevalue='inp_value_status' AND id IN ('OFF','ON')) OR
(typevalue='inp_value_timserid' AND id IN ('Evaporation','Inflow_Hydrograph','Inflow_Pollutograph','Rainfall', 'Temperature_time') OR
(typevalue='inp_value_treatment' AND id IN ('CONCEN_TREAT','RATE','REMOVAL')) OR
(typevalue='inp_value_washoff' AND id IN ('EMC','EXP_WASHOFF','RC')) OR
(typevalue='inp_value_weirs' AND id IN ('SIDEFLOW','TRANSVERSE','TRAPEZOIDAL_WEIR','V-NOTCH')) OR
(typevalue='inp_value_yesno' AND id IN ('YES','NO'))));


-- ADD UNIQUE
ALTER TABLE "inp_flwreg_pump" ADD CONSTRAINT "inp_flwreg_pump_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_orifice" ADD CONSTRAINT "inp_flwreg_orifice_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_weir" ADD CONSTRAINT "inp_flwreg_weir_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_outlet" ADD CONSTRAINT "inp_flwreg_outlet_unique" UNIQUE (node_id, to_arc, flwreg_id);



ALTER TABLE raingage ADD CONSTRAINT raingage_form_type_check CHECK (form_type IN ('CUMULATIVE','INTENSITY','VOLUME'));
ALTER TABLE raingage ADD CONSTRAINT raingage_rgage_type_check CHECK (rgage_type IN ('FILE_RAIN','TIMESERIES_RAIN'));

ALTER TABLE subcatchment ADD CONSTRAINT subcatchment_routeto_check CHECK (routeto IN ('IMPERVIOUS','OUTLET','PERVIOUS'));

ALTER TABLE inp_pollutant ADD CONSTRAINT inp_pollutant_units_type_check CHECK (units_type IN ('#/L','MG/L','UG/L'));

ALTER TABLE cat_hydrology ADD CONSTRAINT cat_hydrology_infiltration_check CHECK (infiltration IN ('CURVE_NUMBER','GREEN_AMPT','HORTON','GREEN_AMPT','MODIFIED_HORTON'));
ALTER TABLE inp_curve_id ADD CONSTRAINT inp_curve_id_curve_type_check CHECK (curve_type IN ('CONTROL','DIVERSION','PUMP1','PUMP2','PUMP3','PUMP4','RATING','SHAPE','STORAGE_CURVE','TIDAL_CURVE'));
ALTER TABLE inp_inflows_pol_x_node ADD CONSTRAINT inp_inflows_pol_x_node_form_type_check CHECK (form_type IN ('CONCEN_INFLOWS','MASS'));
ALTER TABLE inp_lid_control ADD CONSTRAINT inp_lid_control_lidco_type_check CHECK (lidco_type IN ('BC','DRAIN','DRAINMAT','GR','IT','PAVEMENT','PP','RB','SOIL','STORAGE_LID','SURFACE_LID','VS'));

ALTER TABLE inp_options ADD CONSTRAINT inp_options_allow_ponding_check CHECK (allow_ponding IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_normal_flow_limited_check CHECK (normal_flow_limited IN ('BOTH','FROUD','SLOPE'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_inertial_damping_check CHECK (inertial_damping IN ('FULL','NONE_OPTION','PARTIAL'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_skip_steady_state_check CHECK (skip_steady_state IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_ignore_quality_check CHECK (ignore_quality IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_ignore_routing_check CHECK (ignore_routing IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_ignore_groundwater_check CHECK (ignore_groundwater IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_ignore_snowmelt_check CHECK (ignore_snowmelt IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_ignore_rainfall_check CHECK (ignore_rainfall IN ('YES','NO'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_force_main_equation_check CHECK (force_main_equation IN ('D-W','H-W'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_link_offsets_check CHECK (link_offsets IN ('DEPTH','ELEVATION'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_flow_routing_check CHECK (flow_routing IN ('DYNWAVE','KINWAVE','STEADY'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_flow_units_check CHECK (flow_units IN ('CFS','CMS','GPM','LPS','MGD','MLD'));

ALTER TABLE inp_orifice ADD CONSTRAINT inp_orifice_shape_check CHECK (shape IN ('CIRCULAR','RECT-CLOSED'));
ALTER TABLE inp_orifice ADD CONSTRAINT inp_orifice_ori_type_check CHECK (ori_type IN ('BOTTOM','SIDE'));

ALTER TABLE inp_pump ADD CONSTRAINT inp_pump_status_check CHECK (status IN ('OFF','ON'));

ALTER TABLE inp_washoff_land_x_pol ADD CONSTRAINT inp_washoff_land_x_pol_funcw_type_check CHECK (funcw_type IN ('EMC','EXP_WASHOFF','RC'));

ALTER TABLE inp_files ADD CONSTRAINT inp_files_actio_type_check CHECK (actio_type IN ('SAVE','USE'));
ALTER TABLE inp_files ADD CONSTRAINT inp_files_file_type_check CHECK (file_type IN ('HOTSTART','INFLOWS','OUTFLOWS','RAINFALL','RDII','RUNOFF'));

ALTER TABLE inp_report ADD CONSTRAINT inp_report_controls_check CHECK (controls IN ('YES','NO'));
ALTER TABLE inp_report ADD CONSTRAINT inp_report_input_check CHECK (input IN ('YES','NO'));
ALTER TABLE inp_report ADD CONSTRAINT inp_report_continuity_check CHECK (continuity IN ('YES','NO'));
ALTER TABLE inp_report ADD CONSTRAINT inp_report_flowstats_check CHECK (flowstats IN ('YES','NO'));

ALTER TABLE inp_temperature	 ADD CONSTRAINT inp_temperature_temp_type_check CHECK (temp_type IN ('FILE_TEMP','TIMESERIES_TEMP'));


ALTER TABLE inp_weir ADD CONSTRAINT inp_weir_weir_type_check CHECK (weir_type IN ('SIDEFLOW','TRANSVERSE','TRAPEZOIDAL_WEIR','V-NOTCH'));
ALTER TABLE inp_weir ADD CONSTRAINT inp_weir_flap_check CHECK (flap IN ('YES','NO'));

ALTER TABLE inp_buildup_land_x_pol ADD CONSTRAINT inp_buildup_land_x_pol_funcb_type_check CHECK (funcb_type IN ('EXP_BUILDUP','EXT_BUILDUP','POW','SAT'));

--ALTER TABLE inp_treatment_node_x_pol ADD CONSTRAINT inp_treatment_node_x_pol_function_check CHECK (function IN ('CONCEN_TREAT','RATE','REMOVAL'));

ALTER TABLE inp_flwreg_pump ADD CONSTRAINT inp_flwreg_pump_status_check CHECK (status IN ('OFF','ON'));
ALTER TABLE inp_flwreg_weir ADD CONSTRAINT inp_flwreg_weir_weir_type_check CHECK (weir_type IN ('SIDEFLOW','TRANSVERSE','TRAPEZOIDAL','V-NOTCH'));
ALTER TABLE inp_flwreg_weir ADD CONSTRAINT inp_flwreg_weir_flap_check CHECK (flap IN ('YES','NO'));
ALTER TABLE inp_flwreg_orifice ADD CONSTRAINT inp_flwreg_orifice_ori_type_check CHECK (ori_type IN ('BOTTOM','SIDE'));
ALTER TABLE inp_flwreg_orifice ADD CONSTRAINT inp_flwreg_orifice_shape_check CHECK (shape IN ('CIRCULAR_ORIFICE','RECT-CLOSED_ORIFICE'));
ALTER TABLE inp_flwreg_outlet ADD CONSTRAINT inp_flwreg_outlet_outlet_type_check CHECK (outlet_type IN ('FUNCTIONAL/DEPTH','FUNCTIONAL/HEAD','TABULAR/DEPTH','TABULAR/HEAD'));

ALTER TABLE inp_divider ADD CONSTRAINT inp_divider_divider_type_check CHECK (divider_type IN ('CUTOFF','OVERFLOW','TABULAR_DIVIDER','WEIR'));
ALTER TABLE inp_evaporation ADD CONSTRAINT inp_evaporation_evap_type_check CHECK (evap_type IN('CONSTANT','FILE_EVAP','MONTHLY_EVAP','RECOVERY','TEMPERATURE_EVAP','TIMESERIES_EVAP'));
ALTER TABLE inp_outfall ADD CONSTRAINT inp_outfall_outfall_type_check CHECK (outfall_type IN ('FIXED','FREE','NORMAL','TIDAL_OUTFALL','TIMESERIES_OUTFALL'));
ALTER TABLE inp_outlet ADD CONSTRAINT inp_outlet_outlet_type_check CHECK (outlet_type IN ('FUNCTIONAL/DEPTH','FUNCTIONAL/HEAD','TABULAR/DEPTH','TABULAR/HEAD'));
ALTER TABLE inp_pattern ADD CONSTRAINT inp_pattern_pattern_type_check CHECK (pattern_type IN ('DAILY','HOURLY','MONTHLY_PATTERN','WEEKEND'));
ALTER TABLE inp_storage ADD CONSTRAINT inp_storage_storage_type_check CHECK (storage_type IN ('FUNCTIONAL','TABULAR_STORAGE'));
ALTER TABLE inp_windspeed ADD CONSTRAINT inp_windspeed_wind_type_check CHECK (wind_type IN ('FILE_WINDSP','MONTHLY_WINDSP'));


ALTER TABLE inp_snowpack ADD CONSTRAINT inp_snowpack_snow_type_check CHECK (snow_type= ANY(ARRAY[ 'PLOWABLE','IMPERVIOUS', 'PERVIOUS','REMOVAL']));