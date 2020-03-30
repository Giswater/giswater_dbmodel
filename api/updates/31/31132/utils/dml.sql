/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO config_api_cat_datatype VALUES ('nodatatype', NULL);
INSERT INTO config_api_cat_datatype VALUES ('string', NULL);
INSERT INTO config_api_cat_datatype VALUES ('double', NULL);
INSERT INTO config_api_cat_datatype VALUES ('date', NULL);
INSERT INTO config_api_cat_datatype VALUES ('boolean', NULL);
INSERT INTO config_api_cat_datatype VALUES ('integer', NULL);



INSERT INTO config_api_cat_formtemplate VALUES ('generic', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('custom_feature', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('config', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('go2epa', NULL);


INSERT INTO config_api_cat_widgettype VALUES ('label', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('hspacer', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('nowidget', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('checkbox', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('button', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('line', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('date', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('spinbox', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('areatext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('linetext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('combo', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('combotext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('hyperlink', NULL);


INSERT INTO config_api_form VALUES (10, 'visit', 'utils', NULL, '{"activeLayer":"v_edit_arc", "visibleLayer":["v_edit_arc", "v_edit_node", "v_edit_connec"]}');
INSERT INTO config_api_form VALUES (20, 'visitManager', 'utils', NULL, '{"visibleLayer":["v_om_visit_lot_arc", "v_om_visit_lot_node", "v_om_visit_lot_connec"]}');
INSERT INTO config_api_form VALUES (30, 'lot', 'utils', NULL, '{"visibleLayer":["v_om_visit_lot_arc", "v_om_visit_lot_node", "v_om_visit_lot_connec"]}');

INSERT INTO config_api_form_groupbox VALUES (12, 'go2epa', 1, 'Pre-process options');
INSERT INTO config_api_form_groupbox VALUES (13, 'go2epa', 2, 'File manager');
INSERT INTO config_api_form_groupbox VALUES (14, 'epaoptions', 1, 'Options');
INSERT INTO config_api_form_groupbox VALUES (15, 'epaoptions', 2, 'Times');
INSERT INTO config_api_form_groupbox VALUES (16, 'epaoptions', 3, 'Report');
INSERT INTO config_api_form_groupbox VALUES (1, 'config', 1, 'gb1');
INSERT INTO config_api_form_groupbox VALUES (11, 'config', 99, 'gb99');
INSERT INTO config_api_form_groupbox VALUES (2, 'config', 2, 'gb2');
INSERT INTO config_api_form_groupbox VALUES (3, 'config', 3, 'gb3');
INSERT INTO config_api_form_groupbox VALUES (4, 'config', 4, 'gb4');
INSERT INTO config_api_form_groupbox VALUES (5, 'config', 5, 'gb5');
INSERT INTO config_api_form_groupbox VALUES (6, 'config', 6, 'gb6');
INSERT INTO config_api_form_groupbox VALUES (7, 'config', 7, 'gb7');
INSERT INTO config_api_form_groupbox VALUES (8, 'config', 8, 'gb8');
INSERT INTO config_api_form_groupbox VALUES (9, 'config', 9, 'gb9');
INSERT INTO config_api_form_groupbox VALUES (10, 'config', 10, 'gb10');



INSERT INTO config_api_form_tabs VALUES (36, 'lot', 'tabData', 'Dades', 'Dades', 'role_om', 'Dades', '{"name":"gwGetLot", "parameters":{"form":{"tabData":{"active":true}}}}', NULL, 3);
INSERT INTO config_api_form_tabs VALUES (1, 'filters', 'tabExploitation', 'Explotacions', 'Explotacions actives', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (2, 'filters', 'tabNetworkState', 'Elements xarxa', 'Elements de xarxa', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (3, 'filters', 'tabHydroState', 'Abonats', 'Abonats', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (7, 'search', 'tab_network', 'Xarxa', 'Elements de xarxa', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (8, 'search_', 'tab_search', 'Cercador', 'Carrerer API web', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (9, 'search', 'tab_address', 'Carrerer', 'Carrerer dades PG', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (40, 'search', 'tab_hydro', 'Abonat', 'Abonat', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (41, 'search', 'tab_workcat', 'Expedient', 'Expedients', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (42, 'search', 'tab_psector', 'Psector', 'Sectors de planejament', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (204, 'v_edit_connec', 'tab_elements', 'Elem', 'Lista de elementos relacionados', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (408, 'v_edit_connec', 'tab_elements', 'Elem', 'Lista de elementos relacionados', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (409, 'v_edit_connec', 'tab_hydrometer', 'Abonados', 'Lista de abonados', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (411, 'v_edit_connec', 'tab_visit', 'Visit', 'Lista de eventos del elemento', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (412, 'v_edit_connec', 'tab_documents', 'Doc', 'Lista de documentos', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (500, 'config', 'tabUser', 'User', NULL, 'role_basic', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (560, 'config', 'tabAdmin', 'Admin', NULL, 'role_admin', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (43, 'search', 'tab_visit', 'Visita', 'Visita', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (566, 'v_edit_connec', 'tab_hydrometer_val', 'Consumos', 'Valores de consumo para abonado', NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (206, 'v_edit_connec', 'tab_connections', 'Conn', '{"Elementos aguas arriba","Elementos aguas abajo"}', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (34, 'visitManager', 'tabDone', 'Visites realitzades', 'Visites', 'role_om', 'Visites', '{"name":"gwGetVisitManager", "parameters":{"form":{"tabData":{"active":false}, "tabLots":{"active":false},"tabDone":{"active":true},"tabTeam":{"active":false}}}}', '[{"actionName":"actionDelete", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "actionTable":{"tableName":"om_visit","idName":"id"}, "disabled":false},{"actionName":"changeAction", "actionFunction":"gwGetVisit", "disabled":false}]', 3);
INSERT INTO config_api_form_tabs VALUES (32, 'visitManager', 'tabLots', 'Lots', 'Lots', 'role_om', 'Lots', '{"name":"gwGetVisitManager", "parameters":{"form":{"tabData":{"active":false}, "tabLots":{"active":true},"tabDone":{"active":false},"tabTeam":{"active":false}}}}', '[{"actionName":"actionDelete", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "actionTable":{"tableName":"om_visit_lot","idName":"id"}, "disabled":false},{"actionName":"changeAction", "actionFunction":"gwGetLot", "disabled":false}]', 3);
INSERT INTO config_api_form_tabs VALUES (30, 'visitManager', 'tabData', 'Dades generals', 'Dades', 'role_om', 'Dades', '{"name":"gwGetVisitManager", "parameters":{"form":{"tabData":{"active":true}, "tabLots":{"active":false},"tabDone":{"active":false},"tabTeam":{"active":false}}}}', '{}', 3);
INSERT INTO config_api_form_tabs VALUES (207, 'v_edit_connec', 'tab_visit', 'Visit', 'Lista de eventos del elemento', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (208, 'v_edit_connec', 'tab_documents', 'Doc', 'Lista de documentos', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (210, 'v_edit_connec', 'tab_plan', 'Cost', 'Partidas del elemento', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (302, 'v_edit_arc', 'tab_elements', 'Elem', 'Lista de elementos relacionados', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (303, 'v_edit_arc', 'tab_relations', 'Rel', 'Lista de relaciones', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (306, 'v_edit_arc', 'tab_om', 'OM', 'Lista de eventos del elemento', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (307, 'v_edit_arc', 'tab_documents', 'Doc', 'Lista de documentos', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (309, 'v_edit_arc', 'tab_plan', 'Cos', 'Partidas del elemento', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false},{"actionName":"actionSection", "actionFunction":"", "actionTooltip":"actionSection", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (311, 'v_edit_arc', 'tab_visit', 'Visit', 'Lista de eventos del elemento', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (561, 'v_edit_arc', 'tab_inp', 'EPA inp', NULL, 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (562, 'v_edit_arc', 'tab_rpt', 'EPA results', NULL, 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (563, 'v_edit_connec', 'tab_inp', 'EPA inp', NULL, 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (564, 'v_edit_connec', 'tab_rpt', 'EPA results', NULL, 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (567, 've_arc', 'tab_data', 'Data', 'Data', 'role_basic', 'Dades', NULL, '[{"actionName":"actionEdit", "actionTooltip":"actionEdit",  "disabled":false},{"actionName":"actionZoom", "actionTooltip":"actionZoom",  "disabled":false},{"actionName":"actionCentered", "actionTooltip":"actionCentered",  "disabled":false},{"actionName":"actionZoomOut", "actionTooltip":"actionZoomOut",  "disabled":false},{"actionName":"actionCatalog", "actionTooltip":"actionCatalog",  "disabled":false},{"actionName":"actionWorkcat", "actionTooltip":"actionWorkcat",  "disabled":false},{"actionName":"actionCopyPaste", "actionTooltip":"actionCopyPaste",  "disabled":false},{"actionName":"actionSection", "actionTooltip":"actionSection",  "disabled":false},{"actionName":"actionLink", "actionTooltip":"actionLink",  "disabled":false},{"actionName":"actionHelp", "actionTooltip":"actionHelp",  "disabled":false}]', 9);
INSERT INTO config_api_form_tabs VALUES (568, 've_node', 'tab_data', 'Data', 'Data', 'role_basic', 'Dades', NULL, '[{"actionName":"actionEdit", "actionTooltip":"actionEdit",  "disabled":false},{"actionName":"actionZoom", "actionTooltip":"actionZoom",  "disabled":false},{"actionName":"actionCentered", "actionTooltip":"actionCentered",  "disabled":false},{"actionName":"actionZoomOut", "actionTooltip":"actionZoomOut",  "disabled":false},{"actionName":"actionCatalog", "actionTooltip":"actionCatalog",  "disabled":false},{"actionName":"actionWorkcat", "actionTooltip":"actionWorkcat",  "disabled":false},{"actionName":"actionCopyPaste", "actionTooltip":"actionCopyPaste",  "disabled":false},{"actionName":"actionSection", "actionTooltip":"actionSection",  "disabled":false},{"actionName":"actionLink", "actionTooltip":"actionLink",  "disabled":false},{"actionName":"actionHelp", "actionTooltip":"actionHelp",  "disabled":false}]', 9);
INSERT INTO config_api_form_tabs VALUES (569, 've_connec', 'tab_data', 'Data', 'Data', 'role_basic', 'Dades', NULL, '[{"actionName":"actionEdit", "actionTooltip":"actionEdit",  "disabled":false},{"actionName":"actionZoom", "actionTooltip":"actionZoom",  "disabled":false},{"actionName":"actionCentered", "actionTooltip":"actionCentered",  "disabled":false},{"actionName":"actionZoomOut", "actionTooltip":"actionZoomOut",  "disabled":false},{"actionName":"actionCatalog", "actionTooltip":"actionCatalog",  "disabled":false},{"actionName":"actionWorkcat", "actionTooltip":"actionWorkcat",  "disabled":false},{"actionName":"actionCopyPaste", "actionTooltip":"actionCopyPaste",  "disabled":false},{"actionName":"actionSection", "actionTooltip":"actionSection",  "disabled":false},{"actionName":"actionLink", "actionTooltip":"actionLink",  "disabled":false},{"actionName":"actionHelp", "actionTooltip":"actionHelp",  "disabled":false}]', 9);
INSERT INTO config_api_form_tabs VALUES (600, 've_gully', 'tab_data', 'Data', 'Data', 'role_basic', 'data', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionCopyPaste", "actionFunction":"", "actionTooltip":"actionCopyPaste", "disabled":false},{"actionName":"actionCatalog", "actionFunction":"", "actionTooltip":"actionCatalog", "disabled":false},{"actionName":"actionWorkcat", "actionFunction":"", "actionTooltip":"actionWorkcat", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (610, 've_gully', 'tab_elements', 'Elem', 'Elements', 'role_basic', 'Elements', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (620, 've_gully', 'tab_visit', 'Visit', 'Visit', 'role_basic', 'visit', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (630, 've_gully', 'tab_documents', 'Doc', 'Doc', 'role_basic', 'doc', NULL, '[{"actionName":"actionEdit", "actionFunction":"", "actionTooltip":"actionEdit", "disabled":false},{"actionName":"actionZoomIn", "actionFunction":"", "actionTooltip":"actionZoomIn", "disabled":false},{"actionName":"actionZoomOut", "actionFunction":"", "actionTooltip":"actionZoomOut", "disabled":false},{"actionName":"actionCentered", "actionFunction":"", "actionTooltip":"actionCentered", "disabled":false},{"actionName":"actionLink", "actionFunction":"", "actionTooltip":"actionLink", "disabled":false}]', NULL);
INSERT INTO config_api_form_tabs VALUES (35, 'visitManager', 'tabTeam', 'Equips', 'Equips', 'role_om', 'Equips', '{"name":"gwGetVisitManager", "parameters":{"form":{"tabData":{"active":false}, "tabLots":{"active":false},"tabDone":{"active":false},"tabTeam":{"active":true}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add Photo", "disabled":false}]', 3);
INSERT INTO config_api_form_tabs VALUES (10, 'visit', 'tabData', 'Dades', 'Dades', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add Photo", "disabled":false}]', 1);
INSERT INTO config_api_form_tabs VALUES (12, 'visit', 'tabData', 'Dades', 'Dades', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add Photo", "disabled":false}]', 2);
INSERT INTO config_api_form_tabs VALUES (14, 'visit', 'tabData', 'Dades', 'Dades', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false}]', 3);
INSERT INTO config_api_form_tabs VALUES (20, 'visit', 'tabFiles', 'Fotos', 'Files', 'role_om', 'Files', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add Photo", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 1);
INSERT INTO config_api_form_tabs VALUES (16, 'visit', 'tabData', 'Fitxa de visita', 'Dades', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":true}, "tabFiles":{"active":false}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false}]', 9);
INSERT INTO config_api_form_tabs VALUES (22, 'visit', 'tabFiles', 'Fotos', 'Files', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add Photo", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 2);
INSERT INTO config_api_form_tabs VALUES (24, 'visit', 'tabFiles', 'Fotos', 'Files', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 3);
INSERT INTO config_api_form_tabs VALUES (26, 'visit', 'tabFiles', 'Fotos', 'Files', 'role_om', 'Dades', '{"name":"gwGetVisit", "parameters":{"form":{"tabData":{"active":false},"tabFiles":{"active":true, "feature":{"tableName":"om_visit_event_photo"}}}}}', '[{"actionName":"actionAddFile", "actionFunction":"gwSetFileInsert", "actionTooltip":"Add file", "disabled":false},{"actionName":"actionDeleteFile", "actionFunction":"gwSetDelete", "actionTooltip":"Delete file", "disabled":false}]', 9);


INSERT INTO config_api_layer VALUES ('v_edit_arc', true, 'vp_basic_arc', false, NULL, 'custom feature', 'Arc', 2, NULL, NULL, 'vp_epa_arc');
INSERT INTO config_api_layer VALUES ('v_edit_node', true, 'vp_basic_node', false, NULL, 'custom feature', 'Node', 1, NULL, NULL, 'vp_epa_node');
INSERT INTO config_api_layer VALUES ('v_edit_connec', true, 'vp_basic_connec', false, NULL, 'custom feature', 'Connec', 3, NULL, NULL, NULL);

INSERT INTO config_api_list VALUES (6, 'v_ui_element_x_arc', 'SELECT * FROM v_ui_element_x_arc WHERE id IS NOT NULL', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (4, 'v_ui_om_event', 'SELECT * FROM v_ui_om_event WHERE id IS NOT NULL', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (3, 'v_edit_connec', 'SELECT * FROM v_edit_connec WHERE connec_id IS NOT NULL', 3, '[{"actionName":"actionLink", "actionTooltip":"Open", "actionFunction":"openLink", "actionField":"link"}, {"actionName":"actionZoom", "actionTooltip":"Zoom to selection", "actionFunction":"zoomToSelection", "actionField":"the_geom"}]', 'attributeTable', 'list', NULL);
INSERT INTO config_api_list VALUES (2, 'v_edit_node', 'SELECT * FROM v_edit_node WHERE node_id IS NOT NULL', 3, '[{"actionName":"actionLink", "actionTooltip":"Open", "actionFunction":"openLink", "actionField":"link"}, {"actionName":"actionZoom", "actionTooltip":"Zoom to selection", "actionFunction":"zoomToSelection", "actionField":"the_geom"}]', 'attributeTable', 'list', NULL);
INSERT INTO config_api_list VALUES (1, 'v_edit_arc', 'SELECT * FROM v_edit_arc WHERE arc_id IS NOT NULL', 3, '[{"actionName":"actionLink", "actionTooltip":"Open", "actionFunction":"openLink", "actionField":"link"}, {"actionName":"actionZoom", "actionTooltip":"Zoom to selection", "actionFunction":"zoomToSelection", "actionField":"the_geom"}]', 'attributeTable', 'list', NULL);
INSERT INTO config_api_list VALUES (11, 'v_ui_om_visitman_x_connec', 'SELECT visit_id as sys_id, visit_id AS "Id" , visit_start as  "Iniciada", visit_end as "Tancada"  FROM v_ui_om_visitman_x_connec WHERE  visit_id IS NOT NULL', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (10, 'v_ui_om_visitman_x_node', 'SELECT visit_id as sys_id, visit_id AS "Id" , visit_start as  "Iniciada", visit_end as "Tancada" FROM v_ui_om_visitman_x_node WHERE visit_id IS NOT NULL', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (9, 'v_ui_om_visitman_x_arc', 'SELECT visit_id as sys_id, visit_id AS "Id" , visit_start as  "Iniciada", visit_end as "Tancada" FROM v_ui_om_visitman_x_arc WHERE visit_id IS NOT NULL', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (13, 'om_visit', 'SELECT o.id as sys_id, ''om_visit'' as sys_table_id,''id'' as sys_idname, o.id AS "Id visita" , date_trunc(''minute'',startdate) as  "Iniciada",  lot_id AS "Id lot", c.idval AS "Tipus",
CASE WHEN status=4 THEN ''Si'' ELSE ''NO'' END AS "Visita acabada"  FROM om_visit o 
JOIN om_visit_class c ON c.id = o.class_id
WHERE  user_name=current_user
', 3, NULL, 'tab', 'list', '{"orderBy":"1", "orderType": "DESC"}');
INSERT INTO config_api_list VALUES (16, 'om_vehicle_x_parameters', 'SELECT lot_id AS "Lot", ct.idval AS "Equip", cv.idval AS "Vehicle", load AS "Descàrrega", date_trunc(''minute'',tstamp) AS "Data" FROM om_vehicle_x_parameters vp
JOIN ext_cat_vehicle cv ON cv.id = vp.vehicle_id
JOIN cat_team ct ON ct.id=vp.team_id ', 3, NULL, 'tab', 'list', NULL);
INSERT INTO config_api_list VALUES (14, 'om_visit_event_photo', 'SELECT id, visit_id, tstamp, value as url, compass, filetype, fextension, text as idval FROM om_visit_event_photo WHERE id IS NOT NULL', 3, NULL, 'tab', 'iconList', NULL);
INSERT INTO config_api_list VALUES (8, 'om_visit_lot', 'SELECT DISTINCT ON (a.id) a.id AS sys_id, ''id'' as sys_idname, a.id AS "ID LOT", a.serie AS "OT", v.idval AS "TIPUS ACTUACIÓ", t.idval AS "TEAM", s.idval AS "ESTAT", a.descript as "Descripcio", startdate as "Data"  FROM om_visit_lot a
JOIN om_typevalue s ON s.id=a.status AND s.typevalue = ''lot_cat_status''
JOIN om_visit_class v ON v.id=a.visitclass_id
JOIN cat_team t ON t.id=a.team_id WHERE (status = 3 OR status = 4 OR status = 5)', 3, '[{"actionName":"getInfoFromId", "actionTooltip":"Open", "actionFunction":"gwGetInfoFromId", "actionField":"lot_id", "actionTable":{"tableName":"om_visit_lot", "idName":"id"}}]', 'tab', 'list', '{"orderBy":"1", "orderType": "DESC"}');


INSERT INTO config_api_message VALUES (10, 2, 'No class visit', NULL, 'alone');
INSERT INTO config_api_message VALUES (20, 0, 'sucessfully deleted', NULL, 'withfeature');
INSERT INTO config_api_message VALUES (30, 1, 'does not exists, impossible to delete it', NULL, 'withfeature');
INSERT INTO config_api_message VALUES (50, 0, 'sucessfully updated', NULL, 'withfeature');
INSERT INTO config_api_message VALUES (40, 0, 'sucessfully inserted', NULL, 'withfeature');
INSERT INTO config_api_message VALUES (60, 1, 'Visit class have been changed. Previous data have been deleted', NULL, 'alone');
INSERT INTO config_api_message VALUES (70, 0, 'Visit manager have been initialized', NULL, 'alone');
INSERT INTO config_api_message VALUES (80, 0, 'Visit manager have been finished', NULL, 'alone');
INSERT INTO config_api_message VALUES (90, 0, 'Lot succesfully saved', NULL, 'alone');
INSERT INTO config_api_message VALUES (100, 0, 'Lot succesfully deleted', NULL, 'alone');

INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_arc', 1);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_node', 5);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_gully', 6);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_gully', 7);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_node', 3);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_connec', 4);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_connec', 2);
INSERT INTO config_api_visit_x_featuretable VALUES ('v_edit_arc', 12);


INSERT INTO audit_cat_table VALUES ('config_api_form_fields', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_visit', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_visit_x_featuretable', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_cat_datatype', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_cat_formtemplate', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_cat_widgettype', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_form', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_form_groupbox', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_form_tabs', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_images', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_layer', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_message', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_tableinfo_x_infotype', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_layer_child', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
INSERT INTO audit_cat_table VALUES ('config_api_list', 'API', 'Config API', 'role_admin', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE);
