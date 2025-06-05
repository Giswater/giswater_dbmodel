/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 3316

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_admin_transfer_addfields_values();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_admin_transfer_addfields_values()
  RETURNS json AS
$BODY$


/*EXAMPLE

-- Execute function for 1 cat_feature_id
SELECT SCHEMA_NAME.gw_fct_admin_transfer_addfields_values($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, 
"form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "parameters":{"catFeatureId":"UNION"}}}$$);

-- Execute function for all cat_feature_id (all addfields for each cat_feature)
 SELECT ud.gw_fct_admin_transfer_addfields_values(concat('{"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, 
"form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "parameters":{"catFeatureId":"', cat_feature_id, '"}}}')::json)
FROM (select distinct cat_feature_id from sys_addfields where feature_type = 'CHILD')a;

-- Execute function for common addfields:
SELECT ud.gw_fct_admin_transfer_addfields_values($${"client":{"device":4, "lang":"es_ES", "infoType":1, "epsg":25831}, 
"form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "parameters":{"catFeatureId":null}}}$$);

-- fid: 218

*/

DECLARE

    v_schemaname text;
    v_project_type text;
    v_version text;
    v_error_context text;
    v_sql text;
    v_count integer;

    rec_mav record;
    rec_sa record;
    rec_sa_featurestypes record;
    rec_sys record;
    rec_fgk record;

    v_feature_childtable_name text;

    v_cat_feature text;
    v_feature_type text;
    v_feature_system_id text;
    v_viewname text;
    v_view_type integer;
    v_man_fields text;
    v_feature_childtable_fields text;
    v_data_view json;
    exists_record BOOLEAN;
    v_exists_col boolean;
    rec_feature record;
    v_partialquery text;

    v_cat_feature_id text;
    v_addf_type text;
    v_sql_addf text;

    rec_param_name record;

BEGIN

	-- search path
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';

 	SELECT project_type, giswater INTO v_project_type, v_version FROM sys_version ORDER BY id DESC LIMIT 1;

	-- Starting process
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (218, null, 4, 'TRANSFER ADDFIELDS VALUES');
	INSERT INTO audit_check_data (fid, result_id, criticity, error_message) VALUES (218, null, 4, '-------------------------------------------------------------');

	v_cat_feature_id := ((p_data ->>'data')::json->>'parameters')::json->>'catFeatureId'::text;

	if v_cat_feature_id is null then -- addfields for all cat_features

		v_partialquery = 'WHERE sa.feature_type !=''CHILD''';

	else -- addfields for a especific cat_features

		v_partialquery = 'WHERE ct.id = upper('||quote_literal(v_cat_feature_id)||')';

	end if;

	
    -- SECTION: Create table and/or columns in new addfields tables (in case the table exists)

	v_sql_addf = '
        SELECT sa.param_name, ct.feature_type, sa.datatype_id, ct.id FROM sys_addfields sa
       	left join cat_feature ct on sa.cat_feature_id = ct.id '||v_partialquery||'
		';

    FOR rec_sa in execute v_sql_addf
    loop
	    
	    raise notice 'rec_sa.id (%) ------> %', rec_sa.id, rec_sa.param_name;

        v_feature_childtable_name := 'man_' || lower(rec_sa.feature_type) || '_' || lower(rec_sa.id);

        IF (SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = v_schemaname AND table_name = v_feature_childtable_name)) 
        IS FALSE then -- new addfields table does not exists -> create it
        
        	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || v_feature_childtable_name || ' (
                    '|| lower(rec_sa.feature_type) || '_id varchar PRIMARY KEY,
                    ' || lower(rec_sa.param_name) || ' '||rec_sa.datatype_id||'
                )';

            EXECUTE 'ALTER TABLE ' || v_feature_childtable_name || ' ADD CONSTRAINT ' || v_feature_childtable_name || '_fk FOREIGN KEY ('|| lower(rec_sa.feature_type) ||'_id) REFERENCES '|| v_schemaname ||'.'|| lower(rec_sa.feature_type) || '('|| lower(rec_sa.feature_type) || '_id) 
            ON UPDATE CASCADE ON DELETE CASCADE;';

            EXECUTE 'INSERT INTO sys_table (id, descript, sys_role) VALUES ('||quote_literal(v_feature_childtable_name)||', null, ''role_edit'') ON CONFLICT (id) DO NOTHING;';

        ELSE
        
            IF (SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = v_schemaname AND table_name = v_feature_childtable_name AND column_name = lower(rec_sa.param_name))) IS FALSE THEN
                EXECUTE 'ALTER TABLE ' || v_feature_childtable_name || ' ADD COLUMN ' || lower(rec_sa.param_name) || ' '||rec_sa.datatype_id||'';
            END IF;
          
        END IF;

	end loop;

    -- !SECTION
	

    -- SECTION: Transfer addfields values
  	if v_cat_Feature_id is not null then

        -- SECTION of a specific cat_feature_id

        -- insert into log tables those null addfield values
        INSERT INTO audit_log_data (fid, feature_id, feature_type, log_message, addparam)
        SELECT 525, feature_id, cat_Feature_id, 'Null value on addfield',
        concat('{"parameter_id": ', parameter_id, '}')::json
        FROM _man_addfields_value_ mav
        JOIN sys_addfields sa ON sa.id = mav.parameter_id
        WHERE value_param IS null and sa.cat_feature_id = upper(v_cat_feature_id);


       v_sql_addf = '
            SELECT mav.feature_id, mav.value_param, mav.parameter_id, sa.param_name, sa.datatype_id, cf.id, cf.feature_type, cf.child_layer
            FROM _man_addfields_value_ mav
            INNER JOIN sys_addfields sa ON sa.id = mav.parameter_id
            INNER JOIN cat_feature cf ON cf.id = sa.cat_feature_id
            WHERE mav.value_param is not null
            and cf.id = UPPER('||quote_literal(v_cat_feature_id)||')
            ORDER BY sa.param_name
			';
		
		execute 'select count(*) from ('||v_sql_addf||')a' into v_count;
	
		if v_count = 0 then
		
			RETURN ('{"status":"Failed", "message":{"level":"3", "text":"The feature '||v_cat_feature_id||' does not have any values in table man_addfields_value"}, "version":"'||v_version||'"}')::json;

		end if;
		

		execute 'SELECT*FROM ('||v_sql_addf||')a LIMIT 1' into rec_mav; -- get name of the table of addfield from v_sql_addf
	
        v_feature_childtable_name := 'man_' || lower(rec_mav.feature_type) || '_' || lower(rec_mav.id);
       

        -- insert into addfields table, all the feature_id that (1) exist on its parent table and (2) have any value on an addfield
            -- insert into man_node_junction (node_id) select feature_id from (v_sql_addf) where feature_id in (select node_id from node)
      	execute '
		insert into '||v_feature_childtable_name||' ('||lower(rec_mav.feature_type)||'_id) 
		SELECT feature_id from ('||v_sql_addf||')a WHERE feature_id IN (
		select '||lower(rec_mav.feature_type)||'_id from '||lower(rec_mav.feature_type)||'
		) 
		ON CONFLICT ('||lower(rec_mav.feature_type)||'_id) do nothing';


		-- update addfields that have been migrated
		for rec_param_name in execute 'select distinct param_name, datatype_id from ('||v_sql_addf||')a'
		loop
					
			EXECUTE '
			update '||v_feature_childtable_name||' t 
			set '||rec_param_name.param_name||' = a.value_param from (
			select feature_id, value_param::'||rec_param_name.datatype_id||' from ('||v_sql_addf||')b
			where param_name = '||quote_literal(rec_param_name.param_name)||'
			)a where t.'||lower(rec_mav.feature_type)||'_id = a.feature_id';
			
		end loop;
		
        -- !SECTION
       
    else 

        -- SECTION of all cat_feature_id

        IF v_project_type = 'UD' THEN

            v_partialquery = ' 
            SELECT b.node_id AS feature_id, ''NODE'' AS feature_type, node_type as cat_feature_id FROM node b UNION 
            SELECT b.arc_id AS feature_id, ''ARC'' AS feature_type, arc_type as cat_feature_id FROM arc b UNION 
            SELECT b.connec_id AS feature_id, ''CONNEC'' AS feature_type, connec_type AS cat_feature_id FROM connec b UNION
            SELECT gully_id AS feature_id, ''GULLY'' AS feature_type, gully_type AS feature_type FROM gully b';
            
        elsif v_project_type = 'WS' then
        
            v_partialquery = '
            SELECT b.node_id AS feature_id, ''NODE'' AS feature_type, a.nodetype_id as cat_feature_id FROM node b join cat_node a on b.nodecat_id = a.id UNION 
            SELECT b.arc_id AS feature_id, ''ARC'' AS feature_type, a.arctype_id as cat_feature_id FROM arc b left join cat_arc a on b.arccat_id = a.id UNION 
            SELECT b.connec_id AS feature_id, ''CONNEC'' AS feature_type, a.connectype_id AS cat_feature_id FROM connec b left join cat_connec a on b.connecat_id = a.id
            ';

        END IF;

        IF EXISTS (SELECT 1 FROM _man_addfields_value_ mav LEFT JOIN sys_addfields sa ON sa.id = mav.parameter_id WHERE mav.value_param IS NOT NULL) THEN

            v_sql_addf = '   
            WITH subq_1 AS (
                select*from ('||v_partialquery||')								
            ),       
            subq_2 as (
                SELECT mav.feature_id, mav.value_param, sa.param_name, sa.datatype_id
                FROM _man_addfields_value_ mav
                LEFT JOIN sys_addfields sa ON sa.id = mav.parameter_id
                LEFT JOIN cat_feature cf ON cf.id = sa.cat_feature_id
                WHERE sa.feature_type = ''ALL'' AND value_param IS NOT NULL
                ORDER BY sa.param_name
            )       
            SELECT b.feature_id, b.feature_type, a.value_param, a.param_name, a.datatype_id, b.cat_feature_id, 
            concat(''man_'', lower(feature_type), ''_'', lower(cat_feature_id)) as man_table 
            FROM subq_2 a JOIN subq_1 b USING (feature_id)';
            
            
            for rec_param_name in execute 'select distinct man_table, param_name, feature_type, datatype_id from ('||v_sql_addf||')a'
            loop
            
                execute '
                update '||rec_param_name.man_table||' t set '||rec_param_name.param_name||' = a.value_param from (
                    select feature_id, value_param::'||rec_param_name.datatype_id||' from ('||v_sql_addf||')b 
                    where param_name = '||quote_literal(rec_param_name.param_name)||'
                    and man_table = '||quote_literal(rec_param_name.man_table)||'
                )a where t.'||lower(rec_param_name.feature_type)||'_id = a.feature_id
                ';
            
            end loop;

        END IF;

        -- update sys_foreignkey values
        IF EXISTS (SELECT 1 FROM _man_addfields_value_ mav LEFT JOIN sys_addfields sa ON sa.id = mav.parameter_id WHERE mav.value_param IS NOT NULL) THEN
            FOR rec_fgk IN
                SELECT sf.typevalue_table, sf.typevalue_name, sf.target_table, sf.target_field, cf.feature_type, sa.cat_feature_id, sa.param_name
                FROM sys_foreignkey sf
                INNER JOIN sys_addfields sa on sa.param_name = sf.typevalue_name
                INNER JOIN cat_feature cf on cf.id = sa.cat_feature_id
                WHERE sf.target_table = 'man_addfields_value'
            LOOP
                v_feature_childtable_name := 'man_' || lower(rec_fgk.feature_type) || '_' || lower(rec_fgk.cat_feature_id);
                EXECUTE 'UPDATE sys_foreignkey SET typevalue_table=''edit_typevalue'', typevalue_name='''|| rec_fgk.param_name ||''', target_table='''|| v_feature_childtable_name ||''', target_field='''|| rec_fgk.param_name ||''' WHERE typevalue_table='''|| rec_fgk.typevalue_table ||''' AND typevalue_name='''|| rec_fgk.typevalue_name ||''' AND target_table='''|| rec_fgk.target_table ||''' AND target_field='''|| rec_fgk.target_field ||''' ;';
            END LOOP;

        END IF;
	
        -- !SECTION
    
    end if;

    -- !SECTION
    

    -- SECTION: Report of transfer addfields

    -- TODO: Replace "rec_mav" by queries to man_addfields_value table
/*
    -- check if feature_id exists in parent table
    v_sql = 'SELECT * FROM ('||v_sql_addf||')
            WHERE feature_id NOT IN (select '||lower(rec_mav.feature_type)'_id from '||lower(rec_mav.feature_type)'';

    EXECUTE 'SELECT count(*) from ('||v_sql||')' INTO v_count;

    IF v_count = 0 then -- feature_id of man_addfields_value does not exist in parent table

        EXECUTE '
        INSERT INTO audit_log_data (fid, feature_id, feature_type, log_message, addparam)
        SELECT 525, feature_id, feature_type, 
        ''Non-existing feature_id for this addfield '',
        json_build_object(''parameter_id'', parameter_id, ''value_param'', value_param) AS js 
        FROM ('||v_sql||')
        WHERE feature_id NOT '||quote_literal(rec_mav.feature_id)||' AND parameter_id = '||quote_literal(rec_mav.parameter_id)||'';


    ELSIF v_count > 0 then -- feature_id of man_addfields_value exists in parent table

        -- check if feature_type of the feature_id of the addfield matches the real feature_type of the object
        EXECUTE '
        SELECT count(*) FROM '||lower(rec_mav.feature_type)||' 
        WHERE '||lower(rec_mav.feature_type)||'_id = '||quote_literal(rec_mav.feature_id)||'
        AND '||lower(rec_mav.feature_type)||'at_id  = '||quote_literal(rec_mav.id)||''
        INTO v_count;

        IF v_count = 0 THEN

            EXECUTE
            'INSERT INTO audit_log_data (fid, feature_id, feature_type, log_message, addparam)
            SELECT 525, '||quote_literal(rec_mav.feature_id)||', '||quote_literal(rec_mav.feature_type)||', 
            ''The value of this addfield is related to a different feature_type from the existing feature.'',
            json_build_object(''parameter_id'', '||quote_literal(rec_mav.parameter_id)||', ''value_param'', '||quote_literal(rec_mav.value_param)||') AS js 
            FROM _man_addfields_value_
            WHERE feature_id = '||quote_literal(rec_mav.feature_id)||' AND parameter_id = '||quote_literal(rec_mav.parameter_id)||'';

        END IF;

    END IF;
*/

    -- !SECTION



	RETURN ('{"status":"Accepted", "message":{"level":"3", "text":"Process done successfully for '||v_cat_feature_id||' ('||v_feature_childtable_name||')"}, "version":"'||v_version||'"}')::json;

	-- the exception when others need to be disabled because in case of update if it breaks update proces need to be canceled
	--EXCEPTION WHEN OTHERS THEN
	--GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	--RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$function$
;
