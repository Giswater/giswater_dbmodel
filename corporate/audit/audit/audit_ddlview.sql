/*
Copyright © 2023 by BGEO. All rights reserved.
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/



CREATE or replace VIEW audit.v_log AS
SELECT user_name,  count (*) , action, date FROM 
(SELECT user_name, substring(query,0,30)  as action, (substring(date_trunc('day',(tstamp))::text,0,12))::date AS date from audit.log
where  schema = 'SCHEMA_NAME')a
group by user_name, date, action
ORDER BY date desc;

GRANT ALL ON TABLE audit.v_log TO role_master;
