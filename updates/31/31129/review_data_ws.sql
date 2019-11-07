---------
--ws
---------

SET search_path='ws', public;

-- check duplicated parameters on config_param_system
SELECT count(*), parameter FROM config_param_system group by parameter order by 1 desc;

-- delete duplicated param on config_param_system
DELETE FROM config_param_system WHERE id IN (SELECT id FROM config_param_system WHERE parameter ='basic_search_workcat_filter' LIMIT 1);
--only ma.ws
--DELETE FROM config_param_system WHERE id = 201;

-- SELECT deprecated man_addfields values
SELECT * FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec);

-- delete deprecated man_addfields values
DELETE FROM man_addfields_value WHERE feature_id NOT IN (SELECT arc_id FROM arc UNION SELECT node_id FROM node UNION SELECT connec_id FROM connec);

-- Check node_1 or node_2 nulls (state=1)
SELECT arc_id,arccat_id,state,the_geom FROM arc WHERE state =1 AND (node_1 IS NULL OR node_2 IS NULL)

-- reconnect
UPDATE arc SET the_geom = the_geom WHERE state=1 and (node_1 IS NULL OR node_2 IS NULL)

-- Check node_1 or node_2 nulls (state=2)
SELECT arc_id,arccat_id,state,the_geom FROM arc WHERE state =2 AND (node_1 IS NULL OR node_2 IS NULL)

-- reconnect
-- set psector (on nomUsuari és el teu nom d'usuari i numPsector, el numero de psector al que pertany el tram de la llista anterior)
delete from selector_psector where cur_user='nomUsuari';
insert into selector_psector (psector_id, cur_user) VALUES (numPsector, 'nomUsuari')
-- do
update arc set the_geom=the_geom where arc_id='xxxxxxxxxxxxxx'


-- Check state_type nulls (arc, node, connec)
SELECT arc_id FROM arc WHERE state > 0 AND state_type IS NULL 
SELECT node_id FROM node WHERE state > 0 AND state_type IS NULL 
SELECT connec_id FROM connec WHERE state > 0 AND state_type IS NULL 


INSERT INTO value_state_type VALUES (51,0,'S/I', FALSE, FALSE);
INSERT INTO value_state_type VALUES (52,1,'S/I', TRUE, FALSE);
INSERT INTO value_state_type VALUES (53,2,'S/I', TRUE, FALSE);

UPDATE node SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE node SET state_type=53 WHERE state_type IS NULL AND state=2;

UPDATE arc SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE arc SET state_type=53 WHERE state_type IS NULL AND state=2;

UPDATE connec SET state_type=52 WHERE state_type IS NULL AND state=1;
UPDATE connec SET state_type=53 WHERE state_type IS NULL AND state=2;
