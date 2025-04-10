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

-- Check table macroomzone
SELECT has_table('macroomzone'::name, 'Table macroomzone should exist');

-- Check columns
SELECT columns_are(
    'macroomzone',
    ARRAY[
        'macroomzone_id', 'code', 'name', 'descript', 'expl_id', 'lock_level',
        'active', 'the_geom', 'created_at', 'created_by', 'updated_at', 'updated_by'
    ],
    'Table macroomzone should have the correct columns'
);

-- Check primary key
SELECT col_is_pk('macroomzone', ARRAY['macroomzone_id'], 'Column macroomzone_id should be primary key');

-- Check column types
SELECT col_type_is('macroomzone', 'macroomzone_id', 'integer', 'Column macroomzone_id should be integer');
SELECT col_type_is('macroomzone', 'code', 'text', 'Column code should be text');
SELECT col_type_is('macroomzone', 'name', 'varchar(50)', 'Column name should be varchar(50)');
SELECT col_type_is('macroomzone', 'descript', 'text', 'Column descript should be text');
SELECT col_type_is('macroomzone', 'expl_id', 'integer', 'Column expl_id should be integer');
SELECT col_type_is('macroomzone', 'lock_level', 'integer', 'Column lock_level should be integer');
SELECT col_type_is('macroomzone', 'active', 'boolean', 'Column active should be boolean');
SELECT col_type_is('macroomzone', 'the_geom', 'geometry(MultiPolygon,SRID_VALUE)', 'Column the_geom should be geometry(MultiPolygon,SRID_VALUE)');
SELECT col_type_is('macroomzone', 'created_at', 'timestamp with time zone', 'Column created_at should be timestamp with time zone');
SELECT col_type_is('macroomzone', 'created_by', 'varchar(50)', 'Column created_by should be varchar(50)');
SELECT col_type_is('macroomzone', 'updated_at', 'timestamp with time zone', 'Column updated_at should be timestamp with time zone');
SELECT col_type_is('macroomzone', 'updated_by', 'varchar(50)', 'Column updated_by should be varchar(50)');

-- Check foreign keys
SELECT has_fk('macroomzone', 'Table macroomzone should have foreign keys');
SELECT fk_ok('macroomzone', 'expl_id', 'exploitation', 'expl_id', 'FK macroomzone_expl_id_fkey should exist');

-- Check constraints
SELECT col_default_is('macroomzone', 'active', 'true', 'Column active should default to true');
SELECT col_default_is('macroomzone', 'created_at', 'now()', 'Column created_at should default to now()');
SELECT col_default_is('macroomzone', 'created_by', 'CURRENT_USER', 'Column created_by should default to CURRENT_USER');

SELECT * FROM finish();

ROLLBACK;
