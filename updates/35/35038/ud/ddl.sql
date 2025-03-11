/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME ,public;


ALTER TABLE "inp_subcatchment" DROP CONSTRAINT IF EXISTS "subcatchment_rg_id_fkey";

ALTER TABLE inp_subcatchment ADD CONSTRAINT subcatchment_rg_id_fkey
FOREIGN KEY (rg_id) REFERENCES raingage(rg_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "raingage" DROP CONSTRAINT IF EXISTS "raingage_timser_id_fkey";

ALTER TABLE raingage ADD CONSTRAINT raingage_timser_id_fkey
FOREIGN KEY (timser_id) REFERENCES inp_timeseries(id) ON UPDATE CASCADE ON DELETE RESTRICT;
