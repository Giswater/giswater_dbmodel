/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;
--2020/07/06
INSERT INTO config_api_form_fields (formname, formtype, column_id, datatype, widgettype,label,tooltip, ismandatory, isparent,iseditable,
hidden,layout_name)
VALUES('ve_arc','feature','tstamp','date','text','Insert tstamp','tstamp - Fecha de inserción del elemento a la base de datos',
false,false,false,true,'layout_data_2') ON CONFLICT (formname, formtype, column_id) DO NOTHING;

INSERT INTO config_api_form_fields (formname, formtype, column_id, datatype, widgettype,label,tooltip, ismandatory, isparent,iseditable,
hidden,layout_name)
VALUES('ve_node','feature','tstamp','date','text','Insert tstamp','tstamp - Fecha de inserción del elemento a la base de datos',
false,false,false,true,'layout_data_2') ON CONFLICT (formname, formtype, column_id) DO NOTHING;

INSERT INTO config_api_form_fields (formname, formtype, column_id, datatype, widgettype,label,tooltip, ismandatory, isparent,iseditable,
hidden,layout_name)
VALUES('ve_connec','feature','tstamp','date','text','Insert tstamp','tstamp - Fecha de inserción del elemento a la base de datos',
false,false,false,true,'layout_data_2') ON CONFLICT (formname, formtype, column_id) DO NOTHING;

--2020/07/16
INSERT INTO config_api_typevalue (typevalue, id, idval)
VALUES ('widgettype_typevalue','textarea', 'textArea')ON CONFLICT (typevalue, id) DO NOTHING;
