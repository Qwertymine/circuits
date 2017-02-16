local c = circuits
local max_dist = 2

-- Table of mask values for different connection points
local connection_points = {
	[c.hash_pos({x=0,y=1,z=0})] = 0x04,
	[c.hash_pos({x=0,y=-1,z=0})] = 0x08,
	[c.hash_pos({x=1,y=0,z=0})] = 0x10,
	[c.hash_pos({x=-1,y=0,z=0})] = 0x20,
	[c.hash_pos({x=0,y=0,z=1})] = 0x40,
	[c.hash_pos({x=0,y=0,z=-1})] = 0x80,
}

c.register_wire = function(name,def)
end

local function is_wire(name)
	local def = minetest.registered_nodes[name]
	if not def or not def.groups then
		return false
	elseif def.groups.wire and def.groups.wire ~= 0 then
		return true
	end
	return false
end

local function param_connection(param,wire,to)
	local to_relative = c.hash_pos(c.relative_pos(wire,to))
	param = bit.bor(param,connection_points[to_relative])
	return param
end

local function connect_wire(wire,to)
	local node = minetest.get_node(wire)
	node.param2 = param_connection(node.param2,wire,to)
	minetest.swap_node(wire,node)
end

local function connect_to_ajacent(pos)
	local node = minetest.get_node(pos)
	local param = node.param2
	local powered = false
	for i,_ in pairs(connection_points) do
		for dist=1,max_dist do
			local to = c.relative_real_pos(pos,vector.multiply(c.unhash_pos(i),dist))
			local connection,powering = c.connect(node,pos,to)
			if connection then
				param = param_connection(param,pos,connection)
				powered = powered or powering
				break
			end
		end
	end
	node.param2 = param
	minetest.swap_node(pos,node)
	if powered then
		power(pos)
	end
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
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
	on_rightclick = function(pos,node)
		minetest.chat_send_all(node.param2)
		for k,v in pairs(connection_points) do
			if bit.band(node.param2,v) ~= 0 then
				local dir = c.unhash_pos(k)
				minetest.chat_send_all("{ " .. dir.x ..  ","
					.. dir.y .. "," .. dir.z .. "}")
			end
		end
		--]]
	end,
	after_place_node = function(pos,placer,itemstack,pointed_thing)
		connect_to_ajacent(pos)
	end,
	connect = function(this_pos,from_pos)
		if connection_points[c.hash_pos(c.relative_pos(this_pos,from_pos))] then
			connect_wire(this_pos,from_pos)
			return this_pos, c.is_on(power_pos)
		end
		return nil
	end,
}

c.register_on_off("circuits:wire",wire,{},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})

