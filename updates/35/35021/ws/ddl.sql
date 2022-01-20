/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2021/12/02
--2021/12/02
ALTER TABLE config_user_x_sector DROP CONSTRAINT config_user_x_sector_sector_id_fkey;
ALTER TABLE config_user_x_sector ADD CONSTRAINT config_user_x_sector_sector_id_fkey FOREIGN KEY (sector_id)
REFERENCES sector (sector_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;


--2021/12/31
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_arc", "column":"dma_id", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_arc", "column":"presszone_id", "dataType":"text", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_arc", "column":"dqa_id", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_arc", "column":"minsector_id", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"sector", "column":"pattern_id", "dataType":"varchar(20)", "isUtils":"False"}}$$);

ALTER TABLE sector ADD CONSTRAINT sector_pattern_id_fkey FOREIGN KEY (pattern_id)
REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_tank", "column":"overflow", "dataType":"varchar(3)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_inlet", "column":"overflow", "dataType":"varchar(3)", "isUtils":"False"}}$$);


-- 2022/01/01
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"ext_hydrometer_category", "column":"pattern_id", "dataType":"varchar(16)", "isUtils":"False"}}$$);

ALTER TABLE ext_hydrometer_category_x_pattern RENAME TO _ext_hydrometer_category_x_pattern_ ;
DELETE FROM sys_table WHERE id = 'ext_hydrometer_category_x_pattern';


CREATE TABLE inp_dscenario_virtualvalve(
  dscenario_id integer NOT NULL,
  arc_id character varying(16) NOT NULL,
  valv_type character varying(18),
  pressure numeric(12,4),
  diameter numeric(12,4),
  flow numeric(12,4),
  coef_loss numeric(12,4),
  curve_id character varying(16),
  minorloss numeric(12,4),
  status character varying(12),
  CONSTRAINT inp_dscenario_virtualvalve_pkey PRIMARY KEY (dscenario_id, arc_id),
  CONSTRAINT inp_dscenario_virtualvalve_dscenario_id_fkey FOREIGN KEY (dscenario_id)
      REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT inp_dscenario_virtualvalve_arc_id_fkey FOREIGN KEY (arc_id)
      REFERENCES node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_dscenario_virtualvalve_curve_id_fkey FOREIGN KEY (curve_id)
      REFERENCES inp_curve (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE inp_dscenario_pump_additional (
  id serial NOT NULL,
  dscenario_id integer NOT NULL,
  node_id character varying(16) NOT NULL,
  order_id smallint,
  power character varying,
  curve_id character varying,
  speed numeric(12,6),
  pattern character varying,
  status character varying(12),
  energyparam character varying(30),
  energyvalue character varying(30),
  CONSTRAINT inp_dscenario_pump_additional_pkey PRIMARY KEY (id),
  CONSTRAINT inp_dscenario_pump_additional_curve_id_fkey FOREIGN KEY (curve_id)
      REFERENCES inp_curve (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_dscenario_pump_additional_node_id_fkey FOREIGN KEY (node_id)
      REFERENCES node (node_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_dscenario_pump_additional_pattern_id_fkey FOREIGN KEY (pattern)
      REFERENCES inp_pattern (pattern_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_dscenario_pump_additional_unique UNIQUE (node_id, order_id),
  CONSTRAINT inp_dscenario_pump_additional_pattern_check CHECK (status::text = ANY (ARRAY['CLOSED'::character varying, 'OPEN'::character varying]::text[]))
  );

  
CREATE TABLE inp_dscenario_junction(
  dscenario_id integer NOT NULL,
  node_id character varying(16) NOT NULL,
  demand numeric(12,6),
  pattern_id character varying(16),
  peak_factor numeric(12,4),
  CONSTRAINT inp_dscenario_junction_pkey PRIMARY KEY (dscenario_id, node_id),
  CONSTRAINT inp_dscenario_junction_dscenario_id_fkey FOREIGN KEY (dscenario_id)
      REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT inp_dscenario_junction_node_id_fkey FOREIGN KEY (node_id)
      REFERENCES node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_demand_pattern_id_fkey FOREIGN KEY (pattern_id)
      REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE inp_dscenario_connec(
  dscenario_id integer NOT NULL,
  connec_id character varying(16) NOT NULL,
  demand numeric(12,6),
  pattern_id character varying(16),
  peak_factor numeric(12,4),
  status varchar(16),
  minorloss float,
  custom_roughness float,
  custom_length float,
  custom_dint float,
  CONSTRAINT inp_dscenario_connec_pkey PRIMARY KEY (dscenario_id, connec_id),
  CONSTRAINT inp_dscenario_connec_dscenario_id_fkey FOREIGN KEY (dscenario_id)
      REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT inp_dscenario_connec_connec_id_fkey FOREIGN KEY (connec_id)
      REFERENCES connec (connec_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_demand_pattern_id_fkey FOREIGN KEY (pattern_id)
      REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_dscenario_tank", "column":"overflow", "dataType":"float", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_demand", "column":"dscenario_id", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_demand", "column":"source", "dataType":"text", "isUtils":"False"}}$$);

ALTER TABLE inp_dscenario_demand RENAME TO _inp_dscenario_demand_ ;
ALTER TABLE _inp_dscenario_demand_ DROP CONSTRAINT inp_dscenario_demand_pkey;
ALTER TABLE _inp_dscenario_demand_ DROP CONSTRAINT inp_demand_dscenario_id_fkey;
ALTER TABLE _inp_dscenario_demand_ DROP CONSTRAINT inp_demand_pattern_id_fkey;

CREATE TABLE inp_dscenario_demand(
  id serial,
  dscenario_id integer NOT NULL,
  feature_id character varying(16) NOT NULL,
  feature_type character varying(16),
  demand numeric(12,6),
  pattern_id character varying(16),
  demand_type character varying(18),
  source text,
  CONSTRAINT inp_dscenario_demand_pkey PRIMARY KEY (id),
  CONSTRAINT inp_demand_dscenario_id_fkey FOREIGN KEY (dscenario_id)
      REFERENCES cat_dscenario (dscenario_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_demand_pattern_id_fkey FOREIGN KEY (pattern_id)
      REFERENCES inp_pattern (pattern_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE);

INSERT INTO inp_dscenario_demand (dscenario_id, feature_id, feature_type, demand, pattern_id, demand_type)
SELECT dscenario_id, feature_id, feature_type, demand, pattern_id, demand_type FROM _inp_dscenario_demand_;


CREATE TABLE ext_rtc_sector_period(
  sector_id integer,
  cat_period_id character varying(16),
  effc double precision,
  minc double precision,
  maxc double precision,
  pattern_id character varying(16),
  CONSTRAINT ext_rtc_period_sector_id_cat_period_id_pkey PRIMARY KEY (sector_id, cat_period_id)
);

CREATE INDEX inp_dscenario_demand_source ON inp_dscenario_demand USING btree (source);

ALTER TABLE ext_rtc_sector_period ADD CONSTRAINT ext_rtc_sector_period_pattern_id_fkey FOREIGN KEY (pattern_id)
REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ext_hydrometer_category ADD CONSTRAINT ext_hydrometer_category_pattern_id_fkey FOREIGN KEY (pattern_id)
REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE inp_dscenario_inlet(
  dscenario_id integer NOT NULL,
  node_id character varying(16) NOT NULL,
  initlevel numeric(12,4),
  minlevel numeric(12,4),
  maxlevel numeric(12,4),
  diameter numeric(12,4),
  minvol numeric(12,4),
  curve_id character varying(16),
  overflow double precision,
  head double precision,
  pattern_id varchar(16),
  CONSTRAINT inp_dscenario_inlet_pkey PRIMARY KEY (node_id, dscenario_id),
  CONSTRAINT inp_dscenario_inlet_node_id_fkey FOREIGN KEY (node_id)
      REFERENCES node (node_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT inp_dscenario_inlet_pattern_id_fkey FOREIGN KEY (pattern_id)
      REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE ext_rtc_dma_period ADD CONSTRAINT ext_rtc_dma_period_pattern_id_fkey FOREIGN KEY (pattern_id)
REFERENCES inp_pattern (pattern_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_param_user", "column":"epaversion", "dataType":"text", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_connec", "column":"status", "dataType":"varchar(16)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_connec", "column":"minorloss", "dataType":"float", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_arc", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_node", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"age", "dataType":"integer", "isUtils":"False"}}$$);

ALTER TABLE inp_dscenario_pump_additional DROP CONSTRAINT IF EXISTS inp_dscenario_pump_additional_unique;
ALTER TABLE inp_dscenario_pump_additional ADD CONSTRAINT inp_dscenario_pump_additional_unique UNIQUE(dscenario_id, node_id, order_id);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"inp_inlet", "column":"head", "dataType":"double precision", "isUtils":"False"}}$$);
