/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

--DROP CHECK
ALTER TABLE inp_typevalue DROP CONSTRAINT IF EXISTS inp_typevalue_check;

ALTER TABLE "inp_options" DROP CONSTRAINT IF EXISTS "inp_options_check";
ALTER TABLE "inp_project_id" DROP CONSTRAINT IF EXISTS "inp_project_id_check";

ALTER TABLE "inp_arc_type" DROP CONSTRAINT IF EXISTS "inp_arc_type_check";
ALTER TABLE "inp_node_type" DROP CONSTRAINT IF EXISTS "inp_node_type_check";
ALTER TABLE "inp_pump_additional" DROP CONSTRAINT IF EXISTS "inp_pump_additional_check";


--DROP UNIQUE
ALTER TABLE "inp_pump_additional" DROP CONSTRAINT IF EXISTS "inp_pump_additional_unique";



-- ADD CHECK
ALTER TABLE inp_options ADD CONSTRAINT inp_options_check CHECK (id IN (1));

ALTER TABLE inp_project_id ADD CONSTRAINT inp_project_id_check CHECK (title IN (title));

ALTER TABLE inp_arc_type ADD CONSTRAINT inp_arc_type_check CHECK (id IN ('NOT DEFINED', 'PIPE'));
ALTER TABLE inp_node_type ADD CONSTRAINT inp_node_type_check CHECK (id IN ('JUNCTION','NOT DEFINED','PUMP','RESERVOIR','SHORTPIPE','TANK','VALVE'));
ALTER TABLE inp_pump_additional ADD CONSTRAINT inp_pump_additional_check CHECK (order_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20));



ALTER TABLE inp_typevalue ADD CONSTRAINT inp_typevalue_check CHECK 
((typevalue='inp_value_curve' AND id IN ('EFFICIENCY','HEADLOSS','PUMP','VOLUME')) OR
(typevalue='inp_value_yesno'  and id IN ('NO','YES')) OR
(typevalue='inp_typevalue_energy' AND id IN ('DEMAND CHARGE','GLOBAL')) OR
(typevalue='inp_typevalue_pump' AND id IN ('HEAD','PATTERN','POWER','SPEED')) OR
(typevalue='inp_typevalue_reactions_gl' AND id IN ('GLOBAL','LIMITING POTENTIAL','ORDER','ROUGHNESS CORRELATION')) OR
(typevalue='inp_typevalue_source' AND id IN ('CONCEN','FLOWPACED','MASS','SETPOINT')) OR
(typevalue='inp_value_ampm' AND id IN ('AM','PM')) OR
(typevalue='inp_value_mixing' AND id IN  ('2COMP','FIFO','LIFO','MIXED')) OR
(typevalue='inp_value_noneall' AND id IN ('ALL','NONE')) OR
(typevalue='inp_value_opti_headloss' AND id IN ('C-M','D-W','H-W')) OR
(typevalue='inp_value_opti_hyd' AND id IN (' ','SAVE','USE')) OR
(typevalue='inp_value_opti_qual' AND id IN ('AGE','CHEMICAL mg/L','CHEMICAL ug/L','NONE','TRACE')) OR
(typevalue='inp_value_opti_rtc_coef' AND id IN ('AVG','MAX','MIN','REAL')) OR
(typevalue='inp_value_opti_unbal' AND id IN ('CONTINUE','STOP')) OR
(typevalue='inp_value_opti_units' AND id IN ('AFD','CMD','CMH','GPM','IMGD','LPM','LPS','MGD','MLD')) OR
(typevalue='inp_value_opti_valvemode' AND id IN ('EPA TABLES','INVENTORY VALUES','MINCUT RESULTS')) OR
(typevalue='inp_value_param_energy' AND id IN ('EFFIC','PATTERN','PRICE')) OR
(typevalue='inp_value_reactions_el' AND id IN ('BULK','TANK','WALL')) OR
(typevalue='inp_value_reactions_gl' AND id IN ('BULK','TANK','WALL')) OR
(typevalue='inp_value_status_pipe' AND id IN ('CLOSED','CV','OPEN')) OR
(typevalue='inp_value_status_pump' AND id IN ('CLOSED','OPEN')) OR
(typevalue='inp_value_status_valve' AND id IN ('ACTIVE','CLOSED','OPEN')) OR
(typevalue='inp_value_times' AND id IN ('AVERAGED','MAXIMUM','MINIMUM','NONE','RANGE')) OR
(typevalue='inp_value_yesnofull' AND id IN ('FULL','NO','YES')) OR
(typevalue='inp_typevalue_valve' AND id IN ('FCV','GPV','PBV','PRV','PSV','TCV')));


-- ADD UNIQUE
ALTER TABLE "inp_pump_additional" ADD CONSTRAINT "inp_pump_additional_unique" UNIQUE (node_id, order_id);



