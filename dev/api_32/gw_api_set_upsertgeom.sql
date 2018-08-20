-- Function: ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer)

-- DROP FUNCTION ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer);

CREATE OR REPLACE FUNCTION ws_sample.gw_api_set_upsertgeom(
    p_table_id character varying,
    p_id text,
    p_x1 double precision,
    p_y1 double precision,
    p_x2 double precision,
    p_y2 double precision,
    p_device integer,
    p_info_type integer)
  RETURNS json AS
$BODY$

DECLARE
    v_return json;
    v_reduced_geometry public.geometry;
    fields json; 

BEGIN

-- init
	-- Set search path to local schema
	SET search_path = "ws_sample", public;

	-- Geometry column
	IF p_x2 IS NULL THEN
		v_reduced_geometry:= ST_SetSRID(ST_MakePoint(p_x1, p_y1),(SELECT ST_srid (the_geom) FROM sector limit 1));
	ELSIF p_x2 IS NOT NULL THEN
		v_reduced_geometry:= ST_SetSRID(ST_MakeLine(ST_MakePoint(p_x1, p_y1), ST_MakePoint(p_x2, p_y2)),(SELECT ST_srid (the_geom) FROM sector limit 1));
	END IF;
	
	-- Call derivated functions
	IF p_id IS NULL THEN 
		SELECT gw_api_get_infofromid(p_table_id, null, v_reduced_geometry, true, p_device, p_info_type) INTO v_return;
		
	ELSIF p_id IS NOT NULL THEN
		SELECT gw_api_get_upsertfeature(p_table_id, p_id, v_reduced_geometry, p_device, p_info_type, 'UPSERTGEOM') INTO v_return;
		RAISE NOTICE 'v_return %',v_return; 
		SELECT gw_api_set_upsertfields (p_table_id, p_id, v_reduced_geometry, p_device, p_info_type, v_return);
		
	END IF;

--    Return
      RETURN v_return;

--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer)
  OWNER TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer) TO geoadmin;
GRANT EXECUTE ON FUNCTION ws_sample.gw_api_set_upsertgeom(character varying, text, double precision, double precision, double precision, double precision, integer, integer) TO rol_dev;
