---------
--ws
---------

SET search_path='SCHEMA_NAME', public;

-- arcs with state not congruent with nodes
SELECT a.arc_id, arccat_id, the_geom FROM arc a JOIN '||v_edit||'node n ON node_1=node_id WHERE a.state =1 AND n.state=0 
UNION
SELECT a.arc_id, arccat_id, the_geom FROM arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=0

SELECT a.arc_id, arccat_id, the_geom FROM arc a JOIN '||v_edit||'node n ON node_1=node_id WHERE a.state =1 AND n.state=2
UNION
SELECT a.arc_id, arccat_id, the_geom FROM arc a JOIN '||v_edit||'node n ON node_2=node_id WHERE a.state =1 AND n.state=2

-- repair epa tables
INSERT INTO inp_tank (node_id) SELECT node_id FROM node WHERE epa_type='TANK' on conflict (node_id) DO nothing;
INSERT INTO inp_reservoir (node_id) SELECT node_id FROM node WHERE epa_type='RESERVOIR' on conflict (node_id) DO nothing;
INSERT INTO inp_pump (node_id) SELECT node_id FROM node WHERE epa_type='PUMP' on conflict (node_id) DO nothing;
INSERT INTO inp_shortpipe (node_id) SELECT node_id FROM node WHERE epa_type='SHORTPIPE' on conflict (node_id) DO nothing;
INSERT INTO inp_valve (node_id) SELECT node_id FROM node WHERE epa_type='VALVE' on conflict (node_id) DO nothing;
INSERT INTO inp_pipe (arc_id) SELECT node_id FROM arc WHERE epa_type='PIPE' on conflict (arc_id) DO nothing;



