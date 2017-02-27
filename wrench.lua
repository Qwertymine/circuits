local c = circuits

minetest.register_craftitem("circuits:wrench", {
	description = "Wrench",
	inventory_image = "screwdriver.png^[colorize:#111:160",
	on_place = function(itemstack, placer, pointed_thing)
		local npos = c.npos(pointed_thing.under)
		minetest.set_node(npos, npos.node)
	end,
})
