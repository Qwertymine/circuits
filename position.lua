--[[
	A set of position finding utilities for rotatable nodes:
	* wallmounter
	* facedir
--]]

local mounts = {
	y = {
		[-1] = {x="x",y="y",z="z"},
		[1] = {x="x",y="-y",z="-z"},
	},
	x = {
		[-1] = {x="z",y="x",z="y"},
		[1] = {x="-z",y="-x",z="y"},
	},
	z = {
		[-1] = {x="-x",y="z",z="y"},
		[1] = {x="x",y="-z",z="y"},
	},
}

circuits.dir_to_mount = function(dir)
	if dir.x ~= 0 then
		return mounts.x[dir.x]
	elseif dir.y ~= 0 then
		return mounts.y[dir.y]
	elseif dir.z ~= 0 then
		return mounts.z[dir.z]
	end
	return nil
end

local function transform_pos(pos,rot)
	local ret = {}
	for orig,trans in pairs(rot) do
		local axis,dir = "", 1
		if trans == "x" or trans == "y" or trans == "z" then
			axis = trans
		else
			dir = -1
			if trans == "-x" then
				axis = "x"
			elseif trans == "-y" then
				axis = "y"
			elseif trans == "-z" then
				axis = "z"
			end
		end
		ret[orig] = pos[axis] * dir
	end
	return ret
end

local function reverse_transform(pos,rot)
	local ret = {}
	for orig,trans in pairs(rot) do
		local axis,dir = "", 1
		if trans == "x" or trans == "y" or trans == "z" then
			axis = trans
		else
			dir = -1
			if trans == "-x" then
				axis = "x"
			elseif trans == "-y" then
				axis = "y"
			elseif trans == "-z" then
				axis = "z"
			end
		end
		ret[axis] = pos[orig] * dir
	end
	return ret
end

circuits.pos_wallmount_relative = function(wallmount,npos,pos)
	local diff = vector.subtract(pos,npos)
	local rot = circuits.dir_to_mount(minetest.wallmounted_to_dir(wallmount))
	return transform_pos(diff,rot)
end

circuits.wallmount_real_pos = function(wallmount,npos,rpos)
	local rot = circuits.dir_to_mount(minetest.wallmounted_to_dir(wallmount))
	return vector.add(reverse_transform(rpos,rot),npos)
end
	
local axis_dirs = {
	[0] = {x=0,y=-1,z=0},
	{x=0,y=0,z=-1},
	{x=0,y=0,z=1},
	{x=-1,y=0,z=0},
	{x=1,y=0,z=0},
	{x=0,y=1,z=0},
}

local rotations = {
	[axis_dirs[0]] = {
		[0] = {x="x",y="y",z="z"},
		[1] = {x="-z",y="y",z="x"},
		[2] = {x="-x",y="y",z="-z"},
		[3] = {x="z",y="y",z="-x"},
	},
	[axis_dirs[1]] = {
		[0] = {x="x",y="z",z="-y"},
		[1] = {x="y",y="z",z="x"},
		[2] = {x="-x",y="z",z="y"},
		[3] = {x="-y",y="z",z="-x"},
	},
	[axis_dirs[2]] = {
		[0] = {x="x",y="-z",z="y"},
		[1] = {x="-y",y="-z",z="x"},
		[2] = {x="-x",y="-z",z="-y"},
		[3] = {x="y",y="-z",z="-x"},
	},
	[axis_dirs[3]] = {
		[0] = {x="-y",y="x",z="z"},
		[1] = {x="-z",y="x",z="-y"},
		[2] = {x="y",y="x",z="-z"},
		[3] = {x="z",y="x",z="y"},
	},
	[axis_dirs[4]] = {
		[0] = {x="y",y="-x",z="z"},
		[1] = {x="-z",y="-x",z="y"},
		[2] = {x="-y",y="-x",z="-z"},
		[3] = {x="z",y="-x",z="-y"},
	},
	[axis_dirs[5]] = {
		[0] = {x="-x",y="-y",z="z"},
		[1] = {x="-z",y="-y",z="-x"},
		[2] = {x="x",y="-y",z="-z"},
		[3] = {x="z",y="-y",z="x"},
	},

}

circuits.facedir_to_dir = function(facedir)
	local axis_dir = axis_dirs[math.floor(facedir / 4)]
	local rotation = facedir % 4
	return table.copy(axis_dir),table.copy(rotations[axis_dir][rotation])
end

circuits.pos_facedir_relative = function(facedir,npos,pos)
	local diff = vector.subtract(pos,npos)
	local _,rot = circuits.facedir_to_dir(facedir)
	return transform_pos(pos,rot)
end

circuits.facedir_real_pos = function(facedir,npos,rpos)
	local _,rot = circuits.facedir_to_dir(facedir)
	return vector.add(reverse_transform(rpos,rot),npos)
end
	
circuits.relative_pos = function(node,pos)
	return vector.subtract(pos,node)
end

circuits.relative_real_pos = function(node,pos)
	return vector.add(pos,node)
end
