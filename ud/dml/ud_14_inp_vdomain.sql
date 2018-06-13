﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
SET search_path = "SCHEMA_NAME", public, pg_catalog;



-- ----------------------------
-- Records of inp_typevalue
-- ----------------------------
 
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_raingage', 'TIMESERIES_RAIN', 'TIMESERIES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_temp', 'TIMESERIES_TEMP', 'TIMESERIES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'FILE_TIME', 'FILE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_temp', 'FILE_TEMP', 'FILE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_windsp', 'FILE_WINDSP', 'FILE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_windsp', 'MONTHLY_WINDSP', 'MONTHLY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'MONTHLY_PATTERN', 'MONTHLY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'FILE_EVAP', 'FILE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_storage', 'TABULAR_STORAGE', 'TABULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'TABULAR_DIVIDER', 'TABULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_inflows', 'CONCEN_INFLOWS', 'CONCEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'TIMESERIES_EVAP', 'TIMESERIES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'TIMESERIES_OUTFALL', 'TIMESERIES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'MONTHLY_EVAP', 'MONTHLY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'TEMPERATURE_EVAP', 'TEMPERATURE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'TIDAL_OUTFALL', 'TIDAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_raingage', 'FILE_RAIN', 'FILE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'EXP_BUILDUP', 'EXP', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'EXT_BUILDUP', 'EXT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'STORAGE_CURVE', 'STORAGE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'TIDAL_CURVE', 'TIDAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'CUTOFF', 'CUTOFF', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'OVERFLOW', 'OVERFLOW', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_divider', 'WEIR', 'WEIR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'CONSTANT', 'CONSTANT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_evap', 'RECOVERY', 'RECOVERY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_orifice', 'BOTTOM', 'BOTTOM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_orifice', 'SIDE', 'SIDE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'FIXED', 'FIXED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'FREE', 'FREE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outfall', 'NORMAL', 'NORMAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'FUNCTIONAL/DEPTH', 'FUNCTIONAL/DEPTH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'FUNCTIONAL/HEAD', 'FUNCTIONAL/HEAD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'TABULAR/DEPTH', 'TABULAR/DEPTH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_outlet', 'TABULAR/HEAD', 'TABULAR/HEAD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'DAILY', 'DAILY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'HOURLY', 'HOURLY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_pattern', 'WEEKEND', 'WEEKEND', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_storage', 'FUNCTIONAL', 'FUNCTIONAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'ABSOLUTE', 'ABSOLUTE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_typevalue_timeseries', 'RELATIVE', 'RELATIVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_allnone', 'ALL', 'ALL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_allnone', 'NONE', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'POW', 'POW', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_buildup', 'SAT', 'SAT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'CIRCULAR', 'CIRCULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'FILLED_CIRCULAR', 'FILLED_CIRCULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_CLOSED', 'RECT_CLOSED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_OPEN', 'RECT_OPEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'TRAPEZOIDAL', 'TRAPEZOIDAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'TRIANGULAR', 'TRIANGULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'HORIZ_ELLIPSE', 'HORIZ_ELLIPSE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'ARCH', 'ARCH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'PARABOLIC', 'PARABOLIC', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'POWER', 'POWER', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_TRIANGULAR', 'RECT_TRIANGULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'RECT_ROUND', 'RECT_ROUND', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'MODBASKETHANDLE', 'MODBASKETHANDLE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'EGG', 'EGG', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'HORSESHOE', 'HORSESHOE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'SEMIELLIPTICAL', 'SEMIELLIPTICAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'BASKETHANDLE', 'BASKETHANDLE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'SEMICIRCULAR', 'SEMICIRCULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'IRREGULAR', 'IRREGULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'CUSTOM', 'CUSTOM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'DUMMY', 'DUMMY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'FORCE_MAIN', 'FORCE_MAIN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_catarc', 'VIRTUAL', 'VIRTUAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'CONTROL', 'CONTROL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'DIVERSION', 'DIVERSION', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP1', 'PUMP1', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP2', 'PUMP2', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP3', 'PUMP3', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'PUMP4', 'PUMP4', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'RATING', 'RATING', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_curve', 'SHAPE', 'SHAPE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_actio', 'SAVE', 'SAVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_actio', 'USE', 'USE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'HOTSTART', 'HOTSTART', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'INFLOWS', 'INFLOWS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'OUTFLOWS', 'OUTFLOWS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RAINFALL', 'RAINFALL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RDII', 'RDII', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_files_type', 'RUNOFF', 'RUNOFF', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_inflows', 'MASS', 'MASS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'DRAIN', 'DRAIN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'PAVEMENT', 'PAVEMENT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'SOIL', 'SOIL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'BC', 'BC', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'PP', 'PP', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'IT', 'IT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'RB', 'RB', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'VS', 'VS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'GR', 'GR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'DRAINMAT', 'DRAINMAT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'DEGREES', 'DEGREES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'FEET', 'FEET', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'METERS', 'METERS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fme', 'D-W', 'D-W', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fme', 'H-W', 'H-W', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'DYNWAVE', 'DYNWAVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'KINWAVE', 'KINWAVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fr', 'STEADY', 'STEADY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'CFS', 'CFS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'CMS', 'CMS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'GPM', 'GPM', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'LPS', 'LPS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'MGD', 'MGD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_fu', 'MLD', 'MLD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'FULL', 'FULL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'PARTIAL', 'PARTIAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'CURVE_NUMBER', 'CURVE_NUMBER', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'GREEN_AMPT', 'GREEN_AMPT', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'HORTON', 'HORTON', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_in', 'MODIFIED_HORTON', 'MODIFIED_HORTON', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_lo', 'DEPTH', 'DEPTH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_lo', 'ELEVATION', 'ELEVATION', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'BOTH', 'BOTH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'FROUD', 'FROUD', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_nfl', 'SLOPE', 'SLOPE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', '#/L', '#/L', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', 'MG/L', 'MG/L', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_pollutants', 'UG/L', 'UG/L', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'CUMULATIVE', 'CUMULATIVE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'INTENSITY', 'INTENSITY', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_raingage', 'VOLUME', 'VOLUME', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'OUTLET', 'OUTLET', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'IMPERVIOUS', 'IMPERVIOUS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_routeto', 'PERVIOUS', 'PERVIOUS', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status', 'ON', 'ON', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_status', 'OFF', 'OFF', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Evaporation', 'Evaporation', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Inflow_Hydrograph', 'Inflow_Hydrograph', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Inflow_Pollutograph', 'Inflow_Pollutograph', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Rainfall', 'Rainfall', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'RATE', 'RATE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'REMOVAL', 'REMOVAL', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'EMC', 'EMC', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'RC', 'RC', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'NO', 'NO', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_yesno', 'YES', 'YES', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'V-NOTCH', 'V-NOTCH', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'SIDEFLOW', 'SIDEFLOW', 'RECT_OPEN');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'TRANSVERSE', 'TRANSVERSE', 'RECT_OPEN');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_orifice', 'RECT-CLOSED_ORIFICE', 'RECT-CLOSED', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_orifice', 'CIRCULAR_ORIFICE', 'CIRCULAR', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_treatment', 'CONCEN_TREAT', 'CONCEN', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_mapunits', 'NONE_MAP', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_options_id', 'NONE_OPTION', 'NONE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_weirs', 'TRAPEZOIDAL_WEIR', 'TRAPEZOIDAL', 'TRAPEZOIDAL');
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'STORAGE_LID', 'STORAGE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_lidcontrol', 'SURFACE_LID', 'SURFACE', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_timserid', 'Temperature_time', 'Temperature', NULL);
INSERT INTO inp_typevalue (typevalue, id, idval, descript) VALUES ('inp_value_washoff', 'EXP_WASHOFF', 'EXP', NULL);



-- ----------------------------
-- Records of inp_options
-- ----------------------------
 
INSERT INTO inp_options 
VALUES (1,'CMS', 'DYNWAVE', 'ELEVATION', 'H-W', 'NO', 'NO', 'NO', 'NO', 'NO', 'NO', '01/01/2017', '00:00:00', '01/02/2017', '00:00:00', '01/01/2001', '00:00:00', '01/01', '12/31', 10, '00:05:00', '00:05:00', '01:00:00', '00:00:02', NULL, NULL, 'NONE_OPTION', 'BOTH', 0.000000, 0.000000, 'YES', NULL, 0, 0.0000, 5, 5);

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
