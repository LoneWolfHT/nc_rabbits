minetest.register_craftitem("nc_rabbits:rabbit_dead", {
	description = "Dead Rabbit",
	stack_max = 1,
	inventory_image = "nc_rabbits_rabbit_dead.png"
})

minetest.register_craftitem("nc_rabbits:rabbit_cooked", {
	description = "Cooked Rabbit",
	stack_max = 1,
	inventory_image = "nc_rabbits_rabbit_dead.png^nc_rabbits_cook.png",
	on_use = function(itemstack, user)
		local name = user:get_player_name()

		if user:get_hp() < 20 then
			for t = 5, 15, 5 do
				minetest.after(t, function()
					if minetest.get_player_by_name(name) then
						if user:get_hp() < 19 then
							user:set_hp(user:get_hp()+2)
						else
							user:set_hp(20)
						end
					end
				end)
			end

			itemstack:set_count(itemstack:get_count()-1)
		end

		return(itemstack)
	end
})

minetest.register_node("nc_rabbits:rabbit_head", {
	description = "Rabbit head. Not sure how you got this but ok...",
	drawtype = "mesh",
	mesh = "nc_rabbits_rabbit_head.obj",
	tiles = {"nc_rabbits_rabbit_head.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {unbreakable = 1},
})

minetest.register_abm({
	label = "Rabbit head management",
	nodenames = {"nc_rabbits:rabbit_hole"},
	interval = 3.0,
	chance = 1,
	catch_up = true,
	action = function(pos)
		local pos_up = {x = pos.x, y = pos.y+1, z = pos.z}
		local danger = false

		for _, p in ipairs(minetest.get_connected_players()) do
			if vector.distance(p:get_pos(), pos) <= 20 then
				danger = true
			end
		end

		if minetest.get_node(pos_up).name == "nc_rabbits:rabbit_head" then
			if danger == true then
				minetest.remove_node(pos_up)
			end
		elseif danger == false and minetest.get_node(pos_up).name == "air" then
			minetest.set_node(pos_up, {name = "nc_rabbits:rabbit_head", param2 = math.random(0, 3)})
		end
	end
})

nodecore.register_limited_abm({
	label = "Rabbit cooking",
	interval = 2,
	chance = 1,
	nodenames = {"group:visinv"},
	neighbors = {"group:fire"},
	action = function(pos)
		local meta = minetest.get_meta(pos)
		local ctime = meta:get_int("cooktime")
		local inv = meta:get_inventory()
		local stack = inv:get_stack("solo", 1)

		if stack:is_empty() or stack:get_name() ~= "nc_rabbits:rabbit_dead" then return end

		if ctime == 0 then
			meta:set_int("cooktime", 32) -- rabbit cooking time (30 seconds)
		elseif ctime > 2 then
			meta:set_int("cooktime", ctime-2)
		elseif ctime <= 2 then
			minetest.remove_node(pos)
			nodecore.place_stack(pos, "nc_rabbits:rabbit_cooked")
		end
	end
})
