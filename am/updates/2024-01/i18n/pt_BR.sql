/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

SET search_path = am, public;

UPDATE config_form_tableview SET alias = 'Corporativo' WHERE objectname = 'cat_result' AND columnname = 'iscorporate';
