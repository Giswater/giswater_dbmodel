/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

SELECT plan(3);

SELECT is (
    (gw_fct_graphanalytics_upstream($${"client":{"device":4, "infoType":1, "lang":"ES"},
    "feature":{"id":["20607"]},"data":{}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_upstream returns status "Accepted"'
);

SELECT is (
    (gw_fct_graphanalytics_upstream($${"client":{"device":4, "infoType":1, "lang":"ES"},
    "feature":{},"data":{"coordinates":{"xcoord":419278.0533606678,"ycoord":4576625.482073168,
    "zoomRatio":437.2725774103561}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_upstream with coordinates returns status "Accepted"'
);

SELECT is (
    (gw_fct_graphanalytics_upstream($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831},
    "form":{}, "feature":{"id":[35]}, "data":{"filterFields":{}, "pageInfo":{},
    "coordinates":{"xcoord":418978.56563679205,"ycoord":4576668.594284589, "zoomRatio":5563.006982630196}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_upstream with coordinates and epsg returns status "Accepted"'
);

-- Finish the test
SELECT finish();

ROLLBACK;
