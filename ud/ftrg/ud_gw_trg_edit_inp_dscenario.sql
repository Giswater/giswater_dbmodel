/*
This file is part of Giswater
The program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.
*/


-- FUNCTION NUMBER : 3074

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_edit_inp_dscenario()
  RETURNS trigger AS
$BODY$
DECLARE

v_dscenario_type text;

BEGIN


	--Get schema name
	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	--Get view name
	v_dscenario_type = TG_ARGV[0];

	IF TG_OP = 'INSERT' THEN

		-- force selector
		INSERT INTO selector_inp_dscenario VALUES (NEW.dscenario_id, current_user) ON CONFLICT (dscenario_id, cur_user) DO NOTHING;

	 	IF v_dscenario_type = 'CONDUIT' THEN

			-- default values
			IF NEW.arccat_id IS NULL OR NEW.arccat_id='' THEN NEW.arccat_id = (SELECT arccat_id FROM ve_inp_conduit WHERE arc_id = NEW.arc_id);END IF;
			IF NEW.matcat_id IS NULL OR NEW.matcat_id='' THEN NEW.matcat_id = (SELECT matcat_id FROM ve_inp_conduit WHERE arc_id = NEW.arc_id);END IF;
			IF NEW.elev1 IS NULL THEN NEW.elev1 = (SELECT sys_elev1 FROM ve_inp_conduit WHERE arc_id = NEW.arc_id);END IF;
			IF NEW.elev2 IS NULL THEN NEW.elev2 = (SELECT sys_elev2 FROM ve_inp_conduit WHERE arc_id = NEW.arc_id);END IF;
			IF NEW.barrels IS NULL THEN NEW.barrels = (SELECT barrels FROM ve_inp_conduit WHERE arc_id = NEW.arc_id);END IF;

			INSERT INTO inp_dscenario_conduit (dscenario_id, arc_id, arccat_id, matcat_id, elev1, elev2, custom_n, barrels, culvert, kentry, kexit,
			kavg, flap, q0, qmax, seepage)
	 		VALUES (NEW.dscenario_id, NEW.arc_id, NEW.arccat_id, NEW.matcat_id, NEW.elev1, NEW.elev2, NEW.custom_n, NEW.barrels, NEW.culvert, NEW.kentry, NEW.kexit,
	 		NEW.kavg, NEW.flap, NEW.q0, NEW.qmax, NEW.seepage);


		ELSIF v_dscenario_type = 'FLWREG-ORIFICE' THEN

			-- default values
			IF NEW.ori_type IS NULL OR NEW.ori_type='' THEN NEW.ori_type = (SELECT ori_type FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.offsetval IS NULL THEN NEW.offsetval = (SELECT offsetval FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.cd IS NULL THEN NEW.cd = (SELECT cd FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.flap IS NULL OR NEW.flap='' THEN NEW.flap = (SELECT flap FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.shape IS NULL OR NEW.shape='' THEN NEW.shape = (SELECT shape FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom1 IS NULL THEN NEW.geom1 = (SELECT geom1 FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom2 IS NULL THEN NEW.geom2 = (SELECT geom2 FROM ve_inp_frorifice WHERE nodarc_id = NEW.nodarc_id);END IF;

			INSERT INTO inp_dscenario_frorifice (dscenario_id, nodarc_id, ori_type, offsetval, cd, orate, flap, shape, geom1, geom2, geom3, geom4)
			VALUES (NEW.dscenario_id, NEW.nodarc_id, NEW.ori_type, NEW.offsetval, NEW.cd, NEW.orate, NEW.flap, NEW.shape, NEW.geom1, NEW.geom2, NEW.geom3, NEW.geom4);

	 	ELSIF v_dscenario_type = 'FLWREG-OUTLET' THEN

			-- default values
			IF NEW.outlet_type IS NULL OR NEW.outlet_type='' THEN NEW.outlet_type = (SELECT outlet_type FROM ve_inp_froutlet WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.offsetval IS NULL THEN NEW.offsetval = (SELECT offsetval FROM ve_inp_froutlet WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.curve_id IS NULL OR NEW.curve_id='' THEN NEW.curve_id = (SELECT curve_id FROM ve_inp_froutlet WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.cd1 IS NULL THEN NEW.cd1 = (SELECT cd1 FROM ve_inp_froutlet WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.cd2 IS NULL THEN NEW.cd2 = (SELECT cd2 FROM ve_inp_froutlet WHERE nodarc_id = NEW.nodarc_id);END IF;

			INSERT INTO inp_dscenario_froutlet (dscenario_id, nodarc_id, outlet_type, offsetval, curve_id, cd1, cd2)
			VALUES (NEW.dscenario_id, NEW.nodarc_id, NEW.outlet_type, NEW.offsetval, NEW.curve_id, NEW.cd1, NEW.cd2);

	 	ELSIF v_dscenario_type = 'FLWREG-PUMP' THEN

			-- default values
			IF NEW.curve_id IS NULL OR NEW.curve_id='' THEN NEW.curve_id = (SELECT curve_id FROM ve_inp_frpump WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.status IS NULL OR NEW.status='' THEN NEW.status = (SELECT status FROM ve_inp_frpump WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.startup IS NULL THEN NEW.startup = (SELECT startup FROM ve_inp_frpump WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.shutoff IS NULL THEN NEW.shutoff = (SELECT shutoff FROM ve_inp_frpump WHERE nodarc_id = NEW.nodarc_id);END IF;

			INSERT INTO inp_dscenario_frpump (dscenario_id, nodarc_id, curve_id, status, startup, shutoff)
			VALUES (NEW.dscenario_id, NEW.nodarc_id, NEW.curve_id, NEW.status, NEW.startup, NEW.shutoff);

	 	ELSIF v_dscenario_type = 'FLWREG-WEIR' THEN

			-- default values
			IF NEW.weir_type IS NULL OR NEW.weir_type='' THEN NEW.weir_type = (SELECT weir_type FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.offsetval IS NULL THEN NEW.offsetval = (SELECT offsetval FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.cd IS NULL THEN NEW.cd = (SELECT cd FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.ec IS NULL THEN NEW.ec = (SELECT ec FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.cd2 IS NULL THEN NEW.cd2 = (SELECT cd2 FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.flap IS NULL OR NEW.flap='' THEN NEW.flap = (SELECT flap FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom1 IS NULL THEN NEW.geom1 = (SELECT geom1 FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom2 IS NULL THEN NEW.geom2 = (SELECT geom2 FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom3 IS NULL THEN NEW.geom3 = (SELECT geom3 FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.geom4 IS NULL THEN NEW.geom4 = (SELECT geom4 FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.surcharge IS NULL OR NEW.surcharge='' THEN NEW.surcharge = (SELECT surcharge FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.road_width IS NULL THEN NEW.road_width = (SELECT road_width FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.road_surf IS NULL OR NEW.road_surf='' THEN NEW.road_surf = (SELECT road_surf FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;
			IF NEW.coef_curve IS NULL THEN NEW.coef_curve = (SELECT coef_curve FROM ve_inp_frweir WHERE nodarc_id = NEW.nodarc_id);END IF;

			INSERT INTO inp_dscenario_frweir (dscenario_id, nodarc_id, weir_type, offsetval, cd, ec,
			cd2, flap, geom1, geom2, geom3, geom4, surcharge, road_width, road_surf, coef_curve)
			VALUES (NEW.dscenario_id, NEW.nodarc_id, NEW.weir_type, NEW.offsetval, NEW.cd, NEW.ec,
			NEW.cd2, NEW.flap, NEW.geom1, NEW.geom2, NEW.geom3, NEW.geom4, NEW.surcharge, NEW.road_width, NEW.road_surf, NEW.coef_curve);

		ELSIF v_dscenario_type = 'INFLOWS' THEN

			-- default values
			IF NEW.timser_id IS NULL OR NEW.timser_id='' THEN NEW.timser_id = (SELECT timser_id FROM ve_inp_inflows WHERE node_id = NEW.node_id AND order_id = NEW.order_id);END IF;
			IF NEW.base IS NULL THEN NEW.base = (SELECT base FROM ve_inp_inflows WHERE node_id = NEW.node_id AND order_id = NEW.order_id);END IF;
			IF NEW.pattern_id IS NULL OR NEW.pattern_id='' THEN NEW.pattern_id = (SELECT pattern_id FROM ve_inp_inflows WHERE node_id = NEW.node_id AND order_id = NEW.order_id);END IF;

			INSERT INTO inp_dscenario_inflows (dscenario_id, node_id, order_id, timser_id, sfactor, base, pattern_id)
			VALUES(NEW.dscenario_id, NEW.node_id, NEW.order_id, NEW.timser_id, NEW.sfactor, NEW.base, NEW.pattern_id);

	 	ELSIF v_dscenario_type = 'INFLOWS-POLL' THEN

			-- default values
			IF NEW.timser_id IS NULL OR NEW.timser_id='' THEN NEW.timser_id = (SELECT timser_id FROM ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;
			IF NEW.form_type IS NULL OR NEW.form_type='' THEN NEW.form_type = (SELECT form_type FROM ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;
			IF NEW.mfactor IS NULL THEN NEW.mfactor = (SELECT mfactor FROM ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;
			IF NEW.sfactor IS NULL THEN NEW.sfactor = (SELECT sfactor FROM ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;
			IF NEW.base IS NULL THEN NEW.base = (SELECT base FROM ve_inp_inflows_poll ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;
			IF NEW.pattern_id IS NULL THEN NEW.pattern_id = (SELECT pattern_id FROM ve_inp_inflows_poll WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;

			INSERT INTO inp_dscenario_inflows_poll (dscenario_id, poll_id, node_id, timser_id, form_type, mfactor, sfactor, base, pattern_id)
			VALUES (NEW.dscenario_id, NEW.poll_id,  NEW.node_id, NEW.timser_id, NEW.form_type, NEW.mfactor, NEW.sfactor, NEW.base, NEW.pattern_id);

	 	ELSIF v_dscenario_type = 'JUNCTION' THEN

			-- default values
			IF NEW.elev IS NULL THEN NEW.elev = (SELECT elev FROM ve_inp_junction WHERE node_id = NEW.node_id);END IF;
			IF NEW.ymax IS NULL THEN NEW.ymax = (SELECT ymax FROM ve_inp_junction WHERE node_id = NEW.node_id);END IF;
			IF NEW.y0 IS NULL THEN NEW.y0 = (SELECT y0 FROM ve_inp_junction WHERE node_id = NEW.node_id);END IF;
			IF NEW.ysur IS NULL THEN NEW.ysur = (SELECT ysur FROM ve_inp_junction WHERE node_id = NEW.node_id);END IF;
			IF NEW.apond IS NULL THEN NEW.apond = (SELECT apond FROM ve_inp_junction WHERE node_id = NEW.node_id);END IF;

			INSERT INTO inp_dscenario_junction (dscenario_id, node_id, elev, ymax, y0, ysur, apond, outfallparam)
	 		VALUES (NEW.dscenario_id, NEW.node_id, NEW.elev, NEW.ymax, NEW.y0, NEW.ysur, NEW.apond, NEW.outfallparam);

		ELSIF v_dscenario_type = 'LID-USAGE' THEN

			-- default values
			IF NEW.numelem IS NULL THEN NEW.numelem = (SELECT elev FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id);END IF;
			IF NEW.area IS NULL THEN NEW.area = (SELECT area FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.width IS NULL THEN NEW.width = (SELECT width FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.initsat IS NULL THEN NEW.initsat = (SELECT initsat FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.fromimp IS NULL THEN NEW.fromimp = (SELECT fromimp FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.toperv IS NULL THEN NEW.toperv = (SELECT toperv FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.rptfile IS NULL THEN NEW.rptfile = (SELECT rptfile FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;
			IF NEW.descript IS NULL THEN NEW.descript = (SELECT descript FROM ve_inp_dscenario_lids
			WHERE dscenario_id = NEW.dscenario_id AND subc_id=NEW.subc_id );END IF;

			INSERT INTO inp_dscenario_lids (dscenario_id, subc_id, lidco_id, numelem, area, width, initsat, fromimp, toperv, rptfile, descript)
	 		VALUES (NEW.dscenario_id, NEW.subc_id, NEW.lidco_id, NEW.numelem, NEW.area, NEW.width, NEW.initsat, NEW.fromimp, NEW.toperv, NEW.rptfile,NEW.descript);


 		ELSIF v_dscenario_type = 'OUTFALL' THEN

			-- default values
			IF NEW.elev IS NULL THEN NEW.elev = (SELECT elev FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.ymax IS NULL THEN NEW.ymax = (SELECT ymax FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.outfall_type IS NULL OR NEW.outfall_type='' THEN NEW.outfall_type = (SELECT outfall_type FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.stage IS NULL THEN NEW.stage = (SELECT stage FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.curve_id IS NULL OR NEW.curve_id='' THEN NEW.curve_id = (SELECT curve_id FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.timser_id IS NULL OR NEW.timser_id='' THEN NEW.timser_id = (SELECT timser_id FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;
			IF NEW.gate IS NULL OR NEW.gate='' THEN NEW.gate = (SELECT gate FROM ve_inp_outfall WHERE node_id = NEW.node_id);END IF;

			INSERT INTO inp_dscenario_outfall(dscenario_id, node_id, outfall_type, stage, curve_id, timser_id, gate, elev, ymax)
			VALUES (NEW.dscenario_id, NEW.node_id, NEW.outfall_type, NEW.stage, NEW.curve_id, NEW.timser_id, NEW.gate, NEW.elev, NEW.ymax);

		ELSIF v_dscenario_type = 'RAINGAGE' THEN

			IF NEW.form_type IS NULL OR NEW.form_type='' THEN NEW.form_type = (SELECT form_type FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.intvl IS NULL THEN NEW.intvl = (SELECT intvl FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.scf IS NULL THEN NEW.scf = (SELECT scf FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.rgage_type IS NULL OR NEW.rgage_type='' THEN NEW.rgage_type = (SELECT rgage_type FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.timser_id IS NULL OR NEW.timser_id='' THEN NEW.timser_id = (SELECT timser_id FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.fname IS NULL OR NEW.fname='' THEN NEW.fname = (SELECT fname FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.sta IS NULL OR NEW.sta='' THEN NEW.sta = (SELECT sta FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;
			IF NEW.units IS NULL OR NEW.units='' THEN NEW.units = (SELECT units FROM ve_raingage WHERE rg_id = NEW.rg_id);END IF;

			INSERT INTO inp_dscenario_raingage (dscenario_id, rg_id, form_type, intvl, scf, rgage_type, timser_id, fname, sta, units)
	 		VALUES (NEW.dscenario_id, NEW.rg_id, NEW.form_type, NEW.intvl, NEW.scf, NEW.rgage_type, NEW.timser_id, NEW.fname, NEW.sta, NEW.units);

		ELSIF v_dscenario_type = 'STORAGE' THEN

			-- default value
			IF NEW.elev IS NULL THEN NEW.elev = (SELECT elev FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.ymax IS NULL THEN NEW.ymax = (SELECT ymax FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.storage_type IS NULL OR NEW.storage_type='' THEN NEW.storage_type = (SELECT storage_type FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.curve_id IS NULL OR NEW.curve_id='' THEN NEW.curve_id = (SELECT curve_id FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.a1 IS NULL THEN NEW.a1 = (SELECT a1 FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.a2 IS NULL THEN NEW.a2 = (SELECT a2 FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.a0 IS NULL THEN NEW.a0 = (SELECT a0 FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.fevap IS NULL THEN NEW.fevap = (SELECT fevap FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.sh IS NULL THEN NEW.sh = (SELECT sh FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.hc IS NULL THEN NEW.hc = (SELECT hc FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.imd IS NULL THEN NEW.imd = (SELECT imd FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.y0 IS NULL THEN NEW.y0 = (SELECT y0 FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;
			IF NEW.ysur IS NULL THEN NEW.ysur = (SELECT ysur FROM ve_inp_storage WHERE node_id = NEW.node_id);END IF;

			INSERT INTO inp_dscenario_storage (dscenario_id, node_id, elev, ymax, storage_type, curve_id, a1, a2, a0, fevap, sh, hc, imd, y0, ysur)
			VALUES (NEW.dscenario_id, NEW.node_id, NEW.elev, NEW.ymax, NEW.storage_type, NEW.curve_id, NEW.a1, NEW.a2, NEW.a0,
			NEW.fevap, NEW.sh, NEW.hc, NEW.imd, NEW.y0, NEW.ysur);

	 	ELSIF v_dscenario_type = 'TREATMENT' THEN

			-- default value
			IF NEW.function IS NULL OR NEW.function='' THEN NEW.function = (SELECT function FROM ve_inp_treatment WHERE node_id = NEW.node_id AND poll_id = NEW.poll_id);END IF;

			INSERT INTO inp_dscenario_treatment (dscenario_id, node_id, poll_id, function)
			VALUES (NEW.dscenario_id, NEW.node_id, NEW.poll_id, NEW.function);

		ELSIF v_dscenario_type = 'CONTROLS' THEN

			INSERT INTO inp_dscenario_controls(dscenario_id, sector_id, text, active)
			VALUES (NEW.dscenario_id, NEW.sector_id, NEW.text, NEW.active);

		ELSIF v_dscenario_type = 'INLET' THEN

			-- default values
			IF NEW.elev IS NULL THEN NEW.elev = (SELECT elev FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.ymax IS NULL THEN NEW.ymax = (SELECT ymax FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.y0 IS NULL THEN NEW.y0 = (SELECT y0 FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.ysur IS NULL THEN NEW.ysur = (SELECT ysur FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.apond IS NULL THEN NEW.apond = (SELECT apond FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.inlet_type IS NULL THEN NEW.inlet_type = (SELECT inlet_type FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.outlet_type IS NULL THEN NEW.outlet_type = (SELECT outlet_type FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.gully_method IS NULL THEN NEW.gully_method = (SELECT gully_method FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.custom_top_elev IS NULL THEN NEW.custom_top_elev = (SELECT custom_top_elev FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.custom_depth IS NULL THEN NEW.custom_depth = (SELECT custom_depth FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.inlet_length IS NULL THEN NEW.inlet_length = (SELECT inlet_length FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.inlet_width IS NULL THEN NEW.inlet_width = (SELECT inlet_width FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.cd1 IS NULL THEN NEW.cd1 = (SELECT cd1 FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.cd2 IS NULL THEN NEW.cd2 = (SELECT cd2 FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			IF NEW.efficiency IS NULL THEN NEW.efficiency = (SELECT efficiency FROM ve_inp_inlet WHERE node_id = NEW.node_id);END IF;
			

			INSERT INTO inp_dscenario_inlet (dscenario_id, elev, ymax, node_id, y0, ysur, apond, inlet_type, outlet_type, gully_method, custom_top_elev, custom_depth, inlet_length, inlet_width, cd1, cd2, efficiency)
	 		VALUES (NEW.dscenario_id, NEW.elev, NEW.ymax, NEW.node_id, NEW.y0, NEW.ysur, NEW.apond, NEW.inlet_type, NEW.outlet_type, NEW.gully_method, NEW.custom_top_elev, NEW.custom_depth, NEW.inlet_length, NEW.inlet_width, NEW.cd1, NEW.cd2, NEW.efficiency);

		END IF;

		RETURN NEW;

	ELSIF TG_OP = 'UPDATE' THEN

		IF v_dscenario_type = 'CONDUIT' THEN
			UPDATE inp_dscenario_conduit SET dscenario_id=NEW.dscenario_id, arc_id=NEW.arc_id, arccat_id=NEW.arccat_id,
			matcat_id=NEW.matcat_id, elev1=NEW.elev1, elev2=NEW.elev2, custom_n=NEW.custom_n, barrels=NEW.barrels, culvert=NEW.culvert,
			kentry=NEW.kentry, kexit=NEW.kexit, kavg=NEW.kavg, flap=NEW.flap, q0=NEW.q0, qmax=NEW.qmax, seepage=NEW.seepage
			WHERE dscenario_id=OLD.dscenario_id AND arc_id=OLD.arc_id;

		ELSIF v_dscenario_type = 'FLWREG-ORIFICE' THEN
			UPDATE inp_dscenario_frorifice SET dscenario_id=NEW.dscenario_id, nodarc_id=NEW.nodarc_id,
			ori_type=NEW.ori_type, offsetval=NEW.offsetval, cd=NEW.cd, orate=NEW.orate, flap=NEW.flap, shape=NEW.shape,
			geom1=NEW.geom1, geom2=NEW.geom2, geom3=NEW.geom3, geom4=NEW.geom4
			WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id;

	 	ELSIF v_dscenario_type = 'FLWREG-OUTLET' THEN
			UPDATE inp_dscenario_froutlet SET dscenario_id=NEW.dscenario_id, nodarc_id=NEW.nodarc_id,
			outlet_type=NEW.outlet_type, offsetval=NEW.offsetval, curve_id=NEW.curve_id, cd1=NEW.cd1, cd2=NEW.cd2
			WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id;

	 	ELSIF v_dscenario_type = 'FLWREG-PUMP' THEN
			UPDATE inp_dscenario_frpump SET dscenario_id=NEW.dscenario_id, nodarc_id=NEW.nodarc_id,
			curve_id=NEW.curve_id, status=NEW.status, startup=NEW.startup, shutoff=NEW.shutoff
			WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id;

	 	ELSIF v_dscenario_type = 'FLWREG-WEIR' THEN
			UPDATE inp_dscenario_frweir SET dscenario_id=NEW.dscenario_id, nodarc_id=NEW.nodarc_id, weir_type=NEW.weir_type,
			offsetval=NEW.offsetval, cd=NEW.cd, ec=NEW.ec, cd2=NEW.cd2, flap=NEW.flap, geom1=NEW.geom1, geom2=NEW.geom2, geom3=NEW.geom3,
			geom4=NEW.geom4, surcharge=NEW.surcharge, road_width=NEW.road_width, road_surf=NEW.road_surf, coef_curve=NEW.coef_curve
			WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id;

		ELSIF v_dscenario_type = 'INFLOWS' THEN
			UPDATE inp_dscenario_inflows SET dscenario_id=NEW.dscenario_id, node_id=NEW.node_id, order_id=NEW.order_id, timser_id=NEW.timser_id,
			sfactor=NEW.sfactor, base=NEW.base, pattern_id=NEW.pattern_id
			WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND order_id = OLD.order_id;

	 	ELSIF v_dscenario_type = 'INFLOWS-POLL' THEN
			UPDATE inp_dscenario_inflows_poll SET dscenario_id=NEW.dscenario_id, poll_id=NEW.poll_id,  node_id=NEW.node_id, timser_id=NEW.timser_id,
			form_type=NEW.form_type, mfactor=NEW.mfactor, sfactor=NEW.sfactor, base=NEW.base, pattern_id=NEW.pattern_id
			WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND poll_id = OLD.poll_id;

		ELSIF v_dscenario_type = 'JUNCTION' THEN
			UPDATE inp_dscenario_junction SET dscenario_id=NEW.dscenario_id, node_id=NEW.node_id, elev=NEW.elev, ymax=NEW.ymax,
		 	y0=NEW.y0, ysur=NEW.ysur, apond=NEW.apond, outfallparam=NEW.outfallparam
		 	WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

		 ELSIF v_dscenario_type = 'LIDS' THEN
			UPDATE inp_dscenario_lids SET dscenario_id=NEW.dscenario_id, subc_id=NEW.subc_id, lidco_id=NEW.lidco_id,
			numelem=NEW.numelem, area=NEW.area, width=NEW.width, initsat=NEW.initsat, fromimp=NEW.fromimp, toperv=NEW.toperv, rptfile=NEW.rptfile, descript=NEW.descript
			WHERE dscenario_id = OLD.dscenario_id AND subc_id=OLD.subc_id;

		ELSIF v_dscenario_type = 'OUTFALL' THEN
			UPDATE inp_dscenario_outfall SET dscenario_id=NEW.dscenario_id, node_id=NEW.node_id, elev=NEW.elev, ymax=NEW.ymax, outfall_type=NEW.outfall_type, stage=NEW.stage,
			curve_id=NEW.curve_id, timser_id=NEW.timser_id, gate=NEW.gate
			WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

		ELSIF v_dscenario_type = 'RAINGAGE' THEN
			UPDATE inp_dscenario_raingage SET dscenario_id=NEW.dscenario_id, rg_id=NEW.rg_id, form_type=NEW.form_type, intvl=NEW.intvl,
			scf=NEW.scf, rgage_type=NEW.rgage_type, timser_id=NEW.timser_id, fname=NEW.fname, sta=NEW.sta, units=NEW.units
			WHERE dscenario_id=OLD.dscenario_id AND rg_id=OLD.rg_id;

		ELSIF v_dscenario_type = 'STORAGE' THEN
			UPDATE inp_dscenario_storage SET dscenario_id=NEW.dscenario_id, node_id=NEW.node_id, elev=NEW.elev, ymax=New.ymax, storage_type=NEW.storage_type, curve_id=NEW.curve_id,
			a1=NEW.a1, a2=NEW.a2, a0=NEW.a0, fevap=NEW.fevap, sh=NEW.sh, hc=NEW.hc, imd=NEW.imd, y0=NEW.y0, ysur=NEW.ysur
			WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

	 	ELSIF v_dscenario_type = 'TREATMENT' THEN
			UPDATE inp_dscenario_treatment SET dscenario_id=NEW.dscenario_id, node_id=NEW.node_id, poll_id=NEW.poll_id, function=NEW.function
			WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND poll_id = OLD.poll_id;

		ELSIF v_dscenario_type = 'CONTROLS' THEN
			UPDATE inp_dscenario_controls SET dscenario_id = NEW.dscenario_id, sector_id= NEW.sector_id, text= NEW.text, active=NEW.active
			WHERE id=OLD.id;
		END IF;

		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN

		IF v_dscenario_type = 'CONDUIT' THEN
			DELETE FROM inp_dscenario_conduit WHERE dscenario_id=OLD.dscenario_id AND arc_id=OLD.arc_id;

		ELSIF v_dscenario_type = 'FLWREG-ORIFICE' THEN
			DELETE FROM inp_dscenario_frorifice WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id ;

	 	ELSIF v_dscenario_type = 'FLWREG-OUTLET' THEN
			DELETE FROM inp_dscenario_froutlet WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id ;

	 	ELSIF v_dscenario_type = 'FLWREG-PUMP' THEN
			DELETE FROM inp_dscenario_frpump WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id ;

	 	ELSIF v_dscenario_type = 'FLWREG-WEIR' THEN
			DELETE FROM inp_dscenario_frweir WHERE dscenario_id=OLD.dscenario_id AND nodarc_id=OLD.nodarc_id ;

		ELSIF v_dscenario_type = 'INFLOWS' THEN
			DELETE FROM inp_dscenario_inflows WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND order_id = OLD.order_id;

	 	ELSIF v_dscenario_type = 'INFLOWS-POLL' THEN
			DELETE FROM inp_dscenario_inflows_poll WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND poll_id = OLD.poll_id;

		ELSIF v_dscenario_type = 'JUNCTION' THEN
			DELETE FROM inp_dscenario_junction WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

		ELSIF v_dscenario_type = 'LIDS' THEN
			DELETE FROM inp_dscenario_lids
			WHERE dscenario_id = OLD.dscenario_id AND subc_id=OLD.subc_id AND lidco_id=OLD.lidco_id;

		ELSIF v_dscenario_type = 'OUTFALL' THEN
			DELETE FROM inp_dscenario_outfall WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

		ELSIF v_dscenario_type = 'RAINGAGE' THEN
			DELETE FROM inp_dscenario_raingage WHERE dscenario_id=OLD.dscenario_id AND rg_id=OLD.rg_id;

		ELSIF v_dscenario_type = 'STORAGE' THEN
			DELETE FROM inp_dscenario_storage WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id;

	 	ELSIF v_dscenario_type = 'TREATMENT' THEN
			DELETE FROM inp_dscenario_treatment WHERE dscenario_id=OLD.dscenario_id AND node_id=OLD.node_id AND poll_id = OLD.poll_id;

		ELSIF v_dscenario_type = 'CONTROLS' THEN
			DELETE FROM inp_dscenario_controls WHERE id=OLD.id;

		END IF;

		RETURN OLD;
  END IF;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
