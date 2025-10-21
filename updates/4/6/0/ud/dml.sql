/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 21/10/2025
INSERT INTO sys_label (id,idval,label_type)
	VALUES (3013,'To check CRITICAL ERRORS or WARNINGS, execute a query FROM anl_table WHERE fid=error number AND current_user. For example:

SELECT * FROM MySchema.anl_arc WHERE fid = Myfid AND cur_user=current_user;

Only the errors with anl_table next to the number can be checked this way. Using Giswater Toolbox it''s also posible to check these errors.','header');