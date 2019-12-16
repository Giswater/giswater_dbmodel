/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE TABLE ext_cat_vehicle(
  id character varying(50) NOT NULL,
  idval character varying(50),
  descript character varying(50),
  CONSTRAINT ext_cat_vehicle_pkey PRIMARY KEY (id));
  
  
CREATE TABLE om_visit_lot(
  id serial NOT NULL,
  startdate date DEFAULT now(),
  enddate date,
  real_startdate date,
  real_enddate date,
  visitclass_id integer,
  descript text,
  active boolean DEFAULT true,
  team_id integer,
  duration text,
  feature_type text,
  status integer,
  the_geom geometry(MultiPolygon,SRID_VALUE),
  rotation numeric(8,4),
  class_id character varying(5),
  exercice integer,
  serie character varying(10),
  number integer,
  adreca text,
  CONSTRAINT om_visit_lot_pkey PRIMARY KEY (id));
  
  
CREATE TABLE om_visit_lot_x_arc(
  lot_id integer NOT NULL,
  arc_id character varying(16) NOT NULL,
  code character varying(30),
  status integer,
  observ text,
  CONSTRAINT om_visit_lot_x_arc_pkey PRIMARY KEY (lot_id, arc_id));
  
  
CREATE TABLE om_visit_lot_x_connec(
  lot_id integer NOT NULL,
  connec_id character varying(16) NOT NULL,
  code character varying(30),
  status integer,
  observ text,
  CONSTRAINT om_visit_lot_x_connec_pkey PRIMARY KEY (lot_id, connec_id));
  
  
CREATE TABLE om_visit_lot_x_node(
  lot_id integer NOT NULL,
  node_id character varying(16) NOT NULL,
  code character varying(30),
  status integer,
  observ text,
  CONSTRAINT om_visit_lot_x_node_pkey PRIMARY KEY (lot_id, node_id));
  
  
CREATE TABLE om_visit_lot_x_user(
  id serial NOT NULL,
  user_id character varying(16) NOT NULL DEFAULT "current_user"(),
  team_id integer NOT NULL,
  lot_id integer NOT NULL,
  starttime timestamp without time zone DEFAULT ("left"((date_trunc('second'::text, now()))::text, 19))::timestamp without time zone,
  endtime timestamp without time zone,
  the_geom geometry(Point,SRID_VALUE),
  CONSTRAINT om_visit_lot_x_user_pkey PRIMARY KEY (id));
  
  
CREATE TABLE cat_team(
  id serial PRIMARY KEY,
  idval text,
  descript text,
  active boolean DEFAULT true);
  
  
CREATE TABLE om_vehicle_x_parameters(
  id serial NOT NULL,
  vehicle_id character varying(50),
  lot_id integer,
  team_id integer,
  image text,
  load character varying(50),
  cur_user character varying(50) DEFAULT "current_user"(),
  tstamp timestamp without time zone,
  xcoord double precision,
  ycoord double precision,
  compass double precision,
  CONSTRAINT om_vehicle_x_parameters_pkey PRIMARY KEY (id));
  
  
CREATE TABLE om_team_x_vehicle(
  id serial NOT NULL,
  team_id integer,
  vehicle_id character varying(50),
  CONSTRAINT om_team_x_vehicle_pkey PRIMARY KEY (id));


SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit", "column":"lot_id", "dataType":"integer"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit", "column":"class_id", "dataType":"integer"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit", "column":"status", "dataType":"integer"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit", "column":"visit_type", "dataType":"integer"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit", "column":"publish", "dataType":"integer"}}$$);

CREATE TABLE ext_workorder_class(
  id character varying(50) NOT NULL,
  idval character varying(50),
  CONSTRAINT ext_workorder_class_pkey PRIMARY KEY (id));
  
  
CREATE TABLE ext_workorder_type(
  id character varying(50) NOT NULL,
  idval character varying(50),
  class_id character varying(50),
  CONSTRAINT ext_workorder_type_pkey PRIMARY KEY (id));

  
CREATE TABLE om_typevalue(
  typevalue text NOT NULL,
  id integer NOT NULL,
  idval text,
  descript text,
  addparam json,
  CONSTRAINT om_typevalue_pkey PRIMARY KEY (typevalue, id));
  
  
CREATE TABLE om_visit_class(
  id serial NOT NULL,
  idval character varying(30),
  descript text,
  active boolean DEFAULT true,
  ismultifeature boolean,
  ismultievent boolean,
  feature_type text,
  sys_role_id character varying(30),
  visit_type integer,
  param_options json,
  CONSTRAINT om_visit_class_pkey PRIMARY KEY (id));
  
  
CREATE TABLE om_visit_class_x_parameter(
  id serial NOT NULL,
  class_id integer NOT NULL,
  parameter_id character varying(50) NOT NULL,
  CONSTRAINT om_visit_class_x_parameter_pkey PRIMARY KEY (id));
  
CREATE TABLE om_visit_class_x_wo(
  id serial NOT NULL,
  visitclass_id integer,
  wotype_id character varying(50),
  CONSTRAINT om_visit_class_x_wo_pkey PRIMARY KEY (id));
  
  
CREATE TABLE om_visit_team_x_user(
  team_id integer NOT NULL,
  user_id character varying(16) NOT NULL,
  starttime timestamp without time zone DEFAULT now(),
  endtime timestamp without time zone,
  CONSTRAINT om_visit_team_x_user_pkey PRIMARY KEY (team_id, user_id));

CREATE TABLE om_visit_type(
  id serial NOT NULL,
  idval character varying(30),
  descript text,
  CONSTRAINT om_visit_type_pkey PRIMARY KEY (id));
  
  
CREATE TABLE ext_workorder(
  class_id integer,
  class_name character varying(50),
  exercise integer,
  serie character varying(10),
  num_value integer,
  startdate date,
  address character varying(50),
  wotype_id integer,
  visitclass_id integer,
  wotype_name character varying(50),
  cost numeric,
  ct text,
  CONSTRAINT ext_workorder_pkey PRIMARY KEY (class_id, exercise, serie));
  
  
CREATE TABLE selector_lot(
  id serial NOT NULL,
  lot_id integer,
  cur_user text,
  CONSTRAINT selector_lot_pkey PRIMARY KEY (id));
  
ALTER TABLE om_visit ALTER COLUMN publish TYPE BOOLEAN USING publish::boolean;

DROP VIEW IF EXISTS v_edit_plan_psector;
ALTER TABLE plan_psector ALTER COLUMN ext_code TYPE text USING ext_code::text;


