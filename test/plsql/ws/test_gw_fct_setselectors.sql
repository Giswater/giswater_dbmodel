/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- Plan for 14 test
SELECT plan(14);

-- Extract and test the "status" field from the function's JSON response
SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_exploitation", "id":"1",
    "isAlone":"True", "disableParent":"False", "value":"True", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_exploitation" && "value":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_exploitation", "id":"1",
    "isAlone":"True", "disableParent":"False", "value":"False", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_exploitation" && "value":"False" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_sector", "checkAll":"True",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_sector" && "checkAll":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_sector", "checkAll":"False",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_sector" && "checkAll":"False" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_network_state", "id":"1",
    "isAlone":"False", "disableParent":"False", "value":"True", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_network_state" && "value":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_network_state", "id":"1",
    "isAlone":"False", "disableParent":"False", "value":"False", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_network_state" && "value":"False" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_dscenario", "id":"1",
    "isAlone":"False", "disableParent":"False", "value":"True", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_dscenario" && "value":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_dscenario", "id":"1",
    "isAlone":"False", "disableParent":"False", "value":"False", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_dscenario" && "value":"False" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_dscenario",
    "checkAll":"True", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_dscenario" && "checkAll":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_dscenario",
    "checkAll":"False", "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_dscenario" && "checkAll":"False" returns status "Accepted"'
);


SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_hydro_state", "checkAll":"True",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_hydro_state" && "checkAll":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_hydro_state", "checkAll":"False",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_hydro_state" && "checkAll":"False" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_psector", "checkAll":"True",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_psector" && "checkAll":"True" returns status "Accepted"'
);

SELECT is (
    (gw_fct_setselectors($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, "form":{}, "feature":{},
    "data":{"filterFields":{}, "pageInfo":{}, "selectorType":"selector_basic", "tabName":"tab_psector", "checkAll":"False",
    "addSchema":"NULL"}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_setselectors --> "tabName":"tab_psector" && "checkAll":"False" returns status "Accepted"'
);





-- Finish the test
SELECT finish();

ROLLBACK;