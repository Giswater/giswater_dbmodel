/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
BEGIN;

-- Suppress NOTICE messages
SET client_min_messages TO WARNING;

SET search_path = "SCHEMA_NAME", public, pg_catalog;

SELECT * FROM no_plan();

-- Check table element_x_node
SELECT has_table('element_x_node'::name, 'Table element_x_node should exist');

-- Check columns
SELECT columns_are(
    'element_x_node',
    ARRAY[
        'element_id', 'node_id'
    ],
    'Table element_x_node should have the correct columns'
);

-- Check primary key
SELECT col_is_pk('element_x_node', ARRAY['element_id', 'node_id'], 'Columns element_id and node_id should be primary key');

-- Check column types
SELECT col_type_is('element_x_node', 'element_id', 'varchar(16)', 'Column element_id should be varchar(16)');
SELECT col_type_is('element_x_node', 'node_id', 'varchar(16)', 'Column node_id should be varchar(16)');

-- Check foreign keys
SELECT has_fk('element_x_node', 'Table element_x_node should have foreign keys');
SELECT fk_ok('element_x_node', 'element_id', 'element', 'element_id', 'FK element_x_node_element_id_fkey should exist');
SELECT fk_ok('element_x_node', 'node_id', 'node', 'node_id', 'FK element_x_node_node_id_fkey should exist');

-- Check triggers

-- Check rules

-- Check sequences

-- Check constraints
SELECT col_not_null('element_x_node', 'element_id', 'Column element_id should be NOT NULL');
SELECT col_not_null('element_x_node', 'node_id', 'Column node_id should be NOT NULL');

SELECT * FROM finish();

ROLLBACK;
