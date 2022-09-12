/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1116

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_edit_link()
  RETURNS trigger AS
$BODY$

/*
There are three class of links:
		- 1: operative (createds in automatic or manual way)
		- 2: Single psector links when endfeature is not VNODE (lets say NODES, CONNECS & GULLIES). 
		     Only one psector is enabled to work with. Created automaticly as class-3 by trg_plan_psector_link and moved after as class-2
		- 3: Multi psector links when endfeature is VNODE (let say ARCS) created automaticly by trg_plan_psector_link as class-3

There are three diferent workflows to create and manage links:

- gw_fct_setlinktonetwork function that creates link as automatic way, works only with links class 1.

- gw_fct_setarcfusion & gw_fct_setarcdivide functions that updates values of related connect using the spatial intersection of existing link and works with links class 1,3

- trg_edit_link to create custom links (only class-1) and to update automatic links (class-1, 2 or 3).
  In addition, workflow for this function is complex managing with planned network elements. Works with links class 1,2,3 and acts in combination with:

	- trg_plan_psector_link, This trigger CREATES the initial geometry of planned link (always forced for planned connects) creating always as class-3. Also UPDATES the link
      and vnode geometry on the psector tables if link is class-3. In additaionn works in combination with arc_id (to relate arc_id endfeature)
	
	- control for link class, keeping for the rules of links class-2 and class-3
	- trg_plan_psector_x_connec: This trigger controls if connect has link and wich class of link it has
	- trg_plan_psector_x_gully: This trigger controls if connect has link and wich class of link it has
	
	Redraw links when endfeature geometry is updated:
	- trg_connect_update: This trigger updates mapzone connect columns (if endpoint of link is another connec or gully) 
	  and redraws link geometry if also its geometry is updated. Works with 1,2 class links
	- trg_topocontrol_node: It updates geometry links if the geometry of node is updated. It updates arc_id of connect if this changes
	- trg_arc_vnodelink_update: This function redraws links when arc geometry is updated
	
To create new link only with this tool only is possible with operative connects. When a planned connects is created automatic his link is also created.
After that the trg_edit_link can update geometry and enpoint. By updating endpoint maybe link may change class for 3 to 2 or viceversa	

*/

DECLARE 
v_mantable varchar;
v_projectype varchar;
v_arc record;
v_connect record;
v_node record;
v_connec1 record;
v_gully1 record;
v_connec2 record;
v_gully2 record;
v_vnode record;
v_end_point public.geometry;
v_link_searchbuffer double precision;
v_count integer;
v_node_id integer;
v_arc_id text;
v_userdefined_geom boolean;
v_end_state integer;
v_autoupdate_dma boolean;
v_pjoint_id text;
v_pjoint_type text;
v_expl_id integer;
v_dsbl_error boolean;
v_message text;
v_ispresszone boolean;

BEGIN

	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	v_mantable:= TG_ARGV[0];
	
	v_link_searchbuffer=0.1; 	
	
	-- getting system values
	SELECT value::boolean INTO v_autoupdate_dma FROM config_param_system WHERE parameter='edit_connect_autoupdate_dma';
	SELECT value::boolean INTO v_dsbl_error FROM config_param_system WHERE parameter='edit_topocontrol_disable_error' ;
	SELECT project_type INTO v_projectype FROM sys_version LIMIT 1;
	v_ispresszone:= (SELECT value::json->>'PRESSZONE' FROM config_param_system WHERE parameter = 'utils_graphanalytics_status');

	-- Control insertions ID
	IF TG_OP = 'INSERT' THEN
     
		-- link ID
		IF (NEW.link_id IS NULL) THEN
			NEW.link_id:= (SELECT nextval('link_link_id_seq'));
		END IF;	

		-- State control of element
		IF (NEW.state IS NULL) THEN
			NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='edit_state_vdefault' AND "cur_user"="current_user"());
			IF (NEW.state IS NULL) THEN
				NEW.state := 1;
			END IF;
		END IF;
	
	END IF;	
        
	-- topology control
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN

		-- temporary disable linktonetwork
		UPDATE config_param_user SET value='TRUE' WHERE parameter = 'edit_connec_disable_linktonetwork' AND cur_user = current_user;

		-- control of relationship with connec / gully
		SELECT * INTO v_connect FROM connec WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), connec.the_geom, v_link_searchbuffer) 
		ORDER BY CASE WHEN state=1 THEN 1 WHEN state=2 THEN 2 WHEN state=0 THEN 3 END, st_distance(ST_StartPoint(NEW.the_geom), connec.the_geom) LIMIT 1;
		
		IF v_projectype = 'UD' AND v_connect.connec_id IS NULL THEN
			SELECT * INTO v_connect FROM gully WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), gully.the_geom, v_link_searchbuffer) 
			ORDER BY CASE WHEN state=1 THEN 1 WHEN state=2 THEN 2 WHEN state=0 THEN 3 END, st_distance(ST_StartPoint(NEW.the_geom), gully.the_geom) LIMIT 1;
		END IF;

		IF v_connect IS NULL THEN

			NEW.the_geom = ST_reverse (NEW.the_geom);

			-- check control again
			SELECT * INTO v_connect FROM connec WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), connec.the_geom, v_link_searchbuffer) 
			ORDER BY CASE WHEN state=1 THEN 1 WHEN state=2 THEN 2 WHEN state=0 THEN 3 END, st_distance(ST_StartPoint(NEW.the_geom), connec.the_geom) LIMIT 1;
		
			IF v_projectype = 'UD' THEN
				SELECT * INTO v_connect FROM gully WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), gully.the_geom, v_link_searchbuffer) 
				ORDER BY CASE WHEN state=1 THEN 1 WHEN state=2 THEN 2 WHEN state=0 THEN 3 END, st_distance(ST_StartPoint(NEW.the_geom), gully.the_geom) LIMIT 1;
			END IF;
			
			IF v_connect IS NULL THEN
				IF v_dsbl_error IS NOT TRUE THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"3070", "function":"1116","debug_msg":null}}$$);';
				ELSE
					SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3070;
					INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
				END IF;
			END IF;		
		END IF;

		-- arc as end point
		SELECT * INTO v_arc FROM v_edit_arc WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_arc.the_geom, v_link_searchbuffer) AND state>0
		ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_arc.the_geom) LIMIT 1;
		
		-- node as end point
		SELECT * INTO v_node FROM v_edit_node WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_node.the_geom, v_link_searchbuffer) AND state>0
		ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_node.the_geom) LIMIT 1;
		
		
		-- for ws projects control of link related to nodarc
		IF v_projectype = 'WS' AND v_node IS NOT NULL THEN
			IF v_node.node_id IN (SELECT node_id FROM inp_valve UNION SELECT node_id FROM inp_pump) THEN
				IF v_dsbl_error IS NOT TRUE THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"3072", "function":"1116","debug_msg":null}}$$);';
				ELSE
					SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3072;
					INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
				END IF;		
			END IF;
		END IF;
		
		-- connec as init point
		SELECT * INTO v_connec1 FROM v_edit_connec WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), v_edit_connec.the_geom,v_link_searchbuffer) AND state>0 
		ORDER by st_distance(ST_StartPoint(NEW.the_geom), v_edit_connec.the_geom) LIMIT 1;

		-- connec as end point
		SELECT * INTO v_connec2 FROM v_edit_connec WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_connec.the_geom,v_link_searchbuffer) AND state>0 AND connec_id != v_connec1.connec_id
		ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_connec.the_geom) LIMIT 1;

			IF v_projectype='UD' then
		
				--gully as init point
				SELECT * INTO v_gully1 FROM v_edit_gully WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), v_edit_gully.the_geom,v_link_searchbuffer) 
				AND state>0 ORDER by st_distance(ST_StartPoint(NEW.the_geom), v_edit_gully.the_geom) LIMIT 1;

				--gully as end point
				SELECT * INTO v_gully2 FROM v_edit_gully WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_gully.the_geom,v_link_searchbuffer) 
				AND state>0 AND gully_id != v_gully1.gully_id ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_gully.the_geom) LIMIT 1;
	
				IF v_gully1.gully_id IS NOT NULL THEN
					NEW.feature_id=v_gully1.gully_id;
					NEW.feature_type='GULLY';
				END IF;
			END IF;
				
		IF v_connec1.connec_id IS NOT NULL THEN
			NEW.feature_id=v_connec1.connec_id;
			NEW.feature_type='CONNEC';
		END IF;

		--look for obsolete features if init point not found
		IF NEW.feature_type IS NULL THEN
			INSERT INTO selector_state VALUES (0, current_user) ON CONFLICT (state_id, cur_user) DO NOTHING;

			SELECT * INTO v_connec1 FROM connec WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), connec.the_geom,v_link_searchbuffer) AND state=0 
			ORDER by st_distance(ST_StartPoint(NEW.the_geom), connec.the_geom) LIMIT 1;

			IF v_projectype='UD' then
				SELECT * INTO v_gully1 FROM v_edit_gully WHERE ST_DWithin(ST_StartPoint(NEW.the_geom), v_edit_gully.the_geom,v_link_searchbuffer) 
				AND state=0 ORDER by st_distance(ST_StartPoint(NEW.the_geom), v_edit_gully.the_geom) LIMIT 1;
				IF v_gully1.gully_id IS NOT NULL THEN
					NEW.feature_id=v_gully1.gully_id;
					NEW.feature_type='GULLY';
					NEW.state = 0;
				END IF;
			END IF;
			IF v_connec1.connec_id IS NOT NULL THEN
				NEW.feature_id=v_connec1.connec_id;
				NEW.feature_type='CONNEC';
				NEW.state = 0;
			END IF;
		END IF;

		-- feature control
		IF NEW.feature_type IS NULL THEN
			IF v_dsbl_error IS NOT TRUE THEN
				EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
				"data":{"message":"3074", "function":"1116","debug_msg":null}}$$);';
			ELSE
				SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3074;
				INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
			END IF;
		END IF;	
		--for links related to state 0  features look again for final feature if its null
		IF NEW.state = 0 THEN
			INSERT INTO selector_state VALUES (0, current_user) ON CONFLICT (state_id, cur_user) DO NOTHING;

			IF v_arc IS NULL THEN 
				-- arc as end point
				SELECT * INTO v_arc FROM v_edit_arc WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_arc.the_geom, v_link_searchbuffer) AND state=0
				ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_arc.the_geom) LIMIT 1;
			END IF;
			IF v_node IS NULL THEN 
				-- node as end point
				SELECT * INTO v_node FROM v_edit_node WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_node.the_geom, v_link_searchbuffer) AND state=0
				ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_node.the_geom) LIMIT 1;
			END IF;
			IF v_connec2 IS NULL THEN 
			-- connec as end point
				SELECT * INTO v_connec2 FROM v_edit_connec WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_connec.the_geom,v_link_searchbuffer) AND state=0
				ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_connec.the_geom) LIMIT 1;
			END IF;
			IF v_projectype='UD' THEN 
				IF v_gully2 IS NULL THEN
					--gully as end point
					SELECT * INTO v_gully2 FROM v_edit_gully WHERE ST_DWithin(ST_EndPoint(NEW.the_geom), v_edit_gully.the_geom,v_link_searchbuffer) AND state=0 
					ORDER by st_distance(ST_EndPoint(NEW.the_geom), v_edit_gully.the_geom) LIMIT 1;
				END IF;
			END IF;
		END IF;

		-- end control
		IF ( v_arc.arc_id IS NOT NULL AND v_node.node_id IS NULL) THEN
		
			-- end point of link geometry
			v_end_point = (ST_ClosestPoint(v_arc.the_geom, ST_EndPoint(NEW.the_geom)));
			v_end_state= v_arc.state;
			
			-- vnode
			SELECT * INTO v_vnode FROM vnode WHERE ST_DWithin(v_end_point, vnode.the_geom, 0.01) LIMIT 1;
				
			IF v_vnode.vnode_id IS NULL THEN -- there is no vnode on the new position

				v_node_id = (select vnode_id FROM vnode WHERE vnode_id::text = NEW.exit_id AND NEW.exit_type='VNODE');

				IF v_node_id IS NULL THEN -- there is no vnode existing linked				
					INSERT INTO vnode (state, the_geom) 
					VALUES (v_arc.state, v_end_point) RETURNING vnode_id INTO v_node_id;			
				END IF;
			ELSE
				v_end_point = v_vnode.the_geom;
				v_node_id = v_vnode.vnode_id;
			END IF;
			
			--update connec or plan_psector_x_connec.arc_id
			IF NEW.link_class < 3 THEN
				IF v_autoupdate_dma IS FALSE THEN
					UPDATE v_edit_connec SET arc_id=v_arc.arc_id,  
					expl_id=v_arc.expl_id, sector_id=v_arc.sector_id, pjoint_type='VNODE', pjoint_id=v_node_id
					WHERE connec_id=v_connec1.connec_id;
				ELSE
					UPDATE v_edit_connec SET arc_id=v_arc.arc_id, 
					expl_id=v_arc.expl_id, dma_id=v_arc.dma_id, sector_id=v_arc.sector_id, pjoint_type='VNODE', pjoint_id=v_node_id
					WHERE connec_id=v_connec1.connec_id;
				END IF;
					
			ELSIF NEW.link_class < 3 THEN
				UPDATE plan_psector_x_connec SET arc_id=v_arc.arc_id WHERE plan_psector_x_connec.id=NEW.psector_rowid;
			END IF;

			-- specific updates for projectype
			IF v_projectype='UD' THEN
			
				--update gully or plan_psector_x_gully.arc_id
				IF NEW.link_class < 3 THEN
					IF v_autoupdate_dma IS FALSE THEN
						UPDATE v_edit_gully SET arc_id=v_arc.arc_id, 
						expl_id=v_arc.expl_id, sector_id=v_arc.sector_id, pjoint_type='VNODE', pjoint_id=v_node_id
						WHERE gully_id=v_gully1.gully_id;
					ELSE
						UPDATE v_edit_gully SET arc_id=v_arc.arc_id, 
						expl_id=v_arc.expl_id, dma_id=v_arc.dma_id, sector_id=v_arc.sector_id, pjoint_type='VNODE', pjoint_id=v_node_id
						WHERE gully_id=v_gully1.gully_id;
					END IF;

				ELSIF NEW.link_class < 3 THEN
					UPDATE plan_psector_x_gully SET arc_id=v_arc.arc_id WHERE plan_psector_x_gully.id=NEW.psector_rowid;
				END IF;
				
			ELSIF v_projectype='WS' AND NEW.link_class < 3 THEN
				UPDATE connec SET presszone_id = v_arc.presszone_id, dqa_id=v_arc.dqa_id, minsector_id=v_arc.minsector_id
				WHERE connec_id=v_connec1.connec_id;
				
				IF v_ispresszone THEN
					UPDATE connec SET staticpressure = ((SELECT head from presszone WHERE presszone_id = v_arc.presszone_id)- v_connec1.elevation) WHERE connec_id=v_connec1.connec_id;
				END IF;
			END IF;
		
			NEW.exit_type='VNODE';
			NEW.exit_id=v_node_id;
			v_pjoint_id = v_node_id;
			v_pjoint_type = 'VNODE';
			v_end_state= (SELECT state FROM arc WHERE arc_id = v_arc.arc_id);
			v_expl_id = v_arc.expl_id;
			v_arc_id = v_arc.arc_id;

		ELSIF v_node.node_id IS NOT NULL THEN
	
			-- get arc values
			SELECT * INTO v_arc FROM arc WHERE node_1=v_node.node_id LIMIT 1;
			
			-- in case of null values for arc_id (i.e. node sink where there are only entry arcs)
			IF v_arc.arc_id IS NULL THEN
				SELECT * INTO v_arc FROM arc WHERE node_2=v_node.node_id LIMIT 1;
			END IF;

			--update connec or plan_psector_x_connec.arc_id
			IF NEW.link_class < 3 THEN
				IF v_autoupdate_dma IS FALSE THEN
					UPDATE v_edit_connec SET arc_id=v_arc.arc_id,
					expl_id=v_node.expl_id, sector_id=v_node.sector_id, pjoint_type='NODE', pjoint_id=v_node.node_id
					WHERE connec_id=v_connec1.connec_id;
				ELSE
					UPDATE v_edit_connec SET arc_id=v_arc.arc_id, 
					expl_id=v_node.expl_id, dma_id=v_node.dma_id, sector_id=v_node.sector_id, pjoint_type='NODE', pjoint_id=v_node.node_id
					WHERE connec_id=v_connec1.connec_id;
				END IF;
			END IF;
			
			-- specific updates for projectype
			IF v_projectype='UD' THEN
			
				--update gully or plan_psector_x_gully.arc_id
				IF NEW.link_class < 3 THEN
					IF v_autoupdate_dma IS FALSE THEN
						UPDATE v_edit_gully SET arc_id=v_arc.arc_id, 
						expl_id=v_node.expl_id, sector_id=v_node.sector_id, pjoint_type='NODE', pjoint_id=v_node.node_id
						WHERE gully_id=v_gully1.gully_id;
					ELSE
						UPDATE v_edit_gully SET arc_id=v_arc.arc_id,
						expl_id=v_node.expl_id, dma_id=v_node.dma_id, sector_id=v_node.sector_id, pjoint_type='NODE', pjoint_id=v_node.node_id
						WHERE gully_id=v_gully1.gully_id;

					END IF;
				END IF;
									
			ELSIF v_projectype='WS' AND NEW.link_class < 3 THEN
				UPDATE connec SET presszone_id = v_arc.presszone_id, dqa_id=v_arc.dqa_id, minsector_id=v_arc.minsector_id
				WHERE connec_id=v_connec1.connec_id;

				IF v_ispresszone THEN
					UPDATE connec SET staticpressure = ((SELECT head from presszone WHERE presszone_id = v_arc.presszone_id)- v_connec1.elevation) WHERE connec_id=v_connec1.connec_id;
				END IF;
			END IF;
				
			NEW.exit_type='NODE';
			NEW.exit_id=v_node.node_id;
			v_end_point = v_node.the_geom;
			v_end_state= v_node.state;
			v_pjoint_id = v_node.node_id;
			v_pjoint_type = 'NODE';
			v_arc_id = (SELECT arc_id FROM arc WHERE state > 0 AND node_1 = v_node.node_id LIMIT 1);
			IF v_arc_id IS NULL AND NEW.state=0 THEN
				v_arc_id = (SELECT arc_id FROM arc WHERE state = 0 AND node_1 = v_node.node_id LIMIT 1);
			END IF;
			v_expl_id = v_node.expl_id;

		
		ELSIF v_connec2.connec_id IS NOT NULL THEN

			--update connec or plan_psector_x_connec.arc_id
			IF NEW.link_class < 3 THEN
				IF v_autoupdate_dma IS FALSE THEN
					UPDATE v_edit_connec SET arc_id=v_connec2.arc_id, expl_id=v_connec2.expl_id,
					sector_id=v_connec2.sector_id, pjoint_type=v_connec2.pjoint_type, pjoint_id=v_connec2.pjoint_id
					WHERE connec_id=v_connec1.connec_id;
				ELSE
					UPDATE v_edit_connec SET arc_id=v_connec2.arc_id, expl_id=v_connec2.expl_id, dma_id=v_connec2.dma_id, 
					sector_id=v_connec2.sector_id, pjoint_type=v_connec2.pjoint_type, pjoint_id=v_connec2.pjoint_id
					WHERE connec_id=v_connec1.connec_id;

				END IF;
			END IF;
				
			-- specific updates for projectype
			IF v_projectype='UD' THEN
			
				--update gully or plan_psector_x_gully.arc_id
				IF NEW.link_class < 3 THEN
					IF v_autoupdate_dma IS FALSE THEN
						UPDATE v_edit_gully SET arc_id=v_connec2.arc_id, expl_id=v_connec2.expl_id,
						sector_id=v_connec2.sector_id, pjoint_type=v_connec2.pjoint_type, pjoint_id=v_connec2.pjoint_id
						WHERE gully_id=v_gully1.gully_id;
					ELSE
						UPDATE v_edit_gully SET arc_id=v_connec2.arc_id, expl_id=v_connec2.expl_id, dma_id=v_connec2.dma_id, 
						sector_id=v_connec2.sector_id, pjoint_type=v_connec2.pjoint_type, pjoint_id=v_connec2.pjoint_id
						WHERE gully_id=v_gully1.gully_id;

					END IF;
				END IF;
		
			ELSIF v_projectype='WS' AND  NEW.link_class < 3 THEN
				UPDATE connec SET presszone_id = v_connec2.presszone_id, dqa_id=v_connec2.dqa_id, minsector_id=v_connec2.minsector_id
				WHERE connec_id=v_connec1.connec_id;
		
				IF v_ispresszone THEN
					UPDATE connec SET staticpressure = ((SELECT head from presszone WHERE presszone_id = v_connec2.presszone_id)- v_connec1.elevation) WHERE connec_id=v_connec1.connec_id;
				END IF;	
			END IF;
		
			NEW.exit_type='CONNEC';
			NEW.exit_id=v_connec2.connec_id;
			v_end_point = v_connec2.the_geom;
			v_end_state= v_connec2.state;
			v_pjoint_id = v_connec2.pjoint_id;
			v_pjoint_type = v_connec2.pjoint_type;
			v_arc_id =  v_connec2.arc_id;
			v_expl_id = v_connec2.expl_id;

		END IF;
		
		IF v_projectype='UD' THEN
			IF v_gully2.gully_id IS NOT NULL THEN

				--update gully or plan_psector_x_gully.arc_id
				IF NEW.link_class < 3 THEN
					IF v_autoupdate_dma IS FALSE THEN
						UPDATE v_edit_gully SET arc_id=v_gully2.arc_id, expl_id=v_gully2.expl_id, 
						sector_id=v_gully2.sector_id, pjoint_type=v_gully2.pjoint_type, pjoint_id=v_gully2.pjoint_id
						WHERE gully_id=v_gully1.gully_id;
						
						UPDATE v_edit_connec SET arc_id=v_gully2.arc_id, expl_id=v_gully2.expl_id, 
						sector_id=v_gully2.sector_id, pjoint_type=v_gully2.pjoint_type, pjoint_id=v_gully2.pjoint_id
						WHERE connec_id=v_connec1.connec_id;
					ELSE
						UPDATE v_edit_gully SET arc_id=v_gully2.arc_id, expl_id=v_gully2.expl_id,  dma_id=v_gully2.dma_id, 
						sector_id=v_gully2.sector_id, pjoint_type=v_gully2.pjoint_type, pjoint_id=v_gully2.pjoint_id
						WHERE gully_id=v_gully1.gully_id;
						
						UPDATE v_edit_connec SET arc_id=v_gully2.arc_id, expl_id=v_gully2.expl_id,  dma_id=v_gully2.dma_id, 
						sector_id=v_gully2.sector_id, pjoint_type=v_gully2.pjoint_type, pjoint_id=v_gully2.pjoint_id
						WHERE connec_id=v_connec1.connec_id;
					END IF;
				END IF;
							
				NEW.exit_type='GULLY';
				NEW.exit_id=v_gully2.gully_id;
				v_end_point = v_gully2.the_geom;
				v_end_state = v_gully2.state;
				v_pjoint_id = v_gully2.pjoint_id;
				v_pjoint_type = v_gully2.pjoint_type;
				v_arc_id =  v_gully2.arc_id;
				v_expl_id = v_gully2.expl_id;

			END IF;
		END IF;
		
		-- control of null exit_type
		IF v_end_point IS NULL THEN
			IF v_dsbl_error IS NOT TRUE THEN
				EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
				"data":{"message":"2015", "function":"1116","debug_msg":null}}$$);';
			ELSE
				SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 2015;
				INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
			END IF;
		END IF;

		-- psector control (only possible link with feature state=2 on connec/gully 2 on same psector
		IF v_connect.state=2 AND v_end_state=2 THEN
			IF v_projectype = 'WS' THEN
				IF (SELECT psector_id FROM plan_psector_x_connec WHERE connec_id = NEW.exit_id) NOT IN 	
				   (SELECT psector_id FROM plan_psector_x_connec WHERE connec_id = v_connect.connec_id) THEN
				END IF;
			ELSIF v_projectype = 'UD' THEN
				IF NEW.feature_type = 'CONNEC' THEN
					IF (SELECT psector_id FROM plan_psector_x_connec WHERE connec_id = NEW.exit_id
					    UNION SELECT psector_id FROM plan_psector_x_gully WHERE gully_id = NEW.exit_id) NOT IN 	
					   (SELECT psector_id FROM plan_psector_x_connec WHERE connec_id = v_connect.connec_id) THEN
						IF v_dsbl_error IS NOT TRUE THEN
							EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
							"data":{"message":"3178", "function":"1116","debug_msg":null}}$$);';
						ELSE
							SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3178;
							INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
						END IF;				   
					END IF;
				ELSIF NEW.feature_type = 'GULLY' THEN
					IF (SELECT psector_id FROM plan_psector_x_connec WHERE connec_id = NEW.exit_id
					    UNION SELECT psector_id FROM plan_psector_x_gully WHERE gully_id = NEW.exit_id) NOT IN 	
					   (SELECT psector_id FROM plan_psector_x_gully WHERE gully_id = v_connect.gully_id) THEN
						IF v_dsbl_error IS NOT TRUE THEN
							EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
							"data":{"message":"3178", "function":"1116","debug_msg":null}}$$);';
						ELSE
							SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3178;
							INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
						END IF;
					END IF;
				END IF;
			END IF;			
		END IF;
		
		-- upsert link
		NEW.the_geom = (ST_SetPoint(NEW.the_geom, (ST_NumPoints(NEW.the_geom)-1), v_end_point));

		-- check exit type control 
		IF NEW.exit_type != 'VNODE' AND NEW.link_class > 1 THEN-- pjoint_id, pjoint,type, exit_id, exit_type, arc_id must be used one time -> it is possible to planify with only one psector (the only one alternative scenario)

			IF NEW.feature_type =  'CONNEC' THEN
				SELECT count(*) INTO v_count FROM plan_psector_x_connec WHERE connec_id = NEW.feature_id;
			ELSIF NEW.feature_type =  'GULLY' THEN
				SELECT count(*) INTO v_count FROM plan_psector_x_gully WHERE gully_id = NEW.feature_id;
			END IF;

			IF v_count > 1 THEN

				IF v_dsbl_error IS NOT TRUE THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"3082", "function":"1116","debug_msg":null}}$$);';
				ELSE
					SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3082;
					INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
				END IF;
			END IF;
		END IF;		
	END IF;
	
	-- upsert process	
	IF TG_OP ='INSERT' THEN

		-- exception control. It's no possible to create another link when already exists for the connect
		IF (SELECT feature_id FROM link WHERE feature_id=NEW.feature_id AND state > 0 LIMIT 1) IS NOT NULL THEN
			IF NEW.feature_type = 'CONNEC' THEN
				IF v_dsbl_error IS NOT TRUE THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"3076", "function":"1116","debug_msg":""}}$$);';
				ELSE
					SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3076;
					INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
				END IF;
		
			ELSIF NEW.feature_type = 'GULLY' THEN
				IF v_dsbl_error IS NOT TRUE THEN
					EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":4, "infoType":1, "lang":"ES"},"feature":{},
					"data":{"message":"3078", "function":"1116","debug_msg":""}}$$);';
				ELSE
					SELECT concat('ERROR-',id,':',error_message,'.',hint_message) INTO v_message FROM sys_message WHERE id = 3078;
					INSERT INTO audit_log_data (fid, feature_id, log_message) VALUES (394, NEW.link_id, v_message);
				END IF;
			END IF;		
		END IF;

		-- profilactic control in order to do not crash the mandatory column of expl_id
		IF v_expl_id is null then v_expl_id = NEW.expl_id; END IF;

		INSERT INTO link (link_id, feature_type, feature_id, expl_id, exit_id, exit_type, userdefined_geom, 
		state, the_geom, vnode_topelev)
		VALUES (NEW.link_id, NEW.feature_type, NEW.feature_id, v_expl_id, NEW.exit_id, NEW.exit_type, TRUE,
		NEW.state, NEW.the_geom, NEW.vnode_topelev );

		-- update feature 
		IF NEW.feature_type='CONNEC' THEN
			UPDATE v_edit_connec SET arc_id = v_arc_id, pjoint_id = v_pjoint_id, pjoint_type = v_pjoint_type WHERE connec_id = NEW.feature_id;
		ELSIF NEW.feature_type='GULLY' THEN
			UPDATE v_edit_gully SET arc_id = v_arc_id, pjoint_id = v_pjoint_id, pjoint_type = v_pjoint_type WHERE gully_id = NEW.feature_id;
		END IF;
		
		RETURN NEW;

		-- enable linktonetwork
		UPDATE config_param_user SET value='FALSE' WHERE parameter = 'edit_connec_disable_linktonetwork' AND cur_user = current_user;
		
	ELSIF TG_OP = 'UPDATE' THEN 
				
		IF NEW.link_class = 1 THEN -- if geometry comes from link table

			IF st_equals (OLD.the_geom, NEW.the_geom) IS FALSE THEN
				UPDATE link SET userdefined_geom='TRUE', exit_id = NEW.exit_id , exit_type = NEW.exit_type, 
				the_geom=NEW.the_geom, vnode_topelev = NEW.vnode_topelev WHERE link_id=NEW.link_id;
				UPDATE vnode SET the_geom=St_endpoint(NEW.the_geom) WHERE vnode_id=NEW.exit_id::integer;
			END IF;

			UPDATE link SET state = NEW.state WHERE link_id=NEW.link_id;

			-- force reconnection 
			IF NEW.feature_type = 'CONNEC' THEN
				IF NEW.exit_type ='VNODE' THEN -- link_class = 3
					UPDATE connec SET pjoint_type = 'VNODE', pjoint_id = NEW.exit_id WHERE connec_id = NEW.feature_id;
				ELSIF NEW.exit_type ='NODE' THEN
					UPDATE connec SET pjoint_type = 'NODE', pjoint_id = NEW.exit_id WHERE connec_id = NEW.feature_id;
				END IF;
				
			ELSIF NEW.feature_type = 'GULLY' THEN
				IF NEW.exit_type ='VNODE' THEN -- link_class = 3
					UPDATE gully SET pjoint_type = 'VNODE', pjoint_id = NEW.exit_id WHERE gully_id = NEW.feature_id;
				ELSIF NEW.exit_type ='NODE' THEN
					UPDATE gully SET pjoint_type = 'NODE', pjoint_id = NEW.exit_id WHERE gully_id = NEW.feature_id;
				END IF;
				
			END IF;
		
		ELSE -- if geometry comes from psector_plan tables then  (link_class 2 or 3)
			
			-- if geometry have changed by user 
			IF st_equals (OLD.the_geom, NEW.the_geom) IS FALSE THEN
				v_userdefined_geom  = TRUE;
				v_end_point = ST_EndPoint(NEW.the_geom);
			ELSE 
				v_userdefined_geom  = FALSE;

			END IF;

			IF NEW.exit_type ='VNODE' THEN -- link_class = 3

				-- update values on plan_psector tables
				IF NEW.feature_type='CONNEC' THEN

					-- update only arc to trigger psector table
					UPDATE plan_psector_x_connec SET arc_id = v_arc.arc_id WHERE plan_psector_x_connec.id=NEW.psector_rowid;

					-- update to set values
					UPDATE plan_psector_x_connec SET link_geom = NEW.the_geom, userdefined_geom = v_userdefined_geom
					WHERE plan_psector_x_connec.id=NEW.psector_rowid;
		
				ELSIF NEW.feature_type='GULLY' THEN
				
					-- update only arc to trigger psector table
					UPDATE plan_psector_x_gully SET arc_id = v_arc.arc_id WHERE plan_psector_x_gully.id=NEW.psector_rowid;

					-- update to set values
					UPDATE plan_psector_x_gully SET link_geom = NEW.the_geom, userdefined_geom = v_userdefined_geom
					WHERE plan_psector_x_gully.id=NEW.psector_rowid;
				END IF;

				-- update link table (if comes from link_class = 2)
				IF OLD.link_class = 2 THEN
					UPDATE link SET exit_id = NEW.exit_id, exit_type = NEW.exit_type WHERE link_id = NEW.link_id;
				END IF;
			
			-- update values on other tables (if exit_type !='VNODE' considering the scenario of only one alternative)
			ELSIF NEW.exit_type !='VNODE' THEN -- link class  = 1

				-- update link table, because as link class = 1 may change in any moment exit_id, exit_type, geom, etc.....
				UPDATE link SET exit_id = NEW.exit_id, exit_type = NEW.exit_type, userdefined_geom = v_userdefined_geom, the_geom = NEW.the_geom WHERE link_id = NEW.link_id;

				-- delete old vnode if no more links are using it
				IF (SELECT count(*) FROM link WHERE exit_id = OLD.exit_id) = 0 THEN
					DELETE FROM vnode WHERE vnode_id = OLD.exit_id::integer;
				END IF;
				
				-- update connect tables (connec & gully psector_*) -> arc_id must be the same of the exit_type because this is like limited alternative
				IF NEW.feature_type='CONNEC' THEN
				
					UPDATE plan_psector_x_connec SET arc_id = v_arc_id, link_geom = NULL, userdefined_geom = NULL
					WHERE plan_psector_x_connec.id=NEW.psector_rowid;
					UPDATE connec SET arc_id = v_arc_id, pjoint_id = v_pjoint_id, pjoint_type = v_pjoint_type WHERE connec_id = NEW.feature_id;

				ELSIF NEW.feature_type='GULLY' THEN

					UPDATE plan_psector_x_gully SET arc_id = v_arc_id, link_geom = NULL, userdefined_geom = NULL
					WHERE  plan_psector_x_gully.id=NEW.psector_rowid;
					UPDATE v_edit_gully SET arc_id = v_arc_id, pjoint_id = v_pjoint_id, pjoint_type = v_pjoint_type WHERE gully_id = NEW.feature_id;
				END IF;
			END IF;
		END IF;
	
		-- Update state_type if edit_connect_update_statetype is TRUE
		IF (SELECT ((value::json->>'connec')::json->>'status')::boolean FROM config_param_system WHERE parameter = 'edit_connect_update_statetype') IS TRUE THEN
	
			UPDATE connec SET state_type = (SELECT ((value::json->>'connec')::json->>'state_type')::int2 
			FROM config_param_system WHERE parameter = 'edit_connect_update_statetype') WHERE connec_id=v_connec1.connec_id;
	
			IF v_projectype = 'UD' THEN
				UPDATE gully SET state_type = (SELECT ((value::json->>'gully')::json->>'state_type')::int2 
				FROM config_param_system WHERE parameter = 'edit_connect_update_statetype') WHERE gully_id=v_gully1.gully_id;
			END IF;
			
		END IF;

		-- enable linktonetwork
		UPDATE config_param_user SET value='FALSE' WHERE parameter = 'edit_connec_disable_linktonetwork' AND cur_user = current_user;

		RETURN NEW;
						
	ELSIF TG_OP = 'DELETE' THEN

		IF OLD.link_class < 3 THEN -- if geometry comes from link table
			DELETE FROM link WHERE link_id = OLD.link_id;

			IF OLD.exit_type='VNODE' THEN
				-- delete vnode if no more links are related to vnode
				SELECT count(exit_id) INTO v_count FROM link WHERE exit_id=OLD.exit_id;	
							
				IF v_count < 2 THEN -- only 1 link or cero exists
					DELETE FROM vnode WHERE  vnode_id::text=OLD.exit_id;
				END IF;
			END IF;
			
		ELSE
			UPDATE plan_psector_x_connec SET link_geom = NULL, userdefined_geom = NULL, arc_id=NULL
			WHERE plan_psector_x_connec.id=OLD.psector_rowid;
			
			IF v_projectype = 'UD' THEN
				IF OLD.feature_type='GULLY' THEN
					UPDATE plan_psector_x_gully SET link_geom = NULL, userdefined_geom = NULL
					WHERE plan_psector_x_gully.id=OLD.psector_rowid;
				END IF;
			END IF;
		END IF;

		-- update arc_id of connect
		IF OLD.feature_type='CONNEC' THEN
			UPDATE connec SET arc_id=NULL, pjoint_id=NULL, pjoint_type = NULL WHERE connec_id = OLD.feature_id;
		ELSIF OLD.feature_type='GULLY' THEN
			UPDATE gully SET arc_id=NULL, pjoint_id=NULL, pjoint_type = NULL WHERE gully_id = OLD.feature_id;
		END IF;

		RETURN NULL;
	   
	END IF;
    
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
