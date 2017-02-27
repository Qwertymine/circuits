local c = circuits

c.register_on_off = function(name,def,on_def,off_def)
	local name_on = name .. "_on"
	local name_off = name .. "_off"

	def.circuits = def.circuits or {}
	def.circuits.base_node = name

	def.circuits.powered = name_on
	def.circuits.off = name_off

	local on = table.copy(on_def)
	local off = table.copy(off_def)

	for k,v in pairs(def) do
		on[k] = on[k] or v
		off[k] = off[k] or v
	end

	on.drop = on.drop or name_off

	c.register_node(name_on,on)
	c.register_node(name_off,off)
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

c.on_construct = function(pos)
	pos = c.npos(pos)
	c.connect_all(pos)
end

c.on_destruct = function(pos)
	pos = c.npos(pos)
	c.disconnect_all(pos)
end

c.register_node = function(name, def)
	def.circuits = def.circuits or {}
	local cd = def.circuits

	-- Plug in correct rotation
	if def.paramtype2 == "wallmounted" then
		cd.rot = "wallmounted"
	elseif def.paramtype2 == "facedir" then
		cd.rot = "facedir"
	end

	-- Check param storage
	if def.paramtype and cd.store_connect == "param1" then
		error("Storing connections in used param1")
	elseif def.paramtype2 and cd.store_connect == "param2" then
		error("Storing connections in used param2")
	end
	cd.store_connect = cd.store_connect or "meta"

	-- Create construct/destruct
	for _, action in ipairs{"on_construct", "on_destruct"} do
		if def[action] then
			local circuits_action = c[action]
			local def_action = def[action]
			def[action] = function(pos)
				def_action(pos)
				circuits_action(pos)
			end
		else
			def[action] = c[action]
		end
	end

	-- Check that consumers/power have updates
	if  (def.groups.circuit_power or def.groups.circuit_consumer)
	and not cd.on_update then
		error("Consumer/Producer defined without update")
	elseif def.groups.circuit_wire then
		cd.on_update = c.wire_update
	end

	-- Check producer is_powering
	if def.groups.circuit_power
	and not cd.powering then
		error("Producer defined without is_powering")
	end

	-- Check connections exist
	if not cd.connects_to
	or not cd.connects then
		error("Component defined without any connection rules")
	end

	-- Check that a base node is set if wire
	if def.groups.circuit_wire
	and not cd.base_node then
		error("Wire set without a base node")
	end

	minetest.register_node(name, def)
end

