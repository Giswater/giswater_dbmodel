/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2021/12/29
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_timeseries", "column":"sector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_timeseries", "column":"log", "dataType":"text", "isUtils":"False"}}$$);

DROP VIEW vi_options;
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_param_user", "column":"epaversion", "dataType":"text", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_hydrology", "column":"expl_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_dwf_scenario", "column":"expl_id", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_hydrology", "column":"log", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"cat_dwf_scenario", "column":"log", "dataType":"text", "isUtils":"False"}}$$);

ALTER TABLE cat_hydrology DROP CONSTRAINT IF EXISTS cat_hydrology_expl_id_fkey;
ALTER TABLE cat_hydrology ADD CONSTRAINT cat_hydrology_expl_id_fkey FOREIGN KEY (expl_id) 
REFERENCES exploitation (expl_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE cat_dwf_scenario DROP CONSTRAINT IF EXISTS cat_dwf_scenario_expl_id_fkey;
ALTER TABLE cat_dwf_scenario ADD CONSTRAINT cat_dwf_scenario_expl_id_fkey FOREIGN KEY (expl_id) 
REFERENCES exploitation (expl_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE inp_dscenario_conduit DROP CONSTRAINT IF EXISTS inp_dscenario_conduit_dscenario_id_fkey;
ALTER TABLE inp_dscenario_conduit ADD CONSTRAINT inp_dscenario_conduit_dscenario_id_fkey FOREIGN KEY (dscenario_id)
REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE inp_dscenario_junction DROP CONSTRAINT IF EXISTS inp_dscenario_junction_dscenario_id_fkey;
ALTER TABLE inp_dscenario_junction ADD CONSTRAINT inp_dscenario_junction_dscenario_id_fkey FOREIGN KEY (dscenario_id)
REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE inp_dscenario_raingage DROP CONSTRAINT IF EXISTS iinp_dscenario_raingage_dscenario_id_fkey;
ALTER TABLE inp_dscenario_raingage ADD CONSTRAINT iinp_dscenario_raingage_dscenario_id_fkey FOREIGN KEY (dscenario_id)
REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_orifice", "column":"close_time", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_orifice", "column":"close_time", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_weir", "column":"road_width", "dataType":"float", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_weir", "column":"road_surf", "dataType":"varchar(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_weir", "column":"coef_curve", "dataType":"float", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_weir", "column":"road_width", "dataType":"float", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_weir", "column":"road_surf", "dataType":"varchar(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_weir", "column":"coef_curve", "dataType":"float", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_subcatchment", "column":"nperv_pattern_id", "dataType":"varchar(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_subcatchment", "column":"dstore_pattern_id", "dataType":"varchar(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_subcatchment", "column":"infil_pattern_id", "dataType":"varchar(16)", "isUtils":"False"}}$$);


SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_orifice", "column":"flwreg_id", "newName":"order_id", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_weir", "column":"flwreg_id", "newName":"order_id", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_outlet", "column":"flwreg_id", "newName":"order_id", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_pump", "column":"flwreg_id", "newName":"order_id", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_orifice", "column":"nodarc_id", "dataType":"varchar(20)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_weir", "column":"nodarc_id", "dataType":"varchar(20)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_outlet", "column":"nodarc_id", "dataType":"varchar(20)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_flwreg_pump", "column":"nodarc_id", "dataType":"varchar(20)", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"inp_inflows", "column":"format_type", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"inp_inflows", "column":"mfactor","isUtils":"False"}}$$);

DROP VIEW IF EXISTS vi_orifices;
DROP VIEW IF EXISTS vi_weirs;
DROP VIEW IF EXISTS vi_pumps;
DROP VIEW IF EXISTS vi_outlets;
DROP VIEW IF EXISTS vi_xsections;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"temp_arc", "column":"flw_code","isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"rpt_inp_arc", "column":"flw_code","isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"temp_node", "column":"flw_code","isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"rpt_inp_node", "column":"flw_code","isUtils":"False"}}$$);

ALTER TABLE inp_flwreg_orifice ADD CONSTRAINT "inp_flwreg_orifice_nodarc_id_unique" UNIQUE(nodarc_id);
ALTER TABLE inp_flwreg_weir ADD CONSTRAINT "inp_flwreg_weir_nodarc_id_unique" UNIQUE(nodarc_id);
ALTER TABLE inp_flwreg_outlet ADD CONSTRAINT "inp_flwreg_outlet_nodarc_id_unique" UNIQUE(nodarc_id);
ALTER TABLE inp_flwreg_pump ADD CONSTRAINT "inp_flwreg_orifice_pump_id_unique" UNIQUE(nodarc_id);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_inflows", "column":"id", "newName":"order_id", "isUtils":"False"}}$$);


CREATE TABLE inp_dscenario_outfall(
dscenario_id integer,
node_id character varying(16) NOT NULL,
elev numeric(12,3),
ymax numeric(12,3),
outfall_type character varying(16),
stage numeric(12,4),
curve_id character varying(16),
timser_id character varying(16),
gate character varying(3),
CONSTRAINT inp_dscenario_outfall_pkey PRIMARY KEY (dscenario_id, node_id),
CONSTRAINT inp_dscenario_outfall_curve_id_fkey FOREIGN KEY (curve_id)
  REFERENCES inp_curve (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_outfall_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_outfall_node_id_fkey FOREIGN KEY (node_id)
  REFERENCES inp_outfall (node_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_outfall_timser_id_fkey FOREIGN KEY (timser_id)
  REFERENCES inp_timeseries (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE);


CREATE TABLE inp_dscenario_storage(
dscenario_id integer,
node_id character varying(50) NOT NULL,
elev numeric(12,3),
ymax numeric(12,3),
storage_type character varying(18),
curve_id character varying(16),
a1 numeric(12,4),
a2 numeric(12,4),
a0 numeric(12,4),
fevap numeric(12,4),
sh numeric(12,4),
hc numeric(12,4),
imd numeric(12,4),
y0 numeric(12,4),
ysur numeric(12,4),
apond numeric(12,4),
CONSTRAINT inp_dscenario_storage_pkey PRIMARY KEY (dscenario_id, node_id),
CONSTRAINT inp_dscenario_storage_curve_id_fkey FOREIGN KEY (curve_id)
  REFERENCES inp_curve (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_storage_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_storage_node_id_fkey FOREIGN KEY (node_id)
  REFERENCES inp_storage (node_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE);


CREATE TABLE inp_dscenario_flwreg_weir(
dscenario_id integer,
nodarc_id character varying(20) NOT NULL,
weir_type character varying(18) NOT NULL,
offsetval numeric(12,4),
cd numeric(12,4),
ec numeric(12,4),
cd2 numeric(12,4),
flap character varying(3),
geom1 numeric(12,4),
geom2 numeric(12,4) DEFAULT 0.00,
geom3 numeric(12,4) DEFAULT 0.00,
geom4 numeric(12,4) DEFAULT 0.00,
surcharge character varying(3),
road_width float,
road_surf character varying(16),
coef_curve float,
CONSTRAINT inp_dscenario_flwreg_weir_pkey PRIMARY KEY (dscenario_id, nodarc_id),
CONSTRAINT inp_dscenario_flwreg_weir_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_weir_nodarc_id_fkey FOREIGN KEY (nodarc_id)
  REFERENCES inp_flwreg_weir (nodarc_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_weir_check_type CHECK (weir_type::text = ANY (ARRAY['SIDEFLOW'::text, 'TRANSVERSE'::text, 'V-NOTCH'::text, 'TRAPEZOIDAL_WEIR'::text])));


CREATE TABLE inp_dscenario_flwreg_pump(
dscenario_id integer,
nodarc_id character varying(20) NOT NULL,
curve_id character varying(16) NOT NULL,
status character varying(3),
startup numeric(12,4),
shutoff numeric(12,4),
CONSTRAINT inp_dscenario_flwreg_pump_pkey PRIMARY KEY (dscenario_id, nodarc_id),
CONSTRAINT inp_dscenario_flwreg_pump_curve_id_fkey FOREIGN KEY (curve_id)
  REFERENCES inp_curve (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_pump_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_pump_nodarc_id_fkey FOREIGN KEY (nodarc_id)
  REFERENCES inp_flwreg_pump (nodarc_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_pump_check_status CHECK (status::text = ANY (ARRAY['ON'::character varying, 'OFF'::character varying]::text[])));


CREATE TABLE inp_dscenario_flwreg_orifice( 
dscenario_id integer,
nodarc_id character varying(20) NOT NULL,
ori_type character varying(18) NOT NULL,
offsetval numeric(12,4),
cd numeric(12,4) NOT NULL,
orate numeric(12,4),
flap character varying(3) NOT NULL,
shape character varying(18) NOT NULL,
geom1 numeric(12,4) NOT NULL,
geom2 numeric(12,4) NOT NULL DEFAULT 0.00,
geom3 numeric(12,4) DEFAULT 0.00,
geom4 numeric(12,4) DEFAULT 0.00,
close_time integer DEFAULT 0,
CONSTRAINT inp_dscenario_flwreg_orifice_pkey PRIMARY KEY (dscenario_id, nodarc_id),
CONSTRAINT inp_dscenario_flwreg_orifice_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_orifice_nodarc_id_fkey FOREIGN KEY (nodarc_id)
  REFERENCES inp_flwreg_orifice (nodarc_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_orifice_check_ory_type CHECK (ori_type::text = ANY (ARRAY['SIDE'::character varying, 'BOTTOM'::character varying]::text[])),
CONSTRAINT inp_dscenario_flwreg_orifice_check_shape CHECK (shape::text = ANY (ARRAY['CIRCULAR'::character varying, 'RECT-CLOSED'::character varying]::text[])));


CREATE TABLE inp_dscenario_flwreg_outlet(
dscenario_id integer, 
nodarc_id character varying(20) NOT NULL,
outlet_type character varying(16) NOT NULL,
offsetval numeric(12,4),
curve_id character varying(16),
cd1 numeric(12,4),
cd2 numeric(12,4),
flap character varying(3),
CONSTRAINT inp_dscenario_flwreg_outlet_pkey PRIMARY KEY (dscenario_id, nodarc_id),
CONSTRAINT inp_dscenario_flwreg_outlet_curve_id_fkey FOREIGN KEY (curve_id)
  REFERENCES inp_curve (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_outlet_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_outlet_nodarc_id_fkey FOREIGN KEY (nodarc_id)
  REFERENCES inp_flwreg_outlet (nodarc_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_flwreg_outlet_check_type CHECK (outlet_type::text = ANY (ARRAY['FUNCTIONAL/DEPTH'::character varying, 
'FUNCTIONAL/HEAD'::character varying, 'TABULAR/DEPTH'::character varying, 'TABULAR/HEAD'::character varying]::text[])));


CREATE TABLE inp_dscenario_inflows(
dscenario_id integer,
node_id character varying(50),
order_id integer,
timser_id character varying(16),
format_type text,
mfactor numeric(12,4),
sfactor numeric(12,4),
base numeric(12,4),
pattern_id character varying(16),
CONSTRAINT inp_dscenario_inflows_pkey PRIMARY KEY (dscenario_id, node_id, order_id),
CONSTRAINT inp_dscenario_inflows_node_id_fkey FOREIGN KEY (node_id)
  REFERENCES inp_junction (node_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT inp_dscenario_inflows_pattern_id_fkey FOREIGN KEY (pattern_id)
  REFERENCES inp_pattern (pattern_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT inp_dscenario_inflows_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE);

ALTER TABLE inp_inflows_pol_x_node RENAME TO inp_inflows_poll;

CREATE TABLE inp_dscenario_inflows_poll(
dscenario_id integer,
node_id character varying(50) NOT NULL,
poll_id character varying(16) NOT NULL,
timser_id character varying(16),
form_type character varying(18),
mfactor numeric(12,4),
sfactor numeric(12,4),
base numeric(12,4),
pattern_id character varying(16),
CONSTRAINT inp_dscenario_inflows_pol_pkey PRIMARY KEY (dscenario_id, node_id, poll_id),
CONSTRAINT inp_dscenario_inflows_pol_node_id_fkey FOREIGN KEY (node_id, poll_id)
  REFERENCES inp_inflows_poll (node_id, poll_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_inflows_pol_pattern_id_fkey FOREIGN KEY (pattern_id)
  REFERENCES inp_pattern (pattern_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT inp_dscenario_inflows_pol_poll_id_fkey FOREIGN KEY (poll_id)
  REFERENCES inp_pollutant (poll_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_inflows_pol_timser_id_fkey FOREIGN KEY (timser_id)
  REFERENCES inp_timeseries (id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_dscenario_inflows_pol_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE);

ALTER TABLE inp_treatment_node_x_pol RENAME TO inp_treatment;

CREATE TABLE inp_dscenario_treatment(
dscenario_id integer,
node_id character varying(50) NOT NULL,
poll_id character varying(16),
function character varying(100),
CONSTRAINT inp_treatment_pkey PRIMARY KEY (dscenario_id, node_id, poll_id),
CONSTRAINT inp_treatment_node_id_fkey FOREIGN KEY (node_id)
  REFERENCES inp_treatment (node_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT inp_treatment_poll_id_fkey FOREIGN KEY (poll_id)
  REFERENCES inp_pollutant (poll_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE, 
CONSTRAINT inp_dscenario_treatment_dscenario_id_fkey FOREIGN KEY (dscenario_id)
  REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
  ON UPDATE CASCADE ON DELETE CASCADE);


ALTER TABLE inp_hydrograph RENAME TO inp_hydrograph_value;
ALTER TABLE inp_hydrograph_id RENAME TO inp_hydrograph;

ALTER TABLE inp_washoff_land_x_pol RENAME TO inp_washoff;
ALTER TABLE inp_buildup_land_x_pol RENAME TO inp_buildup;

ALTER TABLE inp_coverage_land_x_subc RENAME TO inp_coverage;
ALTER TABLE inp_loadings_pol_x_subc RENAME TO inp_loadings;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"man_conduit", "column":"inlet_offset", "dataType":"float", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_dscenario_conduit", "column":"y1", "newName":"elev1", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_dscenario_conduit", "column":"y2", "newName":"elev2", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_dscenario_junction", "column":"elev", "dataType":"float", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_dscenario_junction", "column":"ymax", "dataType":"float", "isUtils":"False"}}$$);


CREATE TABLE temp_arc_flowregulator(
arc_id character varying(18) PRIMARY KEY,
type character varying(18),
weir_type character varying(18),
offsetval numeric(12,4),
cd numeric(12,4),
ec numeric(12,4),
cd2 numeric(12,4),
flap character varying(3),
geom1 numeric(12,4),
geom2 numeric(12,4) DEFAULT 0.00,
geom3 numeric(12,4) DEFAULT 0.00,
geom4 numeric(12,4) DEFAULT 0.00,
surcharge character varying(3),
road_width float,
road_surf character varying(16),
coef_curve float,
---
curve_id character varying(16),
status character varying(3),
startup numeric(12,4),
shutoff numeric(12,4),
---
ori_type character varying(18),
orate numeric(12,4),
shape character varying(18),
close_time integer DEFAULT 0,
----
outlet_type character varying(16),
cd1 numeric(12,4));


CREATE TABLE temp_node_other (
id serial PRIMARY KEY,
node_id character varying(16),
type character varying(16), -- 'POLLUTANT' or 'FLOW' or 'TREATMENT'
poll_id character varying(16),
timser_id character varying(16),
other varchar(30), -- concen/mas for polluntants or 'FLOW' for flow or function for treatment
mfactor numeric(12,4), -- 1 for flow or mfactor for polluntants
sfactor numeric(12,4),
base numeric(12,4),
pattern_id character varying(16));


SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_orifice", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_weir", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_flwreg_outlet", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_orifice", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_weir", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"inp_outlet", "column":"offset", "newName":"offsetval", "isUtils":"False"}}$$);

ALTER TABLE inp_flwreg_orifice DROP CONSTRAINT IF EXISTS inp_flwreg_orifice_unique;
ALTER TABLE inp_flwreg_outlet DROP CONSTRAINT IF EXISTS inp_flwreg_outlet_unique;
ALTER TABLE inp_flwreg_weir DROP CONSTRAINT IF EXISTS inp_flwreg_weir_unique;
ALTER TABLE inp_flwreg_pump DROP CONSTRAINT IF EXISTS inp_flwreg_pump_unique;

ALTER TABLE temp_node ADD CONSTRAINT temp_node_node_id_unique UNIQUE (node_id);

ALTER TABLE inp_flwreg_weir DROP CONSTRAINT inp_flwreg_weir_check_type;

ALTER TABLE inp_flwreg_weir
  ADD CONSTRAINT inp_flwreg_weir_check_type CHECK (weir_type::text = ANY (ARRAY['SIDEFLOW'::text, 'TRANSVERSE'::text, 'V-NOTCH'::text, 'TRAPEZOIDAL'::text]));

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_dscenario_conduit", "column":"elev1", "dataType":"numeric(12,3)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_dscenario_conduit", "column":"elev2", "dataType":"numeric(12,3)", "isUtils":"False"}}$$);

DROP INDEX IF EXISTS temp_arc_index ;
CREATE INDEX temp_arc_index
  ON temp_arc
  USING gist
  (the_geom);
  
DROP INDEX IF EXISTS temp_node_index ; 
CREATE INDEX temp_node_index
  ON temp_node
  USING gist
  (the_geom);