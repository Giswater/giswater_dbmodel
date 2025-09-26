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

-- Plan for 2 test
SELECT plan(2);

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
    (gw_fct_anl_arc_length($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{},"feature":{"tableName":"ve_arc",
    "featureType":"ARC", "id":[2001,2002]}, "data":{"selectionMode":"previousSelection","parameters":{"shorterThan":"5", "biggerThan":"3"}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_anl_arc_length -> previousSelection returns status "Accepted"'
);


SELECT is (
    (gw_fct_anl_arc_length($${"client":{"device":4, "infoType":1, "lang":"ES"},"form":{},"feature":{"tableName":"ve_arc",
    "featureType":"ARC", "id":[]}, "data":{"selectionMode":"wholeSelection","parameters":{"shorterThan":"5", "biggerThan":"3"}}}$$)::JSON)->>'status',
    'Accepted',
    'Check if gw_fct_anl_arc_length -> wholeSelection returns status "Accepted"'
);


-- Finish the test
SELECT finish();

ROLLBACK;
