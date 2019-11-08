---------
--ud
---------

SET search_path='SCHEMA_NAME', public;

-- check orphan rows on polygon table

-- check missed rows on inp tables
SELECT arc_id FROM arc WHERE arc_id NOT IN (select arc_id from inp_conduit UNION select arc_id from inp_virtual UNION select arc_id from inp_weir 
UNION select arc_id from inp_pump UNION select arc_id from inp_outlet UNION select arc_id from inp_orifice) AND state > 0

SELECT node_id FROM node WHERE node_id NOT IN(
select node_id from inp_junction UNION select node_id from inp_storage UNION select node_id from inp_outfall UNION select node_id from inp_divider)
AND state >0


-- check code null values on feature tables
