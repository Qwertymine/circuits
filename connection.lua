--[[
--	This file contains the generic connection rules
--	for all nodes in this mod
--]]
local c = circuits
local max_dist = 2

-- Conversion table to change dirs to bit
-- patters - for use in param stores
local dir_bits = {
	[c.hash_pos({x=0,y=1,z=0})] = 0x04,
	[c.hash_pos({x=0,y=-1,z=0})] = 0x08,
	[c.hash_pos({x=1,y=0,z=0})] = 0x10,
	[c.hash_pos({x=-1,y=0,z=0})] = 0x20,
	[c.hash_pos({x=0,y=0,z=1})] = 0x40,
	[c.hash_pos({x=0,y=0,z=-1})] = 0x80,
}
c.dir_bits = dir_bits

-- Sets the correct connection bit high
-- connect_flags - int, set of connection flags - only 8 bits for param or param2
-- dir - the direction to disconnect from
-- returns - the new flag setting
local function bit_connect(connect_flags, dir)
	local to_relative = c.hash_pos(dir)
	return bit.bor(connect_flags,dir_bits[to_relative])
end

-- Sets the correct connection bit low
-- connect_flags - int, set of connection flags - only 8 bits for param or param2
-- dir - the direction to disconnect from
-- returns - the new flag setting
local function bit_disconnect(connect_flags, dir)
	local to_relative = c.hash_pos(dir)
	return bit.band(connect_flags, bit.bnot(dir_bits[to_relative]))
end


-- Applies a connection modification to the given node
-- node - npos of the node to modify
-- dir - the direction to modify
-- mod - func to modify the connection
local function map_connect_mod(node, dir, mod)
	local cd = c.get_circuit_def(node.node.name)

	if cd.store_connect == "param" then
		node.node.param = mod(node.node.param, dir)

	elseif cd.store_connect == "param2" then
		node.node.param2 = mod(node.node.param2, dir)

	elseif cd.store_connect == "meta" then
		local meta = minetest.get_meta(node)
		meta:set_int("connect",mod(meta:get_int("connect"), dir))
	end
end

-- Find if an rpos is in a possible connection spot
-- a_cd - circuit_def of node
-- rpos - relative pos
-- [dir] - the dir ({x=0, y=-1, z=0})
local function in_range(a_cd, rpos, dir)
	if not dir then
		dir = c.rpos_is_dir(rpos)
	end
	if not dir then
		return false
	end

	for _, axis in ipairs{"x", "y", "z"} do
		if a_cd.connects[axis] then
			if not (a_cd.connects[axis][1] >= rpos[axis])
			or not (a_cd.connects[axis][2] <= rpos[axis]) then
				return false
			end
		end
	end

	return true
end

-- Check if the circuit-def allows a(_cd) to connect
-- to node (b)
-- a_cd - circuit def
-- node - name of node
local function allow_connect(a_cd, node)
	for _, a_connects_to in ipairs(a_cd.connects_to) do
		if minetest.get_item_group(node, a_connects_to) > 0 then
			return true
		end
	end
	return false
end

-- Write connection changes to map
local function set_connections(npos)
	local cd = c.get_circuit_def(npos.node.name)
	
	if cd.store_connect == "param"
	or cd.store_connect == "param2" then
		minetest.swap_node(npos, npos.node)

	elseif cd.store_connect == "meta" then
		-- Already set
	end
end

-- Try to connect two nodes together - and do so if possible
-- a - npos of a node
-- b - npos of other node
local function connect(a,b)
	local a_cd = c.get_circuit_def(a.node.name)
	local b_cd = c.get_circuit_def(b.node.name)

	-- If one does not have a connection def - they cannot connect
	if not a_cd or not b_cd then
		-- minetest.chat_send_all("Missing cd")
		return false
	end

	local a_rpos = c.rot_relative_pos(a,b)
	-- If they are not aligned to an axis - they cannot connect
	if not c.rpos_is_dir(a_rpos) then
		-- minetest.chat_send_all("rpos is not dir")
		return false
	end

	local b_rpos = c.rot_relative_pos(b,a)
	-- If neither is in the range of the other - they can't connect
	if  not in_range(a_cd, a_rpos)
	and not in_range(b_cd, b_rpos) then
		-- minetest.chat_send_all("rpos not in range")
		return false
	end

	-- If either is not allowed to connect - they cannot connect
	if not allow_connect(a_cd, b.node.name)
	or not allow_connect(b_cd, a.node.name) then
		-- minetest.chat_send_all("node cannot connect")
		return false
	end

	map_connect_mod(a, c.rpos_is_dir(a_rpos), bit_connect)
	map_connect_mod(b, c.rpos_is_dir(b_rpos), bit_connect)

	set_connections(a)
	set_connections(b)
	return true
end
c.connect = connect

-- Disconnect b from a
-- a - npos of a node
-- b - npos of other node
local function disconnect(a, b)
	local b_rpos = c.rot_relative_pos(b,a)

	-- If they are not aligned to an axis - they cannot disconnect
	local dir = c.rpos_is_dir(b_rpos)
	if not dir then
		return
	end

	map_connect_mod(b, dir, bit_disconnect)
	return
end
c.disconnect = disconnect

-- Connect node to all nodes in surrounding area
-- node - npos of node to connect
local function connect_all(node)
	local node_cd = c.get_circuit_def(node.node.name)
	for axis, _ in pairs(node_cd.connects) do
		for dir=1,-1,-2 do
		for dist=1,max_dist do
			local pos = {x=0, y=0, z=0}; pos[axis] = dir * dist
			local to = c.relative_real_pos(node,pos)
			to.node = minetest.get_node(to)

			-- Only one connection per side
			if c.connect(node,to) then
				break
			end
		end
		end
	end
	return node
end
c.connect_all = connect_all

-- node - npos
local function disconnect_all(node)
	local node_cd = c.get_circuit_def(node.node.name)
	for _, other in ipairs(c.get_all_connected(node)) do
		disconnect(node, other)
		set_connections(other)
	end
end
c.disconnect_all = disconnect_all

-- node - npos
local function get_bit_flags(node)
	local cd = c.get_circuit_def(node.node.name)
	if cd.store_connect == "param" then
		return node.node.param

	elseif cd.store_connect == "param2" then
		return node.node.param2

	elseif cd.store_connect == "meta" then
		local meta = minetest.get_meta(node)
		return meta:get_int("connect")
	end
end

local function get_connected_in_dir(npos,dir,flags)
	if not flags then
		flags = get_bit_flags(npos)
	end

	local dir_bit = c.dir_bits[c.hash_pos(dir)]
	if not dir_bit then
		return nil
	end

	if bit.band(flags,dir_bit) == 0 then
		return nil
	end

	for dist=1,max_dist do
		local rpos = vector.multiply(dir, dist)
		local to = c.npos(c.rot_relative_real_pos(npos,rpos))

		local npos_cd = c.get_circuit_def(npos.node.name)
		local to_cd = c.get_circuit_def(to.node.name)

		-- If either is not allowed to connect - they cannot connect
		if  allow_connect(npos_cd, to.node.name)
		and allow_connect(to_cd, npos.node.name) then
			return to
		end
	end

	return nil
end
c.get_connected_in_dir = get_connected_in_dir

local function is_connected(npos, to)
	local dir = c.rpos_is_dir(c.rot_relative_pos(npos,to))
	if not dir then
		return false
	end

	local found = get_connected_in_dir(npos,dir)
	if not found then
		return false
	end

	if not vector.equals(to,found) then
		return false
	end

	return true
end
c.is_connected = is_connected

-- node - npos
local function get_all_connected(node)
	local flags = get_bit_flags(node)
	local connected = {}
	for dir_hash,_ in pairs(c.dir_bits) do
		local to = get_connected_in_dir(node,c.unhash_pos(dir_hash),flags)
		if to then
			connected[#connected+1] = to
		end
	end
	return connected
end
c.get_all_connected = get_all_connected

