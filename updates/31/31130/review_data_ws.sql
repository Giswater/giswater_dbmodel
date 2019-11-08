---------
--ws
---------

SET search_path='SCHEMA_NAME', public;

-- check orphan polygons


-- check code null values


-- check missed rows on inp tables
SELECT arc_id FROM arc WHERE arc_id NOT IN (select arc_id from inp_pipe) AND state > 0
SELECT node_id FROM node WHERE node_id NOT IN(
select node_id from inp_shortpipe UNION select node_id from inp_valve UNION select node_id from inp_tank UNION select node_id from inp_reservoir UNION SELECT node_id from inp_inlet)
AND state >0


