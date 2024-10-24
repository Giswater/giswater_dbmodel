/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


ALTER TABLE sys_style ADD CONSTRAINT sys_style_pkey PRIMARY KEY (layername, styleconfig_id);
ALTER TABLE sys_style ALTER COLUMN styleconfig_id SET NOT NULL;

ALTER TABLE raingage ADD CONSTRAINT raingage_muni_id FOREIGN KEY (muni_id) REFERENCES ext_municipality(muni_id);

CREATE INDEX gully_muni ON gully USING btree (muni_id);

ALTER TABLE sector ALTER COLUMN graphconfig SET DEFAULT '{"use":[{"nodeParent":"", "toArc":[]}], "ignore":[], "forceClosed":[]}'::JSON;
ALTER TABLE dma ALTER COLUMN graphconfig SET DEFAULT '{"use":[{"nodeParent":"", "toArc":[]}], "ignore":[], "forceClosed":[]}'::JSON;