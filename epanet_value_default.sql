/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- Only numeric default values are allowed

-- ----------------------------
-- Default values of node
-- ----------------------------

ALTER TABLE "SCHEMA_NAME".node
ALTER COLUMN elevation SET DEFAULT 0.00;
