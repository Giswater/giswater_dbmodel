/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;



CREATE TABLE SCHEMA_NAME.sys_api_cat_datatype(
  id serial NOT NULL,
  client_id integer ,
  idval text,
  CONSTRAINT sys_api_cat_datatype_pkey PRIMARY KEY (id, client_id)
);



CREATE TABLE SCHEMA_NAME.sys_api_cat_widgettype(
  id serial NOT NULL,
  client_id integer ,
  idval text,
  CONSTRAINT ssys_api_cat_widgettype_pkey PRIMARY KEY (id, client_id)
);



CREATE TABLE "sys_api_cat_formtab" (
id serial PRIMARY KEY,
idval_qgis text,
idval_web text
);

CREATE TABLE "sys_api_cat_form" (
id serial PRIMARY KEY,
idval_qgis text,
idval_web text
);



CREATE TABLE "config_api_layer"(
  layer_id text NOT NULL,
  alias_id text,
  is_parent boolean,
  tableparent_id text,
  is_editable boolean,
  tableinfo_id text,
  formid text,
  formname text,
  orderby integer,
  link_id text,
  type_element text,
  CONSTRAINT config_api_layer_pkey PRIMARY KEY (layer_id)
);



CREATE TABLE "config_api_layer_child"(
  featurecat_id character varying(30) NOT NULL,
  tableinfo_id text,
  CONSTRAINT config_api_layer_child_pkey PRIMARY KEY (featurecat_id)
);




CREATE TABLE "config_api_layer_tab"(
  id serial NOT NULL,
  layer_id character varying(50),
  formtab integer,
  tableview_id text,
  CONSTRAINT config_api_layer_tab_pkey PRIMARY KEY (id),
  CONSTRAINT config_api_layer_formtab_fkey FOREIGN KEY (formtab)
      REFERENCES sys_api_cat_formtab (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT);

	  
	  
CREATE TABLE "config_api_tableinfo_x_inforole"(
  id serial NOT NULL,
  tableinfo_id character varying(50),
  inforole_id integer,
  tableinforole_id text,
  CONSTRAINT config_api_tableinfo_x_inforole_pkey PRIMARY KEY (id)
);



CREATE TABLE "config_api_layer_field"
( id serial NOT NULL,
  table_id character varying(50),
  column_id character varying(30),
  sys_api_cat_datatype_id integer,
  sys_api_cat_widgettype_id integer,
  field_length integer,
  num_decimals integer,
  ismandatory boolean,
  iseditable boolean,
  isnavigationbutton boolean,
  placeholder text,
  form_label text,
  dv_table text,
  dv_id_column text,
  dv_name_column text,
  dv_querytext text,
  dv_filterbyfield text,
  isenabled boolean,
  orderby integer,
  layout_id integer,
  layout_order integer,
  CONSTRAINT config_api_layer_fields_pkey PRIMARY KEY (id)
  );

  
-- datatype_id, ismandatory, must be on both tables because man_addfields acts as database ony for add paramaters
-- and api_layer acts as client for all tables and all columns


CREATE TABLE man_addfields_parameter (
id serial PRIMARY KEY,
idval varchar(50),
cat_feature_id varchar (30)
);


CREATE TABLE man_addfields_value (
id bigserial PRIMARY KEY,
feature_id varchar(16),
parameter_id integer,
value_param text,
CONSTRAINT man_addfields_value_unique UNIQUE (feature_id, parameter_id)
);


CREATE TABLE sys_combo_values (
sys_combo_cat_id int4,
id int4,
idval text,
descript text,
CONSTRAINT sys_combo_pkey PRIMARY KEY (sys_combo_cat_id, id)
);


CREATE TABLE sys_combo_cat (
id serial PRIMARY KEY,
idval text
);



CREATE INDEX man_addfields_value_feature_id_index ON man_addfields_value USING btree (feature_id);
CREATE INDEX man_addfields_value_parameter_id_index ON man_addfields_value USING btree (parameter_id);


