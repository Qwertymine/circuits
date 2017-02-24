local c = circuits

c.register_on_off = function(name,def,on_def,off_def)
	def.on = name .. "_on"
	def.off = name .. "_off"

	local on = table.copy(on_def)
	local off = table.copy(off_def)

	for k,v in pairs(def) do
		on[k] = on[k] or v
		off[k] = off[k] or v
	end

	on.drop = on.drop or def.off

	minetest.register_node(name .. "_on",on)
	minetest.register_node(name .. "_off",off)
end

-- Get the circuits table of a node
-- return nil if does not exist
c.get_circuit_def = function(node_name)
	local def = minetest.registered_nodes[node_name]
	if not def or not def.circuits then
		return nil
	end

	return def.circuits
end
local get_cd = c.get_circuit_def

-- Mutate a pos into an npos
-- pos - a position
-- [node] - a node
c.npos = function(pos, node)
	if not node then
		node = minetest.get_node(pos)
	end
	pos.node = node
	return pos
end

c.pos_string = function(pos)
	return "{" .. pos.x .. "," .. pos.y .. "," .. pos.z .. "}"
end

-- Power a node
-- npos - npos of the powering? node
-- other - npos of the powered? node
-- return - bool if node is powered
c.is_powering = function(npos, other)
end
