-- Function: SCHEMA_NAME.gw_trg_vi()

-- DROP FUNCTION SCHEMA_NAME.gw_trg_vi();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_vi()
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
    
    -- Get SRID
  SELECT epsg INTO v_epsg FROM version LIMIT 1;
  
    --Get view name
    v_view = TG_ARGV[0];

    --inserts of data via editable views into corresponding arc, node, man_* and inp_* tables
    --split_part(NEW.other_val,';',1) splitting the values concatenated in a vie in order to put it in separated fields of a view
    --nullif(split_part(NEW.other_val,';',1),'')::numeric in case of trying to split the value that may not exist(optional value),
    --nullif function returns null instead of cast value error in case when there is no value in the inp data
    
   IF TG_OP = 'INSERT' THEN
  IF v_view='vi_junctions' THEN
    INSERT INTO node (node_id, elevation, nodecat_id,epa_type,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.node_id, NEW.elevation,'EPAJUNCTION-DEF','JUNCTION',1,1,1,1,2) ;
    INSERT INTO inp_junction (node_id, demand, pattern_id) VALUES (NEW.node_id, NEW.demand, NEW.pattern_id);
    INSERT INTO man_junction (node_id) VALUES (NEW.node_id); 
    
  ELSIF v_view='vi_reservoirs' THEN
    INSERT INTO node (node_id, elevation, nodecat_id,epa_type,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.node_id, NEW.head,'EPARESERVOIR-DEF','RESERVOIR',1,1,1,1,2) ;
    INSERT INTO inp_reservoir (node_id, pattern_id) VALUES (NEW.node_id, NEW.pattern_id);
    INSERT INTO man_source(node_id) VALUES (NEW.node_id); 
    
  ELSIF v_view='vi_tanks' THEN
    INSERT INTO node (node_id, elevation, nodecat_id,epa_type,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.node_id, NEW.elevation,'EPATANK-DEF','TANK',1,1,1,1,2);
    INSERT INTO inp_tank (node_id, initlevel, minlevel, maxlevel, diameter, minvol, curve_id) 
    VALUES (NEW.node_id, NEW.initlevel, NEW.minlevel, NEW.maxlevel, NEW.diameter, NEW.minvol, NEW.curve_id);
    INSERT INTO man_tank (node_id) VALUES (NEW.node_id); 
    
  ELSIF v_view='vi_pipes' THEN
    INSERT INTO arc (arc_id, node_1, node_2, arccat_id,epa_type,custom_length,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.arc_id,NEW.node_1, NEW.node_2,concat(NEW.roughness::numeric(10,3),'-',NEW.diameter::numeric(10,3))::text,'PIPE',NEW.length,1,1,1,1,2);
    INSERT INTO inp_pipe (arc_id, minorloss,status, custom_roughness, custom_dint) 
    SELECT NEW.arc_id, NEW.minorloss, inp_typevalue.id, NEW.roughness,NEW.diameter 
    FROM inp_typevalue WHERE upper(NEW.status)=idval AND typevalue='inp_value_status_pipe';
    INSERT INTO man_pipe (arc_id) VALUES (NEW.arc_id); 
    
  ELSIF v_view='vi_pumps' THEN 
    INSERT INTO arc (arc_id, node_1, node_2, arccat_id,epa_type,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.arc_id, NEW.node_1, NEW.node_2, 'EPAPUMP-DEF','PIPE',1,1,1,1,2);
    INSERT INTO inp_pump_importinp (arc_id,power,curve_id,speed,pattern) 
    VALUES (NEW.arc_id,NEW.power,NEW.curve_id, NEW.speed::numeric, NEW.pattern);
    INSERT INTO man_pipe (arc_id) VALUES (NEW.arc_id); 
    
  ELSIF v_view='vi_valves' THEN
    INSERT INTO arc (arc_id, node_1, node_2, arccat_id,epa_type,sector_id, dma_id, expl_id, state, state_type) 
    VALUES (NEW.arc_id, NEW.node_1, NEW.node_2,concat(NEW.valv_type,'-',NEW.diameter::numeric(10,3))::text,'PIPE',1,1,1,1,2);
    INSERT INTO inp_valve_importinp (arc_id, diameter, valv_type, minorloss) VALUES (NEW.arc_id,NEW.diameter, NEW.valv_type, NEW.minorloss);
      IF NEW.valv_type='PRV' THEN
        UPDATE inp_valve_importinp SET pressure=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
      ELSIF NEW.valv_type='FCV' THEN 
        UPDATE inp_valve_importinp SET flow=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
      ELSIF NEW.valv_type='TCV' THEN
        UPDATE inp_valve_importinp SET coef_loss=NEW.setting::numeric WHERE arc_id=NEW.arc_id;
      ELSIF NEW.valv_type='GPV' THEN
        UPDATE inp_valve_importinp SET curve_id=NEW.setting WHERE arc_id=NEW.arc_id;
      END IF;         
    INSERT INTO man_pipe (arc_id) VALUES (NEW.arc_id); 
    
  ELSIF v_view='vi_tags' THEN 
    INSERT INTO inp_tags(object, node_id, tag) VALUES (NEW.object, NEW.node_id, NEW.tag);
    
  ELSIF v_view='vi_demand' THEN 
    INSERT INTO inp_demand(node_id, demand, pattern_id, deman_type) VALUES (NEW.node_id, NEW.demand, NEW.pattern_id, NEW.deman_type);
      
  ELSIF v_view='vi_status' THEN
    IF NEW.arc_id IN (SELECT arc_id FROM inp_pump_importinp) THEN
      UPDATE inp_pump_importinp SET status=NEW.status WHERE arc_id=NEW.arc_id;
    ELSIF NEW.arc_id IN (SELECT arc_id FROM inp_valve_importinp) THEN
      UPDATE inp_valve_importinp SET status=NEW.status WHERE arc_id=NEW.arc_id;
    END IF;
    
  ELSIF v_view='vi_patterns' THEN --insert depends on format of input data..
  --splitting and inserting fields that in views are concatenated as other_value
    INSERT INTO inp_pattern_value (pattern_id,factor_1,factor_2,factor_3,factor_4,factor_5,factor_6) 
    VALUES (NEW.pattern_id, split_part(NEW.multipliers,' ',1)::numeric,split_part(NEW.multipliers,' ',2)::numeric,split_part(NEW.multipliers,' ',3)::numeric,
    split_part(NEW.multipliers,' ',4)::numeric,split_part(NEW.multipliers,' ',5)::numeric,split_part(NEW.multipliers,' ',6)::numeric);
  
  ELSIF v_view='vi_curves' THEN
    IF NEW.curve_id NOT IN (SELECT id FROM inp_curve_id) then
      INSERT INTO inp_curve_id (id,curve_type)  VALUES (NEW.curve_id,'EFFICIENCY'); --curve type by default???
    END IF;
    INSERT INTO inp_curve(curve_id, x_value, y_value) VALUES (NEW.curve_id, NEW.x_value, NEW.y_value);
    
  ELSIF v_view='vi_controls' THEN 
    IF split_part(NEW.text,' ',2) in (select arc_id from arc) then
      INSERT INTO inp_controls_x_arc (arc_id, text) VALUES (split_part(NEW.text,' ',2),NEW.text);
    ELSIF split_part(NEW.text,' ',2) in (select node_id from node) then
      INSERT INTO inp_controls_x_node (node_id, text) VALUES (split_part(NEW.text,' ',2),NEW.text);
    END IF;
  ELSIF v_view='vi_rules' THEN  
    IF split_part(NEW.text,' ',2) in (select arc_id from arc) then
      INSERT INTO inp_rules_x_arc (arc_id, text) VALUES (split_part(NEW.text,' ',2),NEW.text);
    ELSIF split_part(NEW.text,' ',2) in (select node_id from node) then
      INSERT INTO inp_rules_x_node (node_id, text) VALUES (split_part(NEW.text,' ',2),NEW.text);
    END IF;
  ELSIF v_view='vi_emitters' THEN
    INSERT INTO inp_emitter(node_id, coef) VALUES (NEW.node_id, NEW.coef);
  ELSIF v_view='vi_quality' THEN
    INSERT INTO inp_quality (node_id,initqual) VALUES (NEW.node_id,NEW.initqual);
  ELSIF v_view='vi_sources' THEN
    INSERT INTO inp_source(node_id, sourc_type, quality, pattern_id) VALUES (NEW.node_id, NEW.sourc_type, NEW.quality, NEW.pattern_id);
  ELSIF v_view='vi_reactions' THEN
    IF NEW.parameter IS NOT NULL THEN
      IF NEW.parameter IN (SELECT arc_id FROM arc) THEN
        INSERT INTO inp_reactions_el (parameter, arc_id,value) SELECT inp_typevalue.id,NEW.parameter,NEW.value
        FROM inp_typevalue WHERE upper(NEW.react_type)=idval AND typevalue='inp_value_reactions_el';
      ELSE 
        IF NEW.react_type='LIMITING' OR NEW.react_type='ROUGHNESS' THEN
          INSERT INTO inp_reactions_gl (react_type,value) VALUES (concat(NEW.react_type,' ',NEW.parameter),NEW.value);
        ELSE
          INSERT INTO inp_reactions_gl (react_type,parameter,value) VALUES (
          (SELECT inp_typevalue.id FROM inp_typevalue WHERE upper(NEW.react_type)=idval AND typevalue='inp_typevalue_reactions_gl'),
          (select inp_typevalue.id FROM inp_typevalue WHERE upper(NEW.parameter)=idval AND typevalue='inp_value_reactions_gl'), NEW.value);
        END IF;
      END IF;
    END IF;
  ELSIF v_view='vi_energy' THEN
      IF NEW.parameter ilike 'GLOBAL%' THEN
        INSERT INTO inp_energy_gl(energ_type,parameter, value)
        select split_part(NEW.parameter,' ',1),inp_typevalue.id,NEW.value 
        FROM inp_typevalue WHERE upper(split_part(NEW.parameter,' ',2))=idval AND typevalue='inp_value_param_energy';
      ELSIF NEW.parameter ilike 'DEMAND CHARGE' THEN
        INSERT INTO inp_energy_gl(energ_type, value) VALUES ('DEMAND CHARGE',NEW.value);
      ELSIF NEW.parameter ilike '%PUMP%' THEN
        INSERT INTO inp_energy_el(pump_id,parameter, value) VALUES (split_part(NEW.parameter,' ',2),split_part(NEW.parameter,' ',3),NEW.value);
      END IF;
  ELSIF v_view='vi_mixing' THEN
    INSERT INTO inp_mixing(node_id, mix_type, value) VALUES (NEW.node_id, NEW.mix_type, NEW.value);
    
  ELSIF v_view='vi_times' THEN 
    IF NEW.value IS NULL THEN
      INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_times_',(lower(split_part(NEW.parameter,'_',1)))), split_part(NEW.parameter,'_',2), current_user) ;
    ELSE
      INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_times_',(lower(NEW.parameter))), NEW.value, current_user) ;
    END IF;
  ELSIF v_view='vi_report' THEN
    INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_report_',(lower(NEW.parameter))), NEW.value, current_user) ; 
  ELSIF v_view='vi_coordinates' THEN
    UPDATE node SET the_geom=ST_SetSrid(ST_MakePoint(NEW.xcoord,NEW.ycoord),v_epsg) WHERE node_id=NEW.node_id;
  ELSIF v_view='vi_labels' THEN
    INSERT INTO inp_label (xcoord, ycoord, label, node_id) VALUES (NEW.xcoord, NEW.ycoord, NEW.label, NEW.node_id);
  ELSIF v_view='vi_backdrop' THEN
    INSERT INTO inp_backdrop(text) VALUES (NEW.text);
  ELSIF v_view='vi_options' THEN
    INSERT INTO config_param_user (parameter, value, cur_user) VALUES (concat('inp_options_',(lower(NEW.parameter))), NEW.value, current_user) ;
  END IF;
    END IF;

    RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;





DROP TRIGGER IF EXISTS gw_trg_vi_junctions ON SCHEMA_NAME.vi_junctions;
CREATE TRIGGER gw_trg_vi_junctions INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_junctions FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_junctions');
DROP TRIGGER IF EXISTS gw_trg_vi_options ON SCHEMA_NAME.vi_options;
CREATE TRIGGER gw_trg_vi_options INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_options FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_options');
DROP TRIGGER IF EXISTS gw_trg_vi_reservoirs ON SCHEMA_NAME.vi_reservoirs;
CREATE TRIGGER gw_trg_vi_reservoirs INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_reservoirs FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_reservoirs');
DROP TRIGGER IF EXISTS gw_trg_vi_tanks ON SCHEMA_NAME.vi_tanks;
CREATE TRIGGER gw_trg_vi_tanks INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_tanks FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_tanks');
DROP TRIGGER IF EXISTS gw_trg_vi_pipes ON SCHEMA_NAME.vi_pipes;
CREATE TRIGGER gw_trg_vi_pipes INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_pipes FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_pipes');
DROP TRIGGER IF EXISTS gw_trg_vi_pumps ON SCHEMA_NAME.vi_pumps;
CREATE TRIGGER gw_trg_vi_pumps INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_pumps FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_pumps');
DROP TRIGGER IF EXISTS gw_trg_vi_valves ON SCHEMA_NAME.vi_valves;
CREATE TRIGGER gw_trg_vi_valves INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_valves FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_valves');
DROP TRIGGER IF EXISTS gw_trg_vi_tags ON SCHEMA_NAME.vi_tags;
CREATE TRIGGER gw_trg_vi_tags INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_tags FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_tags');
DROP TRIGGER IF EXISTS gw_trg_vi_demands ON SCHEMA_NAME.vi_demands;
CREATE TRIGGER gw_trg_vi_demands INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_demands FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_demands');
DROP TRIGGER IF EXISTS gw_trg_vi_status ON SCHEMA_NAME.vi_status;
CREATE TRIGGER gw_trg_vi_status INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_status FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_status');
DROP TRIGGER IF EXISTS gw_trg_vi_curves ON SCHEMA_NAME.vi_curves;
CREATE TRIGGER gw_trg_vi_curves INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_curves FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_curves');
DROP TRIGGER IF EXISTS gw_trg_vi_emitters ON SCHEMA_NAME.vi_emitters;
CREATE TRIGGER gw_trg_vi_emitters INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_emitters FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_emitters');
DROP TRIGGER IF EXISTS gw_trg_vi_quality ON SCHEMA_NAME.vi_quality;
CREATE TRIGGER gw_trg_vi_quality INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_quality FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_quality');
DROP TRIGGER IF EXISTS gw_trg_vi_sources ON SCHEMA_NAME.vi_sources;
CREATE TRIGGER gw_trg_vi_sources INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_sources FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_sources');
DROP TRIGGER IF EXISTS gw_trg_vi_mixing ON SCHEMA_NAME.vi_mixing;
CREATE TRIGGER gw_trg_vi_mixing INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_mixing FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_mixing');
DROP TRIGGER IF EXISTS gw_trg_vi_times ON SCHEMA_NAME.vi_times;
CREATE TRIGGER gw_trg_vi_times INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_times FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_times');
DROP TRIGGER IF EXISTS gw_trg_vi_report ON SCHEMA_NAME.vi_report;
CREATE TRIGGER gw_trg_vi_report INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_report FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_report');
DROP TRIGGER IF EXISTS gw_trg_vi_coordinates ON SCHEMA_NAME.vi_coordinates;
CREATE TRIGGER gw_trg_vi_coordinates INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_coordinates FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_coordinates');
DROP TRIGGER IF EXISTS gw_trg_vi_vertices ON SCHEMA_NAME.vi_vertices;
CREATE TRIGGER gw_trg_vi_vertices INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_vertices FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_vertices');
DROP TRIGGER IF EXISTS gw_trg_vi_labels ON SCHEMA_NAME.vi_labels;
CREATE TRIGGER gw_trg_vi_labels INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_labels FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_labels');
DROP TRIGGER IF EXISTS gw_trg_vi_backdrop ON SCHEMA_NAME.vi_backdrop;
CREATE TRIGGER gw_trg_vi_backdrop INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_backdrop FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_backdrop');
DROP TRIGGER IF EXISTS gw_trg_vi_patterns ON SCHEMA_NAME.vi_patterns;
CREATE TRIGGER gw_trg_vi_patterns INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_patterns FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_patterns');
DROP TRIGGER IF EXISTS gw_trg_vi_controls ON SCHEMA_NAME.vi_controls;
CREATE TRIGGER gw_trg_vi_controls INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_controls FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_controls');
DROP TRIGGER IF EXISTS gw_trg_vi_rules ON SCHEMA_NAME.vi_rules;
CREATE TRIGGER gw_trg_vi_rules INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_rules FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_rules');
DROP TRIGGER IF EXISTS gw_trg_vi_energy ON SCHEMA_NAME.vi_energy;
CREATE TRIGGER gw_trg_vi_energy INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_energy FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_energy');
DROP TRIGGER IF EXISTS gw_trg_vi_reactions ON SCHEMA_NAME.vi_reactions;
CREATE TRIGGER gw_trg_vi_reactions INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.vi_reactions FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_vi('vi_reactions');

