local c = circuits

local function is_wire(name)
	local def = minetest.registered_nodes[name]
	if not def or not def.groups then
		return false
	elseif def.groups.wire and def.groups.wire ~= 0 then
		return true
	end
	return false
end

local wire = {
	description = "Wire",
	drawtype = "nodebox",
	node_box = {
		type = "connected",
		fixed = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
		connect_top = {-0.2,-0.2,-0.2,0.2,0.5,0.2},
		connect_bottom = {-0.2,-0.5,-0.2,0.2,0.2,0.2},
		connect_front = {-0.2,-0.2,-0.5,0.2,0.2,0.2},
		connect_back = {-0.2,-0.2,-0.2,0.2,0.2,0.5},
		connect_left = {-0.5,-0.2,-0.2,0.2,0.2,0.2},
		connect_right = {-0.2,-0.2,-0.2,0.5,0.2,0.2},
	},
	selection_box = {
		type = "connected",
		fixed = {-0.3,-0.3,-0.3,0.3,0.3,0.3},
		connect_top = {-0.3,-0.3,-0.3,0.3,0.5,0.3},
		connect_bottom = {-0.3,-0.5,-0.3,0.3,0.3,0.3},
		connect_front = {-0.3,-0.3,-0.5,0.3,0.3,0.3},
		connect_back = {-0.3,-0.3,-0.3,0.3,0.3,0.5},
		connect_left = {-0.5,-0.3,-0.3,0.3,0.3,0.3},
		connect_right = {-0.3,-0.3,-0.3,0.5,0.3,0.3},
	},
	collision_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,circuit_wire=1,circuit_raw_wire=1},
	connects_to = {"group:circuit_wire"},
	on_rightclick = function(pos,node)
		--local flags = minetest.get_meta(pos):get_int("connect")
		local flags = node.param2
		minetest.chat_send_all(flags)
		for k,v in pairs(c.dir_bits) do
			if bit.band(flags,v) ~= 0 then
				local dir = c.unhash_pos(k)
				minetest.chat_send_all("{ " .. dir.x ..  ","
					.. dir.y .. "," .. dir.z .. "}")
			end
		end
		--]]
	end,
	--after_place_node = function(pos,placer,itemstack,pointed_thing)
	on_construct = function(pos)
		pos.node = minetest.get_node(pos)
		c.connect_all(pos)
	end,
	after_destruct = function(pos, old_node)
	end,

	--[[
	--	Circuits properties definition area
	--]]
	circuits = {
		connects = c.local_area,
		connects_to = {"circuit_consumer", "circuit_wire", "circuit_power"},
		store_connect = "param2",
	},
}

c.register_on_off("circuits:wire",wire,{},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})

