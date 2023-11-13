/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;


CREATE OR REPLACE VIEW vi_demands AS 
 SELECT temp_demand.feature_id,
    temp_demand.demand,
    temp_demand.pattern_id,
    concat(';', temp_demand.dscenario_id, ' ', temp_demand.source, ' ', temp_demand.demand_type) AS other
   FROM temp_demand
     JOIN temp_node ON temp_demand.feature_id::text = temp_node.node_id::text
     where temp_demand.demand is not null
  ORDER BY temp_demand.feature_id, (concat(';', temp_demand.dscenario_id, ' ', temp_demand.source, ' ', temp_demand.demand_type));