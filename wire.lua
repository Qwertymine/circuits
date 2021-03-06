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
				if not powered
				and minetest.get_item_group(node.node.name,"circuit_power") > 0 then
					powered = powered or c.is_powering(node, item)
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
