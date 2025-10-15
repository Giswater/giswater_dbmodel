/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
*/


SET search_path = cm, public, public;
UPDATE config_form_fields AS t
SET label = v.label, tooltip = v.tooltip
FROM (
    VALUES
    ('active', 'campaign_inventory', 'form_feature', 'tab_data', 'Activo:', 'Activo - active'),
    ('campaign_id', 'campaign_inventory', 'form_feature', 'tab_data', 'Campaña Id:', 'Id'),
    ('descript', 'campaign_inventory', 'form_feature', 'tab_data', 'Descripción:', 'Descripción - descript '),
    ('enddate', 'campaign_inventory', 'form_feature', 'tab_data', 'Fin planificado:', 'Final planificado'),
    ('expl_id', 'campaign_inventory', 'form_feature', 'tab_data', 'Expl Id:', 'Expl Id'),
    ('inventoryclass_id', 'campaign_inventory', 'form_feature', 'tab_data', 'Clase de inventario:', 'Clase de inventario'),
    ('name', 'campaign_inventory', 'form_feature', 'tab_data', 'Nombre:', 'Nombre'),
    ('organization_id', 'campaign_inventory', 'form_feature', 'tab_data', 'Organización:', 'Organización'),
    ('real_enddate', 'campaign_inventory', 'form_feature', 'tab_data', 'Real end:', 'Real end'),
    ('real_startdate', 'campaign_inventory', 'form_feature', 'tab_data', 'Comienzo real:', 'Inicio real'),
    ('sector_id', 'campaign_inventory', 'form_feature', 'tab_data', 'Sector Id:', 'Sector Id'),
    ('startdate', 'campaign_inventory', 'form_feature', 'tab_data', 'Inicio planificado:', 'Inicio planificado'),
    ('status', 'campaign_inventory', 'form_feature', 'tab_data', 'Estado:', 'Estado - status '),
    ('active', 'campaign_review', 'form_feature', 'tab_data', 'Activo:', 'Activo - active'),
    ('campaign_id', 'campaign_review', 'form_feature', 'tab_data', 'Campaña Id:', 'Id'),
    ('descript', 'campaign_review', 'form_feature', 'tab_data', 'Descripción:', 'Descripción - descript '),
    ('enddate', 'campaign_review', 'form_feature', 'tab_data', 'Fin planificado:', 'Final planificado'),
    ('expl_id', 'campaign_review', 'form_feature', 'tab_data', 'Expl Id:', 'Expl Id'),
    ('name', 'campaign_review', 'form_feature', 'tab_data', 'Nombre:', 'Nombre'),
    ('organization_id', 'campaign_review', 'form_feature', 'tab_data', 'Organización:', 'Organización'),
    ('real_enddate', 'campaign_review', 'form_feature', 'tab_data', 'Real end:', 'Real end'),
    ('real_startdate', 'campaign_review', 'form_feature', 'tab_data', 'Comienzo real:', 'Inicio real'),
    ('reviewclass_id', 'campaign_review', 'form_feature', 'tab_data', 'Clase de revisión:', 'Reviewclass'),
    ('sector_id', 'campaign_review', 'form_feature', 'tab_data', 'Sector Id:', 'Sector Id'),
    ('startdate', 'campaign_review', 'form_feature', 'tab_data', 'Inicio planificado:', 'Inicio planificado'),
    ('status', 'campaign_review', 'form_feature', 'tab_data', 'Estado:', 'Estado - status '),
    ('active', 'campaign_visit', 'form_feature', 'tab_data', 'Activo:', 'Activo - active'),
    ('campaign_id', 'campaign_visit', 'form_feature', 'tab_data', 'Lote Id:', 'Id'),
    ('descript', 'campaign_visit', 'form_feature', 'tab_data', 'Descripción:', 'Descripción - descript '),
    ('enddate', 'campaign_visit', 'form_feature', 'tab_data', 'Fin planificado:', 'Final planificado'),
    ('expl_id', 'campaign_visit', 'form_feature', 'tab_data', 'Expl Id:', 'Expl Id'),
    ('name', 'campaign_visit', 'form_feature', 'tab_data', 'Nombre:', 'Nombre'),
    ('organization_id', 'campaign_visit', 'form_feature', 'tab_data', 'Organización:', 'Organización'),
    ('real_enddate', 'campaign_visit', 'form_feature', 'tab_data', 'Real end:', 'Real end'),
    ('real_startdate', 'campaign_visit', 'form_feature', 'tab_data', 'Comienzo real:', 'Inicio real'),
    ('sector_id', 'campaign_visit', 'form_feature', 'tab_data', 'Sector Id:', 'Sector Id'),
    ('startdate', 'campaign_visit', 'form_feature', 'tab_data', 'Inicio planificado:', 'Inicio planificado'),
    ('status', 'campaign_visit', 'form_feature', 'tab_data', 'Estado:', 'Estado - status '),
    ('visitclass_id', 'campaign_visit', 'form_feature', 'tab_data', 'Visitclass:', 'Visitclass'),
    ('campaign', 'generic', 'check_project_cm', 'tab_data', 'Campaña:', 'Campaña'),
    ('lot', 'generic', 'check_project_cm', 'tab_data', 'Lote:', 'Lote'),
    ('txt_info', 'generic', 'check_project_cm', 'tab_data', NULL, NULL),
    ('txt_infolog', 'generic', 'check_project_cm', 'tab_log', NULL, NULL),
    ('active', 'generic', 'team_create', 'tab_none', 'Activo:', 'Active:'),
    ('code', 'generic', 'team_create', 'tab_none', 'Código:', 'Code:'),
    ('descript', 'generic', 'team_create', 'tab_none', 'Descripción:', 'Description:'),
    ('name', 'generic', 'team_create', 'tab_none', 'Nombre:', 'Name:'),
    ('active', 'lot', 'form_feature', 'tab_data', 'Activo:', 'Activo - active'),
    ('campaign_id', 'lot', 'form_feature', 'tab_data', 'Campaña id:', 'Id de campaña'),
    ('descript', 'lot', 'form_feature', 'tab_data', 'Descripción:', 'Descripción - descript '),
    ('enddate', 'lot', 'form_feature', 'tab_data', 'Fin planificado:', 'Final planificado'),
    ('expl_id', 'lot', 'form_feature', 'tab_data', 'Expl Id:', 'Expl Id'),
    ('lot_id', 'lot', 'form_feature', 'tab_data', 'Identificación del lote:', 'Id'),
    ('name', 'lot', 'form_feature', 'tab_data', 'Nombre:', 'Nombre'),
    ('organization_assigned', 'lot', 'form_feature', 'tab_data', 'Organización asignada:', 'Organización asignada'),
    ('real_enddate', 'lot', 'form_feature', 'tab_data', 'Real end:', 'Real end'),
    ('real_startdate', 'lot', 'form_feature', 'tab_data', 'Comienzo real:', 'Inicio real'),
    ('sector_id', 'lot', 'form_feature', 'tab_data', 'Sector Id:', 'Sector Id'),
    ('startdate', 'lot', 'form_feature', 'tab_data', 'Inicio planificado:', 'Inicio planificado'),
    ('status', 'lot', 'form_feature', 'tab_data', 'Estado:', 'Estado - status '),
    ('team_id', 'lot', 'form_feature', 'tab_data', 'Equipo:', 'Equipo'),
    ('workorder_id', 'lot', 'form_feature', 'tab_data', 'Id. de orden de trabajo:', 'Id de orden de trabajo'),
    ('address', 'workorder', 'form_feature', 'tab_data', 'Dirección:', 'Dirección'),
    ('cost', 'workorder', 'form_feature', 'tab_data', 'Coste:', 'Coste'),
    ('exercise', 'workorder', 'form_feature', 'tab_data', 'Ejercicio:', 'Ejercicio'),
    ('observ', 'workorder', 'form_feature', 'tab_data', 'Consultar:', 'Observar'),
    ('serie', 'workorder', 'form_feature', 'tab_data', 'Series:', 'Serie'),
    ('startdate', 'workorder', 'form_feature', 'tab_data', 'Fecha de inicio:', 'Fecha de inicio'),
    ('workorder_class', 'workorder', 'form_feature', 'tab_data', 'Clase de orden de trabajo:', 'Clase de orden de trabajo'),
    ('workorder_id', 'workorder', 'form_feature', 'tab_data', 'Id. de orden de trabajo:', 'Id de orden de trabajo'),
    ('workorder_name', 'workorder', 'form_feature', 'tab_data', 'Nombre de la orden de trabajo:', 'Nombre de la orden de trabajo'),
    ('workorder_type', 'workorder', 'form_feature', 'tab_data', 'Tipo de orden de trabajo:', 'Tipo de orden de trabajo')
) AS v(columnname, formname, formtype, tabname, label, tooltip)
WHERE t.columnname = v.columnname AND t.formname = v.formname AND t.formtype = v.formtype AND t.tabname = v.tabname;

UPDATE config_form_tabs AS t
SET label = v.label, tooltip = v.tooltip
FROM (
    VALUES
    ('selector_campaign', 'tab_campaign', 'Campaña', 'Campaña'),
    ('selector_campaign', 'tab_lot', 'Lote', 'Lote')
) AS v(formname, tabname, label, tooltip)
WHERE t.formname = v.formname AND t.tabname = v.tabname;

UPDATE config_param_system AS t
SET label = v.label, descript = v.descript
FROM (
    VALUES
    ('admin_campaign_type', NULL, 'Variable para especificar el tipo de campaña que queremos ver al crearla'),
    ('basic_selector_tab_campaign', 'Selector variables', 'Variable para configurar todas las opciones relacionadas con la búsqueda de la ficha especifica'),
    ('basic_selector_tab_lot', 'Selector variables', 'Variable para configurar todas las opciones relacionadas con la búsqueda de la ficha especifica')
) AS v(parameter, label, descript)
WHERE t.parameter = v.parameter;

UPDATE sys_typevalue AS t
SET idval = v.idval, descript = v.descript
FROM (
    VALUES
    ('1', 'campaign_feature_status', 'PLANIFICADO', NULL),
    ('2', 'campaign_feature_status', 'NO VISITADO', NULL),
    ('3', 'campaign_feature_status', 'VISITADO', NULL),
    ('4', 'campaign_feature_status', 'VUELVE A VISITAR', NULL),
    ('5', 'campaign_feature_status', 'ACEPTADO', NULL),
    ('6', 'campaign_feature_status', 'CANCELADO', NULL),
    ('1', 'campaign_status', 'PLANIFICACIÓN', NULL),
    ('10', 'campaign_status', 'CANCELADO', NULL),
    ('2', 'campaign_status', 'PLANIFICADO', NULL),
    ('3', 'campaign_status', 'ASIGNADO', NULL),
    ('4', 'campaign_status', 'EN MARCHA', NULL),
    ('5', 'campaign_status', 'STAND-BY', NULL),
    ('6', 'campaign_status', 'EJECUTADO (Fijar OPERATIVO y Guardar Traza)', NULL),
    ('7', 'campaign_status', 'RECHAZADO', NULL),
    ('8', 'campaign_status', 'LISTO PARA ACEPTAR', NULL),
    ('9', 'campaign_status', 'ACEPTADO', NULL),
    ('1', 'campaign_type', 'REVISIÓN', NULL),
    ('2', 'campaign_type', 'VISTA', NULL),
    ('3', 'campaign_type', 'INVENTARIO', NULL),
    ('lyt_buttons', 'layout_name_typevalue', 'lyt_buttons', NULL),
    ('1', 'lot_feature_status', 'PLANIFICADO', NULL),
    ('2', 'lot_feature_status', 'NO VISITADO', NULL),
    ('3', 'lot_feature_status', 'VISITADO', NULL),
    ('4', 'lot_feature_status', 'VUELVE A VISITAR', NULL),
    ('5', 'lot_feature_status', 'ACEPTADO', NULL),
    ('6', 'lot_feature_status', 'CANCELADO', NULL),
    ('1', 'lot_status', 'PLANIFICACIÓN', NULL),
    ('10', 'lot_status', 'CANCELADO', NULL),
    ('2', 'lot_status', 'PLANIFICADO', NULL),
    ('3', 'lot_status', 'ASIGNADO', NULL),
    ('4', 'lot_status', 'EN MARCHA', NULL),
    ('5', 'lot_status', 'STAND-BY', NULL),
    ('6', 'lot_status', 'EJECUTADO (Fijar OPERATIVO y Guardar Traza)', NULL),
    ('7', 'lot_status', 'RECHAZADO', NULL),
    ('8', 'lot_status', 'LISTO PARA ACEPTAR', NULL),
    ('9', 'lot_status', 'ACEPTADO', NULL)
) AS v(id, typevalue, idval, descript)
WHERE t.id = v.id AND t.typevalue = v.typevalue;

UPDATE config_form_fields AS t
SET widgetcontrols = v.text::json
FROM (
	VALUES
	('active', 'campaign_inventory', 'form_feature', 'tab_data', '{"vdefault_value": "Verdadero"}'),
    ('active', 'campaign_review', 'form_feature', 'tab_data', '{"vdefault_value": "Verdadero"}'),
    ('active', 'campaign_visit', 'form_feature', 'tab_data', '{"vdefault_value": "Verdadero"}'),
    ('txt_info', 'generic', 'check_project_cm', 'tab_data', '{"vdefault_value": "Esta función tiene por objetivo pasar el control de calidad de una campaña, pudiendo escoger de forma concreta un lote especifico.<br><br>Se analizan diferentes aspectos siendo lo más destacado que se configura para que los datos esten operativos en el conjunto de una campaña para que el modelo hidraulico funcione."}'),
    ('active', 'lot', 'form_feature', 'tab_data', '{"vdefault_value": "Verdadero"}')
) AS v(columnname, formname, formtype, tabname, text)
WHERE t.columnname = v.columnname AND t.formname = v.formname AND t.formtype = v.formtype AND t.tabname = v.tabname;

UPDATE config_param_system SET value = TRUE WHERE parameter = 'admin_config_control_trigger';
UPDATE sys_table AS t
SET alias = v.alias, descript = v.descript
FROM (
    VALUES
    ('%_camp_arc', NULL, 've_ws44_1709_camp_arc'),
    ('%_camp_connec', NULL, 've_ws44_1709_camp_connec'),
    ('%_camp_link', NULL, 've_ws44_1709_camp_link'),
    ('%_camp_node', NULL, 've_ws44_1709_camp_node'),
    ('%_lot_arc', NULL, 've_ws44_1709_lot_arc'),
    ('%_lot_connec', NULL, 've_ws44_1709_lot_connec'),
    ('%_lot_link', NULL, 've_ws44_1709_lot_link'),
    ('%_lot_node', NULL, 've_ws44_1709_lot_node')
) AS v(id, alias, descript)
WHERE t.id = v.id;

UPDATE config_form_tableview AS t
SET alias = v.alias
FROM (
    VALUES
    ('om_campaign_lot_x_arc', 'action', 'Acción'),
    ('om_campaign_lot_x_connec', 'action', 'Acción'),
    ('om_campaign_lot_x_link', 'action', 'Acción'),
    ('om_campaign_lot_x_node', 'action', 'Acción'),
    ('v_ui_campaign', 'active', 'Activo'),
    ('v_ui_lot', 'active', 'Activo'),
    ('cat_organization', 'active', 'Activo'),
    ('cat_team', 'active', 'Activo'),
    ('cat_user', 'active', 'Activo'),
    ('om_campaign_x_arc', 'admin_observ', 'Admin observar'),
    ('om_campaign_x_connec', 'admin_observ', 'Admin observar'),
    ('om_campaign_x_link', 'admin_observ', 'Admin observar'),
    ('om_campaign_x_node', 'admin_observ', 'Admin observar'),
    ('om_campaign_x_arc', 'arccat_id', 'Arccat id'),
    ('om_campaign_x_arc', 'arc_id', 'Arco id'),
    ('om_campaign_lot_x_arc', 'arc_id', 'Arco id'),
    ('om_campaign_x_arc', 'arc_type', 'Tipo de arco'),
    ('v_ui_campaign', 'campaign_class', 'Clase de campaña'),
    ('v_ui_campaign', 'campaign_id', 'Id de campaña'),
    ('om_campaign_x_arc', 'campaign_id', 'Id de campaña'),
    ('om_campaign_x_connec', 'campaign_id', 'Id de campaña'),
    ('om_campaign_x_link', 'campaign_id', 'Id de campaña'),
    ('om_campaign_x_node', 'campaign_id', 'Id de campaña'),
    ('v_ui_lot', 'campaign_name', 'Nombre de la campaña'),
    ('v_ui_campaign', 'campaign_type', 'Tipo de campaña'),
    ('om_campaign_x_arc', 'code', 'Código'),
    ('om_campaign_x_connec', 'code', 'Código'),
    ('om_campaign_x_link', 'code', 'Código'),
    ('om_campaign_x_node', 'code', 'Código'),
    ('om_campaign_lot_x_arc', 'code', 'Código'),
    ('om_campaign_lot_x_connec', 'code', 'Código'),
    ('om_campaign_lot_x_link', 'code', 'Código'),
    ('om_campaign_lot_x_node', 'code', 'Código'),
    ('cat_organization', 'code', 'Código'),
    ('cat_team', 'code', 'Código'),
    ('cat_user', 'code', 'Código'),
    ('om_campaign_x_connec', 'connec_id', 'Conexión'),
    ('om_campaign_lot_x_connec', 'connec_id', 'Conexión'),
    ('om_campaign_x_connec', 'connectcat_id', 'ID de Connectcat'),
    ('v_ui_campaign', 'descript', 'Describa'),
    ('v_ui_lot', 'descript', 'Describa'),
    ('cat_organization', 'descript', 'Describa'),
    ('cat_team', 'descript', 'Describa'),
    ('v_ui_campaign', 'enddate', 'Fecha final'),
    ('v_ui_lot', 'enddate', 'Fecha final'),
    ('v_ui_lot', 'expl_id', 'Expl id'),
    ('om_campaign_x_arc', 'id', 'Id'),
    ('om_campaign_x_connec', 'id', 'Id'),
    ('om_campaign_x_link', 'id', 'Id'),
    ('om_campaign_x_node', 'id', 'Id'),
    ('om_campaign_lot_x_arc', 'id', 'Id'),
    ('om_campaign_lot_x_connec', 'id', 'Id'),
    ('om_campaign_lot_x_link', 'id', 'Id'),
    ('om_campaign_lot_x_node', 'id', 'Id'),
    ('om_campaign_x_link', 'linkcat_id', 'Id. de Linkcat'),
    ('om_campaign_x_link', 'link_id', 'Enlace id'),
    ('om_campaign_lot_x_link', 'link_id', 'Enlace id'),
    ('v_ui_lot', 'lot_id', 'Identificación del lote'),
    ('om_campaign_lot_x_arc', 'lot_id', 'Identificación del lote'),
    ('om_campaign_lot_x_connec', 'lot_id', 'Identificación del lote'),
    ('om_campaign_lot_x_link', 'lot_id', 'Identificación del lote'),
    ('om_campaign_lot_x_node', 'lot_id', 'Identificación del lote'),
    ('v_ui_campaign', 'name', 'Nombre'),
    ('v_ui_lot', 'name', 'Nombre'),
    ('om_campaign_x_arc', 'node_1', 'Nodo 1'),
    ('om_campaign_lot_x_arc', 'node_1', 'Nodo 1'),
    ('om_campaign_x_arc', 'node_2', 'Nodo 2'),
    ('om_campaign_lot_x_arc', 'node_2', 'Nodo 2'),
    ('om_campaign_x_node', 'nodecat_id', 'Nodecat id'),
    ('om_campaign_x_node', 'node_id', 'Id de nodo'),
    ('om_campaign_lot_x_node', 'node_id', 'Id de nodo'),
    ('om_campaign_x_node', 'node_type', 'Tipo de nodo'),
    ('v_ui_campaign', 'organization_id', 'Organización'),
    ('cat_organization', 'organization_id', 'Organización'),
    ('cat_organization', 'orgname', 'Nombre org.'),
    ('cat_team', 'orgname', 'Nombre org.'),
    ('om_campaign_x_arc', 'org_observ', 'Org observar'),
    ('om_campaign_x_connec', 'org_observ', 'Org observar'),
    ('om_campaign_x_link', 'org_observ', 'Org observar'),
    ('om_campaign_x_node', 'org_observ', 'Org observar'),
    ('om_campaign_lot_x_arc', 'org_observ', 'Org observar'),
    ('om_campaign_lot_x_connec', 'org_observ', 'Org observar'),
    ('om_campaign_lot_x_link', 'org_observ', 'Org observar'),
    ('om_campaign_lot_x_node', 'org_observ', 'Org observar'),
    ('om_campaign_x_arc', 'qindex1', 'Qindex1'),
    ('om_campaign_x_connec', 'qindex1', 'Qindex1'),
    ('om_campaign_x_link', 'qindex1', 'Qindex1'),
    ('om_campaign_x_node', 'qindex1', 'Qindex1'),
    ('om_campaign_lot_x_arc', 'qindex1', 'Qindex1'),
    ('om_campaign_lot_x_connec', 'qindex1', 'Qindex1'),
    ('om_campaign_lot_x_link', 'qindex1', 'Qindex1'),
    ('om_campaign_lot_x_node', 'qindex1', 'Qindex1'),
    ('om_campaign_x_arc', 'qindex2', 'Qindex2'),
    ('om_campaign_x_connec', 'qindex2', 'Qindex2'),
    ('om_campaign_x_link', 'qindex2', 'Qindex2'),
    ('om_campaign_x_node', 'qindex2', 'Qindex2'),
    ('om_campaign_lot_x_arc', 'qindex2', 'Qindex2'),
    ('om_campaign_lot_x_connec', 'qindex2', 'Qindex2'),
    ('om_campaign_lot_x_link', 'qindex2', 'Qindex2'),
    ('om_campaign_lot_x_node', 'qindex2', 'Qindex2'),
    ('v_ui_campaign', 'real_enddate', 'Fecha final real'),
    ('v_ui_lot', 'real_enddate', 'Fecha final real'),
    ('v_ui_campaign', 'real_startdate', 'Fecha de inicio real'),
    ('v_ui_lot', 'real_startdate', 'Fecha de inicio real'),
    ('cat_team', 'role_id', 'Id de rol'),
    ('v_ui_lot', 'sector_id', 'Identificación del sector'),
    ('v_ui_campaign', 'startdate', 'Fecha de inicio'),
    ('v_ui_lot', 'startdate', 'Fecha de inicio'),
    ('v_ui_campaign', 'status', 'Estado'),
    ('om_campaign_x_arc', 'status', 'Estado'),
    ('om_campaign_x_connec', 'status', 'Estado'),
    ('om_campaign_x_link', 'status', 'Estado'),
    ('om_campaign_x_node', 'status', 'Estado'),
    ('v_ui_lot', 'status', 'Estado'),
    ('om_campaign_lot_x_arc', 'status', 'Estado'),
    ('om_campaign_lot_x_connec', 'status', 'Estado'),
    ('om_campaign_lot_x_link', 'status', 'Estado'),
    ('om_campaign_lot_x_node', 'status', 'Estado'),
    ('cat_team', 'team_id', 'Identificación del equipo'),
    ('v_ui_lot', 'team_name', 'Nombre del equipo'),
    ('cat_team', 'teamname', 'Nombre del equipo'),
    ('cat_user', 'teamname', 'Nombre del equipo'),
    ('om_campaign_lot_x_arc', 'team_observ', 'Observación del equipo'),
    ('om_campaign_lot_x_connec', 'team_observ', 'Observación del equipo'),
    ('om_campaign_lot_x_link', 'team_observ', 'Observación del equipo'),
    ('om_campaign_lot_x_node', 'team_observ', 'Observación del equipo'),
    ('v_ui_campaign', 'the_geom', 'El geom'),
    ('om_campaign_x_arc', 'the_geom', 'El geom'),
    ('om_campaign_x_connec', 'the_geom', 'El geom'),
    ('om_campaign_x_link', 'the_geom', 'El geom'),
    ('om_campaign_x_node', 'the_geom', 'El geom'),
    ('v_ui_lot', 'the_geom', 'El geom'),
    ('om_campaign_lot_x_arc', 'update_count', 'Actualizar recuento'),
    ('om_campaign_lot_x_connec', 'update_count', 'Actualizar recuento'),
    ('om_campaign_lot_x_link', 'update_count', 'Actualizar recuento'),
    ('om_campaign_lot_x_node', 'update_count', 'Actualizar recuento'),
    ('om_campaign_lot_x_arc', 'update_log', 'Registro de actualización'),
    ('om_campaign_lot_x_connec', 'update_log', 'Registro de actualización'),
    ('om_campaign_lot_x_link', 'update_log', 'Registro de actualización'),
    ('om_campaign_lot_x_node', 'update_log', 'Registro de actualización'),
    ('cat_user', 'user_id', 'Id de usuario'),
    ('cat_user', 'username', 'Nombre de usuario'),
    ('v_ui_lot', 'workorder_name', 'Nombre de la orden de trabajo')
) AS v(objectname, columnname, alias)
WHERE t.objectname = v.objectname AND t.columnname = v.columnname;

UPDATE sys_fprocess AS t
SET except_msg = v.except_msg, info_msg = v.info_msg, fprocess_name = v.fprocess_name
FROM (
    VALUES
    (100, 'valor nulo en la columna %check_column% de %table_name%.', 'Las %check_column% en %table_name% tienen valores correctos.', 'Comprobar la coherencia de los nulos'),
    (200, 'Hay algunos usuarios sin equipo asignado.', 'Todos los usuarios tienen un equipo asignado.', 'Comprobar la coherencia de los usuarios'),
    (201, 'equipos sin usuarios asignados.', 'Todos los equipos tienen usuarios asignados.', 'Comprobar la coherencia de los equipos'),
    (202, 'Hay algunos nodos huérfanos', 'No hay nodos huérfanos.', 'Comprobar nodos huérfanos'),
    (203, 'nodos duplicados con el estado 1.', 'No existen nodos duplicados con el estado 1.', 'Comprobar nodos duplicados')
) AS v(fid, except_msg, info_msg, fprocess_name)
WHERE t.fid = v.fid;

