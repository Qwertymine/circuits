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

c.is_on = function(name)
	local def = minetest.registered_nodes[name]
	if not def then
		return false
	end
	return def.on == name
end

c.get_on = function(name)
	local def = minetest.registered_nodes[name]
	if not def then
		return nil
	end
	return def.on
end
	
c.get_off = function(name)
	local def = minetest.registered_nodes[name]
	if not def then
		return nil
	end
	return def.off
end

c.power = function(power,as)
	local node = minetest.get_node(power)
	local def = minetest.registered_nodes[node.name]
	if not def or not def.power then
		return false
	end
	def.on_power(power,as)
end

c.unpower = function(power,as)
	local node = minetest.get_node(power)
	local def = minetest.registered_nodes[node.name]
	if not def or not def.unpower then
		return false
	end
	def.on_unpower(power,as)
end

c.connect = function(recipient,other)
	local node = minetest.get_node(other)
	local def = minetest.registered_nodes[node.name]
	if not def or not def.connect then
		return nil,false
	else
		return def.connect(other,recipient)
	end
end

c.is_wire = function(name)
	local def = minetest.registered_nodes[name]
	if not def or not def.groups then
		return false
	else
		return def.groups.wire
	end
end
