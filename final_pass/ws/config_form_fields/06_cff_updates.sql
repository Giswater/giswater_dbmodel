/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

DELETE FROM config_form_fields WHERE (formname ILIKE '%frelem%' OR formname ILIKE '%genelem%') AND tabname = 'tab_none';
DELETE FROM config_form_fields WHERE formname ILIKE '%frelem%' AND columnname = 'nodarc_id';

-- 05/08/2025
UPDATE config_form_fields SET dv_querytext = 'WITH check_value AS (
  SELECT value::integer AS psector_value 
  FROM config_param_user 
  WHERE parameter = ''plan_psector_current''
  AND cur_user = current_user
)
SELECT id, name as idval 
FROM value_state 
WHERE id IS NOT NULL 
AND CASE 
  WHEN (SELECT psector_value FROM check_value) IS NULL THEN id != 2 
  ELSE id=2 
END' WHERE columnname = 'state';


-- 06/08/2025
-- Add brand and model to ve_node, ve_arc, ve_connec, ve_element, ve_frelem, ve_genelem
  -- Existing ones
    -- Brand_id
UPDATE config_form_fields SET dv_querytext = NULL, label = 'Brand', isparent = false, isautoupdate = false, widgetcontrols = '{"setMultiline":false}'::json
WHERE columnname = 'brand_id' AND formtype = 'form_feature' AND tabname = 'tab_data';

DO $$
DECLARE
  v_dv_querytext text;
  v_layoutorder integer;
  rec record;
BEGIN
  FOR rec IN SELECT * FROM config_form_fields WHERE formtype='form_feature' AND columnname='brand_id' AND tabname='tab_data' AND formname ilike any(array['ve_node_%', 've_arc_%', 've_connec_%', 've_gully_%'])
  LOOP
    v_dv_querytext := format('SELECT id, id as idval FROM cat_brand WHERE %L = ANY(featurecat_id::text[])', upper(regexp_replace(rec.formname, '^ve_(node|arc|connec|gully)_', '', 'i')));
    v_layoutorder := (SELECT MAX(layoutorder) + 1 FROM config_form_fields WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND layoutname = 'lyt_data_2');
	UPDATE config_form_fields SET dv_querytext = v_dv_querytext, widgettype = 'combo', layoutname = 'lyt_data_2', layoutorder = v_layoutorder WHERE formname = rec.formname AND formtype = rec.formtype AND columnname = rec.columnname AND tabname = rec.tabname;
  END LOOP;
END $$;

    -- Model_id
UPDATE config_form_fields SET dv_querytext = NULL, label = 'Model', isparent = false, isautoupdate = false, widgetcontrols = '{"setMultiline":false}'::json
WHERE columnname = 'model_id' AND formtype = 'form_feature' AND tabname = 'tab_data';

DO $$
DECLARE
  v_dv_querytext text;
  v_layoutorder integer;
  rec record;
BEGIN
  FOR rec IN SELECT * FROM config_form_fields WHERE formtype='form_feature' AND columnname='model_id' AND tabname='tab_data' AND formname ilike any(array['ve_node_%', 've_arc_%', 've_connec_%', 've_gully_%'])
  LOOP
    v_dv_querytext := format('SELECT id, id as idval FROM cat_brand_model WHERE %L = ANY(featurecat_id::text[])', upper(regexp_replace(rec.formname, '^ve_(node|arc|connec|gully)_', '', 'i')));
    v_layoutorder := (SELECT MAX(layoutorder) + 1 FROM config_form_fields WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND layoutname = 'lyt_data_2');
	UPDATE config_form_fields SET dv_querytext = v_dv_querytext, widgettype = 'combo', layoutname = 'lyt_data_2', layoutorder = v_layoutorder WHERE formname = rec.formname AND formtype = rec.formtype AND columnname = rec.columnname AND tabname = rec.tabname;
  END LOOP;
END $$;

 -- New ones
    -- brand_id
DO $$
DECLARE
  v_dv_querytext text;
  v_layoutorder integer;
  rec record;
BEGIN
  FOR rec IN SELECT DISTINCT formname, formtype, tabname FROM config_form_fields cff WHERE formname ILIKE ANY (ARRAY['ve_node_%', 've_arc_%', 've_connec_%', 've_gully_%'])
      AND tabname = 'tab_data' AND formtype = 'form_feature' AND NOT EXISTS (SELECT 1 FROM config_form_fields cff2 WHERE cff2.formname = cff.formname AND cff2.formtype = cff.formtype
      AND cff2.tabname = cff.tabname AND cff2.columnname = 'brand_id')
  LOOP
    v_dv_querytext := format('SELECT id, id as idval FROM cat_brand WHERE %L = ANY(featurecat_id::text[])', upper(regexp_replace(rec.formname, '^ve_(node|arc|connec|gully)_', '', 'i')));
    v_layoutorder := (SELECT MAX(layoutorder) + 1 FROM config_form_fields WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND layoutname = 'lyt_data_2');

    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, label, tooltip, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, hidden) VALUES
    (rec.formname, rec.formtype, rec.tabname, 'brand_id', 'lyt_data_2', v_layoutorder, 'text', 'combo', 'Brand id', 'brand_id', false, false, true, false, v_dv_querytext, false);
  END LOOP;
END $$;

    -- model_id
DO $$
DECLARE
  v_dv_querytext text;
  v_layoutorder integer;
  rec record;
BEGIN
  FOR rec IN SELECT DISTINCT formname, formtype, tabname FROM config_form_fields cff WHERE formname ILIKE ANY (ARRAY['ve_node_%', 've_arc_%', 've_connec_%', 've_gully_%'])
      AND tabname = 'tab_data' AND formtype = 'form_feature' AND NOT EXISTS (SELECT 1 FROM config_form_fields cff2 WHERE cff2.formname = cff.formname AND cff2.formtype = cff.formtype
      AND cff2.tabname = cff.tabname AND cff2.columnname = 'model_id')
  LOOP
    v_dv_querytext := format('SELECT id, id as idval FROM cat_brand_model WHERE %L = ANY(featurecat_id::text[])', upper(regexp_replace(rec.formname, '^ve_(node|arc|connec|gully)_', '', 'i')));
    v_layoutorder := (SELECT MAX(layoutorder) + 1 FROM config_form_fields WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND layoutname = 'lyt_data_2');

    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, label, tooltip, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, hidden) VALUES
    (rec.formname, rec.formtype, rec.tabname, 'model_id', 'lyt_data_2', v_layoutorder, 'text', 'combo', 'Model id', 'model_id', false, false, true, false, v_dv_querytext, false);
  END LOOP;
END $$;

  -- Elements
    -- ve_frelem
      -- evalve
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_evalve','form_feature','tab_data','brand_id','lyt_data_1',13,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''EVALVE'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_evalve','form_feature','tab_data','model_id','lyt_data_1',14,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''EVALVE'' = ANY(featurecat_id::text[])');

      -- epump
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_epump','form_feature','tab_data','brand_id','lyt_data_1',13,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''EPUMP'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_epump','form_feature','tab_data','model_id','lyt_data_1',14,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''EPUMP'' = ANY(featurecat_id::text[])');


UPDATE config_form_fields SET layoutorder=15 WHERE formname ILIKE 've_frelem_%' AND formtype='form_feature' AND columnname='rotation' AND tabname='tab_data';
UPDATE config_form_fields SET layoutorder=16 WHERE formname ILIKE 've_frelem_%' AND formtype='form_feature' AND columnname='top_elev' AND tabname='tab_data';

    -- ve_genelem
      -- ecover
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_ecover','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''COVER'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_ecover','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''COVER'' = ANY(featurecat_id::text[])');

      -- ehydrant_plate
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
    VALUES ('ve_frelem_ehydrant_plate','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''HYDRANT_PLATE'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_ehydrant_plate','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''HYDRANT_PLATE'' = ANY(featurecat_id::text[])');

      -- emanhole
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_emanhole','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''MANHOLE'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_emanhole','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''MANHOLE'' = ANY(featurecat_id::text[])');

      -- eprotect_band
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_eprotect_band','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''EPROTECT_BAND'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_eprotect_band','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''EPROTECT_BAND'' = ANY(featurecat_id::text[])');

      -- eregister
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_eregister','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''EREGISTER'' = ANY(featurecat_id::text[])');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_eregister','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''EREGISTER'' = ANY(featurecat_id::text[])');

      -- estep
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_estep','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''ESTEP'' = ANY(featurecat_id::text[]) ');
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext)
	VALUES ('ve_frelem_estep','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''ESTEP'' = ANY(featurecat_id::text[])');

UPDATE config_form_fields SET layoutorder=14 WHERE formname ILIKE 've_genelem_%' AND formtype='form_feature' AND columnname='rotation' AND tabname='tab_data';
UPDATE config_form_fields SET layoutorder=15 WHERE formname ILIKE 've_genelem_%' AND formtype='form_feature' AND columnname='top_elev' AND tabname='tab_data';

-- Generate base element
DELETE FROM config_form_fields WHERE formname = 've_element';

INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,stylesheet,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','sector_id','lyt_bot_1',1,'integer','combo','Sector ID','Sector ID',false,false,true,false,'SELECT sector_id as id, name as idval FROM sector WHERE sector_id IS NOT NULL',true,false,'{"label":"color:blue; font-weight:bold;"}'::json,'{"setMultiline": false, "labelPosition": "top"}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','state','lyt_bot_1',2,'integer','combo','State','State',false,false,true,false,'SELECT id, name as idval FROM value_state WHERE id IS NOT NULL',true,false,'{"setMultiline": false, "labelPosition": "top"}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','state_type','lyt_bot_1',3,'integer','combo','State Type','State Type',false,false,true,false,'SELECT id, name as idval FROM value_state_type WHERE id IS NOT NULL',true,false,'{"setMultiline": false, "labelPosition": "top"}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','code','lyt_data_1',1,'string','text','Code','Code',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','num_elements','lyt_data_1',2,'integer','text','Number of Elements','Number of Elements',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','comment','lyt_data_1',3,'string','text','Comments','Comments',false,false,true,false,'{"setMultiline":true}'::json,true) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','function_type','lyt_data_1',4,'string','combo','Function Type','Function Type',false,false,true,false,'SELECT function_type as id, function_type as idval FROM man_type_function WHERE feature_type = ''ELEMENT'' OR ''EORIFICE'' = ANY(featurecat_id::text[])',true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','category_type','lyt_data_1',5,'string','combo','Category Type','Category Type',false,false,true,false,'SELECT category_type as id, category_type as idval FROM man_type_category WHERE feature_type = ''ELEMENT'' OR ''EORIFICE'' = ANY(featurecat_id::text[])',true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','location_type','lyt_data_1',6,'string','combo','Location Type','Location Type',false,false,true,false,'SELECT location_type as id, location_type as idval FROM man_type_location WHERE feature_type = ''ELEMENT'' OR ''EORIFICE'' = ANY(featurecat_id::text[])',true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,widgetcontrols,linkedobject,hidden)
	VALUES ('ve_element','form_feature','tab_data','workcat_id','lyt_data_1',7,'string','typeahead','Workcat ID','Workcat ID',false,false,true,false,'SELECT id, id as idval FROM cat_work WHERE id IS NOT NULL AND active IS TRUE','{"setMultiline":false}'::json,'action_workcat',false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,placeholder,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','workcat_id_end','lyt_data_1',8,'string','typeahead','Workcat ID End','Workcat ID End','Only when state is obsolete',false,false,true,false,'SELECT id, id as idval FROM cat_work WHERE id IS NOT NULL AND active IS TRUE','{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','builtdate','lyt_data_1',9,'date','datetime','Built Date','Built Date',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','enddate','lyt_data_1',10,'date','datetime','End Date','End Date',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','ownercat_id','lyt_data_1',11,'string','combo','Owner Catalog','Owner Catalog',false,false,true,false,'SELECT id, id as idval FROM cat_owner WHERE id IS NOT NULL AND active IS TRUE',true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,hidden)
	VALUES ('ve_element','form_feature','tab_data','brand_id','lyt_data_1',12,'text','combo','Brand','brand_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand WHERE ''GENELEM'' = ANY(featurecat_id::text[])', false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,hidden)
	VALUES ('ve_element','form_feature','tab_data','model_id','lyt_data_1',13,'text','combo','Model','model_id',false,false,true,false,'SELECT id, id as idval FROM cat_brand_model WHERE ''GENELEM'' = ANY(featurecat_id::text[])',false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','rotation','lyt_data_1',12,'double','text','Rotation','Rotation',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','top_elev','lyt_data_1',13,'double','text','Top Elevation','Top Elevation',false,false,true,false,'{"setMultiline":false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,stylesheet,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','expl_id','lyt_data_2',1,'integer','combo','Exploitation ID','Exploitation ID',false,false,true,false,'SELECT expl_id as id, name as idval FROM exploitation WHERE expl_id IS NOT NULL',true,false,'{"label":"color:green; font-weight:bold;"}'::json,'{"setMultiline": false}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,dv_querytext,dv_orderby_id,dv_isnullvalue,hidden)
	VALUES ('ve_element','form_feature','tab_data','muni_id','lyt_data_3',1,'string','combo','Municipality id:','muni_id - Identifier of the municipality',false,false,true,'SELECT muni_id as id, name as idval from v_ext_municipality WHERE muni_id IS NOT NULL',true,false,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','observ','lyt_data_3',2,'string','text','Observations','Observations',false,false,true,false,'{"setMultiline":true}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,dv_querytext,dv_orderby_id,dv_isnullvalue,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','elementcat_id','lyt_top_1',1,'string','combo','Element Catalog','Element Catalog',true,false,true,false,'SELECT id, id as idval FROM cat_element WHERE element_type = ''ECOVER''',true,false,'{"setMultiline": false, "labelPosition": "top"}'::json,false) ON CONFLICT DO NOTHING;
INSERT INTO config_form_fields (formname,formtype,tabname,columnname,layoutname,layoutorder,"datatype",widgettype,"label",tooltip,ismandatory,isparent,iseditable,isautoupdate,widgetcontrols,hidden)
	VALUES ('ve_element','form_feature','tab_data','element_id','lyt_top_1',2,'string','text','Element ID','Element ID',false,false,false,false,'{"saveValue":false,"setMultiline": false, "labelPosition": "top"}'::json,false) ON CONFLICT DO NOTHING;


-- Config_form_fields
DO $$
DECLARE
  rec record;
BEGIN
-- frelem
  FOR rec IN (SELECT * FROM config_form_fields WHERE formname ILIKE '%frelem_%')
  LOOP
    UPDATE config_form_fields SET formname = replace(rec.formname, 'frelem', 'element') WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND columnname = rec.columnname;
  END LOOP;
  -- genelem
  FOR rec IN (SELECT * FROM config_form_fields WHERE formname ILIKE '%genelem_%')
  LOOP
    UPDATE config_form_fields SET formname = replace(rec.formname, 'genelem', 'element') WHERE formname = rec.formname AND formtype = rec.formtype AND tabname = rec.tabname AND columnname = rec.columnname;
  END LOOP;
END $$;

-- 12/08/2025
DELETE FROM config_form_fields WHERE formname ILIKE '%element%' AND formtype='form_feature' AND columnname='order_id' AND tabname='tab_data';
UPDATE config_form_fields SET layoutorder=4 WHERE formname ILIKE '%element%' AND formtype='form_feature'AND tabname='tab_data' AND columnname='expl_id' AND layoutorder=5;
UPDATE config_form_fields
	SET layoutorder=3
	WHERE formname='ve_element_epump' AND formtype='form_feature' AND columnname='flwreg_length' AND tabname='tab_data';
UPDATE config_form_fields
	SET layoutorder=2
	WHERE formname='ve_element_epump' AND formtype='form_feature' AND columnname='to_arc' AND tabname='tab_data';

-- Editable, datatype and mandatory fields for frelemnts
UPDATE config_form_fields
	SET ismandatory=true,iseditable=true
	WHERE formname='ve_element_epump' AND formtype='form_feature' AND columnname='to_arc' AND tabname='tab_data';
UPDATE config_form_fields
	SET iseditable=true,"datatype"='integer'
	WHERE formname='ve_element_eorifice' AND formtype='form_feature' AND columnname='to_arc' AND tabname='tab_data';
UPDATE config_form_fields
	SET iseditable=true,"datatype"='integer'
	WHERE formname='ve_element_eoutlet' AND formtype='form_feature' AND columnname='to_arc' AND tabname='tab_data';
UPDATE config_form_fields
	SET iseditable=true,"datatype"='integer'
	WHERE formname='ve_element_eweir' AND formtype='form_feature' AND columnname='to_arc' AND tabname='tab_data';

-- last update
-- Normalize "label": replace underscores with spaces, trim, ensure only the first letter is uppercase,
-- and append a colon if missing. Only updates rows needing changes.
UPDATE config_form_fields
SET "label" =
    UPPER(LEFT(cleaned, 1)) ||
    SUBSTRING(cleaned FROM 2) ||
    CASE WHEN RIGHT(cleaned, 1) = ':' THEN '' ELSE ':' END
FROM (
    SELECT
        formname, formtype, columnname, tabname,
        TRIM(
            regexp_replace(
                regexp_replace(replace("label", '_', ' '), '\s+', ' ', 'g'),
                '\s+$', '', 'g'
            )
        ) AS cleaned
    FROM config_form_fields
) AS sub
WHERE config_form_fields.formname   = sub.formname
  AND config_form_fields.formtype   = sub.formtype
  AND config_form_fields.columnname = sub.columnname
  AND config_form_fields.tabname    = sub.tabname
  AND "label" IS NOT NULL
  AND (
        LEFT("label", 1) <> UPPER(LEFT("label", 1))
     OR RIGHT(sub.cleaned, 1) <> ':'
  );

UPDATE config_param_system
SET "label" =
    UPPER(LEFT(cleaned, 1)) ||
    SUBSTRING(cleaned FROM 2) ||
    CASE WHEN RIGHT(cleaned, 1) = ':' THEN '' ELSE ':' END
FROM (
    SELECT
        "parameter",
        TRIM(
            regexp_replace(
                regexp_replace(replace("label", '_', ' '), '\s+', ' ', 'g'),
                '\s+$', '', 'g'
            )
        ) AS cleaned
    FROM config_param_system
) AS sub
WHERE config_param_system."parameter" = sub."parameter"
  AND "label" IS NOT NULL
  AND (
        LEFT("label", 1) <> UPPER(LEFT("label", 1))
     OR RIGHT(sub.cleaned, 1) <> ':'
  );

UPDATE config_form_fields SET "datatype"='string', widgettype='combo', ismandatory=false, iseditable=false, dv_querytext='SELECT fluid_type as id, fluid_type as idval FROM man_type_fluid WHERE ((featurecat_id is null AND feature_type=''NODE'') ) AND active IS TRUE  OR ''WATER_CONNECTION'' = ANY(featurecat_id::text[])', dv_isnullvalue=true WHERE formname ILIKE '%ve_link%' AND formtype='form_feature' AND columnname='fluid_type' AND tabname='tab_data';

DELETE FROM config_form_fields WHERE formname ILIKE '%ve_link%' AND formtype='form_feature' AND columnname='n_hydrometer' AND tabname='tab_none';

-- 08/08/2025
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_vlink', 'form_feature', 'tab_data', 'linkcat_id', 'lyt_top_1', 2, 'string', 'typeahead', 'Linkcat ID:', 'linkcat_id - To be selected from the catalog of arcs. It is independent of the type of arch', NULL, true, false, true, false, NULL, 'SELECT id, id as idval FROM cat_link WHERE id IS NOT NULL AND active IS TRUE ', NULL, NULL, 'link_type', ' AND cat_link.link_type IS NULL OR cat_link.link_type', NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "cat_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 3)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_vlink', 'form_feature', 'tab_data', 'link_type', 'lyt_top_1', 1, 'string', 'combo', 'Link Type:', 'Type of link. It is auto-populated based on the linkcat_id', NULL, true, true, false, false, NULL, 'SELECT id, id as idval FROM cat_feature_link WHERE id IS NOT NULL', true, false, NULL, NULL, NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "ve_cat_feature_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 2)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_pipelink', 'form_feature', 'tab_data', 'linkcat_id', 'lyt_top_1', 2, 'string', 'typeahead', 'Linkcat ID:', 'linkcat_id - To be selected from the catalog of arcs. It is independent of the type of arch', NULL, true, false, true, false, NULL, 'SELECT id, id as idval FROM cat_link WHERE id IS NOT NULL AND active IS TRUE ', NULL, NULL, 'link_type', ' AND cat_link.link_type IS NULL OR cat_link.link_type', NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "cat_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 3)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_pipelink', 'form_feature', 'tab_data', 'link_type', 'lyt_top_1', 1, 'string', 'combo', 'Link Type:', 'Type of link. It is auto-populated based on the linkcat_id', NULL, true, true, false, false, NULL, 'SELECT id, id as idval FROM cat_feature_link WHERE id IS NOT NULL', true, false, NULL, NULL, NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "ve_cat_feature_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 2)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;

INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_link', 'form_feature', 'tab_data', 'linkcat_id', 'lyt_top_1', 2, 'string', 'typeahead', 'Linkcat ID:', 'linkcat_id - To be selected from the catalog of arcs. It is independent of the type of arch', NULL, true, false, true, false, NULL, 'SELECT id, id as idval FROM cat_link WHERE id IS NOT NULL AND active IS TRUE ', NULL, NULL, 'link_type', ' AND cat_link.link_type IS NULL OR cat_link.link_type', NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "cat_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 3)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;
INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder, "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
VALUES('ve_link_link', 'form_feature', 'tab_data', 'link_type', 'lyt_top_1', 1, 'string', 'combo', 'Link Type:', 'Type of link. It is auto-populated based on the linkcat_id', NULL, true, true, false, false, NULL, 'SELECT id, id as idval FROM cat_feature_link WHERE id IS NOT NULL', true, false, NULL, NULL, NULL, '{"setMultiline": false, "labelPosition": "top", "valueRelation": {"layer": "ve_cat_feature_link", "activated": true, "keyColumn": "id", "nullValue": false, "valueColumn": "id", "filterExpression": null}}'::json, NULL, NULL, false, 2)
ON CONFLICT (formname, formtype, tabname, columnname) DO NOTHING;

-- 08/08/2025
DELETE FROM config_form_fields WHERE formname ILIKE '%elem%' AND formtype='form_feature' AND columnname='element_id' AND tabname='tab_data';

-- 12/08/2025
DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN (SELECT child_layer FROM cat_feature WHERE feature_class = 'PUMP')
  LOOP
    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder,
    "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter,
    dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,
    stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
    VALUES(rec.child_layer, 'form_feature', 'tab_data', 'pump_type', 'lyt_data_2', (SELECT max(layoutorder) + 1 AS layoutorder FROM config_form_fields WHERE formname = rec.child_layer AND tabname = 'tab_data' AND layoutname = 'lyt_data_2'),
    'integer', 'combo', 'Pump Type:', 'Pump Type', NULL, false, false, true, false, NULL,
    'SELECT id, idval FROM edit_typevalue WHERE typevalue = ''man_pump_pump_type''', true, false, NULL, NULL,
    NULL, NULL, NULL, NULL, true, NULL)
    ON CONFLICT (formname, formtype, tabname, columnname) DO UPDATE SET
    layoutorder = EXCLUDED.layoutorder,
    datatype = EXCLUDED.datatype,
    widgettype = EXCLUDED.widgettype,
    label = EXCLUDED.label,
    dv_querytext = EXCLUDED.dv_querytext,
    dv_orderby_id = EXCLUDED.dv_orderby_id,
    dv_isnullvalue = EXCLUDED.dv_isnullvalue,
    dv_parent_id = EXCLUDED.dv_parent_id,
    dv_querytext_filterc = EXCLUDED.dv_querytext_filterc,
    hidden = EXCLUDED.hidden;


    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder,
    "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter,
    dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,
    stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
    VALUES(rec.child_layer, 'form_feature', 'tab_data', 'engine_type', 'lyt_data_2', (SELECT max(layoutorder) + 1 AS layoutorder FROM config_form_fields WHERE formname = rec.child_layer AND tabname = 'tab_data' AND layoutname = 'lyt_data_2'),
    'integer', 'combo', 'Engine Type:', 'Engine Type', NULL, false, false, true, false, NULL,
    'SELECT id, idval FROM edit_typevalue WHERE typevalue = ''man_pump_engine_type''', true, false, NULL, NULL,
    NULL, NULL, NULL, NULL, true, NULL)
    ON CONFLICT (formname, formtype, tabname, columnname) DO UPDATE SET
    layoutorder = EXCLUDED.layoutorder,
    datatype = EXCLUDED.datatype,
    widgettype = EXCLUDED.widgettype,
    label = EXCLUDED.label,
    dv_querytext = EXCLUDED.dv_querytext,
    dv_orderby_id = EXCLUDED.dv_orderby_id,
    dv_isnullvalue = EXCLUDED.dv_isnullvalue,
    dv_parent_id = EXCLUDED.dv_parent_id,
    dv_querytext_filterc = EXCLUDED.dv_querytext_filterc,
    hidden = EXCLUDED.hidden;
  END LOOP;
END $$;


DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN (SELECT child_layer FROM cat_feature WHERE feature_class = 'VALVE')
  LOOP
    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder,
    "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter,
    dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,
    stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
    VALUES(rec.child_layer, 'form_feature', 'tab_data', 'flowsetting', 'lyt_data_2', (SELECT max(layoutorder) + 1 AS layoutorder FROM config_form_fields WHERE formname = rec.child_layer AND tabname = 'tab_data' AND layoutname = 'lyt_data_2'),
    'numeric', 'text', 'Flow Setting:', 'Flow Setting:', NULL, false, false, true, false, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, true, NULL)
    ON CONFLICT (formname, formtype, tabname, columnname) DO UPDATE SET
    layoutorder = EXCLUDED.layoutorder,
    datatype = EXCLUDED.datatype,
    widgettype = EXCLUDED.widgettype,
    label = EXCLUDED.label,
    dv_querytext = EXCLUDED.dv_querytext,
    dv_orderby_id = EXCLUDED.dv_orderby_id,
    dv_isnullvalue = EXCLUDED.dv_isnullvalue,
    dv_parent_id = EXCLUDED.dv_parent_id,
    dv_querytext_filterc = EXCLUDED.dv_querytext_filterc,
    hidden = EXCLUDED.hidden;
  END LOOP;
END $$;

DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN (SELECT child_layer FROM cat_feature WHERE feature_class = 'METER')
  LOOP
    INSERT INTO config_form_fields (formname, formtype, tabname, columnname, layoutname, layoutorder,
    "datatype", widgettype, "label", tooltip, placeholder, ismandatory, isparent, iseditable, isautoupdate, isfilter,
    dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc,
    stylesheet, widgetcontrols, widgetfunction, linkedobject, hidden, web_layoutorder)
    VALUES(rec.child_layer, 'form_feature', 'tab_data', 'nominal_flowrate', 'lyt_data_2', (SELECT max(layoutorder) + 1 AS layoutorder FROM config_form_fields WHERE formname = rec.child_layer AND tabname = 'tab_data' AND layoutname = 'lyt_data_2'),
    'numeric', 'text', 'Nominal Flowrate:', 'Nominal Flowrate:', NULL, false, false, true, false, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, true, NULL)
    ON CONFLICT (formname, formtype, tabname, columnname) DO UPDATE SET
    layoutorder = EXCLUDED.layoutorder,
    datatype = EXCLUDED.datatype,
    widgettype = EXCLUDED.widgettype,
    label = EXCLUDED.label,
    dv_querytext = EXCLUDED.dv_querytext,
    dv_orderby_id = EXCLUDED.dv_orderby_id,
    dv_isnullvalue = EXCLUDED.dv_isnullvalue,
    dv_parent_id = EXCLUDED.dv_parent_id,
    dv_querytext_filterc = EXCLUDED.dv_querytext_filterc,
    hidden = EXCLUDED.hidden;
  END LOOP;
END $$;

DO $$
DECLARE
  rec record;
BEGIN
  FOR rec IN (SELECT child_layer FROM cat_feature WHERE feature_class = 'WTP')
  LOOP
    UPDATE config_form_fields SET columnname = 'chemical' WHERE formname = rec.child_layer AND columnname = 'chemcond';
    DELETE FROM config_form_fields WHERE formname = rec.child_layer AND columnname = 'chemtreatment';
  END LOOP;
END $$;
DELETE FROM config_form_fields WHERE formname ILIKE 've_element%' AND formtype='form_feature' AND columnname='tbl_element_x_gully' AND tabname='tab_features';


UPDATE config_form_fields SET dv_querytext =
'WITH psector_value AS (
  		SELECT value::integer AS psector_value 
  		FROM config_param_user 
  		WHERE parameter = ''plan_psector_current'' AND cur_user = current_user),
	 tg_op_value AS (
  		SELECT value::text AS tg_op_value 
  		FROM config_param_user 
  		WHERE parameter = ''utils_transaction_mode'' AND cur_user = current_user)  
SELECT id::integer as id, name as idval
FROM value_state 
WHERE id IS NOT NULL 
AND CASE 
  WHEN (SELECT tg_op_value FROM tg_op_value)!=''INSERT'' THEN id IN (0,1,2)
  WHEN (SELECT tg_op_value FROM tg_op_value) =''INSERT'' AND (SELECT psector_value FROM psector_value) IS NOT NULL THEN id = 2 
  ELSE id < 2 
END' 
WHERE columnname = 'state';

update config_form_fields set dv_orderby_id = true where formtype ='psector' and columnname ='status';