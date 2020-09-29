/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = ws_sample, public, pg_catalog;


-- 2020/09/18
UPDATE audit_cat_function SET  return_type =
'[{"widgetname":"grafClass", "label":"Graf class:", "widgettype":"combo","datatype":"text","tooltip": "Grafanalytics method used", "layoutname":"grl_option_parameters","layout_order":1,"comboIds":["PRESSZONE","DQA","DMA","SECTOR"],
"comboNames":["Pressure Zonification (PRESSZONE)", "District Quality Areas (DQA) ", "District Metering Areas (DMA)", "Inlet Sectorization (SECTOR-HIGH / SECTOR-LOW)"], "selectedId":"DMA"}, 

{"widgetname":"exploitation", "label":"Exploitation:","widgettype":"combo","datatype":"text","tooltip": "Choose exploitation to work with", "layoutname":"grl_option_parameters","layout_order":2, 
"dvQueryText":"select expl_id as id, name as idval from exploitation where active is not false order by name", "selectedId":"1"},

{"widgetname":"floodFromNode", "label":"Flood from node parent: (*)","widgettype":"linetext", "datatype":"text", "isMandatory":false, "tooltip":"Optative parameter to constraint algorithm to work only flooding from this header affecting only its mapzone", "placeholder":"1015", "layoutname":"grl_option_parameters","layout_order":3, "value":""},

{"widgetname":"forceOpen", "label":"Force open nodes: (*)","widgettype":"linetext", "datatype":"text", "isMandatory":false, "tooltip":"Optative node id(s) to temporary open closed node(s) in order to force algorithm to continue there", "placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layout_order":4, "value":""},

{"widgetname":"forceClosed", "label":"Force closed nodes: (*)","widgettype":"text", "isMandatory":false, "datatype":"text","tooltip":"Optative node id(s) to temporary close open node(s) to force algorithm to stop there","placeholder":"1015,2231,3123", "layoutname":"grl_option_parameters","layout_order":5,"value":""},

{"widgetname":"usePlanPsector", "label":"Use selected psectors:", "widgettype":"check","datatype":"boolean","tooltip":"If true, use selected psectors. If false ignore selected psectors and only works with on-service network" , "layoutname":"grl_option_parameters","layout_order":6, "value":"false"},

{"widgetname":"updateMapZone", "label":"Mapzone constructor method:","widgettype":"combo","datatype":"integer","layoutname":"grl_option_parameters","layout_order":7,
"comboIds":[0,1,2,3], "comboNames":["NONE", "CONCAVE POLYGON", "PIPE BUFFER", "PLOT & PIPE BUFFER"], "selectedId":"2"}, 

{"widgetname":"geomParamUpdate", "label":"Pipe buffer","widgettype":"text","datatype":"float","tooltip":"Buffer from arcs to create mapzone geometry. Only works with PIPE BUFFER & PLOT&PIPE BUFFER", "layoutname":"grl_option_parameters","layout_order":8, "isMandatory":false, "placeholder":"5-30", "value":""}]'
WHERE id = 2768;