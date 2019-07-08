/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 08/07/2019

CREATE TABLE om_visit_filetype_x_extension
(
 filetype character varying(30) NOT NULL,
 fextension character varying(16) NOT NULL,
 CONSTRAINT om_visit_filetype_x_extension_pkey PRIMARY KEY (filetype, fextension)
)
WITH (
 OIDS=FALSE
);

ALTER TABLE om_visit_event_photo ADD COLUMN filetype  character varying(30);
ALTER TABLE om_visit_event_photo ADD COLUMN fextension  character varying(16);