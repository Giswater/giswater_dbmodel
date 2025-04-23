/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


INSERT INTO cat_feature VALUES ('RECLORADOR', 'NETELEMENT', 'NODE');
INSERT INTO node_type VALUES ('RECLORADOR', 'NETELEMENT', 'SHORTPIPE', 'man_netelement', 'inp_shortpipe', true, true, 2, true, 'Element to reclorate water', NULL, true, 'DQA');

