/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

SELECT plan(6);

insert into plan_netscenario (netscenario_id) values (-901);
insert into selector_netscenario (netscenario_id, cur_user) values (-901, current_user);
INSERT INTO v_edit_plan_netscenario_valve (netscenario_id, node_id, closed, the_geom) 
VALUES(-901, '1079', false, null);
SELECT is((SELECT count(*)::integer FROM v_edit_plan_netscenario_valve WHERE netscenario_id = -901), 1, 'INSERT: v_edit_plan_netscenario_valve -901 was inserted');
SELECT is((SELECT count(*)::integer FROM plan_netscenario_valve WHERE netscenario_id = -901), 1, 'INSERT: plan_netscenario_valve -901 was inserted');


UPDATE v_edit_plan_netscenario_valve SET closed = 'true' WHERE netscenario_id = -901;
SELECT is((SELECT node_id FROM v_edit_plan_netscenario_valve WHERE netscenario_id = -901), 'true', 'UPDATE: v_edit_plan_netscenario_valve -901 was updated');
SELECT is((SELECT node_id FROM plan_netscenario_valve WHERE netscenario_id = -901), 'true', 'UPDATE: plan_netscenario_valve -901 was updated');


DELETE FROM v_edit_plan_netscenario_valve WHERE netscenario_id = -901;
SELECT is((SELECT count(*)::integer FROM v_edit_plan_netscenario_valve WHERE netscenario_id = -901), 0, 'DELETE: v_edit_plan_netscenario_valve -901 was deleted');
SELECT is((SELECT count(*)::integer FROM plan_netscenario_valve WHERE netscenario_id = -901), 0, 'DELETE: plan_netscenario_valve -901 was deleted');


SELECT * FROM finish();

ROLLBACK;