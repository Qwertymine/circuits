local c = circuits

local function is_wire(name)
	return minetest.get_item_group("circuit_wire") > 0
end

local max_net_items = 50
local function get_wire_network(npos)
	local network = {npos}
	local seen = {[c.hash_pos(npos)] = npos}
	for i=1,max_net_items do
		local item = network[i]
		if not item then
			break
		end

		if is_wire(item.node.name) then
			for _, node in ipairs(c.get_all_connected(item)) do
				if not seen[c.hash_pos(node)] then
					network[#network+1] = node
					seen[c.hash_pos(node)] = node
				end
			end
		end
	end
	return network
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
	connects_to = {"group:circuit_wire", "group:circuit_consumer", "group:circuit_power"},
	on_rightclick = function(pos,node)
		local flags = node.param2
		pos.node = node
		minetest.chat_send_all(flags)
		for _,real in pairs(get_wire_network(pos)) do
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
	end,
	after_destruct = function(pos, old_node)
		pos.node = old_node
		c.disconnect_all(pos)
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

