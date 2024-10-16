/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- Plan for 3 test
SELECT plan(3);

SELECT is (
    (gw_fct_graphanalytics_downstream($${"client":{"device":4, "infoType":1, "lang":"ES"},
    "feature":{"id":["20607"]},"data":{}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_downstream returns status "Accepted"'
);

SELECT is (
    (SELECT gw_fct_graphanalytics_downstream($${"client":{"device":4, "infoType":1, "lang":"ES"},
    "feature":{},"data":{ "coordinates":{"xcoord":419277.7306855297,"ycoord":4576625.674511955,
    "zoomRatio":3565.9967217571534}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_downstream with coordinates returns status "Accepted"'
);

SELECT is (
    (gw_fct_graphanalytics_downstream($${"client":{"device":4, "lang":"es_ES", "infoType":1,
    "epsg":25831}, "form":{}, "feature":{"id":[38]}, "data":{"filterFields":{}, "pageInfo":{},
    "coordinates":{"xcoord":419164.5943072313,"ycoord":4576631.247667303,
    "zoomRatio":585.5045021272166}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_graphanalytics_downstream with coordinates and epsg returns status "Accepted"'
);

-- Finish the test
SELECT finish();

ROLLBACK;
