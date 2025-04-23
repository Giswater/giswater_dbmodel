/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

UPDATE config_param_user SET value = true where parameter = 'plan_psector_force_delete';

UPDATE arc SET sector_id = expl_id;
UPDATE node SET sector_id = expl_id;
UPDATE connec SET sector_id = expl_id;
UPDATE gully SET sector_id = expl_id;
UPDATE link SET sector_id = expl_id;

DELETE FROM inp_controls;

DELETE FROM sector WHERE sector_id > 2;

UPDATE sector s SET the_geom = e.the_geom FROM exploitation e WHERE s.sector_id = e.expl_id;

UPDATE inp_junction SET y0=null, ysur=null, apond=null, outfallparam=null;
UPDATE inp_conduit SET q0=null, qmax=null;
UPDATE inp_storage SET storage_type =null, curve_id = null, y0=null, ysur=null, apond=null;
UPDATE inp_outfall SET outfall_type = null;

DELETE FROM inp_frweir;
DELETE FROM inp_frpump;
DELETE FROM inp_frorifice;
DELETE FROM inp_froutlet;

UPDATE inp_weir SET weir_type=null, offsetval=null, cd=null, geom1=null, geom2=null, geom3=null, geom4=null;
UPDATE inp_pump SET curve_id=null, status=null, startup=null , shutoff=null;

UPDATE cat_material SET n = null;

DELETE FROM inp_dwf;
DELETE FROM inp_pattern;
DELETE FROM inp_curve;

DELETE FROM cat_hydrology;
DELETE FROM cat_dwf;
DELETE FROM cat_dscenario;
DELETE FROM plan_psector;

DELETE FROM rpt_cat_result;

UPDATE config_param_user SET value = false where parameter = 'plan_psector_force_delete';
UPDATE inp_gully SET outlet_type =null,  "method"  = null, weir_cd =null , orifice_cd =null , efficiency =null ;

DELETE FROM raingage;
DELETE from inp_timeseries;
DELETE from inp_lid;