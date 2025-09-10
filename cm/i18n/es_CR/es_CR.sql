/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
*/


SET search_path = cm, public, public;
UPDATE config_form_tabs AS t
SET label = v.label, tooltip = v.tooltip
FROM (
    VALUES
    ('selector_campaign', 'tab_campaign', 'Campaña', 'Campaña'),
    ('selector_campaign', 'tab_lot', 'Lote', 'Lote')
) AS v(formname, tabname, label, tooltip)
WHERE t.formname = v.formname AND t.tabname = v.tabname;

