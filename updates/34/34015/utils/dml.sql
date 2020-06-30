/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2020/06/21

INSERT INTO config_function VALUES (2112, 'gw_fct_arc_fusion', null, '{"addToc": {"v_edit_arc": {"the_geom": "the_geom","field_id": "arc_id","group": "groupTest"},
                                "v_edit_connec": {"the_geom": "the_geom","field_id": "connec_id", "group": "groupTest"}},"active": "v_edit_arc","zoom": "v_edit_arc",
                                "visible": ["v_edit_arc","v_edit_node"],"index": ["v_edit_arc","v_edit_node"]}', null);
INSERT INTO config_function VALUES (2114, 'gw_fct_arc_fusion', null, '{"addToc": {"v_edit_arc": {"the_geom": "the_geom","field_id": "arc_id","group": "groupTest"},
                                "v_edit_connec": {"the_geom": "the_geom","field_id": "connec_id", "group": "groupTest"}},"active": "v_edit_arc","zoom": "v_edit_arc",
                                "visible": ["v_edit_arc","v_edit_node"],"index": ["v_edit_arc","v_edit_node"]}', null);