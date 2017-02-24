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

-- Returns the mapping matrix for each possible dir
-- dir - dir in the form {y=-2}
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

-- Applies tranformation in the form in mounts matrix
-- rot - mapping matrix
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

-- Reverses the transformation applied by transform_pos
-- rot - mapping matrix
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

-- Converts a wallmounted position to a relative pos
-- wallmount - param of wallmounted node
-- npos - pos of wallmounted node
-- pos - real pos of node
circuits.pos_wallmount_relative = function(wallmount,npos,pos)
	local diff = vector.subtract(pos,npos)
	local rot = circuits.dir_to_mount(minetest.wallmounted_to_dir(wallmount))
	return transform_pos(diff,rot)
end

-- Converts wallmounted relative pos into real pos
-- wallmount - param of wallmounted node
-- npos - pos of wallmouned node
-- rpos - relative pos
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

-- Returns the vertical axis and axis transformations of a facedir node
circuits.facedir_to_dir = function(facedir)
	local axis_dir = axis_dirs[math.floor(facedir / 4)]
	local rotation = facedir % 4
	return table.copy(axis_dir),table.copy(rotations[axis_dir][rotation])
end

-- Transforms pos to pos relative to a facedir node
-- facedir - param of facedir node
-- npos - pos of facedir node
-- pos - real pos
circuits.pos_facedir_relative = function(facedir,npos,pos)
	local diff = vector.subtract(pos,npos)
	local _,rot = circuits.facedir_to_dir(facedir)
	return transform_pos(pos,rot)
end

-- Transforms a real pos into a pos relative to facedir node
-- facedir - param of facedir node
-- npos - pos of facedir node
-- rpos - real pos
circuits.facedir_real_pos = function(facedir,npos,rpos)
	local _,rot = circuits.facedir_to_dir(facedir)
	return vector.add(reverse_transform(rpos,rot),npos)
end
	
circuits.relative_pos = function(node,pos)
	return vector.subtract(pos,node)
end

circuits.relative_real_pos = function(node,rpos)
	return vector.add(node,rpos)
end

circuits.invert_relative = function(dir)
	return vector.multiply(dir, -1)
end

circuits.rpos_is_dir = function(rpos)
	local mag
	if rpos.x ~= 0 then
		if rpos.y ~= 0
		or rpos.z ~= 0 then
			return nil
		end

		mag = rpos.x

	elseif rpos.y ~= 0 then
		if rpos.z ~= 0 then
			return nil
		end

		mag = rpos.y

	elseif rpos.z ~= 0 then

		mag = rpos.z
	end

	if mag then
		return vector.divide(rpos, math.abs(mag))
	end

	return nil
end

-- Takes two npos and returns the rpos for a, relative to
-- any rotation a might have
-- a - npos a 
-- b - pos b
circuits.rot_relative_pos = function(a, b)
	local a_cd = circuits.get_circuit_def(a.node.name)
	if a_cd.rot == "wallmounted" then
		return circuits.pos_wallmount_relative(a.node.param1, a, b)
	elseif a_cd.rot == "facedir" then
		return circuits.pos_facedir_relative(a.node.param1, a, b)
	else
		return circuits.relative_pos(a, b)
	end
end
	
-- Takes two one npos and an rpos, and returns the real pos, relative to
-- any rotation a might have
-- a - npos a 
-- rpos - rpos (b)
circuits.rot_relative_real_pos = function(a, rpos)
	local a_cd = circuits.get_circuit_def(a.node.name)
	if a_cd.rot == "wallmounted" then
		return circuits.wallmount_real_pos(a.node.param1, a, rpos)
	elseif a_cd.rot == "facedir" then
		return circuits.facedir_real_pos(a.node.param1, a, rpos)
	else
		return circuits.relative_real_pos(a, rpos)
	end
end


--[[
--	A set of basic connection configs for use 
--	in node defs
--]]

circuits.local_area = {
	x = {1, -1},
	y = {1, -1},
	z = {1, -1}
}

circuits.behind = {
	y = {0, -2}
}
