dofile(minetest.get_modpath("nc_rabbits").."/rabbits.lua")

minetest.register_node("nc_rabbits:trap", {
	description = "Rabbit trap",
	drawtype = "mesh",
	mesh = "nc_rabbits_trap.obj",
	tiles = {"nc_rabbits_trap.png"},
	paramtype = "light",
	groups = {unbreakable = 1},
})

minetest.register_node("nc_rabbits:rabbit_hole", {
	description = "Holey Grass",
	tiles = {
		"nc_terrain_grass_top.png^nc_rabbits_hole.png",
		"nc_terrain_dirt.png",
		"nc_terrain_dirt.png^(nc_terrain_grass_top.png^[mask:nc_terrain_grass_sidemask.png)"
	},
	groups = {
		crumbly = 2,
	},
	silktouch = {crumbly = 4},
	stack_max = 1,
	drop_in_place = "nc_terrain:dirt"
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "nc_rabbits:rabbit_hole",
	wherein        = "nc_terrain:dirt_with_grass",
	clust_scarcity = 10 * 10 * 10,
	clust_num_ores = 1,
	clust_size     = 1,
	y_max          = 20,
	y_min          = 0,
})

nodecore.register_craft({
	normal = {y = 1},
	nodes = {
		{match = "nc_terrain:cobble_loose", replace = "air"},
		{y = -1, match = "nc_woodwork:frame", replace = "nc_rabbits:trap"},
	}
})

nodecore.register_craft({
	label = "break up rabbit trap",
	action = "pummel",
	toolgroups = {snappy = 1},
	nodes = {
		{match = "nc_rabbits:trap", replace = "air"}
	},
	items = {
		{name = "nc_terrain:cobble_loose", count = 1, scatter = 1},
		{name = "nc_woodwork:frame", count = 1, scatter = 1},
	}
})

minetest.register_abm({
	label = "Rabbit trapping",
	interval = 10,
	chance = 1,
	nodenames = {"nc_rabbits:trap"},
	neighbors = {"nc_rabbits:rabbit_hole"},
	action = function(pos)
		local pos_up = {x = pos.x, y = pos.y+1, z = pos.z}
		local pos_up2 = {x = pos.x, y = pos.y+2, z = pos.z}
		local pos_down = {x = pos.x, y = pos.y-1, z = pos.z}

		local meta = minetest.get_meta(pos)
		local trap_time = meta:get_int("trap_time")

		if trap_time == 0 then
			meta:set_int("trap_time", math.random(60*3, 60*7)) -- rabbit trapping time (3-7 minutes)
		elseif trap_time > 10 then
			meta:set_int("trap_time", trap_time-10)
		elseif trap_time <= 10 then
		if minetest.get_node(pos_up).name == "air" and minetest.get_node(pos_up2).name == "air" then
			if math.random(1, 3) == 2 then
				nodecore.place_stack(pos_up2, "nc_terrain:cobble_loose")
				nodecore.place_stack(pos_up, "nc_woodwork:frame")
				nodecore.place_stack(pos, "nc_rabbits:rabbit_dead")
				minetest.set_node(pos_down, {name = "nc_terrain:dirt"})
			else
				nodecore.place_stack(pos_up, "nc_terrain:cobble_loose")
				nodecore.place_stack(pos, "nc_woodwork:frame")
			end
		end
		end
	end
})

minetest.register_abm({
	label = "Rabbit spreading",
	interval = 60 * 3, -- 3 minutes
	chance = 0.5,
	nodenames = {"nc_terrain:dirt_with_grass"},
	neighbors = {"nc_rabbits:rabbit_hole", "nc_rabbits:rabbit_hole"},
	action = function(pos)
		local neighbors = minetest.find_nodes_in_area_under_air(
			vector.subtract(pos, 1), -- pos1
			vector.add(pos, 1), -- pos2
			"nc_rabbits:rabbit_hole" -- nodenames
		)

		for _, npos in pairs(neighbors) do
			local oppositepos = vector.add(vector.subtract(pos, npos), pos)

			if minetest.get_node(oppositepos).name == "nc_rabbits:rabbit_hole" then -- There is another rabbit hole opposite the grass node
				minetest.set_node(pos, {name = "nc_rabbits:rabbit_hole"})
				return
			end
		end
	end
})
