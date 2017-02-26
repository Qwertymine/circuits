local c = circuits

-- npos - npos of powering? node
-- node - npos of powered? node
c.is_powering = function(npos, node)
	local cd = c.get_circuit_def(npos.node.name)

	if not cd
	or not cd.powering
	or not c.is_connected(npos,node) then
		return false
	end

	return cd.powering(npos,c.rot_relative_pos(npos,node))
end

-- c.pending is in persistance.lua
local function insert_update(update, type)
	if not update 
	or not type then
		return
	end
	local update_list = c.pending

	update_list[type] = update_list[type] or {}
	update_list[type][#update_list[type]+1] = update
	return
end

local function cons_or_wire(name)
	local is_wire = minetest.get_item_group(name, "circuit_wire")
	if is_wire > 0 then
		return "wire"
	end
	local is_cons = minetest.get_item_group(name, "circuit_consumer")
	if is_cons > 0 then
		return "consumer"
	end

	return nil
end

c.wait = function(npos, args, no_ticks)
	local update = {
		npos = npos,
		args = args,
		delay = no_ticks
	}
	insert_update(update,"wait")
end

c.update = function(npos, args)

	local type = cons_or_wire(npos.node.name)
	local update = {
		npos = npos,
		args = args
	}
	insert_update(update,type)
end

c.power_update = function(npos, args)
	local update = {
		npos = npos,
		args = args
	}
	insert_update(update,"power")
end

local function is_valid_update(npos)
	if not npos then
		return nil
	end

	local cd = c.get_circuit_def(npos.node.name)
	local node = minetest.get_node(npos)
	local new_cd = c.get_circuit_def(node.name)

	if not cd or not new_cd
	or cd.base_node ~= new_cd.base_node then
		return nil
	end

	npos.node = node
	return npos, cd
end

local no_ticks_sec = 12

-- Wait for local area to load - hack
-- TODO force loading or something else
local timer = -5
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 1/no_ticks_sec then
		return
	else
		timer = 0
	end

	if not c.pending then
		return
	end

	-- Handle basic updates
	for _, power_type in ipairs{"power", "wire", "consumer"} do
		for _,update in ipairs(c.pending[power_type] or {}) do
			-- Check that node is still the same
			local npos, cd = is_valid_update(update.npos)
			if npos and cd and cd.on_update then
				-- Update if possible
				cd.on_update(npos,update.args,power_type)
			end
		end
		c.pending[power_type] = nil
	end

	local replace = 1
	-- Handle items in the wait queue
	for i=1,#c.pending.wait do
		update = c.pending.wait[i]

		update.delay = update.delay - 1
		if update.delay <= 0 then
			local npos, cd = is_valid_update(update.npos)
			if npos and cd and cd.on_wait then
				-- Update if possible
				cd.on_wait(npos,update.args,"wait")
			end
		else
			c.pending.wait[replace] = update
			replace = replace + 1
		end
	end
	-- Remove duplicate/consumed items
	for i=#c.pending.wait,replace+1,-1 do
		c.pending.wait[i] = nil
	end

end)


