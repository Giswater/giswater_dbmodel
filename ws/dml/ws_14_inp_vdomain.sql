/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;


-- ----------------------------
-- Records of inp_typevalue
-- ----------------------------


INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_energy', 'DEMAND CHARGE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_energy', 'GLOBAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'HEAD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'PATTERN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'POWER', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pump', 'SPEED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'GLOBAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'LIMITING POTENTIAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'ORDER', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_reactions_gl', 'ROUGHNESS CORRELATION', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'CONCEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'FLOWPACED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'MASS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_source', 'SETPOINT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_ampm', 'AM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_ampm', 'PM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'EFFICIENCY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'HEADLOSS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'VOLUME', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', '2COMP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'FIFO', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'LIFO', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mixing', 'MIXED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_noneall', 'ALL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_noneall', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'C-M', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'D-W', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_headloss', 'H-W', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', ' ', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', 'SAVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_hyd', 'USE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'AGE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'CHEMICAL mg/L', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'CHEMICAL ug/L', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_qual', 'TRACE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'MIN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'AVG', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_rtc_coef', 'MAX', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_unbal', 'CONTINUE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_unbal', 'STOP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'AFD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'CMD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'CMH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'GPM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'IMGD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'LPM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'LPS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'MGD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_units', 'MLD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'EPA TABLES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'INVENTORY VALUES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_opti_valvemode', 'MINCUT RESULTS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'EFFIC', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'PATTERN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_param_energy', 'PRICE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'BULK', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'TANK', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_el', 'WALL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'BULK', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'TANK', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_reactions_gl', 'WALL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'CLOSED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'CV', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pipe', 'OPEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pump', 'CLOSED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_pump', 'OPEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'ACTIVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'CLOSED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status_valve', 'OPEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'AVERAGED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'MAXIMUM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'MINIMUM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_times', 'RANGE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'NO', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'YES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'FULL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'NO', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesnofull', 'YES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'GPV', NULL, 'General Purpose Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'FCV', NULL, 'Flow Control Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PBV', NULL, 'Pressure Break Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PRV', NULL, 'Pressure Reduction Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'PSV', NULL, 'Pressure Sustain Valve');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_valve', 'TCV', NULL, 'Throttle Control Valve');
-- ----------------------------
-- Records of inp_options
-- ----------------------------
 
INSERT INTO inp_options VALUES (1,'LPS', 'H-W', NULL, 1.000000, 1.000000, 40.000000, 0.001000, 'CONTINUE', 2.000000, 10.000000, 0.000000, '1', 1.000000, 0.500000, 'NONE', 1.000000, 0.010000, '', 40.000000, NULL, 'EPA TABLES', NULL, 'f', NULL, NULL);


-- ----------------------------
-- Records of inp_report
-- ----------------------------
 
INSERT INTO "inp_report" VALUES ('0', '', 'YES', 'YES', 'YES', 'ALL', 'ALL', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES', 'YES');
 

-- ----------------------------
-- Records of inp_times
-- ----------------------------
 
INSERT INTO "inp_times" VALUES (1,'24', '0:30', '0:06', '0:05', '1:00', '0:00', '1:00', '0:00', '12', 'NONE');


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

