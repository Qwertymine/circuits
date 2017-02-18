local c = circuits

c.source = "source"
c.reciever = "reciever"
c.wire = "wire"

c.on = "on"
c.off = "off"

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

-- Power a node
-- from - pos of initiating node (powering)
-- power - pos of recieving node (powered)
-- return - bool if node is powered
c.power = function(from, power)
	local node = minetest.get_node(power)
	local def = get_cd(node.name)
	if not def or not def.on_power then
		return false
	end
	return def.on_power(power, node, from)
end

-- Unpower a node
-- from - pos of initiating node (powering)
-- power - pos of recieving node (powered)
-- return - bool if node is unpowered
c.unpower = function(power,as)
	local node = minetest.get_node(power)
	local def = minetest.registered_nodes[node.name]
	if not def or not def.unpower then
		return false
	end
	return def.on_unpower(power, node, from)
end
