-- Function: ud_inp.gw_trg_vi()

-- DROP FUNCTION ud_inp.gw_trg_vi();

CREATE OR REPLACE FUNCTION ud_inp.gw_trg_vi()
  RETURNS trigger AS
$BODY$
DECLARE 
	v_view text;
	v_epsg integer;
	geom_array public.geometry array;
	v_point_geom public.geometry;
	rec_arc record;
BEGIN

    --Get schema name
    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	SELECT epsg INTO v_epsg FROM version LIMIT 1;
	
    --Get view name
    v_view = TG_ARGV[0];
    
    IF TG_OP = 'INSERT' THEN
	IF v_view='vi_options' THEN
		INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_options_',(lower(NEW.parameter))), NEW.value, current_user) ;
	ELSIF v_view='vi_report' THEN
		INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_report_',(lower(NEW.repor_type))), NEW.value, current_user) ;
	ELSIF v_view='vi_files' THEN
		INSERT INTO inp_files (actio_type, file_type, fname) VALUES (NEW.actio_type, NEW.file_type, NEW.fname);
	ELSIF v_view='vi_evaporation' THEN --complicated
	ELSIF v_view='vi_raingages' THEN --like pump in ws?
	ELSIF v_view='vi_temperature' THEN 
		INSERT INTO inp_temperature (temp_type, value) VALUES (NEW.temp_type, NEW.value);
	ELSIF v_view='vi_subcatchments' THEN 
		INSERT INTO subcatchment (subc_id, rg_id, node_id, area, imperv, width, slope, clength,snow_id) 
		VALUES (NEW.subc_id, NEW.rg_id, NEW.node_id, NEW.area, NEW.imperv, NEW.width, NEW.slope, NEW.clength,NEW.snow_id);
	ELSIF v_view='vi_subareas' THEN
		UPDATE subcatchment SET nimp=NEW.nimp, nperv=NEW.nperv, simp=NEW.simp, sperv=NEW.sperv, zero=NEW.zero, routeto=NEW.routeto, rted=NEW.rted WHERE subc_id=NEW.subc_id;
	ELSIF v_view='vi_infiltration' THEN --complicated
	ELSIF v_view='vi_aquifers' THEN
		INSERT INTO inp_aquifer (aquif_id, por, wp, fc, k, ks, ps, uef, led, gwr, be, wte, umc, pattern_id) 
		VALUES (NEW.aquif_id, NEW.por, NEW.wp, NEW.fc, NEW.k, NEW.ks, NEW.ps, NEW.uef, NEW.led, NEW.gwr, NEW.be, NEW.wte, NEW.umc, NEW.pattern_id);
	ELSIF v_view='vi_groundwater' THEN
		INSERT INTO inp_groundwater (subc_id, aquif_id, node_id, surfel, a1, b1, a2, b2, a3, tw, h) 
		VALUES (NEW.subc_id, NEW.aquif_id, NEW.node_id, NEW.surfel, NEW.a1, NEW.b1, NEW.a2, NEW.b2, NEW.a3, NEW.tw, NEW.h);
	ELSIF v_view='vi_snowpacks' THEN--complicated
	ELSIF v_view='vi_gwf' THEN --like pumps
		--INSERT INTO inp_groundwater(subc_id, fl_eq_lat, fl_eq_deep) VALUES (NEW.subc_id, NEW.fl_eq_lat, NEW.fl_eq_deep);
	END IF;
    END IF;

    RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ud_inp.gw_trg_vi()
  OWNER TO geoadmin;




DROP TRIGGER IF EXISTS gw_trg_vi_options ON ud_inp.vi_options;
CREATE TRIGGER gw_trg_vi_options INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_options FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_options');
DROP TRIGGER IF EXISTS gw_trg_vi_report ON ud_inp.vi_report;
CREATE TRIGGER gw_trg_vi_report INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_report FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_report');
DROP TRIGGER IF EXISTS gw_trg_vi_files ON ud_inp.vi_files;
CREATE TRIGGER gw_trg_vi_files INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_files FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_files');
DROP TRIGGER IF EXISTS gw_trg_vi_evaporation ON ud_inp.vi_evaporation;
CREATE TRIGGER gw_trg_vi_evaporation INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_evaporation FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_evaporation');
DROP TRIGGER IF EXISTS gw_trg_vi_raingages ON ud_inp.vi_raingages;
CREATE TRIGGER gw_trg_vi_raingages INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_raingages FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_raingages');
DROP TRIGGER IF EXISTS gw_trg_vi_temperature ON ud_inp.vi_temperature;
CREATE TRIGGER gw_trg_vi_temperature INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_temperature FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_temperature');
DROP TRIGGER IF EXISTS gw_trg_vi_subcatchments ON ud_inp.vi_subcatchments;
CREATE TRIGGER gw_trg_vi_subcatchments INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_subcatchments FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_subcatchments');
DROP TRIGGER IF EXISTS gw_trg_vi_subareas ON ud_inp.vi_subareas;
CREATE TRIGGER gw_trg_vi_subareas INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_subareas FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_subareas');
DROP TRIGGER IF EXISTS gw_trg_vi_infiltration ON ud_inp.vi_infiltration;
CREATE TRIGGER gw_trg_vi_infiltration INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_infiltration FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_infiltration');
DROP TRIGGER IF EXISTS gw_trg_vi_aquifers ON ud_inp.vi_aquifers;
CREATE TRIGGER gw_trg_vi_aquifers INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_aquifers FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_aquifers');
DROP TRIGGER IF EXISTS gw_trg_vi_groundwater ON ud_inp.vi_groundwater;
CREATE TRIGGER gw_trg_vi_groundwater INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_groundwater FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_groundwater');
DROP TRIGGER IF EXISTS gw_trg_vi_snowpacks ON ud_inp.vi_snowpacks;
CREATE TRIGGER gw_trg_vi_snowpacks INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_snowpacks FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_snowpacks');
DROP TRIGGER IF EXISTS gw_trg_vi_gwf ON ud_inp.vi_gwf;
CREATE TRIGGER gw_trg_vi_gwf INSTEAD OF INSERT OR UPDATE OR DELETE ON ud_inp.vi_gwf FOR EACH ROW EXECUTE PROCEDURE ud_inp.gw_trg_vi('vi_gwf');