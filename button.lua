local c = circuits

local function get_connect_points(node,pos)
	local power = c.wallmount_real_pos(node.param2,{x=0,y=-2,z=0},pos)
	local as = c.wallmount_real_pos(node.param2,{x=0,y=-1,z=0},pos)
	return power,as
end

local function power_on(node,pos)
	local power,as = get_connect_points(node,pos)
	local on = table.copy(node)
	on.name = c.get_on(node.name)
	c.power(power,as)
	minetest.swap_node(pos,on)
end

local function power_off(node,pos,replace)
	local power,as = get_connect_points(node,pos)
	local off = table.copy(node)
	off.name = c.get_off(node.name)
	c.unpower(power,as)
	if replace then
		minetest.swap_node(pos,off)
	end
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
	groups = {dig_immediate=3,wire=1},
	connects_to = {"group:wire"},
	on_rightclick = function(pos,node,clicker,itemstack,pointed_thing)
		if not c.is_on(node.name) then
			power_on(node,pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos,_)
		local node = minetest.get_node(pos)
		if c.is_on(node.name) then
			power_off(node,pos,true)
		end

		return false
	end,
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		if c.is_on(node.name) then
			power_off(node,pos,false)
		end
	end,
}

circuits.register_on_off("circuits:button",button,
{
	connect = function(power_pos,to_pos)
		local node = minetest.get_node(power_pos)
		local powers,as = get_connect_points(node,power_pos)
		if vector.equals(to_pos,powers) then
			return as,true
		else
			return nil
		end
	end,
},
{
	tiles = {"default_mese_block.png^[colorize:#111:160"},
})
