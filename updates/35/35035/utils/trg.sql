/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE TRIGGER gw_trg_link_data AFTER INSERT 
ON link FOR EACH ROW EXECUTE FUNCTION gw_trg_link_data('link'); 

CREATE TRIGGER gw_trg_link_data AFTER INSERT OR UPDATE OF  expl_id2
ON connec FOR EACH ROW EXECUTE FUNCTION gw_trg_link_data('connec');

DROP TRIGGER IF EXISTS gw_trg_edit_review_node ON v_edit_review_node;
DROP TRIGGER IF EXISTS gw_trg_edit_review_arc ON v_edit_review_arc;
DROP TRIGGER IF EXISTS gw_trg_edit_review_connec ON v_edit_review_connec;

CREATE TRIGGER gw_trg_edit_review_node INSTEAD OF INSERT OR UPDATE OR DELETE ON v_edit_review_node FOR EACH ROW EXECUTE FUNCTION gw_trg_edit_review_node();
CREATE TRIGGER gw_trg_edit_review_arc INSTEAD OF INSERT OR UPDATE OR DELETE ON v_edit_review_arc FOR EACH ROW EXECUTE FUNCTION gw_trg_edit_review_arc();
CREATE TRIGGER gw_trg_edit_review_connec INSTEAD OF INSERT OR UPDATE OR DELETE ON v_edit_review_connec FOR EACH ROW EXECUTE FUNCTION gw_trg_edit_review_connec();