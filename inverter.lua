local c = circuits

local function power_on(npos)
	npos.node.name = c.get_powered(npos)
	minetest.swap_node(npos,npos.node)
end

local function power_off(npos)
	npos.node.name = c.get_off(npos)
	minetest.swap_node(npos,npos.node)
end

local inverter = {
	description = "Inverter",
	drawtype = "normal",
	tiles = {"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^carts_rail_crossing.png^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
		,"(default_mese_block.png)^default_glass.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {dig_immediate=3, circuit_consumer=1, circuit_power=1},
	on_rightclick = function(pos,node)
		local flags = minetest.get_meta(pos):get_int("connect")
		pos.node = node
		minetest.chat_send_all(flags)
		for _,real in pairs(c.get_all_connected(pos)) do
			local dir = c.rot_relative_pos(pos, real)
			minetest.chat_send_all("{ " .. dir.x ..  ","
				.. dir.y .. "," .. dir.z .. "}")
		end
	end,
	--after_place_node = function(pos,placer,itemstack,pointed_thing)
	circuits = {
		base_node = "circuits:inverter",
		connects = c.local_area,
		connects_to = {"circuit_consumer","circuit_wire","circuit_power"},
		store_connect = "meta",
		on_update = function(npos, args, type)
			if type == "power" then
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
			elseif type == "consumer" then
				local node = c.get_connected_in_dir(npos,{x=0, y=-1, z=0})
				local power
				if not node then
					power = false
				else
					power = c.is_powering(node, npos)
				end
				if not power and not c.is_on(npos) then
					c.power_update(npos,"on")
				elseif power and c.is_on(npos) then
					c.power_update(npos,"off")
				end
				return false
			end
		end,
		powering = function(npos, rpos)
			if rpos.y == -1 then
				return false
			end

			return c.is_on(npos)
		end,
	},
}

c.register_on_off("circuits:inverter",inverter,
{
},
{
	tiles = {"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^carts_rail_crossing.png^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
		,"(default_mese_block.png)"
		.. "^[colorize:#111:160^default_glass.png"
	},
})
