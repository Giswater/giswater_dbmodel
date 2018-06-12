/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


-- ----------------------------
-- Records of inp_typevalue
-- ----------------------------


INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'PATTERN_PUMP', 'PATTERN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'HEAD_PUMP', 'HEAD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'SPEED_PUMP', 'SPEED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'POWER_PUMP', 'POWER', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'GLOBAL_GL', 'GLOBAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'AGE', 'AGE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_energy', 'DEMAND CHARGE', 'DEMAND CHARGE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_energy', 'GLOBAL', 'GLOBAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'CONCEN', 'CONCEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'FLOWPACED', 'FLOWPACED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'MASS', 'MASS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'SETPOINT', 'SETPOINT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_ampm', 'AM', 'AM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_ampm', 'PM', 'PM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'EFFICIENCY', 'EFFICIENCY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'HEADLOSS', 'HEADLOSS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP', 'PUMP', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'VOLUME', 'VOLUME', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', '2COMP', '2COMP', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'FIFO', 'FIFO', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'LIFO', 'LIFO', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'MIXED', 'MIXED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_noneall', 'ALL', 'ALL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_noneall', 'NONE', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'C-M', 'C-M', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'D-W', 'D-W', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'H-W', 'H-W', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', ' ', ' ', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', 'SAVE', 'SAVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', 'USE', 'USE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'CHEMICAL mg/L', 'CHEMICAL mg/L', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'CHEMICAL ug/L', 'CHEMICAL ug/L', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'MIN', 'MIN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'AVG', 'AVG', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'MAX', 'MAX', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_unbal', 'CONTINUE', 'CONTINUE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_unbal', 'STOP', 'STOP', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'AFD', 'AFD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'CMD', 'CMD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'CMH', 'CMH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'GPM', 'GPM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'IMGD', 'IMGD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'LPM', 'LPM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'LPS', 'LPS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'MGD', 'MGD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'MLD', 'MLD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'EPA TABLES', 'EPA TABLES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'INVENTORY VALUES', 'INVENTORY VALUES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'MINCUT RESULTS', 'MINCUT RESULTS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'EFFIC', 'EFFIC', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'PATTERN', 'PATTERN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'PRICE', 'PRICE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'NO', 'NO', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'YES', 'YES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'GPV', 'GPV', 'General Purpose Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'FCV', 'FCV', 'Flow Control Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PBV', 'PBV', 'Pressure Break Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PRV', 'PRV', 'Pressure Reduction Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PSV', 'PSV', 'Pressure Sustain Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'TCV', 'TCV', 'Throttle Control Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'BULK_EL', 'BULK', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'TANK_EL', 'TANK', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'WALL_EL', 'WALL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'BULK_GL', 'BULK', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'TANK_GL', 'TANK', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'WALL_GL', 'WALL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'CLOSED_PIPE', 'CLOSED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'CV_PIPE', 'CV', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'OPEN_PIPE', 'OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pump', 'CLOSED_PUMP', 'CLOSED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pump', 'OPEN_PUMP', 'OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'ACTIVE_VALVE', 'ACTIVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'CLOSED_VALVE', 'CLOSED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'OPEN_VALVE', 'OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'FULL_YNF', 'FULL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'NO_YNF', 'NO', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'YES_YNF', 'YES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'NONE_QUAL', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'NONE_TIMES', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'RANGE', 'RANGE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'MINIMUM', 'MINIMUM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'MAXIMUM', 'MAXIMUM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'AVERAGED', 'AVERAGED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'TRACE', 'TRACE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'ROUGHNESS CORRELATION', 'ROUGHNESS CORRELATION', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'ORDER', 'ORDER', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'LIMITING POTENTIAL', 'LIMITING POTENTIAL', NULL);

-- ----------------------------
-- Records of inp_options
-- ----------------------------
 
INSERT INTO inp_options VALUES (1,'LPS', 'H-W', NULL, 1.000000, 1.000000, 40.000000, 0.001000, 'CONTINUE', 2.000000, 10.000000, 0.000000, '1', 1.000000, 0.500000, 'NONE_QUAL', 1.000000, 0.010000, '', 40.000000, NULL, 'EPA TABLES', NULL, 'f', NULL, NULL);


-- ----------------------------
-- Records of inp_report
-- ----------------------------
 
INSERT INTO "inp_report" VALUES ('0', '', 'YES_YNF', 'YES', 'YES', 'ALL', 'ALL', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES');
 

-- ----------------------------
-- Records of inp_times
-- ----------------------------
 
INSERT INTO "inp_times" VALUES (1,'24', '0:30', '0:06', '0:05', '1:00', '0:00', '1:00', '0:00', '12', 'NONE_TIMES');



-- ----------------------------
-- Records of inp_arc_type
-- ----------------------------
 
INSERT INTO "inp_arc_type" VALUES ('PIPE');
INSERT INTO "inp_arc_type" VALUES ('NOT DEFINED');

-- ----------------------------
-- Records of inp_node_type
-- ----------------------------
 
INSERT INTO "inp_node_type" VALUES ('JUNCTION');
INSERT INTO "inp_node_type" VALUES ('RESERVOIR');
INSERT INTO "inp_node_type" VALUES ('TANK');
INSERT INTO "inp_node_type" VALUES ('PUMP');
INSERT INTO "inp_node_type" VALUES ('VALVE');
INSERT INTO "inp_node_type" VALUES ('SHORTPIPE');
INSERT INTO "inp_node_type" VALUES ('NOT DEFINED');

