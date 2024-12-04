/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(541, 'Gully without link', 'ud', NULL, 'core', true, 'Check om-data', NULL, NULL, 'gullys without links or gullies over arc without arc_id.', NULL, 'SELECT gully_id, gratecat_id, c.the_geom, c.expl_id from v_prefix_gully c WHERE c.state= 1 
AND gully_id NOT IN (SELECT feature_id FROM link)
EXCEPT 
SELECT gully_id, gratecat_id, c.the_geom, c.expl_id FROM v_prefix_gully c
LEFT JOIN v_prefix_arc a USING (arc_id) WHERE c.state= 1 
AND arc_id IS NOT NULL AND st_dwithin(c.the_geom, a.the_geom, 0.1)', 'All gullies have links or are over arc with arc_id.', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(542, 'feature which id is not an integer', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'which id is not an integer. Please, check your data before continue', NULL, 'SELECT CASE WHEN arc_id~E''^\\d+$'' THEN CAST (arc_id AS INTEGER)
ELSE 0 END  as feature_id, ''ARC'' as type, arccat_id as featurecat,the_geom, expl_id  FROM arc
UNION SELECT CASE WHEN node_id~E''^\\d+$'' THEN CAST (node_id AS INTEGER)
ELSE 0 END as feature_id, ''NODE'' as type, nodecat_id as featurecat,the_geom, expl_id FROM node
UNION SELECT CASE WHEN connec_id~E''^\\d+$'' THEN CAST (connec_id AS INTEGER)
ELSE 0 END as feature_id, ''CONNEC'' as type, connecat_id as featurecat,the_geom, expl_id FROM connec
UNION SELECT CASE WHEN gully_id~E''^\\d+$'' THEN CAST (gully_id AS INTEGER)
ELSE 0 END as feature_id, ''GULLY'' as type, gratecat_id as featurecat,the_geom, expl_id FROM gully', 'All features with id integer.', '[gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;


INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(543, 'Gully chain with different arc_id than the final connec/gully', 'ud', NULL, 'core', true, 'Check om-data', NULL, NULL, 'chained connecs/gullys without links or gullies over arc without arc_id.', NULL, 'with c as (
Select v_prefix_connec.connec_id as id, arc_id as arc, v_prefix_connec.connecat_id as 
feature_catalog, the_geom, v_prefix_connec.expl_id from v_prefix_connec
UNION select v_prefix_gully.gully_id as id, arc_id as arc, v_prefix_gully.gratecat_id, 
the_geom, v_prefix_gully.expl_id  from v_prefix_gully
)
select c1.id, c1.feature_catalog, c1.the_geom,  c1.expl_id
from link a
left join c c1 on a.feature_id = c1.id
left join c c2 on a.exit_id = c2.id
where (a.exit_type =''CONNEC'' OR a.exit_type =''GULLY'')
and c1.arc <> c2.arc', 'All chained connecs and gullies have the same arc_id.', '[gw_fct_om_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(545, 'State not according with state_type', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with state without concordance with state_type. Please, check your data before continue features with state without concordance with state_type. Please, check your data before continue', NULL, 'SELECT arc_id as id, a.state, state_type FROM v_prefix_arc a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
UNION SELECT node_id as id, a.state, state_type FROM v_prefix_node a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
UNION SELECT connec_id as id, a.state, state_type FROM v_prefix_connec a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state
UNION SELECT gully_id as id, a.state, state_type FROM v_prefix_gully a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state	
UNION SELECT element_id as id, a.state, state_type FROM v_prefix_element a JOIN value_state_type b ON id=state_type WHERE a.state <> b.state', 'No features without concordance against state and state_type.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(547, 'Check fluid_type values exists on man_ table', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with fluid_type does not exists on man_type_fluid table.', NULL, 'SELECT ''ARC'', arc_id, fluid_type FROM v_prefix_arc WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
UNION
SELECT ''NODE'', node_id, fluid_type FROM v_prefix_node WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
UNION
SELECT ''CONNEC'', connec_id, fluid_type FROM v_prefix_connec WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL
UNION
SELECT ''GULLY'', gully_id, fluid_type FROM v_prefix_gully WHERE fluid_type NOT IN (SELECT fluid_type FROM man_type_fluid WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND fluid_type IS NOT NULL', 'All features has fluid_type informed on man_type_fluid table', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(548, 'Check orphan elements', 'ud', NULL, 'core', true, 'Function process', NULL, 2, 'elements not related to any feature and without geometry.', NULL, 'select element_id, the_geom from element where the_geom is null and element_id not in (
with mec as (select distinct element_id from element_x_arc UNION
select distinct element_id from element_x_connec UNION
select distinct element_id from element_x_node UNION
select distinct element_id from element_x_gully)
select a.element_id from mec a left join "element" b using (element_id))', 'All elements are related to the features or have geometry.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(549, 'Node orphan with isarcdivide=TRUE (OM)', 'ud', NULL, 'core', true, 'Check om-topology', NULL, 2, 'orphan nodes with isarcdivide=TRUE.', NULL, 'SELECT * FROM v_prefix_node a JOIN cat_feature_node ON id = a.node_type WHERE a.state>0 AND isarcdivide= ''true'' 
AND (SELECT COUNT(*) FROM arc WHERE node_1 = a.node_id OR node_2 = a.node_id and arc.state>0) = 0', 'There are no orphan nodes with isarcdivide=TRUE', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;




INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(550, 'Check function_type values exists on man_ table', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with function_type does not exists on man_type_function table.', NULL, 'SELECT ''ARC'', arc_id, function_type FROM v_prefix_arc WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
UNION
SELECT ''NODE'', node_id, function_type FROM v_prefix_node WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
UNION
SELECT ''CONNEC'', connec_id, function_type FROM v_prefix_connec WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL
UNION
SELECT ''GULLY'', gully_id, function_type FROM v_prefix_gully WHERE function_type NOT IN (SELECT function_type FROM man_type_function WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND function_type IS NOT NULL', 'All features has function_type informed on man_type_function table', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(551, 'Features state=1 and end date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features on service with value of end date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where state = 1 and enddate is not null
UNION SELECT node_id as feature_id from v_prefix_node where state = 1 and enddate is not null
UNION SELECT connec_id as feature_id from v_prefix_connec where state = 1 and enddate is not null
UNION SELECT gully_id as feature_id from v_prefix_gully where state = 1 and enddate is not null', 'No features on service have value of end date', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(552, 'Gully without or with wrong arc_id', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'gullies without or with incorrect arc_id.', NULL, 'SELECT c.gully_id, c.gratecat_id, c.the_geom, c.expl_id, l.feature_type, link_id 
FROM arc a, link l
JOIN v_prefix_gully c ON l.feature_id = c.gully_id 
WHERE st_dwithin(a.the_geom, st_endpoint(l.the_geom), 0.01)
AND exit_type = ''ARC''
AND (a.arc_id <> c.arc_id or c.arc_id is null) 
AND l.feature_type = ''GULLY'' AND a.state=1 and c.state = 1 and l.state=1
EXCEPT
SELECT c.gully_id, c.gratecat_id, c.the_geom, c.expl_id, l.feature_type, link_id
FROM node n, link l
JOIN v_prefix_gully c ON l.feature_id = c.gully_id 
WHERE st_dwithin(n.the_geom, st_endpoint(l.the_geom), 0.01)
AND exit_type IN (''NODE'', ''ARC'')
AND l.feature_type = ''GULLY'' AND n.state=1 and c.state = 1 and l.state=1
ORDER BY feature_type, link_id', 'All connecs have correct arc_id. All gullies have correct arc_id.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(553, 'Features with code null', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with code with NULL values. Please, check your data before continue with code with NULL values. Please, check your data before continue', NULL, 'SELECT arc_id, arccat_id, the_geom FROM v_prefix_arc WHERE code IS NULL 
UNION SELECT node_id, nodecat_id, the_geom FROM v_prefix_node WHERE code IS NULL
UNION SELECT connec_id, connecat_id, the_geom FROM v_prefix_connec WHERE code IS NULL
UNION SELECT gully_id, gratecat_id, the_geom FROM v_prefix_gully WHERE code IS NULL
UNION SELECT element_id, elementcat_id, the_geom FROM v_prefix_element WHERE code IS NULL', 'No features (arc, node, connec, element, gully) with NULL values on code found.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(554, 'Features state=0 without end date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features with state 0 without value of end date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where state = 0 and enddate is null
UNION SELECT node_id from v_prefix_node where state = 0 and enddate is null
UNION SELECT connec_id from v_prefix_connec where state = 0 and enddate is null
UNION SELECT gully_id from v_prefix_gully where state = 0 and enddate is null', 'No features with state 0 are missing the end date', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(555, 'Check connecs with more than 1 link on service', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'connecs with more than 1 link on service', NULL, 'SELECT connec_id, connecat_id, the_geom, expl_id FROM v_prefix_connec WHERE connec_id 
IN (SELECT feature_id FROM link WHERE state=1 GROUP BY feature_id HAVING count(*) > 1)
UNION SELECT gully_id, gratecat_id, the_geom, expl_id FROM v_prefix_gully WHERE gully_id 
IN (SELECT feature_id FROM link WHERE state=1 GROUP BY feature_id HAVING count(*) > 1)', 'No connects with more than 1 link on service', '[gw_fct_om_check_data, gw_fct_pg2epa_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(556, 'Check orphan visits', 'ud', NULL, 'core', true, 'Function process', NULL, 2, 'visits not related to any feature and without geometry.', NULL, 'select id, the_geom from om_visit where the_geom is null and id not in (
with mec as (
select distinct visit_id from om_visit_x_arc UNION
select distinct visit_id from om_visit_x_connec UNION
select distinct visit_id from om_visit_x_node UNION
select distinct visit_id from om_visit_x_gully)
select a.visit_id from mec a left join om_visit b on a.visit_id = id
)', 'All visits are related to the features or have geometry.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(557, 'Builddate before 1900', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features with built date before 1900.', NULL, 'SELECT arc_id, ''ARC''::text FROM v_prefix_arc WHERE builtdate < ''1900/01/01''::date
UNION 
SELECT  node_id, ''NODE''::text FROM v_prefix_node WHERE builtdate < ''1900/01/01''::date
UNION  
SELECT  connec_id, ''CONNEC''::text FROM v_prefix_connec WHERE builtdate < ''1900/01/01''::date
UNION 
SELECT  gully_id, ''GULLY''::text FROM v_prefix_gully WHERE builtdate < ''1900/01/01''::date', 'No feature with builtdate before 1900.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(558, 'Check location_type values exists on man_ table', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with location_type does not exists on man_type_location table.', NULL, 'SELECT ''ARC'', arc_id, location_type FROM v_prefix_arc WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
UNION
SELECT ''NODE'', node_id, location_type FROM v_prefix_node WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
UNION
SELECT ''CONNEC'', connec_id, location_type FROM v_prefix_connec WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL
UNION
SELECT ''GULLY'', gully_id, location_type FROM v_prefix_gully WHERE location_type NOT IN (SELECT location_type FROM man_type_location WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND location_type IS NOT NULL', 'All features has location_type informed on man_type_location table', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(559, 'Planned connecs without reference link', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'planned connecs without reference link planned connecs or gullys without reference link', NULL, 'SELECT * FROM plan_psector_x_connec WHERE link_id IS NULL
UNION SELECT * FROM plan_psector_x_gully WHERE link_id IS NULL', 'All planned connecs or gullys have a reference link', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(561, 'Duplicated ID between arc, node, connec, gully', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with duplicated ID value between arc, node, connec, gully features with duplicated ID values between arc, node, connec, gully', NULL, 'SELECT * FROM (SELECT node_id FROM node UNION ALL SELECT arc_id FROM arc UNION ALL SELECT connec_id FROM connec UNION ALL SELECT gully_id FROM gully)a 
group by node_id having count(*) > 1', 'All features have a diferent ID to be correctly identified', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(562, 'Features state=2 are involved in psector', 'ud', NULL, 'core', true, 'Check plan-config', NULL, 3, 'planified arcs without psector. planified nodes without psector. planified connecs without psector. planified gullys without psector. features with state=2 without psector assigned. Please, check your data before continue', NULL, 'SELECT a.arc_id FROM v_prefix_arc a RIGHT JOIN plan_psector_x_arc USING (arc_id) WHERE a.state = 2 AND a.arc_id IS NULL
UNION
SELECT a.node_id FROM v_prefix_node a RIGHT JOIN plan_psector_x_node USING (node_id) WHERE a.state = 2 AND a.node_id IS NULL
UNION
SELECT a.connec_id FROM v_prefix_connec a RIGHT JOIN plan_psector_x_connec USING (connec_id) WHERE a.state = 2 AND a.connec_id IS NULL
UNION 
SELECT a.gully_id FROM v_prefix_gully a RIGHT JOIN plan_psector_x_gully USING (gully_id) WHERE a.state = 2 AND a.gully_id IS NULL', 'There are no features with state=2 without psector.', '[gw_fct_plan_check_data, gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(563, 'Connec or gully with different expl_id than arc', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'connecs with exploitation different than the exploitation of the related arc', NULL, 'SELECT DISTINCT connec_id, connecat_id, c.the_geom, c.expl_id FROM v_prefix_connec c JOIN v_prefix_arc b using (arc_id) 
WHERE b.expl_id::text != c.expl_id::text
UNION 
SELECT DISTINCT  gully_id, gratecat_id, g.the_geom gully_id, g.expl_id FROM v_prefix_gully g JOIN v_prefix_arc d using (arc_id) WHERE d.expl_id::text != g.expl_id::text', 'All connecs or gullys have the same exploitation as the related arc', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(564, 'Check orphan documents', 'ud', NULL, 'core', true, 'Function process', NULL, 2, 'documents not related to any feature.', NULL, 'select id from doc where id not in (
select distinct  doc_id from doc_x_arc UNION
select distinct  doc_id from doc_x_connec UNION
select distinct  doc_id from doc_x_node UNION
select distinct  doc_id from doc_x_gully)', 'All documents are related to the features.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(565, 'Node orphan with isarcdivide=FALSE (OM)', 'ud', NULL, 'core', true, 'Check om-topology', NULL, 2, 'orphan nodes with isarcdivide=FALSE.', NULL, 'SELECT * FROM v_prefix_node a JOIN cat_feature_node ON id = a.node_type WHERE a.state>0 AND isarcdivide=''false''', 'There are no orphan nodes with isarcdivide=FALSE', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(566, 'Features state=1 and end date before start date', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'features with end date earlier than built date.', NULL, 'SELECT arc_id as feature_id from v_prefix_arc where enddate < builtdate and state = 1
UNION SELECT node_id from v_prefix_node where enddate < builtdate and state = 1
UNION SELECT connec_id from v_prefix_connec where enddate < builtdate and state = 1
UNION SELECT gully_id from v_prefix_gully where enddate < builtdate and state = 1', 'No features with end date earlier than built date', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(567, 'Check features without defined sector_id', 'ud', NULL, 'core', true, 'Check om-data', NULL, 2, 'connecs with sector_id 0 or -1.', NULL, 'SELECT connec_id, connecat_id, the_geom, expl_id FROM v_prefix_connec WHERE state > 0 AND (sector_id=0 OR sector_id=-1)
UNION SELECT gully_id, gratecat_id, the_geom, expl_id FROM v_prefix_gully WHERE state > 0 AND (sector_id=0 OR sector_id=-1)', 'No connecs with 0 or -1 value on sector_id.', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;

INSERT INTO sys_fprocess (fid, fprocess_name, project_type, parameters, "source", isaudit, fprocess_type, addparam, except_level, except_msg, except_msg_feature, query_text, info_msg, function_name) VALUES(568, 'Check category_type values exists on man_ table', 'ud', NULL, 'core', true, 'Check om-data', NULL, 3, 'features with category_type does not exists on man_type_category table.', NULL, 'SELECT ''ARC'', arc_id, category_type FROM v_prefix_arc WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''ARC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
UNION
SELECT ''NODE'', node_id, category_type FROM v_prefix_node WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''NODE'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
UNION
SELECT ''CONNEC'', connec_id, category_type FROM v_prefix_connec WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''CONNEC'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL
UNION
SELECT ''GULLY'', gully_id, category_type FROM v_prefix_gully WHERE category_type NOT IN (SELECT category_type FROM man_type_category WHERE feature_type is null or feature_type = ''GULLY'' or featurecat_id IS NOT NULL) AND category_type IS NOT NULL', 'All features has category_type informed on man_type_category table', '[gw_fct_om_check_data, gw_fct_admin_check_data]') ON CONFLICT (fid) DO NOTHING;




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
UPDATE sys_fprocess SET fprocess_name='Conduits with negative slope and inverted slope', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-topology', addparam=NULL, except_level=3, except_msg='arcs with inverted slope false and slope negative values. Please, check your data before continue', except_msg_feature=NULL, query_text='SELECT a.arc_id, arccat_id, a.the_geom, expl_id FROM arc a WHERE sys_slope < 0 AND state > 0 AND inverted_slope IS FALSE', info_msg='No arcs with inverted slope checked found.', function_name='[gw_fct_om_check_data]' WHERE fid=251;
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

UPDATE sys_fprocess SET fprocess_name='Check redundant values on y-top_elev-elev', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-topology', addparam=NULL, except_level=NULL, except_msg='nodes with redundancy on ymax, top_elev & elev values.', except_msg_feature=NULL, query_text='SELECT node_id, nodecat_id, the_geom, expl_id FROM v_prefix_node WHERE (ymax is not null or custom_ymax is not null) 
and (top_elev is not null or custom_top_elev is not null) and (elev is not null or custom_elev is not null)', info_msg='There are no nodes with redundancy on ymax, top_elev & elev values.', function_name='[gw_fct_om_check_data]' WHERE fid=461;

UPDATE sys_fprocess SET fprocess_name='Links without gully on startpoint', project_type='ud', parameters=NULL, "source"='core', isaudit=true, fprocess_type='Check om-data', addparam=NULL, except_level=NULL, except_msg='links with wrong topology. Startpoint does not fit with connec.', except_msg_feature=NULL, query_text='with subq1 as (SELECT l.link_id, c.connec_id, c.the_geom FROM connec c, link l
WHERE l.state = 1 and c.state = 1 and ST_DWithin(ST_startpoint(l.the_geom), c.the_geom, 0.01) group by 1,2 ORDER BY 1 DESC)
select connec_id, the_geom From subq1 where connec_id not in (select connec_id from connec)', info_msg='All connec links has connec on startpoint', function_name='[gw_fct_om_check_data]' WHERE fid=418;