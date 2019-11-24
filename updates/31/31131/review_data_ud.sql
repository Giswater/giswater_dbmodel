---------
--ud
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
INSERT INTO inp_junction (node_id) SELECT node_id FROM node WHERE epa_type='JUNCTION' on conflict (node_id) DO nothing;
INSERT INTO inp_outfall (node_id) SELECT node_id FROM node WHERE epa_type='OUTFALL' on conflict (node_id) DO nothing;
INSERT INTO inp_storage (node_id) SELECT node_id FROM node WHERE epa_type='STORAGE' on conflict (node_id) DO nothing;
INSERT INTO inp_divider (node_id) SELECT node_id FROM node WHERE epa_type='DIVIDER' on conflict (node_id) DO nothing;
INSERT INTO inp_pump (arc_id) SELECT arc_id FROM node WHERE epa_type='PUMP' on conflict (arc_id) DO nothing;
INSERT INTO inp_conduit (arc_id) SELECT arc_id FROM arc WHERE epa_type='CONDUIT' on conflict (arc_id) DO nothing;
INSERT INTO inp_weir (arc_id) SELECT arc_id FROM arc WHERE epa_type='WEIR' on conflict (arc_id) DO nothing;
INSERT INTO inp_orifice (arc_id) SELECT arc_id FROM arc WHERE epa_type='ORIFICE' on conflict (arc_id) DO nothing;
INSERT INTO inp_outlet (arc_id) SELECT arc_id FROM arc WHERE epa_type='OUTLET' on conflict (arc_id) DO nothing;
INSERT INTO inp_virtual (arc_id) SELECT arc_id FROM arc WHERE epa_type='VIRTUAL' on conflict (arc_id) DO nothing



