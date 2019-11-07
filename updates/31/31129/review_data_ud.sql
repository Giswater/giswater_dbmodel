---------
--ud
---------

SET search_path='ud', public;

-- check duplicated parameters on config_param_system
SELECT count(*), parameter FROM config_param_system group by parameter order by 1 desc;

-- delete duplicated
DELETE FROM config_param_system WHERE id IN (SELECT id FROM config_param_system WHERE parameter ='utils_csv2pg_om_visit_parameters' LIMIT 1);
--only ma.ud
DELETE FROM config_param_system WHERE id = 201;


-- SELECT deprecated man_addfields values
SELECT * FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec UNION SELECT gully_id FROM gully);

-- delete deprecated man_addfields values
DELETE FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec UNION SELECT gully_id FROM gully);


-- Check node_1 or node_2 nulls (state=1)
SELECT arc_id,arccat_id,state,the_geom FROM arc WHERE state =1 AND (node_1 IS NULL OR node_2 IS NULL)


-- Check node_1 or node_2 nulls (state=2)
SELECT arc_id,arccat_id,state,the_geom FROM arc WHERE state =2 AND (node_1 IS NULL OR node_2 IS NULL)


-- Check state_type nulls (arc, node, connec, gully)
SELECT arc_id FROM arc WHERE state > 0 AND state_type IS NULL 
SELECT node_id FROM node WHERE state > 0 AND state_type IS NULL 
SELECT connec_id FROM connec WHERE state > 0 AND state_type IS NULL 
SELECT gully_id FROM gully WHERE state > 0 AND state_type IS NULL 


INSERT INTO value_state_type VALUES (51,0,'S/I', FALSE, FALSE);
INSERT INTO value_state_type VALUES (52,1,'S/I', TRUE, FALSE);
INSERT INTO value_state_type VALUES (53,2,'S/I', TRUE, FALSE);

UPDATE node SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE node SET state_type=53 WHERE state_type IS NULL AND state=2;

UPDATE arc SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE arc SET state_type=53 WHERE state_type IS NULL AND state=2;

UPDATE connec SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE connec SET state_type=53 WHERE state_type IS NULL AND state=2;

UPDATE gully SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE gully SET state_type=53 WHERE state_type IS NULL AND state=2;

