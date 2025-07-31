/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- Plan for 5 test
SELECT plan(5);

-- Create roles for testing
CREATE USER plan_user;
GRANT role_plan to plan_user;

CREATE USER epa_user;
GRANT role_epa to epa_user;

CREATE USER edit_user;
GRANT role_edit to edit_user;

CREATE USER om_user;
GRANT role_om to om_user;

CREATE USER basic_user;
GRANT role_basic to basic_user;

-- Extract and test the "status" field from the function's JSON response
SELECT is (
    (gw_fct_getprocess($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "functionId":3042}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getprocess --> "functionId":3042 returns status "Accepted"'
);

SELECT is (
    (gw_fct_getprocess($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "functionId":"3160"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getprocess --> "functionId":"3160" returns status "Accepted"'
);

-- Create Demand Dscenario from ToC
SELECT is (
    (gw_fct_getprocess($${"client":{"device":4, "lang":"es_ES", "version":"4.2.0", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "functionId":"3112"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getprocess --> "functionId":"3112" returns status "Accepted"'
);

-- Create Network Dscenario from ToC
SELECT is (
    (gw_fct_getprocess($${"client":{"device":4, "lang":"es_ES", "version":"4.2.0", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "functionId":"3108"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getprocess --> "functionId":"3108" returns status "Accepted"'
);

-- Manage Dscenario values
SELECT is (
    (gw_fct_getprocess($${"client":{"device":4, "lang":"es_ES", "version":"4.2.0", "infoType":1, "epsg":25831}, "form":{},
    "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "functionId":"3042"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_getprocess --> "functionId":"3042" returns status "Accepted"'
);


-- Finish the test
SELECT finish();

ROLLBACK;