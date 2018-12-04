

--DROP CONSTRAINT
ALTER TABLE ws_sample.config_api_form_fields DROP CONSTRAINT config_api_form_fields_pkey2;

ALTER TABLE ws_sample.config_api_visit DROP CONSTRAINT config_api_visit_fkey;
ALTER TABLE ws_sample.config_api_visit DROP CONSTRAINT config_api_visit_formname_key;

ALTER TABLE ws_sample.om_visit_class_x_parameter DROP CONSTRAINT om_visit_class_x_parameter_class_fkey;
ALTER TABLE ws_sample.om_visit_class_x_parameter DROP CONSTRAINT om_visit_class_x_parameter_class_fkey;

ALTER TABLE ws_sample.rpt_selector_compare DROP CONSTRAINT rpt_selector_compare_result_id_cur_user_unique;

ALTER TABLE ws_sample.rpt_selector_hourly_compare DROP CONSTRAINT time_compare_cur_user_unique;

DROP INDEX ws_sample.shortcut_unique;

--ADD CONSTRAINT
ALTER TABLE ws_sample.config_api_form_fields ADD CONSTRAINT config_api_form_fields_pkey2 UNIQUE(formname, formtype, column_id);

ALTER TABLE ws_sample.config_api_visit ADD CONSTRAINT config_api_visit_formname_key UNIQUE(formname);
ALTER TABLE ws_sample.config_api_visit  ADD CONSTRAINT config_api_visit_fkey FOREIGN KEY (visitclass_id) 
REFERENCES ws_sample.om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ws_sample.om_visit_class_x_parameter ADD CONSTRAINT om_visit_class_x_parameter_class_fkey FOREIGN KEY (class_id)
REFERENCES ws_sample.om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ws_sample.om_visit_class_x_parameter ADD CONSTRAINT om_visit_class_x_parameter_class_fkey FOREIGN KEY (class_id) 
REFERENCES ws_sample.om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ws_sample.rpt_selector_compare ADD CONSTRAINT rpt_selector_compare_result_id_cur_user_unique UNIQUE(result_id, cur_user);

ALTER TABLE ws_sample.rpt_selector_hourly_compare ADD CONSTRAINT time_compare_cur_user_unique UNIQUE("time", cur_user);

CREATE UNIQUE INDEX shortcut_unique ON ws_sample.cat_feature USING btree (shortcut_key COLLATE pg_catalog."default");

/*

    CONSTRAINT inp_typevalue_id_unique UNIQUE (id),
  CONSTRAINT inp_typevalue_check CHECK (typevalue::text = 'inp_value_curve'::text AND (id::text = ANY (ARRAY['EFFICIENCY'::character varying::text, 'HEADLOSS'::character varying::text, 'PUMP'::character varying::text, 'VOLUME'::character varying::text])) OR typevalue::text = 'inp_value_yesno'::text AND (id::text = ANY (ARRAY['NO'::character varying::text, 'YES'::character varying::text])) OR typevalue::text = 'inp_typevalue_energy'::text AND (id::text = ANY (ARRAY['DEMAND CHARGE'::character varying::text, 'GLOBAL'::character varying::text])) OR typevalue::text = 'inp_typevalue_pump'::text AND (id::text = ANY (ARRAY['HEAD_PUMP'::character varying::text, 'PATTERN_PUMP'::character varying::text, 'POWER_PUMP'::character varying::text, 'SPEED_PUMP'::character varying::text])) OR typevalue::text = 'inp_typevalue_reactions_gl'::text AND (id::text = ANY (ARRAY['GLOBAL_GL'::character varying::text, 'LIMITING POTENTIAL'::character varying::text, 'ORDER'::character varying::text, 'ROUGHNESS CORRELATION'::character varying::text])) OR typevalue::text = 'inp_typevalue_source'::text AND (id::text = ANY (ARRAY['CONCEN'::character varying::text, 'FLOWPACED'::character varying::text, 'MASS'::character varying::text, 'SETPOINT'::character varying::text])) OR typevalue::text = 'inp_value_ampm'::text AND (id::text = ANY (ARRAY['AM'::character varying::text, 'PM'::character varying::text])) OR typevalue::text = 'inp_value_mixing'::text AND (id::text = ANY (ARRAY['2COMP'::character varying::text, 'FIFO'::character varying::text, 'LIFO'::character varying::text, 'MIXED'::character varying::text])) OR typevalue::text = 'inp_value_noneall'::text AND (id::text = ANY (ARRAY['ALL'::character varying::text, 'NONE'::character varying::text])) OR typevalue::text = 'inp_value_opti_headloss'::text AND (id::text = ANY (ARRAY['C-M'::character varying::text, 'D-W'::character varying::text, 'H-W'::character varying::text])) OR typevalue::text = 'inp_value_opti_hyd'::text AND (id::text = ANY (ARRAY[' '::character varying::text, 'SAVE'::character varying::text, 'USE'::character varying::text])) OR typevalue::text = 'inp_value_opti_qual'::text AND (id::text = ANY (ARRAY['AGE'::character varying::text, 'CHEMICAL mg/L'::character varying::text, 'CHEMICAL ug/L'::character varying::text, 'NONE_QUAL'::character varying::text, 'TRACE'::character varying::text])) OR typevalue::text = 'inp_value_opti_rtc_coef'::text AND (id::text = ANY (ARRAY['AVG'::character varying::text, 'MAX'::character varying::text, 'MIN'::character varying::text, 'REAL'::character varying::text])) OR typevalue::text = 'inp_value_opti_unbal'::text AND (id::text = ANY (ARRAY['CONTINUE'::character varying::text, 'STOP'::character varying::text])) OR typevalue::text = 'inp_value_opti_units'::text AND (id::text = ANY (ARRAY['AFD'::character varying::text, 'CMD'::character varying::text, 'CMH'::character varying::text, 'GPM'::character varying::text, 'IMGD'::character varying::text, 'LPM'::character varying::text, 'LPS'::character varying::text, 'MGD'::character varying::text, 'MLD'::character varying::text])) OR typevalue::text = 'inp_value_opti_valvemode'::text AND (id::text = ANY (ARRAY['EPA TABLES'::character varying::text, 'INVENTORY VALUES'::character varying::text, 'MINCUT RESULTS'::character varying::text])) OR typevalue::text = 'inp_value_param_energy'::text AND (id::text = ANY (ARRAY['EFFIC'::character varying::text, 'PATTERN'::character varying::text, 'PRICE'::character varying::text])) OR typevalue::text = 'inp_value_reactions_el'::text AND (id::text = ANY (ARRAY['BULK_EL'::character varying::text, 'TANK_EL'::character varying::text, 'WALL_EL'::character varying::text])) OR typevalue::text = 'inp_value_reactions_gl'::text AND (id::text = ANY (ARRAY['BULK_GL'::character varying::text, 'TANK_GL'::character varying::text, 'WALL_GL'::character varying::text])) OR typevalue::text = 'inp_value_status_pipe'::text AND (id::text = ANY (ARRAY['CLOSED_PIPE'::character varying::text, 'CV_PIPE'::character varying::text, 'OPEN_PIPE'::character varying::text])) OR typevalue::text = 'inp_value_status_pump'::text AND (id::text = ANY (ARRAY['CLOSED_PUMP'::character varying::text, 'OPEN_PUMP'::character varying::text])) OR typevalue::text = 'inp_value_status_valve'::text AND (id::text = ANY (ARRAY['ACTIVE_VALVE'::character varying::text, 'CLOSED_VALVE'::character varying::text, 'OPEN_VALVE'::character varying::text])) OR typevalue::text = 'inp_value_times'::text AND (id::text = ANY (ARRAY['AVERAGED'::character varying::text, 'MAXIMUM'::character varying::text, 'MINIMUM'::character varying::text, 'NONE_TIMES'::character varying::text, 'RANGE'::character varying::text])) OR typevalue::text = 'inp_value_yesnofull'::text AND (id::text = ANY (ARRAY['FULL_YNF'::character varying::text, 'NO_YNF'::character varying::text, 'YES_YNF'::character varying::text])) OR typevalue::text = 'inp_typevalue_valve'::text AND (id::text = ANY (ARRAY['FCV'::character varying::text, 'GPV'::character varying::text, 'PBV'::character varying::text, 'PRV'::character varying::text, 'PSV'::character varying::text, 'TCV'::character varying::text])))
)

   CONSTRAINT audit_cat_table_x_column_sys_role_id_fkey FOREIGN KEY (sys_role_id)
      REFERENCES ws_sample.sys_role (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT audit_cat_table_x_column_table_id_fkey FOREIGN KEY (table_id)
      REFERENCES ws_sample.audit_cat_table (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT table_id_column_id_unique UNIQUE (table_id, column_id)
*/
