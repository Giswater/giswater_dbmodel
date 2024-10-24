/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- Plan for 5 test
SELECT plan(5);

-- Extract and test the "status" field from the function's JSON response
SELECT is (
    (gw_fct_getgraphconfig($${"client":{"device":4, "lang":"", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "context":"OPERATIVE", "mapzone": "sector", "mapzoneId": "1"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getgraphconfig --> "context":"OPERATIVE" and "mapzone": "sector"  returns status "Accepted"'
);

SELECT is (
    (gw_fct_getgraphconfig($${"client":{"device":4, "lang":"", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "context":"OPERATIVE", "mapzone": "presszone"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getgraphconfig --> "context":"OPERATIVE" and "mapzone": "presszone"  returns status "Accepted"'
);

SELECT is (
    (gw_fct_getgraphconfig($${"client":{"device":4, "lang":"", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "context":"OPERATIVE", "mapzone": "dma"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getgraphconfig --> "context":"OPERATIVE" and "mapzone": "dma"  returns status "Accepted"'
);

SELECT is (
    (gw_fct_getgraphconfig($${"client":{"device":4, "lang":"", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "context":"NETSCENARIO", "mapzone": "presszone"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getgraphconfig --> "context":"NETSCENARIO" and "mapzone": "presszone"  returns status "Accepted"'
);

SELECT is (
    (gw_fct_getgraphconfig($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{}, "data":{"filterFields":{},
    "pageInfo":{}, "context":"NETSCENARIO", "mapzone": "dma", "mapzoneId": "2", "netscenarioId": 1}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getgraphconfig --> "context":"NETSCENARIO" and "mapzone": "dma"  returns status "Accepted"'
);

-- Finish the test
SELECT finish();

ROLLBACK;