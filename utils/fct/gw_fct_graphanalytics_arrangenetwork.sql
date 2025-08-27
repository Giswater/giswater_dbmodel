/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/

-- FUNCTION CODE: 3326

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_graphanalytics_arrangenetwork();
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_graphanalytics_arrangenetwork(p_data json)
RETURNS json AS
$BODY$

/* Example:
SELECT gw_fct_graphanalytics_arrangenetwork('{"data":{"mapzone_name":"MINSECTOR"}}');
It is an auxiliary process used by macro_minsector, minsector, or mapzone that generates additional arcs.
*/

DECLARE

    -- configuration
	v_version TEXT;
    v_project_type TEXT;
    v_from_zero boolean;

    -- parameters
    v_mapzone_name TEXT;
    -- extra variables
    v_graph_delimiter TEXT;
    v_record RECORD;
    v_pgr_node_id INTEGER;
    v_cost integer=0; -- for the new arcs the cost/reverse_cost is 0 and not 1 so the inundation will be seen correct
    v_reverse_cost integer=0;
    v_query_text TEXT;
    v_pgr_root_vids INT[];
    v_pgr_distance INTEGER = 1000000;
    v_source TEXT;
    v_target TEXT;

BEGIN

	-- Search path
    SET search_path = "SCHEMA_NAME", public;

    -- Select configuration values
    SELECT giswater, UPPER(project_type) INTO v_version, v_project_type FROM sys_version ORDER BY id DESC LIMIT 1;

	-- Get variables from input JSON
    v_mapzone_name = (SELECT (p_data::json->>'data')::json->>'mapzone_name');
    v_from_zero = p_data->'data'->>'from_zero';

    IF v_mapzone_name IS NULL OR v_mapzone_name = '' THEN
        RETURN jsonb_build_object(
            'status', 'Failed',
            'message', jsonb_build_object(
                'level', 3,
                'text', 'v_mapzone_name is null or empty'
            ),
            'version', v_version,
            'body', jsonb_build_object(
                'form', jsonb_build_object(),
                'data', jsonb_build_object()
            )
        );
    END IF;

    IF v_mapzone_name IN ('MINSECTOR', 'MINCUT') THEN
        v_graph_delimiter := 'SECTOR';
    ELSE
        v_graph_delimiter := v_mapzone_name;
    END IF;

    IF v_project_type = 'UD' THEN
        v_reverse_cost = -1;
    ELSE
        -- ARCS TO MODIFY - Depending on the nodes with modif = TRUE
        -- ARCS VALVES
    	-- for the valves with to_arc NULL, one of the arcs that connect to the valve is modif = TRUE
        WITH arcs_selected AS (
            SELECT DISTINCT ON (n.pgr_node_id)
                a.pgr_arc_id,
                n.pgr_node_id,
                a.pgr_node_1,
                a.pgr_node_2
            FROM temp_pgr_node n
            JOIN temp_pgr_arc a ON n.pgr_node_id IN (a.pgr_node_1, a.pgr_node_2)
            WHERE n.modif = TRUE
            AND n.graph_delimiter = 'MINSECTOR'
            AND n.to_arc IS NULL
        ), arcs_modif AS (
            SELECT
                pgr_arc_id,
                bool_or(pgr_node_id = pgr_node_1) AS modif1,
                bool_or( pgr_node_id = pgr_node_2) AS modif2
            FROM arcs_selected
            GROUP BY pgr_arc_id
        )
        UPDATE temp_pgr_arc t
        SET
            modif1 = s.modif1,
            modif2 = s.modif2
        FROM arcs_modif s
        WHERE t.pgr_arc_id = s.pgr_arc_id;

        -- for the valves with to_arc NOT NULL, the arc that is not to_arc is modif = TRUE
        WITH arcs_selected AS (
		SELECT
			a.pgr_arc_id,
			n.pgr_node_id,
			a.pgr_node_1,
			a.pgr_node_2
		FROM  temp_pgr_node n
		JOIN temp_pgr_arc a on n.pgr_node_id in (a.pgr_node_1, a.pgr_node_2)
		WHERE n.modif = TRUE AND n.graph_delimiter = 'MINSECTOR' AND n.to_arc IS NOT NULL AND a.arc_id <> ALL(n.to_arc)
        ), arcs_modif AS (
            SELECT
                pgr_arc_id,
                bool_or(pgr_node_id = pgr_node_1) AS modif1,
                bool_or( pgr_node_id = pgr_node_2) AS modif2
            FROM arcs_selected
            GROUP BY pgr_arc_id
        )
        UPDATE temp_pgr_arc t
        SET modif1= s.modif1,
            modif2= s.modif2
        FROM arcs_modif s
        WHERE t.pgr_arc_id= s.pgr_arc_id;
    END IF;

    -- for the nodes with v_graph_delimiter - all the arcs
    WITH arcs_selected AS (
    SELECT
        a.pgr_arc_id,
        n.pgr_node_id,
        a.pgr_node_1,
        a.pgr_node_2
    FROM temp_pgr_node n
    JOIN temp_pgr_arc a ON n.pgr_node_id IN (a.pgr_node_1, a.pgr_node_2)
    WHERE n.modif = TRUE AND n.graph_delimiter = v_graph_delimiter
    ), arcs_modif AS (
        SELECT
            pgr_arc_id,
            bool_or(pgr_node_id = pgr_node_1) AS modif1,
            bool_or( pgr_node_id = pgr_node_2) AS modif2
        FROM arcs_selected
        GROUP BY pgr_arc_id
    )
    UPDATE temp_pgr_arc t
    SET modif1= s.modif1,
        modif2= s.modif2
    FROM arcs_modif s
    WHERE t.pgr_arc_id= s.pgr_arc_id;

    -- for the nodes with graph_delimiter = 'FORCECLOSED' - all the arcs
    WITH arcs_selected AS (
        SELECT
            a.pgr_arc_id,
            n.pgr_node_id,
            a.pgr_node_1,
            a.pgr_node_2
        FROM temp_pgr_node n
        JOIN temp_pgr_arc a ON n.pgr_node_id IN (a.pgr_node_1, a.pgr_node_2)
        WHERE n.modif = TRUE AND n.graph_delimiter = 'FORCECLOSED'
        ), arcs_modif AS (
            SELECT
                pgr_arc_id,
                bool_or(pgr_node_id = pgr_node_1) AS modif1,
                bool_or( pgr_node_id = pgr_node_2) AS modif2
            FROM arcs_selected
            GROUP BY pgr_arc_id
        )
    UPDATE temp_pgr_arc t
    SET modif1= s.modif1,
        modif2= s.modif2
    FROM arcs_modif s
    WHERE t.pgr_arc_id= s.pgr_arc_id;

    -- Disconnect arcs with modif = TRUE at nodes with modif1 = TRUE; a new arc N_new->N_original is created with the v_cost and v_reverse_cost
    FOR v_record IN
	    SELECT n.graph_delimiter AS n_graph_delimiter, n.node_id, a.graph_delimiter AS a_graph_delimiter, a.pgr_arc_id, a.arc_id, a.pgr_node_1, a.node_1
	    FROM temp_pgr_node n
	    JOIN temp_pgr_arc a ON n.pgr_node_id = a.pgr_node_1
	    WHERE n.modif AND a.modif1
    LOOP
	    INSERT INTO temp_pgr_node (old_node_id, modif, graph_delimiter) VALUES (v_record.node_id, FALSE, v_record.n_graph_delimiter);
        SELECT LAST_VALUE INTO v_pgr_node_id FROM temp_pgr_node_pgr_node_id_seq;
	    UPDATE temp_pgr_arc SET pgr_node_1 = v_pgr_node_id, node_1 = NULL
	    WHERE pgr_arc_id = v_record.pgr_arc_id;
	    INSERT INTO temp_pgr_arc (old_arc_id, pgr_node_1, pgr_node_2, node_1, graph_delimiter, cost, reverse_cost)
	    VALUES (v_record.arc_id, v_record.pgr_node_1, v_pgr_node_id, v_record.node_1,
        CASE WHEN v_record.a_graph_delimiter = 'NONE' THEN v_record.n_graph_delimiter ELSE v_record.a_graph_delimiter END, v_cost, v_reverse_cost);
    END LOOP;

    -- Disconnect arcs with modif = TRUE at nodes with modif2 = TRUE; a new arc N_new->N_original is created with the v_cost and v_reverse_cost
    FOR v_record IN
	    SELECT n.graph_delimiter AS n_graph_delimiter, n.node_id, a.graph_delimiter AS a_graph_delimiter, a.pgr_arc_id, a.arc_id, a.pgr_node_2, a.node_2
	    FROM temp_pgr_node n
	    JOIN temp_pgr_arc a ON n.pgr_node_id = a.pgr_node_2
	    WHERE n.modif AND a.modif2
    LOOP
	    INSERT INTO temp_pgr_node (old_node_id, modif, graph_delimiter) VALUES (v_record.node_id, FALSE, v_record.n_graph_delimiter);
        SELECT LAST_VALUE INTO v_pgr_node_id FROM temp_pgr_node_pgr_node_id_seq;
	    UPDATE temp_pgr_arc SET pgr_node_2 = v_pgr_node_id, node_2 = NULL
	    WHERE pgr_arc_id = v_record.pgr_arc_id;
	    INSERT INTO temp_pgr_arc(old_arc_id, pgr_node_1, pgr_node_2, node_2, graph_delimiter, cost, reverse_cost)
	    VALUES (v_record.arc_id, v_pgr_node_id, v_record.pgr_node_2, v_record.node_2,
        CASE WHEN v_record.a_graph_delimiter = 'NONE' THEN v_record.n_graph_delimiter ELSE v_record.a_graph_delimiter END, v_cost, v_reverse_cost);
    END LOOP;

    IF v_project_type = 'WS' THEN
        UPDATE temp_pgr_arc t
        SET closed = n.closed, broken = n.broken, to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE COALESCE(t.node_1, t.node_2) = n.node_id
        AND t.graph_delimiter = 'MINSECTOR';

        UPDATE temp_pgr_node t
        SET closed = n.closed, broken = n.broken, to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE t.old_node_id = n.node_id
        AND t.graph_delimiter = 'MINSECTOR';

        UPDATE temp_pgr_arc t
        SET to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE COALESCE(t.node_1, t.node_2) = n.node_id
        AND t.graph_delimiter = v_graph_delimiter;

        UPDATE temp_pgr_node t
        SET to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE t.old_node_id = n.node_id
        AND t.graph_delimiter = v_graph_delimiter;

        -- closed valves
        UPDATE temp_pgr_arc a
        SET cost = -1, reverse_cost = -1
        WHERE a.graph_delimiter  = 'MINSECTOR'
        AND a.closed = TRUE;

        -- checkvalves
        UPDATE temp_pgr_arc a
        SET cost = CASE WHEN a.node_1 IS NOT NULL THEN -1 ELSE a.cost END,
            reverse_cost = CASE WHEN a.node_2 IS NOT NULL THEN -1 ELSE a.reverse_cost END
        WHERE a.graph_delimiter  = 'MINSECTOR'
        AND a.to_arc IS NOT NULL
        AND a.closed = FALSE;

        -- for mapzone graph_delimiter - the inlet arcs behave like checkvalves
        UPDATE temp_pgr_arc a
        SET cost = CASE WHEN a.node_1 IS NOT NULL THEN -1 ELSE a.cost END,
            reverse_cost = CASE WHEN a.node_2 IS NOT NULL THEN -1 ELSE a.reverse_cost END
        WHERE a.graph_delimiter = v_graph_delimiter
        AND a.old_arc_id <> ALL (a.to_arc);
    END IF;

    -- nodes FORCECLOSED
    UPDATE temp_pgr_arc a
    SET cost = -1, reverse_cost = -1
    WHERE a.graph_delimiter  = 'FORCECLOSED';



    IF v_project_type = 'WS' THEN
        v_source := 'pgr_node_1';
        v_target := 'pgr_node_2';
    ELSE
        v_source := 'pgr_node_2';
        v_target := 'pgr_node_1';
    END IF;
    -- calculate to_arc of node parents in from zero mode
    IF v_from_zero THEN
        IF v_project_type = 'UD' AND v_mapzone_name = 'DWFZONE' THEN
            v_query_text := 'SELECT pgr_arc_id AS id, ' || v_source || ' AS source, ' || v_target || ' AS target, cost, reverse_cost 
                FROM temp_pgr_arc
                WHERE graph_delimiter <> ''INITOVERFLOWPATH'' AND reverse_cost < 0'; -- if pgr_node_1 or pgr_node_2 have graph_delimiter = IGNORE, the arcs will not be filtered
        ELSIF v_project_type = 'UD' THEN
            v_query_text := 'SELECT pgr_arc_id AS id, ' || v_source || ' AS source, ' || v_target || ' AS target, cost, reverse_cost 
                FROM temp_pgr_arc';
        ELSE
            v_query_text := 'SELECT pgr_arc_id AS id, ' || v_source || ' AS source, ' || v_target || ' AS target, cost, reverse_cost 
                FROM temp_pgr_arc';

            EXECUTE 'SELECT array_agg(pgr_node_id)::INT[] 
                    FROM temp_pgr_node 
                    JOIN man_tank ON man_tank.node_id = temp_pgr_node.node_id'
            INTO v_pgr_root_vids;
        END IF;

        INSERT INTO temp_pgr_drivingdistance(seq, "depth", start_vid, pred, node, edge, "cost", agg_cost)
        (
            SELECT seq, "depth", start_vid, pred, node, edge, "cost", agg_cost
            FROM pgr_drivingdistance(v_query_text, v_pgr_root_vids, v_pgr_distance)
        );
        -- update to_arc of nodes in from zero mode
        v_query_text = '
        WITH node_parents AS (
            SELECT pgr_node_id, node_id
            FROM temp_pgr_node
            WHERE graph_delimiter = ''' || v_mapzone_name || '''
            AND to_arc IS NULL
            AND node_id IS NOT NULL
        ), nodes_to_update AS (
            SELECT node 
            FROM temp_pgr_drivingdistance tpd
            JOIN node_parents n ON tpd.pred = n.pgr_node_id
        ), correct_to_arc AS (
            SELECT *
            FROM temp_pgr_arc tpa
            JOIN nodes_to_update nu ON (tpa.pgr_node_1 = nu.node OR tpa.pgr_node_2 = nu.node)
            JOIN node_parents np ON (tpa.node_1 = np.node_id OR tpa.node_2 = np.node_id)
        )
        UPDATE temp_pgr_node t
        SET to_arc = a.to_arc
        FROM (
            SELECT pgr_node_id, array_agg(old_arc_id) AS to_arc
            FROM correct_to_arc
            GROUP BY pgr_node_id
        ) a
        WHERE t.pgr_node_id = a.pgr_node_id;';

        EXECUTE v_query_text;

    END IF;

    -- NOTE: This is the same code, because we need to update the to_arc of the nodes in the mapzone graph_delimiter
    IF v_project_type = 'WS' THEN
        UPDATE temp_pgr_arc t
        SET closed = n.closed, broken = n.broken, to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE COALESCE(t.node_1, t.node_2) = n.node_id
        AND t.graph_delimiter = 'MINSECTOR';

        UPDATE temp_pgr_node t
        SET closed = n.closed, broken = n.broken, to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE t.old_node_id = n.node_id
        AND t.graph_delimiter = 'MINSECTOR';

        UPDATE temp_pgr_arc t
        SET to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE COALESCE(t.node_1, t.node_2) = n.node_id
        AND t.graph_delimiter = v_graph_delimiter;

        UPDATE temp_pgr_node t
        SET to_arc = n.to_arc
        FROM temp_pgr_node n
        WHERE t.old_node_id = n.node_id
        AND t.graph_delimiter = v_graph_delimiter;

        -- closed valves
        UPDATE temp_pgr_arc a
        SET cost = -1, reverse_cost = -1
        WHERE a.graph_delimiter  = 'MINSECTOR'
        AND a.closed = TRUE;

        -- checkvalves
        UPDATE temp_pgr_arc a
        SET cost = CASE WHEN a.node_1 IS NOT NULL THEN -1 ELSE a.cost END,
            reverse_cost = CASE WHEN a.node_2 IS NOT NULL THEN -1 ELSE a.reverse_cost END
        WHERE a.graph_delimiter  = 'MINSECTOR'
        AND a.to_arc IS NOT NULL
        AND a.closed = FALSE;

        -- for mapzone graph_delimiter - the inlet arcs behave like checkvalves
        UPDATE temp_pgr_arc a
        SET cost = CASE WHEN a.node_1 IS NOT NULL THEN -1 ELSE a.cost END,
            reverse_cost = CASE WHEN a.node_2 IS NOT NULL THEN -1 ELSE a.reverse_cost END
        WHERE a.graph_delimiter = v_graph_delimiter
        AND a.old_arc_id <> ALL (a.to_arc);
    END IF;

    RETURN jsonb_build_object(
        'status', 'Accepted',
        'message', jsonb_build_object(
            'level', 1,
            'text', 'The network has been arranged successfully.'
        ),
        'version', v_version,
        'body', jsonb_build_object(
            'form', jsonb_build_object(),
            'data', jsonb_build_object()
        )
    );

    EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'status', 'Failed',
        'message', jsonb_build_object(
            'level', 3,
            'text', 'An error occurred while arranging the network:' || SQLERRM
        ),
        'version', v_version,
        'body', jsonb_build_object(
            'form', jsonb_build_object(),
            'data', jsonb_build_object()
        )
    );

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
