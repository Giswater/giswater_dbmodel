/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(580, 'Features state=2 are involved in psector', 'ud', NULL, 'core', true, 'Check plan-config', NULL, 3, 'planified arcs without psector. planified nodes without psector. planified connecs without psector. planified gullys without psector. features with state=2 without psector assigned. Please, check your data before continue', NULL, 'SELECT a.feature_id, a.feature , a.catalog, a.the_geom, count(*) FROM (
SELECT node_id as feature_id, ''NODE'' as feature, nodecat_id as catalog, 
the_geom FROM v_edit_node WHERE state=2 AND node_id NOT IN 
(select node_id FROM plan_psector_x_node) UNION  
SELECT arc_id as feature_id, ''ARC'' as feature, arccat_id as catalog, 
the_geom  FROM v_edit_arc WHERE state=2 AND arc_id NOT IN 
(select arc_id FROM plan_psector_x_arc) UNION  
SELECT connec_id as feature_id, ''CONNEC'' as feature, connecat_id  as catalog, the_geom  FROM v_edit_connec WHERE state=2 AND connec_id NOT IN 
(select connec_id FROM plan_psector_x_connec) UNION 
SELECT gully_id as feature_id, ''GULLY'' as feature , gratecat_id as catalog, the_geom 
FROM v_edit_gully WHERE state=2 AND gully_id NOT IN (select gully_id FROM plan_psector_x_gully)) a
GROUP BY a.feature_id, a.feature ,a.catalog, a.the_geom', 'There are no features with state=2 without psector.', '[gw_fct_plan_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(582, 'State not according with state_type', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with state without concordance with state_type. Please, check your data before continue features with state without concordance with state_type. Please, check your data before continue', NULL, 'SELECT arc_id as id, a.state, state_type FROM v_prefix_arc a 
JOIN value_state_type b ON id=state_type 
WHERE a.state <> b.state UNION 
SELECT node_id as id, a.state, state_type FROM v_prefix_node a 
JOIN value_state_type b ON id=state_type WHERE a.state <> b.state UNION 
SELECT connec_id as id, a.state, state_type FROM v_prefix_connec a 
JOIN value_state_type b ON id=state_type WHERE a.state <> b.state UNION 
SELECT gully_id as id, a.state, state_type FROM v_prefix_gully a 
JOIN value_state_type b ON id=state_type WHERE a.state <> b.state UNION 
SELECT element_id as id, a.state, state_type FROM v_prefix_element a 
JOIN value_state_type b ON id=state_type WHERE a.state <> b.state', 'No features without concordance against state and state_type.', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(584, 'Features with code null', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with code with NULL values. Please, check your data before continue with code with NULL values. Please, check your data before continue', NULL, 'SELECT arc_id, arccat_id, the_geom FROM v_prefix_arc WHERE code IS NULL UNION 
SELECT node_id, nodecat_id, the_geom FROM v_prefix_node WHERE code IS NULL UNION 
SELECT connec_id, connecat_id, the_geom FROM v_prefix_connec WHERE code IS NULL UNION 
SELECT gully_id, gratecat_id, the_geom FROM v_prefix_gully WHERE code IS NULL UNION 
SELECT element_id, elementcat_id, the_geom FROM v_prefix_element WHERE code IS NULL', 'No features (arc, node, connec, gully, element) with NULL values on code found. No features (arc, node, connec, element) with NULL values on code found.', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(586, 'Features state=1 and end date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features on service with value of end date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where state = 1 and enddate is not null UNION 
SELECT node_id from v_prefix_node where state = 1 and enddate is not null UNION 
SELECT connec_id from v_prefix_connec where state = 1 and enddate is not null UNION 
SELECT gully_id from v_prefix_gully where state = 1 and enddate is not null', 'No features on service have value of end date', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(588, 'Features state=0 without end date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features with state 0 without value of end date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where state = 0 and enddate is null UNION 
SELECT node_id from v_prefix_node where state = 0 and enddate is null UNION 
SELECT connec_id from v_prefix_connec where state = 0 and enddate is null UNION 
SELECT gully_id from v_prefix_gully where state = 0 and enddate is null', 'No features with state 0 are missing the end date', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(590, 'Features state=1 and end date before start date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features with end date earlier than built date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where enddate < builtdate and state = 1 UNION 
SELECT node_id from v_prefix_node where enddate < builtdate and state = 1 UNION 
SELECT connec_id from v_prefix_connec where enddate < builtdate and state = 1 UNION 
SELECT gully_id from v_prefix_gully where enddate < builtdate and state = 1', 'No features with end date earlier than built date', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(592, 'Duplicated ID between arc, node, connec, gully', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with duplicated ID value between arc, node, connec, gully features with duplicated ID values between arc, node, connec, gully', NULL, 'SELECT node_id AS feature_id FROM v_prefix_node n JOIN v_prefix_arc a ON a.arc_id=n.node_id UNION 
SELECT node_id FROM v_prefix_node n JOIN v_prefix_connec c ON c.connec_id=n.node_id UNION 
SELECT node_id FROM v_prefix_node n JOIN v_prefix_gully g ON g.gully_id=n.node_id UNION 
SELECT connec_id FROM v_prefix_connec c JOIN v_prefix_gully g ON g.gully_id=c.connec_id UNION 
SELECT a.arc_id FROM v_prefix_arc a JOIN v_prefix_connec c ON c.connec_id=a.arc_id UNION 
SELECT a.arc_id FROM v_prefix_arc a JOIN v_prefix_gully g ON g.gully_id=a.arc_id', 'All features have a diferent ID to be correctly identified', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(596, 'Node orphan with isarcdivide=TRUE (OM)', 'ud', NULL, 'core', true, 'Check om-topology', NULL, 2, 'orphan nodes with isarcdivide=TRUE.', NULL, 'SELECT * FROM v_prefix_node a JOIN cat_feature_node ON id = a.node_type WHERE a.state>0 AND isarcdivide = true 
AND (SELECT COUNT(*) FROM arc WHERE node_1 = a.node_id OR node_2 = a.node_id and arc.state>0) = 0', 'There are no orphan nodes with isarcdivide=TRUE', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(598, 'Node orphan with isarcdivide=FALSE (OM)', 'ud', NULL, 'core', true, 'Check om-topology', NULL, 2, 'orphan nodes with isarcdivide=FALSE.', NULL, 'SELECT  * FROM v_edit_node a JOIN cat_feature_node ON id = a.node_type WHERE a.state>0 AND isarcdivide=false', 'There are no orphan nodes with isarcdivide=FALSE', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(541, 'Gully without link', 'ud', NULL, 'core', true, 'Check om-data', NULL, NULL, 'gullys without links or gullies over arc without arc_id.', NULL, 'SELECT gully_id, gratecat_id, c.the_geom, c.expl_id from v_prefix_gully c WHERE c.state= 1 
AND gully_id NOT IN (SELECT feature_id FROM link)
EXCEPT 
SELECT gully_id, gratecat_id, c.the_geom, c.expl_id FROM v_prefix_gully c
LEFT JOIN v_prefix_arc a USING (arc_id) WHERE c.state= 1 
AND arc_id IS NOT NULL AND st_dwithin(c.the_geom, a.the_geom, 0.1)', 'All gullies have links or are over arc with arc_id.', '[gw_fct_om_check_data]');

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(542, 'feature which id is not an integer', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'which id is not an integer. Please, check your data before continue', NULL, 'SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat,the_geom, expl_id  FROM v_prefix_arc
UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat,the_geom, expl_id FROM v_prefix_node
UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat,the_geom, expl_id FROM v_prefix_connec
UNION SELECT CASE WHEN gully_id~E''^\\d+$'' THEN CAST (gully_id AS INTEGER)
ELSE 0 END as feature_id, ''GULLY'' as type, gratecat_id as featurecat,the_geom, expl_id FROM v_prefix_gully', 'All features with id integer.', '[gw_fct_om_check_data, gw_fct_admin_check_data]');


UPDATE sys_fprocess SET fprocess_name='Arc intersection', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=109;
UPDATE sys_fprocess SET fprocess_name='Arc inverted', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=110;
UPDATE sys_fprocess SET fprocess_name='Node exit upper intro', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=111;
UPDATE sys_fprocess SET fprocess_name='Node flow regulator', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=112;
UPDATE sys_fprocess SET fprocess_name='Node sink', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=113;
UPDATE sys_fprocess SET fprocess_name='EDIT check data', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=116;
UPDATE sys_fprocess SET fprocess_name='SYS check data', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Not used', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=126;
UPDATE sys_fprocess SET fprocess_name='Flow trace', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=220;
UPDATE sys_fprocess SET fprocess_name='Flow exit', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=221;
UPDATE sys_fprocess SET fprocess_name='Import gully visits', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=243;
UPDATE sys_fprocess SET fprocess_name='Slope consistency', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=250;
UPDATE sys_fprocess SET fprocess_name='Conduits with negative slope and inverted slope', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-topology', addparam=NULL, except_level=3, except_msg='arcs with inverted slope false and slope negative values. Please, check your data before continue', except_msg_feature=NULL, query_text='SELECT a.arc_id, arccat_id, a.the_geom, expl_id FROM v_prefix_arc a WHERE sys_slope < 0 AND state > 0 AND inverted_slope IS FALSE', info_msg='No arcs with inverted slope checked found.', function_name='[gw_fct_om_check_data]' WHERE fid=251;
UPDATE sys_fprocess SET fprocess_name='Orphan polygons', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-topology', addparam=NULL, except_level=2, except_msg='polygons without parent. Check your data before continue. polygons without parent. Check your data before continue.', except_msg_feature=NULL, query_text='SELECT pol_id FROM polygon WHERE feature_id IS NULL OR feature_id NOT IN (SELECT gully_id FROM gully UNION
SELECT node_id FROM node UNION SELECT connec_id FROM connec)', info_msg='No polygons without parent feature found.', function_name='[gw_fct_om_check_data, gw_fct_admin_check_data]' WHERE fid=255;
UPDATE sys_fprocess SET fprocess_name='Arcs without elevation', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=284;
UPDATE sys_fprocess SET fprocess_name='Null values on raingage', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=285;
UPDATE sys_fprocess SET fprocess_name='Null values on raingage timeseries', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=286;
UPDATE sys_fprocess SET fprocess_name='Null values on raingage file', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=287;
UPDATE sys_fprocess SET fprocess_name='Check cat_feature_node field isexitupperintro', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check admin', addparam=NULL, except_level=3, except_msg='nodes without value on field "isexitupperintro" from cat_feature_node.', except_msg_feature=NULL, query_text='SELECT * FROM cat_feature_node WHERE isexitupperintro IS NULL', info_msg='All nodes have value on field "isexitupperintro"', function_name='[gw_fct_admin_check_data]' WHERE fid=308;
UPDATE sys_fprocess SET fprocess_name='Check cat_node field estimated_y', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check plan-config', addparam=NULL, except_level=2, except_msg='rows without values on cat_node.estimated_y column.', except_msg_feature=NULL, query_text='SELECT * FROM cat_node WHERE estimated_y IS NULL and active=TRUE', info_msg='There is/are no rows without values on cat_node.estimated_y column.', function_name='[gw_fct_plan_check_data]' WHERE fid=331;
UPDATE sys_fprocess SET fprocess_name='Check cat_grate field active', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check plan-config', addparam=NULL, except_level=3, except_msg='rows without values on cat_grate.active column.', except_msg_feature=NULL, query_text='SELECT * FROM cat_grate WHERE active IS NULL', info_msg='There is/are no rows without values on cat_grate.active column.', function_name='[gw_fct_plan_check_data]' WHERE fid=344;
UPDATE sys_fprocess SET fprocess_name='Check cat_grate field cost_ut', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check plan-config', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=345;
UPDATE sys_fprocess SET fprocess_name='Check subcatchment configuration', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=369;
UPDATE sys_fprocess SET fprocess_name='Check features with sector_id=0', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=370;
UPDATE sys_fprocess SET fprocess_name='Nodes with duplicated values of top_elev, ymax and elev', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=389;
UPDATE sys_fprocess SET fprocess_name='Arcs with duplicated values of y and elev', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=390;
UPDATE sys_fprocess SET fprocess_name='Check gully duplicated', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-data', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=393;
UPDATE sys_fprocess SET fprocess_name='Import istram nodes', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=408;
UPDATE sys_fprocess SET fprocess_name='Import istram arcs', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Function process', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=409;
UPDATE sys_fprocess SET fprocess_name='Check minimun length for arcs', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-network', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=431;
UPDATE sys_fprocess SET fprocess_name='Check outlet_id assigned to subcatchments', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check epa-config', addparam=NULL, except_level=NULL, except_msg=NULL, except_msg_feature=NULL, query_text=NULL, info_msg=NULL, function_name=NULL WHERE fid=440;



