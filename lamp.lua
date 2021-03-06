local c = circuits

local lamp = {
	description = "Lamp",
	drawtype = "normal",
	tiles = {"default_mese_block.png"
		.. "^(carts_rail_crossing.png)"
		.. "^default_glass.png"
	},
	use_texture_alpha = true,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	light_source = 14,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,circuit_consumer=1},
	connects_to = {"group:circuit_wire","group:circuit_power"},
	circuits = {
		connects = c.local_area,
		connects_to = {"circuit_wire", "circuit_power"},
		store_connect = "meta",
		on_update = function(npos)
			for _,node in ipairs(c.get_all_connected(npos)) do
				if c.is_powering(node, npos) then
					if not c.is_on(npos) then
						npos.node.name = c.get_powered(npos)
						minetest.swap_node(npos,npos.node)
						return true
					else
						return false
					end
				end
			end

			if c.is_on(npos) then
				npos.node.name = c.get_off(npos)
				minetest.swap_node(npos,npos.node)
				return true
			else
				return false
			end
		end

	},

}

c.register_on_off("circuits:lamp",lamp,{},
{
	tiles = {"default_mese_block.png"
		.. "^(carts_rail_crossing.png)"
		.. "^[colorize:#111:160"
		.. "^default_glass.png"
	},
	light_source = 0,
})

