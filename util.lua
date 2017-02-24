local c = circuits

c.register_on_off = function(name,def,on_def,off_def)
	local name_on = name .. "_on"
	local name_off = name .. "_off"

	def.circuits = def.circuits or {}
	def.circuits.powered = name_on
	def.circuits.off = name_off

	local on = table.copy(on_def)
	local off = table.copy(off_def)

	for k,v in pairs(def) do
		on[k] = on[k] or v
		off[k] = off[k] or v
	end

	on.drop = on.drop or name_off

	minetest.register_node(name_on,on)
	minetest.register_node(name_off,off)
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

c.get_powered = function(npos)
	local cd = c.get_circuit_def(npos.node.name)

	if not cd
	or not cd.powered then
		return nil
	end

	return cd.powered
end

c.get_off = function(npos)
	local cd = c.get_circuit_def(npos.node.name)

	if not cd
	or not cd.off then
		return nil
	end

	return cd.off
end

c.is_on = function(npos)
	if npos.node.name == c.get_off(npos) then
		return false
	end
	if npos.node.name == c.get_powered(npos) then
		return true
	end
	return nil
end
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
