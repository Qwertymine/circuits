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
	
local pressure_plate = {
	description = "Pressure Plate",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4,-0.5,-0.4,0.4,-0.4,0.4 },
			{-0.2,-0.5,-0.2,0.2,-1.8,0.2 },
		},
	},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.4,0.3,-0.4,0.4,0.5,0.4},
		wall_side = {-0.3,-0.4,-0.4,-0.5,0.4,0.4},
		wall_bottom = {-0.4,-0.3,-0.4,0.4,-0.5,0.4},
	},
	tiles = {"default_mese_block.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {dig_immediate=3,source=1},
	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_contruct = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_timer = function(pos,_)
		local node = minetest.get_node(pos)
		local entity = minetest.get_objects_inside_radius(pos,0.8)

		if entity and #entity >= 1 then
			if not c.is_on(node.name) then
				power_on(node,pos)
			end
		else
			if c.is_on(node.name) then
				power_off(node,pos,true)
			end
		end
		return true
	end,
	on_destruct = function(pos)
		local node = minetest.get_node(pos)
		if c.is_on(node.name) then
			power_off(node,pos,false)
		end
	end,
}

c.register_on_off("circuits:pressure_plate",pressure_plate,
{
	connect = function(plate_pos,to_pos)
		local node = minetest.get_node(plate_pos)
		local powers,as = get_connect_points(node,plate_pos)
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
