/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2112


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_arc_fusion(node_id_arg character varying, workcat_id_end_aux character varying, enddate_aux date)


  RETURNS integer AS
$BODY$
DECLARE
    epa_type_aux varchar;
    arc_id_new varchar;
    arc_id_old varchar;
    rec_aux record;
    intersect_loc double precision;
    exists_id varchar;
    message_id integer;
    controlValue integer;
    newRecord SCHEMA_NAME.v_edit_arc;
    myRecord1 SCHEMA_NAME.v_edit_arc;
    myRecord2 SCHEMA_NAME.v_edit_arc;
    arc_geom geometry;
    arc_id_1 varchar;
    arc_id_2 varchar;
    pointArray1 geometry[];
    pointArray2 geometry[];
	rec_doc_arc record;
	rec_doc_node record;
	rec_visit_node record;
	rec_visit_arc record;
	project_type_aux text;
	array_agg varchar[];
	connec_id_aux varchar;
	gully_id_aux varchar;
    addfieldRecord1 record;
    addfieldRecord2 record;
    rec_param integer;
    v_vnode integer;
    v_node_geom public.geometry;

BEGIN

    -- Search path
    SET search_path = SCHEMA_NAME, public;

    SELECT wsoftware INTO project_type_aux FROM version LIMIT 1;

    -- Check if the node is exists
    SELECT node_id INTO exists_id FROM v_edit_node WHERE node_id = node_id_arg;
    SELECT the_geom INTO v_node_geom FROM node WHERE node_id = node_id_arg;
    

    -- Compute proceed
    IF FOUND THEN

        -- Find arcs sharing node
        SELECT COUNT(*) INTO controlValue FROM v_edit_arc WHERE node_1 = node_id_arg OR node_2 = node_id_arg;

        -- Accepted if there are just two distinc arcs
        IF controlValue = 2 THEN

            -- Get both arc features
            SELECT * INTO myRecord1 FROM v_edit_arc WHERE node_1 = node_id_arg OR node_2 = node_id_arg ORDER BY arc_id DESC LIMIT 1;
            SELECT * INTO myRecord2 FROM v_edit_arc WHERE node_1 = node_id_arg OR node_2 = node_id_arg ORDER BY arc_id ASC LIMIT 1;

            -- Compare arcs
            IF  myRecord1.arccat_id = myRecord2.arccat_id AND
                myRecord1.sector_id = myRecord2.sector_id AND
                myRecord1.expl_id = myRecord2.expl_id AND
                myRecord1.state = myRecord2.state
                THEN

                -- Final geometry
                IF myRecord1.node_1 = node_id_arg THEN
                    IF myRecord2.node_1 = node_id_arg THEN
                        pointArray1 := ARRAY(SELECT (ST_DumpPoints(ST_Reverse(myRecord1.the_geom))).geom);
                        pointArray2 := array_cat(pointArray1, ARRAY(SELECT (ST_DumpPoints(myRecord2.the_geom)).geom));
                    ELSE
                        pointArray1 := ARRAY(SELECT (ST_DumpPoints(myRecord2.the_geom)).geom);
                        pointArray2 := array_cat(pointArray1, ARRAY(SELECT (ST_DumpPoints(myRecord1.the_geom)).geom));
                    END IF;
                ELSE
                    IF myRecord2.node_1 = node_id_arg THEN
                        pointArray1 := ARRAY(SELECT (ST_DumpPoints(myRecord1.the_geom)).geom);
                        pointArray2 := array_cat(pointArray1, ARRAY(SELECT (ST_DumpPoints(myRecord2.the_geom)).geom));
                    ELSE
                        pointArray1 := ARRAY(SELECT (ST_DumpPoints(myRecord2.the_geom)).geom);
                        pointArray2 := array_cat(pointArray1, ARRAY(SELECT (ST_DumpPoints(ST_Reverse(myRecord1.the_geom))).geom));
                    END IF;
                END IF;

                arc_geom := ST_MakeLine(pointArray2);


                SELECT * INTO newRecord FROM v_edit_arc WHERE arc_id = myRecord1.arc_id;

                -- Create a new arc values
                newRecord.the_geom := arc_geom;
                newRecord.node_1 := (SELECT node_id FROM node WHERE state=1 AND ST_DWithin(ST_StartPoint(arc_geom), node.the_geom, 0.01) LIMIT 1);
                newRecord.node_2 := (SELECT node_id FROM node WHERE state=1 AND ST_DWithin(ST_EndPoint(arc_geom), node.the_geom, 0.01) LIMIT 1);
		newRecord.arc_id := (SELECT nextval('urn_id_seq'));

            --Compare addfields and assign them to new arc
            FOR rec_param IN SELECT DISTINCT parameter_id FROM man_addfields_value WHERE feature_id=myRecord1.arc_id
                OR feature_id=myRecord2.arc_id
            LOOP

            SELECT * INTO addfieldRecord1 FROM man_addfields_value WHERE feature_id=myRecord1.arc_id and parameter_id=rec_param;
            SELECT * INTO addfieldRecord2 FROM man_addfields_value WHERE feature_id=myRecord2.arc_id and parameter_id=rec_param;

                IF addfieldRecord1.value_param!=addfieldRecord2.value_param  THEN
                    RETURN audit_function(3008,2112);
                ELSIF addfieldRecord2.value_param IS NULL and addfieldRecord1.value_param IS NOT NULL THEN
                    UPDATE man_addfields_value SET feature_id=newRecord.arc_id WHERE feature_id=myRecord1.arc_id AND parameter_id=rec_param;
                ELSIF addfieldRecord1.value_param IS NULL and addfieldRecord2.value_param IS NOT NULL THEN
                    UPDATE man_addfields_value SET feature_id=newRecord.arc_id WHERE feature_id=myRecord2.arc_id AND parameter_id=rec_param;
                ELSE
                   UPDATE man_addfields_value SET feature_id=newRecord.arc_id WHERE feature_id=myRecord1.arc_id AND parameter_id=rec_param;
               END IF;

            END LOOP;
			-- temporary dissable the arc_searchnodes_control in order to use the node1 and node2 getted before
			-- to get values topocontrol arc needs to be before, but this is not possible
			UPDATE config SET arc_searchnodes_control='false';
			INSERT INTO v_edit_arc SELECT newRecord.*;
			UPDATE config SET arc_searchnodes_control='true';

			UPDATE arc SET node_1=newRecord.node_1, node_2=newRecord.node_2 where arc_id=newRecord.arc_id;
					
			--Insert data on audit_log_arc_traceability table
			INSERT INTO audit_log_arc_traceability ("type", arc_id, arc_id1, arc_id2, node_id, "tstamp", "user") 
			VALUES ('ARC FUSION', newRecord.arc_id, myRecord2.arc_id,myRecord1.arc_id,exists_id, CURRENT_TIMESTAMP, CURRENT_USER);
				
			-- Update complementary information from old arcs to new one
			UPDATE element_x_arc SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;
			UPDATE doc_x_arc SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;
			UPDATE om_visit_x_arc SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;
			UPDATE connec SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;
			UPDATE node SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;

			-- update links related to node
			IF  (SELECT link_id FROM link WHERE exit_type='NODE' and exit_id=node_id_arg LIMIT 1) IS NOT NULL THEN
			
				-- insert one vnode (indenpendently of the number of links. Only one vnode must replace the node)
				INSERT INTO vnode (vnode_id, vnode_type, state, sector_id, dma_id, expl_id, the_geom) 
				VALUES ((SELECT nextval('vnode_vnode_id_seq')), 'AUTO', newRecord.state, newRecord.sector_id, newRecord.dma_id, newRecord.expl_id, v_node_geom) RETURNING vnode_id INTO v_vnode;
				
				-- update link with new vnode
				UPDATE link SET exit_type='VNODE', exit_id=v_vnode WHERE exit_type='NODE' and exit_id=node_id_arg;	
			END IF;
	
			IF project_type_aux='UD' THEN
				UPDATE gully SET arc_id=newRecord.arc_id WHERE arc_id=myRecord1.arc_id OR arc_id=myRecord2.arc_id;
			END IF;

			-- Delete information of arc deleted
			DELETE FROM arc WHERE arc_id = myRecord1.arc_id;
			DELETE FROM arc WHERE arc_id = myRecord2.arc_id;

			-- create links that where related to deprecated node
		
			-- Moving to obsolete the previous node
			UPDATE node SET state=0, workcat_id_end=workcat_id_end_aux, enddate=enddate_aux WHERE node_id = node_id_arg;

            -- Arcs has different types
            ELSE
                --INSERT INTO temp_table (fprocesscat_id, text_column) VALUES (1, node_id_arg);
                RETURN audit_function(2004,2112);
            END IF;
         
        -- Node has not 2 arcs
        ELSE
            RETURN audit_function(2006,2112);
        END IF;

    -- Node not found
    ELSE 
        RETURN audit_function(2002,2112);
    END IF;

    RETURN audit_function(0,2112);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


