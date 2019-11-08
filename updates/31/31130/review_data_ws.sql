---------
--ws
---------

SET search_path='SCHEMA_NAME', public;

-- check orphan polygons
SELECT pol_id FROM polygon EXCEPT SELECT pol_id FROM (select pol_id from man_register UNION select pol_id from man_tank UNION select pol_id from man_fountain) a


-- check code null values
SELECT arc_id, arccat_id, the_geom FROM arc WHERE code IS NULL 
SELECT node_id, nodecat_id, the_geom FROM node WHERE code IS NULL 
SELECT connec_id, connecat_id, the_geom FROM connec WHERE code IS NULL
SELECT element_id, elementcat_id, the_geom FROM element WHERE code IS NULL


-- check missed rows on inp tables
SELECT arc_id FROM arc WHERE arc_id NOT IN (select arc_id from inp_pipe) AND state > 0
SELECT node_id FROM node WHERE node_id NOT IN(
select node_id from inp_shortpipe UNION select node_id from inp_valve UNION select node_id from inp_tank UNION select node_id from inp_reservoir)
AND state >0


