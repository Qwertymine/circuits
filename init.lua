circuits = {}

-- Request insecure environment for luajit bitops
local insecure = minetest.request_insecure_environment()
if not insecure then
	error(table.concat{"\nCircuits requires bitops library to function.\n"
			, "Please add circuits to the trusted mods list\n"
			, "in settings or disable mod security."})
end
bit = insecure.require("bit")

circuits.hash_pos = minetest.hash_node_position
circuits.unhash_pos = minetest.get_position_from_hash

local modpath = minetest.get_modpath("circuits")

dofile(modpath .. "/util.lua")
dofile(modpath .. "/position.lua")
dofile(modpath .. "/connection.lua")
dofile(modpath .. "/persistance.lua")
dofile(modpath .. "/power.lua")
dofile(modpath .. "/wire.lua")
dofile(modpath .. "/wire_node.lua")
dofile(modpath .. "/lamp.lua")
dofile(modpath .. "/indicator.lua")
dofile(modpath .. "/inverter.lua")
dofile(modpath .. "/pressure_plate.lua")
dofile(modpath .. "/button.lua")
dofile(modpath .. "/wrench.lua")
--dofile(modpath .. "/prototype.lua")
