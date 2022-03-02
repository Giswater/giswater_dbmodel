/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_audit()
  RETURNS trigger AS
$BODY$

/*
The goal of this trigger is to disable it when mapzones are enabled in order to enhance performance
*/


DECLARE
v_old_data json;
v_new_data json;
v_sector boolean = true;
v_minsector boolean = true;
v_presszone boolean = true;
v_dqa boolean = true;
v_dma boolean = true;

BEGIN

--	Set search path to local schema
	SET search_path = SCHEMA_NAME, public;

	IF (TG_OP = 'INSERT') THEN
		v_new_data := row_to_json(NEW.*);
		INSERT INTO audit.log (schema,table_name,user_name,action,newdata,query)
		VALUES (TG_TABLE_SCHEMA::TEXT, TG_TABLE_NAME::TEXT ,session_user::TEXT,substring(TG_OP,1,1),v_new_data, current_query());
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
    
		IF current_query() like '%gw_fct_grafanalytics_mapzones%' THEN
		
		ELSE
			v_old_data := row_to_json(OLD.*);
			v_new_data := row_to_json(NEW.*);
			INSERT INTO audit.log (schema,table_name,user_name,action,olddata,newdata,query) 
			VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query());
		END IF;

	
		RETURN NEW;
	
	ELSIF (TG_OP = 'DELETE') THEN
		v_old_data := row_to_json(OLD.*);
		INSERT INTO audit.log (schema,table_name,user_name,action,olddata,query)
		VALUES (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query());
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;