/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE OR REPLACE VIEW v_ui_om_visit_lot AS
 SELECT om_visit_lot.id,
    om_visit_lot.startdate,
    om_visit_lot.enddate,
    om_visit_lot.real_startdate,
    om_visit_lot.real_enddate,
    om_visit_class.idval as visit_class,
    om_visit_lot.descript,
    cat_team.idval as team,
    om_visit_lot.duration,
    om_typevalue.idval as status,
    om_visit_lot.class_id,
    om_visit_lot.exercice,
    om_visit_lot.serie,
    ext_workorder.wotype_id,
    ext_workorder.wotype_name,
    om_visit_lot.adreca,
    om_visit_lot.feature_type
   FROM om_visit_lot
     LEFT JOIN ext_workorder ON ext_workorder.serie::text = om_visit_lot.serie::text
     LEFT JOIN om_visit_class ON om_visit_class.id = om_visit_lot.visitclass_id
     LEFT JOIN cat_team ON cat_team.id = om_visit_lot.team_id
     LEFT JOIN om_typevalue ON om_typevalue.id = om_visit_lot.status AND om_typevalue.typevalue = 'lot_cat_status'::text;
	 
	 
 CREATE OR REPLACE VIEW v_res_lot_x_user AS 
 SELECT om_visit_lot_x_user.id,
    om_visit_lot_x_user.user_id,
    om_visit_lot_x_user.team_id,
    om_visit_lot_x_user.lot_id,
    om_visit_lot_x_user.starttime,
    om_visit_lot_x_user.endtime,
    (om_visit_lot_x_user.endtime - om_visit_lot_x_user.starttime)::text AS duration,
    om_visit_lot.the_geom
   FROM selector_date, om_visit_lot_x_user
    JOIN om_visit_lot ON om_visit_lot.id=om_visit_lot_x_user.lot_id
  WHERE "overlaps"(om_visit_lot_x_user.starttime, om_visit_lot_x_user.starttime, selector_date.from_date, selector_date.to_date) AND selector_date.cur_user = "current_user"()::text;
  
  
CREATE OR REPLACE VIEW v_om_team_x_vehicle AS 
 SELECT om_team_x_vehicle.id,
    cat_team.idval AS team,
    ext_cat_vehicle.idval AS vehicle
   FROM om_team_x_vehicle
     JOIN cat_team ON om_team_x_vehicle.team_id = cat_team.id
     JOIN ext_cat_vehicle ON om_team_x_vehicle.vehicle_id::text = ext_cat_vehicle.id::text;
	 
	 
CREATE OR REPLACE VIEW ve_lot_x_arc AS 
 SELECT arc.arc_id,
    om_visit_lot_x_arc.lot_id,
    om_visit_lot_x_arc.status,
    arc.the_geom
   FROM selector_lot,
    om_visit_lot
     JOIN om_visit_lot_x_arc ON om_visit_lot_x_arc.lot_id = om_visit_lot.id
     JOIN arc ON arc.arc_id::text = om_visit_lot_x_arc.arc_id::text
  WHERE selector_lot.lot_id = om_visit_lot.id AND selector_lot.cur_user = "current_user"()::text;
  
  
 CREATE OR REPLACE VIEW ve_lot_x_connec AS 
 SELECT connec.connec_id,
    om_visit_lot_x_connec.lot_id,
    om_visit_lot_x_connec.status,
    connec.the_geom
   FROM om_visit_lot
     JOIN om_visit_lot_x_connec ON om_visit_lot_x_connec.lot_id = om_visit_lot.id
     JOIN connec ON connec.connec_id::text = om_visit_lot_x_connec.connec_id::text;
	 

 CREATE OR REPLACE VIEW ve_lot_x_node AS 
 SELECT node.node_id,
    om_visit_lot_x_node.lot_id,
    om_visit_lot_x_node.status,
    node.the_geom
   FROM om_visit_lot
     JOIN om_visit_lot_x_node ON om_visit_lot_x_node.lot_id = om_visit_lot.id
     JOIN node ON node.node_id::text = om_visit_lot_x_node.node_id::text;


CREATE OR REPLACE VIEW v_edit_plan_psector AS 
 SELECT plan_psector.psector_id,
    plan_psector.name,
    plan_psector.descript,
    plan_psector.priority,
    plan_psector.text1,
    plan_psector.text2,
    plan_psector.observ,
    plan_psector.rotation,
    plan_psector.scale,
    plan_psector.sector_id,
    plan_psector.atlas_id,
    plan_psector.gexpenses,
    plan_psector.vat,
    plan_psector.other,
    plan_psector.the_geom,
    plan_psector.expl_id,
    plan_psector.psector_type,
    plan_psector.active,
    plan_psector.ext_code,
    plan_psector.status
   FROM selector_expl,
    plan_psector
  WHERE plan_psector.expl_id = selector_expl.expl_id AND selector_expl.cur_user = "current_user"()::text;


