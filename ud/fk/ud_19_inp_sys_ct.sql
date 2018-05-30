/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


--DROP CHECK
ALTER TABLE inp_typevalue DROP CONSTRAINT IF EXISTS inp_typevalue_check;
ALTER TABLE "inp_options" DROP CONSTRAINT IF EXISTS "inp_options_check";
ALTER TABLE "inp_timser_id" DROP CONSTRAINT IF EXISTS "inp_timser_id_check";

ALTER TABLE "inp_arc_type" DROP CONSTRAINT IF EXISTS "inp_arc_type_check";
ALTER TABLE "inp_node_type" DROP CONSTRAINT IF EXISTS "inp_node_type_check";
ALTER TABLE "inp_flwreg_pump" DROP CONSTRAINT IF EXISTS "inp_flwreg_pump_check";
ALTER TABLE "inp_flwreg_orifice" DROP CONSTRAINT IF EXISTS "inp_flwreg_orifice_check";
ALTER TABLE "inp_flwreg_weir" DROP CONSTRAINT IF EXISTS "inp_flwreg_weir_check" ;
ALTER TABLE "inp_flwreg_outlet" DROP CONSTRAINT IF EXISTS "inp_flwreg_outlet_check" ;


-- DROP UNIQUE
ALTER TABLE "inp_flwreg_pump" DROP CONSTRAINT IF EXISTS "inp_flwreg_pump_unique";
ALTER TABLE "inp_flwreg_orifice" DROP CONSTRAINT IF EXISTS "inp_flwreg_orifice_unique";
ALTER TABLE "inp_flwreg_weir" DROP CONSTRAINT IF EXISTS "inp_flwreg_weir_unique";
ALTER TABLE "inp_flwreg_outlet" DROP CONSTRAINT IF EXISTS "inp_flwreg_outlet_unique";




-- ADD CHECK
ALTER TABLE inp_timser_id ADD CONSTRAINT inp_timser_id_check CHECK (id IN ('T10-5m','T5-5m'));
ALTER TABLE inp_options ADD CONSTRAINT inp_options_check CHECK (id IN (1));

ALTER TABLE inp_arc_type ADD CONSTRAINT inp_arc_type_check CHECK (id IN ('CONDUIT','NOT DEFINED','ORIFICE','OUTLET','PUMP','VIRTUAL','WEIR'));
ALTER TABLE inp_node_type ADD CONSTRAINT inp_node_type_check CHECK (id IN ('DIVIDER','JUNCTION','NOT DEFINED','OUTFALL','STORAGE'));
ALTER TABLE inp_flwreg_pump ADD CONSTRAINT inp_flwreg_pump_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_orifice ADD CONSTRAINT inp_flwreg_orifice_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_weir ADD CONSTRAINT inp_flwreg_weir_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));
ALTER TABLE inp_flwreg_outlet ADD CONSTRAINT inp_flwreg_outlet_check CHECK (flwreg_id IN (1,2,3,4,5,6,7,8,9));



ALTER TABLE inp_typevalue ADD CONSTRAINT inp_typevalue_check CHECK 
((typevalue='inp_typevalue_divider' AND id IN ('CUTOFF','OVERFLOW','TABULAR','WEIR')) OR
(typevalue='inp_typevalue_evap' AND id IN ('CONSTANT','FILE','MONTHLY','RECOVERY','TEMPERATURE','TIMESERIES')) OR
(typevalue='inp_typevalue_orifice' AND id IN ('BOTTOM','SIDE')) OR
(typevalue='inp_typevalue_outfall' AND id IN  ('FIXED','FREE','NORMAL','TIDAL','TIMESERIES')) OR
(typevalue='inp_typevalue_outlet' AND id IN ('FUNCTIONAL/DEPTH','FUNCTIONAL/HEAD','TABULAR/DEPTH','TABULAR/HEAD')) OR
(typevalue='inp_typevalue_pattern' AND id IN ('DAILY','HOURLY','MONTHLY','WEEKEND')) OR
(typevalue='inp_typevalue_raingage' AND id IN ('FILE','TIMESERIES')) OR
(typevalue='inp_typevalue_storage' AND id IN ('FUNCTIONAL','TABULAR')) OR
(typevalue='inp_typevalue_temp' AND id IN ('FILE','TIMESERIES')) OR
(typevalue='inp_typevalue_timeseries' AND id IN ('ABSOLUTE','FILE','RELATIVE')) OR
(typevalue='inp_typevalue_windsp' AND id IN ('FILE','MONTHLY')) OR
(typevalue='inp_value_allnone' AND id IN ('ALL','NONE')) OR
(typevalue='inp_value_buildup' AND id IN ('EXP','EXT','POW','SAT')) OR
(typevalue='inp_value_catarc' AND id IN ('ARCH','BASKETHANDLE','CIRCULAR','CUSTOM','DUMMY','EGG','FILLED_CIRCULAR','FORCE_MAIN','HORIZ_ELLIPSE','HORSESHOE',
	'IRREGULAR','MODBASKETHANDLE','PARABOLIC','POWER','RECT_CLOSED','RECT_OPEN','RECT_ROUND','RECT_TRIANGULAR','SEMICIRCULAR','SEMIELLIPTICAL','TRAPEZOIDAL','TRIANGULAR','VIRTUAL')) OR
(typevalue='inp_value_curve' AND id IN ('CONTROL','DIVERSION','PUMP1','PUMP2','PUMP3','PUMP4','RATING','SHAPE','STORAGE','TIDAL')) OR
(typevalue='inp_value_files_actio' AND id IN ('SAVE','USE')) OR
(typevalue='inp_value_files_type' AND id IN ('HOTSTART','INFLOWS','OUTFLOWS','RAINFALL','RDII','RUNOFF')) OR
(typevalue='inp_value_inflows' AND id IN ('CONCEN','MASS')) OR
(typevalue='inp_value_lidcontrol' AND id IN ('BC','DRAIN','DRAINMAT','GR','IT','PAVEMENT','PP','RB','SOIL','STORAGE','SURFACE','VS')) OR
(typevalue='inp_value_mapunits' AND id IN ('DEGREES','FEET','METERS','NONE')) OR
(typevalue='inp_value_options_fme' AND id IN ('D-W','H-W')) OR
(typevalue='inp_value_options_fr' AND id IN ('DYNWAVE','KINWAVE','STEADY')) OR
(typevalue='inp_value_options_fu' AND id IN ('CFS','CMS','GPM','LPS','MGD','MLD')) OR
(typevalue='inp_value_options_id' AND id IN ('FULL','NONE','PARTIAL')) OR
(typevalue='inp_value_options_in' AND id IN ('CURVE_NUMBER','GREEN_AMPT','HORTON','GREEN_AMPT','MODIFIED_HORTON')) OR
(typevalue='inp_value_options_lo' AND id IN ('DEPTH','ELEVATION')) OR
(typevalue='inp_value_options_nfl' AND id IN ('BOTH','FROUD','SLOPE')) OR
(typevalue='inp_value_orifice' AND id IN ('CIRCULAR','RECT-CLOSED')) OR
(typevalue='inp_value_pollutants' AND id IN ('#/L','MG/L','UG/L')) OR
(typevalue='inp_value_raingage' AND id IN ('CUMULATIVE','INTENSITY','VOLUME')) OR
(typevalue='inp_value_routeto' AND id IN ('IMPERVIOUS','OUTLET','PERVIOUS')) OR
(typevalue='inp_value_status' AND id IN ('OFF','ON')) OR
(typevalue='inp_value_timserid' AND id IN ('Evaporation','Inflow_Hydrograph','Inflow_Pollutograph','Rainfall', 'Temperature') OR
(typevalue='inp_value_treatment' AND id IN ('CONCEN','RATE','REMOVAL')) OR
(typevalue='inp_value_washoff' AND id IN ('EMC','EXP','RC')) OR
(typevalue='inp_value_weirs' AND id IN ('SIDEFLOW','TRANSVERSE','TRAPEZOIDAL','V-NOTCH')) OR
(typevalue='inp_value_yesno' AND id IN ('YES','NO'))));


-- ADD UNIQUE
ALTER TABLE "inp_flwreg_pump" ADD CONSTRAINT "inp_flwreg_pump_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_orifice" ADD CONSTRAINT "inp_flwreg_orifice_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_weir" ADD CONSTRAINT "inp_flwreg_weir_unique" UNIQUE (node_id, to_arc, flwreg_id);
ALTER TABLE "inp_flwreg_outlet" ADD CONSTRAINT "inp_flwreg_outlet_unique" UNIQUE (node_id, to_arc, flwreg_id);



