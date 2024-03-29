/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2744

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_typevalue_fk()
  RETURNS trigger AS
$BODY$

DECLARE
v_table text;
v_typevalue_fk text;
rec record;
v_list TEXT[];
v_new_field text;
v_new_data json;
v_new_param integer;
v_field text;
v_disable boolean = true;

BEGIN
	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	v_table:= TG_ARGV[0];
	v_disable := (SELECT value::boolean FROM config_param_user WHERE parameter = 'edit_typevalue_fk_disable' AND cur_user = current_user);
	
	IF v_disable THEN 
		RETURN NULL;
	ELSE

		-- Do no allow to insert or update value '0' for exploitation
		IF v_table IN ('arc', 'node', 'connec', 'gully', 'element', 'link') AND TG_OP IN ('INSERT', 'UPDATE') THEN
			IF NEW.expl_id = 0 THEN 
				EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},
				"feature":{},
				"data":{"message":"3250", "function":"2744","debug_msg":"", "variables":"value", "is_process":true}}$$)';
			END IF;
		END IF;
				
		--select typevalue for the table
		v_typevalue_fk = 'SELECT * FROM sys_foreignkey WHERE target_table='''||v_table||''' AND active IS TRUE';
		
		--insert new fields values into json
		v_new_data := row_to_json(NEW.*);

		--in case that field is one of the addfields capture the parameter_id
		v_new_param = (v_new_data ->>'parameter_id')::text;

		IF v_typevalue_fk IS NOT NULL THEN
		
			--loop over defined typevalues
			FOR rec IN EXECUTE v_typevalue_fk LOOP
				
				--capture new value of a target field
				v_new_field = (v_new_data ->>rec.target_field)::text;
			
				IF  v_new_param = rec.parameter_id or v_new_param IS NULL THEN
					--create a list of possible values of the field
					EXECUTE 'SELECT array_agg(id) FROM '||rec.typevalue_table||' 
					WHERE typevalue='''||rec.typevalue_name||''';'
					INTO v_list;		
					--compare the new value with the list of possible options
					IF  v_new_field = ANY(v_list) OR v_new_field IS NULL  THEN
						CONTINUE;
					ELSE 
						IF rec.target_field = 'value_param' THEN
							v_field = rec.typevalue_name;
						ELSE
							v_field=rec.target_field;
						END IF;

						v_new_field = REPLACE(v_new_field, '"', '\"');
						
						EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
						"data":{"message":"3022", "function":"2744","debug_msg":
						"'||concat('Catalog: ', rec.typevalue_table,', insert table: ',v_table, ', field: ',v_field,', value: ', v_new_field)||'"}}$$);';	

					END IF;
				END IF;
			END LOOP;
		END IF;
	END IF;
		
	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;