/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

UPDATE config_param_user SET value = true where parameter = 'plan_psector_force_delete';

UPDATE arc SET sector_id = expl_id;
UPDATE node SET sector_id = expl_id;
UPDATE connec SET sector_id = expl_id;
UPDATE gully SET sector_id = expl_id;
UPDATE link SET sector_id = expl_id;

DELETE FROM inp_controls;
DELETE FROM node_border_sector;

DELETE FROM sector WHERE sector_id > 2;

UPDATE sector s SET the_geom = e.the_geom FROM exploitation e WHERE s.sector_id = e.expl_id;

UPDATE inp_junction SET y0=null, ysur=null, apond=null, outfallparam=null;
UPDATE inp_conduit SET q0=null, qmax=null;
UPDATE inp_storage SET storage_type =null, curve_id = null, y0=null, ysur=null, apond=null;
UPDATE inp_outfall SET outfall_type = null;

DELETE FROM inp_flwreg_weir;
DELETE FROM inp_flwreg_pump;
DELETE FROM inp_flwreg_orifice;
DELETE FROM inp_flwreg_outlet;

update cat_mat_arc SET n = null;

DELETE FROM inp_pattern;
DELETE FROM inp_curve;

DELETE FROM cat_hydrology;
DELETE FROM cat_dwf_scenario;
DELETE FROM cat_dscenario;
DELETE FROM plan_psector;

DELETE FROM rpt_cat_result;

UPDATE config_param_user SET value = false where parameter = 'plan_psector_force_delete';
UPDATE inp_gully SET outlet_type =null,  "method"  = null, weir_cd =null , orifice_cd =null , efficiency =null ;

-- reconvert storage 237 in a simple junction 
SELECT gw_fct_setchangefeaturetype(concat('{"client":{}, "feature":{"type":"node"},"data":{"filterFields":{}, "pageInfo":{},"feature_id":"237", "feature_type_new":"JUNCTION", "featurecat_id":"JUNCTION-01"}}')::json)

DELETE FROM inp_flwreg_weir where to_arc = '242';

SELECT gw_fct_setarcfusion('{"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{"id":[250]},
"data":{"workcatId":"work1","enddate":"2020-02-05", "state_type":2, "state":1, "psectorId":null, "arccat_id":"RC200", "arc_type":"CONDUIT"}}'::json);

SELECT gw_fct_setarcfusion('{"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{"id":[20587]},
"data":{"workcatId":"work1","enddate":"2020-02-05", "state_type":2, "state":1, "psectorId":null, "arccat_id":"RC200", "arc_type":"CONDUIT"}}'::json);

SELECT gw_fct_setarcfusion('{"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{"id":[20590]},
"data":{"workcatId":"work1","enddate":"2020-02-05", "state_type":2, "state":1, "psectorId":null, "arccat_id":"RC200", "arc_type":"CONDUIT"}}'::json);

DELETE FROM polygon WHERE feature_id = '237';


