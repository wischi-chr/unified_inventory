unified_inventory.register_page("waypoints", {
	get_formspec = function(player)
		local player_name = player:get_player_name()
		local need_save = false
		local waypoints = datastorage.get_container (player, "waypoints")
		local formspec = "background[0,4.5;8,4;ui_main_inventory.png]"..
			"image[0,0;1,1;ui_waypoints_icon.png]"..
			"label[1,0;Waypoints]" 
		for i = 1, 5, 1 do
			formspec = formspec .. "label[0,".. 0.2 + i*0.7 ..";".. i ..".]" 
			if waypoints[i].edit then 
				formspec = formspec .. 
					"image_button[1.7,".. 0.2 + i*0.7 ..";.8,.8;ui_ok_icon.png;confirm_rename".. i .. ";]"..
					"field[2.7,".. 0.5 + i*0.7 ..";5,.8;rename_box".. i ..";;".. waypoints[i].name .."]"
			else
				formspec = formspec ..
				 	"image_button[1.7,".. 0.2 + i*0.7 ..";.8,.8;ui_pencil_icon.png;rename_waypoint".. i .. ";]".. 
					"label[3,".. 0.2 + i*0.7 ..";(".. 
					waypoints[i].world_pos.x .. "," ..
					waypoints[i].world_pos.y .. "," ..
					waypoints[i].world_pos.z .. "), "..
					waypoints[i].name .. "]"
			end
			formspec = formspec .. "image_button[1.0,".. 0.2 + i*0.7 ..";.8,.8;ui_waypoint_set_icon.png;set_waypoint".. i .. ";]"
			if not waypoints[i].active then  
				formspec = formspec .. "image_button[0.3,".. 0.2 + i*0.7 ..";.8,.8;ui_off_icon.png;toggle_waypoint".. i .. ";]"
			else 
				formspec = formspec .. "image_button[0.3,".. 0.2 + i*0.7 ..";.8,.8;ui_on_icon.png;toggle_waypoint".. i .. ";]"
			end
		end	
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("waypoints", {
	type = "image",
	image = "ui_waypoints_icon.png",
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end
	local waypoints = datastorage.get_container (player, "waypoints")		
	for i = 1, 5, 1 do
		if fields["toggle_waypoint"..i] then
			waypoints[i].active = not (waypoints[i].active)
			unified_inventory.set_inventory_formspec(player, "waypoints")
			if waypoints[i].active == true then
				waypoints[i].hud = player:hud_add({
					hud_elem_type = "waypoint",
					number = 0xFFFFFF ,
					name = waypoints[i].name,
					text = "m",
					world_pos = waypoints[i].world_pos
					})
			else
				if waypoints[i].hud ~= nil then 
					player:hud_remove(waypoints[i].hud)
				end
			end	
		end
		
		if fields["set_waypoint"..i] then
			local pos = player:getpos()
			pos.x = math.floor(pos.x)
			pos.y = math.floor(pos.y)
			pos.z = math.floor(pos.z)
			waypoints[i].world_pos = pos
				if waypoints[i].active == true then
					player:hud_remove(waypoints[i].hud)
					waypoints[i].hud = player:hud_add({
						hud_elem_type = "waypoint",
						number = 0xFFFFFF ,
						name = waypoints[i].name,
						text = "m",
						world_pos = waypoints[i].world_pos
					})
				end
			unified_inventory.set_inventory_formspec(player, "waypoints")
		end
		
		if fields["rename_waypoint"..i] then
			waypoints[i].edit = true
			unified_inventory.set_inventory_formspec(player, "waypoints")
		end
		if fields["confirm_rename"..i] then
			waypoints[i].edit = false
			waypoints[i].name = fields["rename_box"..i] 
			unified_inventory.set_inventory_formspec(player, "waypoints")
			player:hud_remove(waypoints[i].hud)
			if waypoints[i].active == true then	
				waypoints[i].hud = player:hud_add({
					hud_elem_type = "waypoint",
					number = 0xFFFFFF ,
					name = waypoints[i].name,
					text = "m",
					world_pos = waypoints[i].world_pos
				})
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	local waypoints = datastorage.get_container (player, "waypoints")
	if waypoints[1] == nil then 
		for i = 1, 5, 1 do
			waypoints[i] = {
			edit = false,
			active = false,
			name = "Waypoint ".. i,
			world_pos = {x = 0, y = 0, z = 0},
			}
		end
		datastorage.save_container(player)
	end
	for i = 1, 5, 1 do
		waypoints[i].edit = false
	end
end)
