local c = circuits

local function power_on(node,pos)
	local on = table.copy(node)
	on.name = "circuits:pressure_plate_on"
	minetest.swap_node(pos,on)
end

local function power_off(node,pos,replace)
	local off = table.copy(node)
	off.name = "circuits:pressure_plate_off"
	minetest.swap_node(pos,off)
end
	
local pressure_plate = {
	description = "Pressure Plate",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4,-0.5,-0.4,0.4,-0.4,0.4 },
			{-0.2,-0.5,-0.2,0.2,-1.8,0.2 },
		},
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.4,0.3,-0.4,0.4,0.5,0.4},
		wall_side = {-0.3,-0.4,-0.4,-0.5,0.4,0.4},
		wall_bottom = {-0.4,-0.3,-0.4,0.4,-0.5,0.4},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {dig_immediate=3,source=1, circuit_power=1},
	on_rightclick = function(pos,node)
		local flags = minetest.get_meta(pos):get_int("connect")
		pos.node = node
		minetest.chat_send_all(flags)
		for _,real in pairs(c.get_all_connected(pos)) do
			local dir = c.rot_relative_pos(pos, real)
			minetest.chat_send_all("{ " .. dir.x ..  ","
				.. dir.y .. "," .. dir.z .. "}")
		end
		--]]
	end,
	--after_place_node = function(pos,placer,itemstack,pointed_thing)
	on_construct = function(pos)
		pos.node = minetest.get_node(pos)
		c.connect_all(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	after_destruct = function(pos, old_node)
		pos.node = old_node
		c.disconnect_all(pos)
	end,
	on_timer = function(pos,_)
		local node = minetest.get_node(pos)
		local entity = minetest.get_objects_inside_radius(pos,0.8)

		if entity and #entity >= 1 then
			power_on(node,pos)
		else
			power_off(node,pos,true)
		end
		return true
	end,
	circuits = {
		connects = c.behind,
		connects_to = {"circuit_consumer", "circuit_wire"},
		store_connect = "meta",
	},
}

c.register_on_off("circuits:pressure_plate",pressure_plate,
{
},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})
