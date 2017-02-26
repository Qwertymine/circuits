local c = circuits
local database_path = minetest.get_worldpath() .. "/circuits_db.txt"

--[[ {
--	[1..max_update_time] = update_list
--
--	producer = {updates}
--	wire     = {updates}
--	consumer = {updates}
--
--	wait = {}
--	longstay = {} 	-- Storage for updates > max_update_time
--   }
--]]

local file = io.open(database_path,"r")
if file then
	local pending_string = file:read("*all")
	if pending_string and pending_string ~= "" then
		c.pending = minetest.deserialize(pending_string)
	end
	file:close()
end

if not c.pending then
	c.pending = {
		update_list = {},
		wait = {},
	}
end

local function save_pending()
	local file = assert(io.open(database_path,"w"))
	local pending_string = minetest.serialize(c.pending)
	if pending_string then
		file:write(pending_string)
	end
	file:close()
end

minetest.register_on_shutdown(save_pending)
