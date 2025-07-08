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

SELECT * FROM no_plan();

-- Check table
SELECT has_table('cat_pavement'::name, 'Table cat_pavement should exist');

-- Check columns
SELECT columns_are(
    'cat_pavement',
    ARRAY[
        'id', 'descript', 'link', 'thickness', 'm2_cost', 'active'
    ],
    'Table cat_pavement should have the correct columns'
);

-- Check primary key
SELECT col_is_pk('cat_pavement', 'id', 'Column id should be primary key'); 

-- Check column types
SELECT col_type_is('cat_pavement', 'id', 'varchar(30)', 'Column id should be varchar(30)');
SELECT col_type_is('cat_pavement', 'descript', 'text', 'Column descript should be text');
SELECT col_type_is('cat_pavement', 'link', 'varchar(512)', 'Column link should be varchar(512)');
SELECT col_type_is('cat_pavement', 'thickness', 'numeric(12, 2)', 'Column thickness should be numeric(12, 2)');
SELECT col_type_is('cat_pavement', 'm2_cost', 'varchar(16)', 'Column m2_cost should be varchar(16)');
SELECT col_type_is('cat_pavement', 'active', 'bool', 'Column active should be bool');

-- Check default values
SELECT col_has_default('cat_pavement', 'id', 'Column id should have default value');

-- Check foreign keys
SELECT has_fk('cat_pavement', 'Table cat_pavement should have foreign keys');

SELECT fk_ok('cat_pavement', 'm2_cost', 'plan_price', 'id', 'Table should have foreign key from m2_cost to plan_price.id');

-- Check indexes
SELECT has_index('cat_pavement', 'id', 'Table should have index on id');

-- Finish
SELECT * FROM finish();

ROLLBACK;