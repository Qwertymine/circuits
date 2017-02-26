local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	minetest.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	minetest.swap_node(npos,npos.node)
end

local button = {
	description = "Button",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.15,-0.501,-0.15,0.15,-0.35,0.15 },
			{-0.2,-0.501,-0.2,0.2,-1.8,0.2 },
		},
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.2,0.3,-0.2,0.2,0.5,0.2},
		wall_side = {-0.3,-0.2,-0.2,-0.5,0.2,0.2},
		wall_bottom = {-0.2,-0.3,-0.2,0.2,-0.5,0.2},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {dig_immediate=3,circuit_power=1},
	connects_to = {"group:wire"},
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		local npos = c.npos(pos,node)
		if not c.is_on(npos) then
			c.power_update(npos,"on")
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos,_)
		local npos = c.npos(pos)
		if c.is_on(npos) then
			c.power_update(npos,"off")
		end

		return false
	end,
	circuits = {
		connects = c.behind,
		connects_to = {"circuit_consumer", "circuit_wire"},
		store_connect = "meta",
		on_update = function(npos, args)
			if args == "on" and not c.is_on(npos) then
				power_on(npos)
			elseif args =="off" and c.is_on(npos) then
				power_off(npos)
			else
				return false
			end

			for _,node in ipairs(c.get_all_connected(npos)) do
				c.update(node)
			end
			return true
		end,
		powering = function(npos, rpos)
			return c.is_on(npos)
		end,
	},
}

circuits.register_on_off("circuits:button",button,
{
},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})
