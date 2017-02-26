local c = circuits

local function is_wire(name)
	return minetest.get_item_group(name,"circuit_wire") > 0
end

local max_net_items = 50
local function get_wire_network(npos)
	local network = {npos}
	local seen = {[c.hash_pos(npos)] = npos}
	local powered = false
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
		if minetest.get_item_group(item.node.name,"circuit_power") > 0 then
			for _, node in ipairs(c.get_all_connected(item)) do
				if seen[c.hash_pos(node)] then
					powered = powered or c.is_powering(item, node)
				end
			end
		end
	end
	return network, powered, (#network <= max_net_items)
end

c.wire_update = function(npos)
	if not npos then
		return false
	end

	local network, powered, complete = get_wire_network(npos)
	if not complete then
		return false
	end

	if  powered
	and c.is_on(npos) then
		return true
	elseif not powered
	and    not c.is_on(npos) then
		return true
	end

	local to_function
	if powered then
		to_function = c.get_powered
	else
		to_function = c.get_off
	end

	for _, node in ipairs(network) do
		if is_wire(node.node.name) then
			local new_name = to_function(node)
			if node.node.name ~= new_name then
				node.node.name = new_name
				minetest.swap_node(node,node.node)
			end
		elseif minetest.get_item_group(node.node.name,"circuit_consumer") > 0 then
			c.update(node)
		end
	end

	return true
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

