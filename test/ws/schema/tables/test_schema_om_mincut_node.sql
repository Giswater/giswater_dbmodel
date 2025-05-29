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

-- Check table om_mincut_node
SELECT has_table('om_mincut_node'::name, 'Table om_mincut_node should exist');

-- Check columns
SELECT columns_are(
    'om_mincut_node',
    ARRAY[
        'id', 'result_id', 'node_id', 'the_geom', 'node_type', 'minsector_id'
    ],
    'Table om_mincut_node should have the correct columns'
);

-- Check primary key
SELECT col_is_pk('om_mincut_node', ARRAY['id'], 'Column id should be primary key');

-- Check column types
SELECT col_type_is('om_mincut_node', 'id', 'integer', 'Column id should be integer');
SELECT col_type_is('om_mincut_node', 'result_id', 'integer', 'Column result_id should be integer');
SELECT col_type_is('om_mincut_node', 'node_id', 'integer', 'Column node_id should be integer');
SELECT col_type_is('om_mincut_node', 'the_geom', 'geometry(Point,25831)', 'Column the_geom should be geometry(Point,25831)');
SELECT col_type_is('om_mincut_node', 'node_type', 'varchar(30)', 'Column node_type should be varchar(30)');
SELECT col_type_is('om_mincut_node', 'minsector_id', 'integer', 'Column minsector_id should be integer');

-- Check unique constraints
SELECT col_is_unique('om_mincut_node', ARRAY['result_id', 'node_id'], 'Columns result_id and node_id should have a unique constraint');

-- Check foreign keys
SELECT has_fk('om_mincut_node', 'Table om_mincut_node should have foreign keys');
SELECT fk_ok('om_mincut_node', 'result_id', 'om_mincut', 'id', 'FK result_id should reference om_mincut.id');

-- Check constraints
SELECT col_not_null('om_mincut_node', 'id', 'Column id should be NOT NULL');
SELECT col_not_null('om_mincut_node', 'result_id', 'Column result_id should be NOT NULL');
SELECT col_not_null('om_mincut_node', 'node_id', 'Column node_id should be NOT NULL');

-- Check indexes
SELECT has_index('om_mincut_node', 'mincut_node_index', 'Table should have mincut_node_index on the_geom');

SELECT * FROM finish();

ROLLBACK;