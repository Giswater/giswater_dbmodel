/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- Plan for 2 test
SELECT plan(2);

-- Extract and test the "status" field from the function's JSON response
SELECT is (
    (gw_fct_getconfig($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{"formName":"epaoptions"},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getconfig --> "formName":"epaoptions" returns status "Accepted"'
);

SELECT is (
    (gw_fct_getconfig($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{"formName":"config"},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "list_layers_name":"{Mincut init point, Mincut result valve, Mincut result node, Mincut result connec, Mincut result arc, Node, Connec, Arc, Link, Connec polygon, Node polygon, Dimensioning, Inp reservoir, Inp tank, Inp inlet, Inp junction, Inp shortpipe, Inp valve, Inp pump, Inp connec, Inp pipe, Inp virtualvalve, Inp virtualpump, Plan psector connec, Plan psector node, Plan psector arc, Plan psector link, Municipality, Streetaxis, Plot}", "list_tables_name":"{v_om_mincut_initpoint, v_om_mincut_valve, v_om_mincut_node, v_om_mincut_connec, v_om_mincut_arc, v_edit_node, v_edit_connec, v_edit_arc, v_edit_link, ve_pol_connec, ve_pol_node, v_edit_dimensions, v_edit_inp_reservoir, v_edit_inp_tank, v_edit_inp_inlet, v_edit_inp_junction, v_edit_inp_shortpipe, v_edit_inp_valve, v_edit_inp_pump, v_edit_inp_connec, v_edit_inp_pipe, v_edit_inp_virtualvalve, v_edit_inp_virtualpump, v_plan_psector_connec, v_plan_psector_node, v_plan_psector_arc, v_plan_psector_link, ext_municipality, v_ext_streetaxis, v_ext_plot}"}}$$)::JSON)->>'status','Accepted',
    'Check if gw_fct_getconfig --> "formName":"config" returns status "Accepted"'
);

-- Finish the test
SELECT finish();

ROLLBACK;