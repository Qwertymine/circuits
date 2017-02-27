local c = circuits

local function is_facedir(npos)
	local def = minetest.registered_nodes[npos.node.name]
	if not def then
		return false
	end

	if def.paramtype2 == "facedir" then
		return true
	end

	return false
end

local dir_to_facedir = {
	[c.hash_pos({x=0,y=1,z=0})] = 0,
	[c.hash_pos({x=0,y=-1,z=0})] = 20,
	[c.hash_pos({x=1,y=0,z=0})] = 12,
	[c.hash_pos({x=-1,y=0,z=0})] = 16,
	[c.hash_pos({x=0,y=0,z=1})] = 4,
	[c.hash_pos({x=0,y=0,z=-1})] = 8,
}

minetest.register_craftitem("circuits:wrench", {
	description = "Wrench",
	inventory_image = "screwdriver.png^[colorize:#111:160",
	on_use = function(itemstack, placer, pointed_thing)
		local npos = c.npos(pointed_thing.under)
		if not is_facedir(npos) then
			return
		end
		local above = pointed_thing.above
		local dir = vector.subtract(npos, above)
		npos.node.param2 = dir_to_facedir[c.hash_pos(dir)]
		minetest.set_node(npos, npos.node)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local npos = c.npos(pointed_thing.under)
		if not is_facedir(npos) then
			return
		end
		local new_rot = npos.node.param2 + 1
		if new_rot % 4 < npos.node.param2 % 4 then
			new_rot = npos.node.param2 - (npos.node.param2 % 4)
		end
		npos.node.param2 = new_rot
		minetest.set_node(npos, npos.node)
	end,
})
