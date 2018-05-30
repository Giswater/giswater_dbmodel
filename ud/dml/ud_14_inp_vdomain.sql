/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
SET search_path = "SCHEMA_NAME", public, pg_catalog;



-- ----------------------------
-- Records of inp_typevalue
-- ----------------------------
 
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'CUTOFF', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'OVERFLOW', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'TABULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'WEIR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'CONSTANT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'FILE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'MONTHLY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'RECOVERY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'TEMPERATURE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'TIMESERIES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_orifice', 'BOTTOM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_orifice', 'SIDE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'FIXED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'FREE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'NORMAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'TIDAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'TIMESERIES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'FUNCTIONAL/DEPTH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'FUNCTIONAL/HEAD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'TABULAR/DEPTH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'TABULAR/HEAD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'DAILY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'HOURLY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'MONTHLY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'WEEKEND', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_raingage', 'FILE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_raingage', 'TIMESERIES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_storage', 'FUNCTIONAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_storage', 'TABULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_temp', 'FILE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_temp', 'TIMESERIES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'ABSOLUTE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'FILE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'RELATIVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_windsp', 'FILE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_windsp', 'MONTHLY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_allnone', 'ALL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_allnone', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'EXP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'EXT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'POW', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'SAT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'CIRCULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'FILLED_CIRCULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_CLOSED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_OPEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'TRAPEZOIDAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'TRIANGULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'HORIZ_ELLIPSE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'ARCH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'PARABOLIC', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'POWER', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_TRIANGULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_ROUND', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'MODBASKETHANDLE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'EGG', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'HORSESHOE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'SEMIELLIPTICAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'BASKETHANDLE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'SEMICIRCULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'IRREGULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'CUSTOM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'DUMMY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'FORCE_MAIN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'VIRTUAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'CONTROL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'DIVERSION', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP1', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP2', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP3', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP4', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'RATING', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'SHAPE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'STORAGE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'TIDAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_actio', 'SAVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_actio', 'USE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'HOTSTART', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'INFLOWS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'OUTFLOWS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RAINFALL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RDII', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RUNOFF', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_inflows', 'CONCEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_inflows', 'MASS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'DRAIN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'PAVEMENT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'SOIL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'STORAGE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'SURFACE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'BC', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'PP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'IT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'RB', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'VS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'GR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'DRAINMAT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'DEGREES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'FEET', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'METERS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fme', 'D-W', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fme', 'H-W', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'DYNWAVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'KINWAVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'STEADY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'CFS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'CMS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'GPM', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'LPS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'MGD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'MLD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'FULL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'NONE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'PARTIAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'CURVE_NUMBER', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'GREEN_AMPT', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'HORTON', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'MODIFIED_HORTON', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_lo', 'DEPTH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_lo', 'ELEVATION', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'BOTH', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'FROUD', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'SLOPE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_orifice', 'CIRCULAR', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_orifice', 'RECT-CLOSED', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', '#/L', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', 'MG/L', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', 'UG/L', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'CUMULATIVE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'INTENSITY', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'VOLUME', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'OUTLET', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'IMPERVIOUS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'PERVIOUS', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status', 'ON', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status', 'OFF', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Evaporation', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Inflow_Hydrograph', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Inflow_Pollutograph', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Rainfall', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Temperature', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'CONCEN', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'RATE', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'REMOVAL', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'EMC', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'EXP', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'RC', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'NO', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'YES', NULL, NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'SIDEFLOW', 'RECT_OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'TRANSVERSE', 'RECT_OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'TRAPEZOIDAL', 'TRAPEZOIDAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'V-NOTCH', 'TRIANGULAR', NULL);


-- ----------------------------
-- Records of inp_options
-- ----------------------------
 
INSERT INTO inp_options 
VALUES (1,'CMS', 'DYNWAVE', 'ELEVATION', 'H-W', 'NO', 'NO', 'NO', 'NO', 'NO', 'NO', '01/01/2017', '00:00:00', '01/02/2017', '00:00:00', '01/01/2001', '00:00:00', '01/01', '12/31', 10, '00:05:00', '00:05:00', '01:00:00', '00:00:02', NULL, NULL, 'NONE', 'BOTH', 0.000000, 0.000000, 'YES', NULL, 0, 0.0000, 5, 5);

-- ----------------------------
-- Records of inp_report
-- ----------------------------
 
INSERT INTO inp_report VALUES ('YES', 'YES', 'YES', 'YES', 'ALL', 'ALL', 'ALL');


-- ----------------------------
-- Records of inp_arc_type
-- ----------------------------
 
INSERT INTO "inp_arc_type" VALUES ('CONDUIT');
INSERT INTO "inp_arc_type" VALUES ('ORIFICE');
INSERT INTO "inp_arc_type" VALUES ('OUTLET');
INSERT INTO "inp_arc_type" VALUES ('PUMP');
INSERT INTO "inp_arc_type" VALUES ('WEIR');
INSERT INTO "inp_arc_type" VALUES ('NOT DEFINED');
INSERT INTO "inp_arc_type" VALUES ('VIRTUAL');


-- ----------------------------
-- Records of inp_node_type
-- ----------------------------
 
INSERT INTO "inp_node_type" VALUES ('JUNCTION');
INSERT INTO "inp_node_type" VALUES ('OUTFALL');
INSERT INTO "inp_node_type" VALUES ('DIVIDER');
INSERT INTO "inp_node_type" VALUES ('STORAGE');
INSERT INTO "inp_node_type" VALUES ('NOT DEFINED');

 

-- ----------------------------
-- Records of inp_hydrology
-- ----------------------------
INSERT INTO "cat_hydrology" VALUES (1, 'Infiltration default value', 'CURVE_NUMBER', 'Default value of infiltration');
