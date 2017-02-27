local c = circuits

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
	connects_to = {"group:circuit_wire", "group:circuit_consumer", "group:circuit_power"},
	--[[
	on_rightclick = function(pos,node)
		local flags = node.param2
		pos = c.npos(pos,node)
		minetest.chat_send_all(flags)
		local network, powered = get_wire_network(pos)
		for _,real in pairs(network) do
			local dir = c.rot_relative_pos(pos, real)
			minetest.chat_send_all("{ " .. dir.x ..  ","
				.. dir.y .. "," .. dir.z .. "}")
		end
		minetest.chat_send_all(tostring(powered))
	end,
	--]]
	--after_place_node = function(pos,placer,itemstack,pointed_thing)
	--[[
	--	Circuits properties definition area
	--]]
	circuits = {
		connects = c.local_area,
		connects_to = {"circuit_consumer", "circuit_wire", "circuit_power"},
		store_connect = "param2",
		powering = function(npos, rpos)
			return c.is_on(npos)
		end
	},
}

c.register_on_off("circuits:wire",wire,{},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})

local colours = {
	red = "^[colorize:#F00:120",
	green = "^[colorize:#0F0:120",
	blue = "^[colorize:#00F:120",
}

for _, colour in ipairs{"red", "green", "blue"} do
	local def = table.copy(wire)
	local col_string = colours[colour]
	def.tiles[1] = def.tiles[1] .. col_string
	def.groups = {dig_immediate=3,["circuit_wire_" .. colour]=1,circuit_wire=1}
	def.connects_to = {"group:circuit_raw_wire", "group:circuit_wire_" .. colour
	                  , "group:circuit_consumer", "group:circuit_power"}
	def.circuits.connects_to = {"circuit_raw_wire", "circuit_wire_" .. colour
	                  , "circuit_consumer", "circuit_power"}
	c.register_on_off("circuits:wire_" .. colour,def,{},
	{
		tiles = {"default_mese_block.png^[colorize:#111:160" .. col_string},
	})
end

