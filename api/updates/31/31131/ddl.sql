/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"config_api_form_fields", "column":"layout_name", "dataType":"text"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"config_api_form_fields", "column":"editability", "dataType":"json"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"config_api_form_fields", "column":"widgetcontrols", "dataType":"json"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"config_api_form_fields", "column":"hidden", "dataType":"boolean"}}$$);

CREATE TABLE config_api_visit (
  visitclass_id serial NOT NULL,
  formname character varying(30),
  tablename character varying(30),
  CONSTRAINT config_api_visit_pkey PRIMARY KEY (visitclass_id));
  

CREATE TABLE config_api_visit_x_featuretable(
  tablename character varying(30) NOT NULL,
  visitclass_id integer NOT NULL,
  CONSTRAINT config_api_visit_x_table_pkey PRIMARY KEY (visitclass_id, tablename));
  
  
CREATE TABLE config_api_cat_datatype (
    id character varying(30) NOT NULL,
    descript text,
    CONSTRAINT config_api_cat_datatype_pkey PRIMARY KEY (id));


CREATE TABLE config_api_cat_formtemplate (
    id character varying(30) NOT NULL,
    descript text,
    CONSTRAINT config_api_cat_formtemplate_pkey PRIMARY KEY (id));


CREATE TABLE config_api_cat_widgettype (
    id character varying(30) NOT NULL,
    descript text,
    CONSTRAINT config_api_cat_widgettype_pkey PRIMARY KEY (id));


CREATE TABLE config_api_form (
    id integer NOT NULL,
    formname character varying(50),
    projecttype character varying,
    actions json,
    layermanager json,
    CONSTRAINT config_api_form_pkey PRIMARY KEY (id));


CREATE TABLE config_api_form_groupbox (
    id integer NOT NULL,
    formname character varying(50) NOT NULL,
    layout_id integer,
    label text,
    CONSTRAINT config_api_form_groupbox_pkey PRIMARY KEY (id));


CREATE TABLE config_api_form_tabs (
    id integer NOT NULL,
    formname character varying(50),
    tabname text,
    tablabel text,
    tabtext text,
    sys_role text,
    tooltip text,
    tabfunction json,
    tabactions json,
    device integer,
    CONSTRAINT config_api_form_tabs_pkey PRIMARY KEY (id));


CREATE TABLE config_api_images (
    id integer NOT NULL,
    idval text,
    image bytea,
    CONSTRAINT config_api_images_pkey PRIMARY KEY (id));
    
    
CREATE TABLE config_api_layer (
    layer_id text NOT NULL,
    is_parent boolean,
    tableparent_id text,
    is_editable boolean,
    tableinfo_id text,
    formtemplate text,
    headertext text,
    orderby integer,
    link_id text,
    is_tiled boolean,
    tableparentepa_id text,
    CONSTRAINT config_api_layer_pkey PRIMARY KEY (layer_id));
    
    
CREATE TABLE config_api_message (
    id integer NOT NULL,
    loglevel integer,
    message text,
    hintmessage text,
    mtype text,
    CONSTRAINT config_api_message_pkey PRIMARY KEY (id));


CREATE TABLE config_api_tableinfo_x_infotype (
    id integer NOT NULL,
    tableinfo_id character varying(50),
    infotype_id integer,
    tableinfotype_id text,
    CONSTRAINT config_api_tableinfo_x_infotype_pkey PRIMARY KEY (id));



CREATE TABLE config_api_layer_child (
    featurecat_id character varying(30) NOT NULL,
    tableinfo_id text,
    CONSTRAINT config_api_layer_child_pkey PRIMARY KEY (featurecat_id));


CREATE TABLE config_api_list (
    id integer NOT NULL,
    tablename character varying(50),
    query_text text,
    device smallint,
    actionfields json,
    listtype character varying(30),
    listclass character varying(30),
    vdefault json,
    CONSTRAINT config_api_list_pkey PRIMARY KEY (id));
    
    

