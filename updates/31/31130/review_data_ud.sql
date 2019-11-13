---------
--ud
---------

SET search_path='SCHEMA_NAME', public;

-- check orphan rows on polygon table
SELECT pol_id FROM polygon EXCEPT SELECT pol_id  FROM 
(select pol_id from gully UNION select pol_id from man_chamber UNION select pol_id from man_netgully UNION select pol_id from man_storage UNION select pol_id from man_wwtp) a;

-- delete orphan polygons
/*DELETE FROM polygon WHERE pol_id IN (SELECT pol_id FROM polygon EXCEPT SELECT pol_id  FROM 
(select pol_id from gully UNION select pol_id from man_chamber UNION select pol_id from man_netgully UNION select pol_id from man_storage UNION select pol_id from man_wwtp) a);*/


-- check code null values on feature tables
SELECT arc_id, arccat_id, the_geom FROM arc WHERE code IS NULL; 
SELECT node_id, nodecat_id, the_geom FROM node WHERE code IS NULL;
SELECT connec_id, connecat_id, the_geom FROM connec WHERE code IS NULL;
SELECT gully_id, gratecat_id, the_geom FROM gully WHERE code IS NULL;
SELECT element_id, elementcat_id, the_geom FROM element WHERE code IS NULL;

-- update code null values to id in case is null
/*UPDATE arc SET code=arc_id WHERE code IS NULL;
UPDATE node SET code=node_id WHERE code IS NULL;
UPDATE connec SET code=connec_id WHERE code IS NULL;
UPDATE gully SET code=gully_id WHERE code IS NULL;
UPDATE element SET code=element_id WHERE code IS NULL;*/



-- check missed rows on inp tables
SELECT arc_id FROM arc WHERE arc_id NOT IN (select arc_id from inp_conduit UNION select arc_id from inp_virtual UNION select arc_id from inp_weir 
UNION select arc_id from inp_pump UNION select arc_id from inp_outlet UNION select arc_id from inp_orifice) AND state > 0;

SELECT node_id FROM node WHERE node_id NOT IN(
select node_id from inp_junction UNION select node_id from inp_storage UNION select node_id from inp_outfall UNION select node_id from inp_divider)
AND state >0;


