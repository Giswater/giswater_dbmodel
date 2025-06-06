/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
*/


SET search_path = am, public;
UPDATE config_engine_def AS t
SET label = v.label, descript = v.descript, placeholder = v.placeholder
FROM (
    VALUES
    ('rleak_1', 'WM', 'Roturas reales', NULL, NULL),
    ('strategic_1', 'WM', 'Estratégico', NULL, NULL),
    ('rleak_2', 'WM', 'Roturas reales', NULL, NULL),
    ('strategic_2', 'WM', 'Estratégico', NULL, NULL),
    ('mleak_1', 'WM', 'Probabilidad de falla', NULL, NULL),
    ('mleak_2', 'WM', 'Probabilidad de falla', NULL, NULL),
    ('compliance_1', 'WM', 'Normativo', NULL, NULL),
    ('longevity_1', 'WM', 'Longevidad', NULL, NULL),
    ('compliance_2', 'WM', 'Normativo', NULL, NULL),
    ('longevity_2', 'WM', 'Longevidad', NULL, NULL),
    ('strategic', 'SH', 'Peso de estratégico', 'Peso en matriz final por factores estratégicos', NULL),
    ('flow_1', 'WM', 'Caudal circulante', NULL, NULL),
    ('flow_2', 'WM', 'Caudal circulante', NULL, NULL),
    ('nrw_1', 'WM', 'ANC', NULL, NULL),
    ('nrw_2', 'WM', 'ANC', NULL, NULL),
    ('expected_year', 'SH', 'Peso de año esperado', 'Peso en matriz final por año de renovación', NULL),
    ('compliance', 'SH', 'Peso de normativo', 'Peso en matriz final por cumplimiento normativo', NULL),
    ('bratemain0', 'SH', 'Coeficiente de tasa de rotura', 'Tasa de crecimiento de fugas en tuberías', NULL),
    ('drate', 'SH', 'Tasa de descuento (%)', 'Tasa de actualización real de precios (discount rate). Tiene en cuenta el aumento de precios descontando la inflación.', NULL)
) AS v(parameter, method, label, descript, placeholder)
WHERE t.parameter = v.parameter AND t.method = v.method;

UPDATE value_result_type AS t
SET idval = v.idval
FROM (
    VALUES
    ('GLOBAL', 'GLOBAL'),
    ('SELECTION', 'SELECCIÓN')
) AS v(id, idval)
WHERE t.id = v.id;

UPDATE value_status AS t
SET idval = v.idval
FROM (
    VALUES
    ('FINISHED', 'ACABADO'),
    ('ON PLANNING', 'EN PLANIFICACIÓN'),
    ('CANCELED', 'CANCELADO')
) AS v(id, idval)
WHERE t.id = v.id;

