/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

CREATE OR REPLACE VIEW v_anl_mincut_result_cat AS
SELECT 
anl_mincut_result_cat.id,
work_order,
anl_mincut_cat_state.name as state,
anl_mincut_cat_class.name as class,
mincut_type,
received_date,
anl_mincut_result_cat.expl_id,
exploitation.name AS expl_name,
macroexploitation.name AS macroexpl_name,
anl_mincut_result_cat.macroexpl_id,
anl_mincut_result_cat.muni_id,
ext_municipality.name AS muni_name,
postcode,
streetaxis_id,
ext_streetaxis.name AS street_name,
postnumber,
anl_cause,
anl_tstamp ,
anl_user,
anl_descript,
anl_feature_id,
anl_feature_type,
anl_the_geom,
forecast_start,
forecast_end,
assigned_to,
exec_start,
exec_end,
exec_user,
exec_descript,
exec_the_geom,
exec_from_plot,
exec_depth,
exec_appropiate,
notified
FROM anl_mincut_result_selector, anl_mincut_result_cat
LEFT JOIN anl_mincut_cat_class ON anl_mincut_cat_class.id = mincut_class
LEFT JOIN anl_mincut_cat_state ON anl_mincut_cat_state.id = mincut_state
LEFT JOIN exploitation ON anl_mincut_result_cat.expl_id = exploitation.expl_id
LEFT JOIN ext_streetaxis ON anl_mincut_result_cat.streetaxis_id::text = ext_streetaxis.id::text
LEFT JOIN macroexploitation ON anl_mincut_result_cat.macroexpl_id = macroexploitation.macroexpl_id
LEFT JOIN ext_municipality ON anl_mincut_result_cat.muni_id = ext_municipality.muni_id
	WHERE anl_mincut_result_selector.result_id = anl_mincut_result_cat.id AND anl_mincut_result_selector.cur_user = "current_user"()::text;
    

    
CREATE OR REPLACE VIEW v_ui_anl_mincut_result_cat AS
SELECT
anl_mincut_result_cat.id,
anl_mincut_result_cat.id as name,
work_order,
anl_mincut_cat_state.name as state,
anl_mincut_cat_class.name as class,
mincut_type,
received_date,
expl_id,
macroexpl_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
anl_cause,
anl_tstamp ,
anl_user,
anl_descript,
anl_feature_id,
anl_feature_type,
anl_the_geom,
forecast_start,
forecast_end,
assigned_to,
exec_start,
exec_end,
exec_user,
exec_descript,
exec_the_geom,
exec_from_plot,
exec_depth,
exec_appropiate,
notified
FROM anl_mincut_result_cat
LEFT JOIN anl_mincut_cat_class ON anl_mincut_cat_class.id = mincut_class
LEFT JOIN anl_mincut_cat_state ON anl_mincut_cat_state.id = mincut_state;