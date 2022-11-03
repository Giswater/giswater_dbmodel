/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2022/09/15
drop view v_om_waterbalance cascade;
CREATE OR REPLACE VIEW v_om_waterbalance AS 
 SELECT e.name AS exploitation,
    d.name AS dma,
    p.code AS period,
    ((COALESCE(om_waterbalance.auth_bill_met_export, 0::double precision) + COALESCE(om_waterbalance.auth_bill_met_hydro, 0::double precision) + COALESCE(om_waterbalance.auth_bill_unmet, 0::double precision))::numeric(12,2))::numeric(12,2) AS auth_bill,
    ((COALESCE(om_waterbalance.auth_unbill_met, 0::double precision) + COALESCE(om_waterbalance.auth_unbill_unmet, 0::double precision))::numeric(12,2))::numeric(12,2) AS auth_unbill,
    (COALESCE(om_waterbalance.loss_app_unath, 0::double precision)+(COALESCE(om_waterbalance.loss_app_met_error, 0::double precision) + COALESCE(om_waterbalance.loss_app_data_error, 0::double precision))::numeric(12,2))::numeric(12,2) AS loss_app,
    ((COALESCE(om_waterbalance.loss_real_leak_main, 0::double precision) + COALESCE(om_waterbalance.loss_real_leak_service, 0::double precision) + COALESCE(om_waterbalance.loss_real_storage, 0::double precision))::numeric(12,2))::numeric(12,2) AS loss_real,
    (COALESCE(om_waterbalance.total_in, 0::double precision))::numeric(12,2) AS total_in,
    (COALESCE(om_waterbalance.total_out, 0::double precision))::numeric(12,2) AS total_out,
    (COALESCE(om_waterbalance.total_sys_input, 0::double precision))::numeric(12,2) AS total,
    p.start_date::date as crm_startdate,
    p.end_date::date as crm_enddate,
    startdate as wbal_startdate,
    enddate as wbal_enddate,
    ili,
    d.the_geom
   FROM om_waterbalance
     JOIN exploitation e USING (expl_id)
     JOIN dma d USING (dma_id)
     JOIN ext_cat_period p ON p.id::text = om_waterbalance.cat_period_id::text;



CREATE OR REPLACE VIEW v_om_waterbalance_efficiency AS
 
 SELECT v_om_waterbalance.exploitation,
    v_om_waterbalance.dma,
    v_om_waterbalance.period,
    crm_startdate,
    crm_enddate,
    wbal_startdate,
    wbal_enddate,
    total_in,
    total_out,
    v_om_waterbalance.total,  
    (v_om_waterbalance.auth_bill + v_om_waterbalance.auth_unbill)::numeric(12,2) AS auth,
    (v_om_waterbalance.total - v_om_waterbalance.auth_bill::double precision - v_om_waterbalance.auth_unbill::double precision)::numeric(12,2) AS loss,
        CASE
            WHEN v_om_waterbalance.total > 0::double precision THEN ((100::numeric * (v_om_waterbalance.auth_bill + v_om_waterbalance.auth_unbill))::double precision / v_om_waterbalance.total)::numeric(12,2)
            ELSE 0::numeric(12,2)
        END AS loss_eff,
    v_om_waterbalance.auth_bill AS rw,
    (v_om_waterbalance.total - v_om_waterbalance.auth_bill::double precision)::numeric(12,2) AS nrw,
        CASE
            WHEN v_om_waterbalance.total > 0::double precision THEN ((100::numeric * v_om_waterbalance.auth_bill)::double precision / v_om_waterbalance.total)::numeric(12,2)
            ELSE 0::numeric(12,2)
        END AS nrw_eff,
        ili,    
        v_om_waterbalance.the_geom
   FROM v_om_waterbalance;
   