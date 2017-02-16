
local inverter = {
	description = "Inverter wire",
	drawtype = "normal",
	tiles = {"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_rail_crossing.png^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
	},
	use_texture_alpha = true,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
	on_rightclick = function(pos,node)
		local dir,rot = circuits.facedir_to_dir(node.param2)
		minetest.chat_send_all("{ " .. dir.x ..  ","
			.. dir.y .. "," .. dir.z .. "}")
		minetest.chat_send_all("{ " .. rot.x ..  ","
			.. rot.y .. "," .. rot.z .. "}")
	end,
}

circuits.register_on_off("circuits:inverter",inverter,{
	tiles = {"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^default_rail_crossing.png^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
	},
}, {}
)

local lamp = {
	description = "Lamp",
	drawtype = "normal",
	tiles = {"default_mese_block.png"
		.. "^(default_rail_crossing.png)"
		.. "^default_glass.png"
	},
	use_texture_alpha = true,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	--light_source = 14,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
}

circuits.register_on_off("circuits:lamp",lamp,{},
{
	tiles = {"default_mese_block.png"
		.. "^(default_rail_crossing.png)"
		.. "^[colorize:#111:160"
		.. "^default_glass.png"
	},
	light_source = 0,
})

minetest.register_node("circuits:piston",{
	description = "Piston",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.2,-0.2,-0.2,0.2,1.3,0.2}
			,{-0.5,-0.5,-0.5,0.5,0.5,0.5}
			,{-0.5,1.3,-0.5,0.5,1.5,0.5}
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {0.5,1.5,0.5,-0.5,-0.5,-0.5},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
})

minetest.register_node("circuits:dirs",{
	description = "Inverter wire",
	drawtype = "normal",
	tiles = {
		"y.png","ym.png","x.png","xm.png","z.png","zm.png"
	},
	use_texture_alpha = true,
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
	--[[
	on_rightclick = function(pos,node)
		local dir,rot = circuits.facedir_to_dir(node.param2)
		minetest.chat_send_all("{ " .. dir.x ..  ","
			.. dir.y .. "," .. dir.z .. "}")
		minetest.chat_send_all("{ " .. rot.x ..  ","
			.. rot.y .. "," .. rot.z .. "}")
	end,
	--]]
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		local dir = circuits.pos_facedir_relative(node.param2,pos,pointed_thing.above)
		minetest.chat_send_all("{ " .. dir.x ..  ","
			.. dir.y .. "," .. dir.z .. "}")
	end
})

local through_wire = {
	description = "Through wire",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.2,-0.2,-0.2,0.2,1.499,0.2}
			,{-0.5,-0.5,-0.5,0.5,0.5,0.5}
		},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		local dir = circuits.pos_facedir_relative(node.param2,pos,pointed_thing.above)
		minetest.chat_send_all("{ " .. dir.x ..  ","
			.. dir.y .. "," .. dir.z .. "}")
	end
		
	--[[
	on_rightclick = function(pos,node)
		local dir,rot = circuits.facedir_to_dir(node.param2)
		minetest.chat_send_all("{ " .. dir.x ..  ","
			.. dir.y .. "," .. dir.z .. "}")
		minetest.chat_send_all("{ " .. rot.x ..  ","
			.. rot.y .. "," .. rot.z .. "}")
	end,
	--]]
}
circuits.register_on_off("circuits:through_wire",through_wire,{},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})
