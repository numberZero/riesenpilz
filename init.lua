local load_time_start = os.clock()
local MAX_SIZE = 3

riesenpilz = {}
dofile(minetest.get_modpath("riesenpilz").."/settings.lua")
dofile(minetest.get_modpath("riesenpilz").."/functions.lua")

local function r_area(manip, width, height, pos)
	local emerged_pos1, emerged_pos2 = manip:read_from_map(
		{x=pos.x-width, y=pos.y, z=pos.z-width},
		{x=pos.x+width, y=pos.y+height, z=pos.z+width}
	)
	return VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
end

local function set_vm_data(manip, nodes, pos, t1, name)
	manip:set_data(nodes)
	manip:write_to_map()
	riesenpilz.inform("a "..name.." mushroom grew at ("..pos.x.."|"..pos.y.."|"..pos.z..")", 3, t1)
	local t1 = os.clock()
	manip:update_map()
	riesenpilz.inform("map updated", 3, t1)
end

--Growing Functions

local c

function riesenpilz_hybridpilz(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, MAX_SIZE+1, MAX_SIZE+3, pos)
	local nodes = manip:get_data()

	local breite = math.random(MAX_SIZE)
	local br = breite+1
	local height = breite+2

	for i = 0, height, 1 do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem
	end

	for l = -br+1, br, 1 do
		for k = -1, 1, 2 do
			nodes[area:index(pos.x+br*k, pos.y+height, pos.z-l*k)] = c.head_red
			nodes[area:index(pos.x+l*k, pos.y+height, pos.z+br*k)] = c.head_red
		end
	end

	for k = -breite, breite, 1 do
		for l = -breite, breite, 1 do
			nodes[area:index(pos.x+l, pos.y+height+1, pos.z+k)] = c.head_red
			nodes[area:index(pos.x+l, pos.y+height, pos.z+k)] = c.lamellas
		end
	end

	set_vm_data(manip, nodes, pos, t1, "red")
end


function riesenpilz_brauner_minecraftpilz(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, MAX_SIZE+1, MAX_SIZE+2, pos)
	local nodes = manip:get_data()

	local random = math.random(MAX_SIZE-1)
	local br	 = random+1
	local breite = br+1
	local height = br+2

	for i in area:iterp(pos, {x=pos.x, y=pos.y+height, z=pos.z}) do
		nodes[i] = c.stem
	end

	for l = -br, br, 1 do
		for k = -breite, breite, breite*2 do
			nodes[area:index(pos.x+k, pos.y+height+1, pos.z+l)] = c.head_brown
			nodes[area:index(pos.x+l, pos.y+height+1, pos.z+k)] = c.head_brown
		end
		for k = -br, br, 1 do
			nodes[area:index(pos.x+l, pos.y+height+1, pos.z+k)] = c.head_brown
		end
	end

	set_vm_data(manip, nodes, pos, t1, "brown")
end


function riesenpilz_minecraft_fliegenpilz(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 2, 4, pos)
	local nodes = manip:get_data()
	local param2s = manip:get_param2_data() 

	local height = 3

	for i = 0, height, 1 do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem
	end

	for j = -1, 1, 1 do
		for k = -1, 1, 1 do
			nodes[area:index(pos.x+j, pos.y+height+1, pos.z+k)] = c.head_red
		end
		for l = 1, height, 1 do
			local y = pos.y+l
			for _,p in ipairs({
				{area:index(pos.x+j, y, pos.z+2), 0},
				{area:index(pos.x+j, y, pos.z-2), 2},
				{area:index(pos.x+2, y, pos.z+j), 1},
				{area:index(pos.x-2, y, pos.z+j), 3},
			}) do
				local tmp = p[1]
				nodes[tmp] = c.head_red_side
				param2s[tmp] = p[2]
			end
		end
	end

	manip:set_data(nodes)
	manip:set_param2_data(param2s)
	manip:write_to_map()
	manip:update_map()
	riesenpilz.inform("a fly agaric grew at ("..pos.x.."|"..pos.y.."|"..pos.z..")", 3, t1)
end


local function ran_node(a, b, ran)
	if math.random(ran) == 1 then
		return a
	end
	return b
end

function riesenpilz_lavashroom(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 4, MAX_SIZE+7, pos)
	local nodes = manip:get_data()

	local height = 3+math.random(MAX_SIZE-2)
	nodes[area:index(pos.x, pos.y, pos.z)] = c.air

	for i = -1, 1, 2 do
		local o = 2*i

		for n = 0, height, 1 do
			nodes[area:index(pos.x+i, pos.y+n, pos.z)] = c.stem_brown
			nodes[area:index(pos.x, pos.y+n, pos.z+i)] = c.stem_brown
		end

		for l = -1, 1, 1 do
			for k = 2, 3, 1 do
				nodes[area:index(pos.x+k*i, pos.y+height+2, pos.z+l)] = c.head_brown_full
				nodes[area:index(pos.x+l, pos.y+height+2, pos.z+k*i)] = c.head_brown_full
			end
			nodes[area:index(pos.x+l, pos.y+height+1, pos.z+o)] = c.head_brown_full
			nodes[area:index(pos.x+o, pos.y+height+1, pos.z+l)] = c.head_brown_full
		end

		for m = -1, 1, 2 do
			for k = 2, 3, 1 do
				for j = 2, 3, 1 do
					nodes[area:index(pos.x+j*i, pos.y+height+2, pos.z+k*m)] = ran_node(c.head_yellow, c.head_orange, 7)
				end
			end
			nodes[area:index(pos.x+i, pos.y+height+1, pos.z+m)] = c.head_brown_full
			nodes[area:index(pos.x+m*2, pos.y+height+1, pos.z+o)] = c.head_brown_full
		end

		for l = -3+1, 3, 1 do
			nodes[area:index(pos.x+3*i, pos.y+height+5, pos.z-l*i)] = ran_node(c.head_yellow, c.head_orange, 5)
			nodes[area:index(pos.x+l*i, pos.y+height+5, pos.z+3*i)] = ran_node(c.head_yellow, c.head_orange, 5)
		end

		for j = 0, 1, 1 do
			for l = -3, 3, 1 do
				nodes[area:index(pos.x+i*4, pos.y+height+3+j, pos.z+l)] = ran_node(c.head_yellow, c.head_orange, 6)
				nodes[area:index(pos.x+l, pos.y+height+3+j, pos.z+i*4)] = ran_node(c.head_yellow, c.head_orange, 6)
			end
		end

	end

	for k = -2, 2, 1 do
		for l = -2, 2, 1 do
			nodes[area:index(pos.x+k, pos.y+height+6, pos.z+l)] = ran_node(c.head_yellow, c.head_orange, 4)
		end
	end

	set_vm_data(manip, nodes, pos, t1, "lavashroom")
end


function riesenpilz_glowshroom(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 2, MAX_SIZE+5, pos)
	local nodes = manip:get_data()

	local height = 2+math.random(MAX_SIZE)
	local br = 2

	for i = 0, height, 1 do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.stem_blue
	end

	for i = -1, 1, 2 do

		for k = -br, br, 2*br do
			for l = 2, height, 1 do
				nodes[area:index(pos.x+i*br, pos.y+l, pos.z+k)] = c.head_blue
			end
			nodes[area:index(pos.x+i*br, pos.y+1, pos.z+k)] = c.head_blue_bright
		end

		for l = -br+1, br, 1 do
			nodes[area:index(pos.x+i*br, pos.y+height, pos.z-l*i)] = c.head_blue
			nodes[area:index(pos.x+l*i, pos.y+height, pos.z+br*i)] = c.head_blue
		end

	end

	for l = 0, br, 1 do
		for i = -br+l, br-l, 1 do
			for k = -br+l, br-l, 1 do
				nodes[area:index(pos.x+i, pos.y+height+1+l, pos.z+k)] = c.head_blue
			end
		end
	end

	set_vm_data(manip, nodes, pos, t1, "glowshroom")
end


function riesenpilz_parasol(pos)
	local t1 = os.clock()

	local height = 6+math.random(MAX_SIZE)
	local br = math.random(MAX_SIZE+1,MAX_SIZE+2)

	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, br, height, pos)
	local nodes = manip:get_data()

	local rh = math.random(2,3)
	local bhead1 = br-1
	local bhead2 = math.random(1,br-2)

	--stem
	for i in area:iterp(pos, {x=pos.x, y=pos.y+height-2, z=pos.z}) do
		nodes[i] = c.stem
	end

	for _,j in ipairs({
		{bhead2, 0, c.head_brown_bright},
		{bhead1, -1, c.head_binge}
	}) do
		for i in area:iter(pos.x-j[1], pos.y+height+j[2], pos.z-j[1], pos.x+j[1], pos.y+height+j[2], pos.z+j[1]) do
			nodes[i] = j[3]
		end
	end

	for k = -1, 1, 2 do
		for l = 0, 1 do
			nodes[area:index(pos.x+k, pos.y+rh, pos.z-l*k)] = c.head_white
			nodes[area:index(pos.x+l*k, pos.y+rh, pos.z+k)] = c.head_white
		end
		for l = -br+1, br do
			nodes[area:index(pos.x+br*k, pos.y+height-2, pos.z-l*k)] = c.head_binge
			nodes[area:index(pos.x+l*k, pos.y+height-2, pos.z+br*k)] = c.head_binge
		end
		for l = -bhead1+1, bhead1 do
			nodes[area:index(pos.x+bhead1*k, pos.y+height-2, pos.z-l*k)] = c.head_white
			nodes[area:index(pos.x+l*k, pos.y+height-2, pos.z+bhead1*k)] = c.head_white
		end
	end

	set_vm_data(manip, nodes, pos, t1, "parasol")
end


function riesenpilz_apple(pos)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local area = r_area(manip, 5, 14, pos)
	local nodes = manip:get_data()

	local size = 5
	local a = size*2
	local b = size-1

	for l = -b, b, 1 do
		for j = 1, a-1, 1 do
			for k = -size, size, a do
				nodes[area:index(pos.x+k, pos.y+j, pos.z+l)] = c.red
				nodes[area:index(pos.x+l, pos.y+j, pos.z+k)] = c.red
			end
		end
		for i = -b, b, 1 do
			nodes[area:index(pos.x+i, pos.y, pos.z+l)] = c.red
			nodes[area:index(pos.x+i, pos.y+a, pos.z+l)] = c.red
		end
	end

	for i = a+1, a+b, 1 do
		nodes[area:index(pos.x, pos.y+i, pos.z)] = c.tree
	end

	local c = pos.y+1
	for i = -3,1,1 do
		nodes[area:index(pos.x+i, c, pos.z+1)] = c.brown
	end
	for i = 0,1,1 do
		nodes[area:index(pos.x+i+1, c, pos.z-1-i)] = c.brown
		nodes[area:index(pos.x+i+2, c, pos.z-1-i)] = c.brown
	end
	nodes[area:index(pos.x+1, c, pos.z)] = c.brown
	nodes[area:index(pos.x-3, c+1, pos.z+1)] = c.brown

	manip:set_data(nodes)
	manip:write_to_map()
	riesenpilz.inform("an apple grew at ("..pos.x.."|"..pos.y.."|"..pos.z..")", 3, t1)
	manip:update_map()
end



--3D apple [3apple]


local tmp = minetest.registered_nodes["default:apple"]
minetest.register_node(":default:apple", {
	description = tmp.description,
	drawtype = "nodebox",
	visual_scale = tmp.visual_scale,
	tiles = {"3apple_apple_top.png","3apple_apple_bottom.png","3apple_apple.png"},
	inventory_image = tmp.inventory_image,
	sunlight_propagates = tmp.sunlight_propagates,
	walkable = tmp.walkable,
	paramtype = tmp.paramtype,
	node_box = {
		type = "fixed",
		fixed = {
			{-3/16,	-7/16,	-3/16,	3/16,	1/16,	3/16},
			{-4/16,	-6/16,	-3/16,	4/16,	0,		3/16},
			{-3/16,	-6/16,	-4/16,	3/16,	0,		4/16},
			{-1/32,	1/16,	-1/32,	1/32,	4/16,	1/32},
			{-1/16,	1.6/16,	0,		1/16,	1.8/16,	1/16},
			{-2/16,	1.4/16,	1/16,	1/16,	1.6/16,	2/16},
			{-2/16,	1.2/16,	2/16,	0,		1.4/16,	3/16},
			{-1.5/16,	1/16,	.5/16,	0.5/16,		1.2/16,	2.5/16},
		}
	},
	groups = tmp.groups,
	on_use = tmp.on_use,
	sounds = tmp.sounds,
	after_place_node = tmp.after_place_node,
})



--Mushroom Nodes


local BOX = {
	RED = {
		{-1/16, -8/16, -1/16, 1/16, -6/16, 1/16},
		{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16},
		{-4/16, -5/16, -4/16, 4/16, -4/16, 4/16},
		{-3/16, -4/16, -3/16, 3/16, -3/16, 3/16},
		{-2/16, -3/16, -2/16, 2/16, -2/16, 2/16}
	},
	BROWN = {
		{-0.15, -0.2, -0.15, 0.15, -0.1, 0.15},
		{-0.2, -0.3, -0.2, 0.2, -0.2, 0.2},
		{-0.05, -0.5, -0.05, 0.05, -0.3, 0.05}
	},
	FLY_AGARIC = {
		{-0.05, -0.5, -0.05, 0.05, 1/20, 0.05},
		{-3/20, -6/20, -3/20, 3/20, 0, 3/20},
		{-4/20, -2/20, -4/20, 4/20, -4/20, 4/20}
	},
	LAVASHROOM = {
		{-1/16, -8/16, -1/16, 1/16, -6/16, 1/16},
		{-2/16, -6/16, -2/16, 2/16,     0, 2/16},
		{-3/16, -5/16, -3/16, 3/16, -1/16, 3/16},
		{-4/16, -4/16, -4/16, 4/16, -2/16, 4/16}
	},
	GLOWSHROOM = {
		{-1/16, -8/16, -1/16, 1/16, -1/16, 1/16},
		{-2/16, -3/16, -2/16, 2/16, -2/16, 2/16},
		{-3/16, -5/16, -3/16, 3/16, -3/16, 3/16},
		{-3/16, -7/16, -3/16, -2/16, -5/16, -2/16},
		{3/16, -7/16, -3/16, 2/16, -5/16, -2/16},
		{-3/16, -7/16, 3/16, -2/16, -5/16, 2/16},
		{3/16, -7/16, 3/16, 2/16, -5/16, 2/16}
	},
	NETHER_SHROOM = {
		{-1/16, -8/16, -1/16, 1/16, -2/16, 1/16},
		{-2/16, -6/16, -2/16, 2/16, -5/16, 2/16},
		{-3/16, -2/16, -3/16, 3/16,     0, 3/16},
		{-4/16, -1/16, -4/16, 4/16,  1/16,-2/16},
		{-4/16, -1/16,  2/16, 4/16,  1/16, 4/16},
		{-4/16, -1/16, -2/16,-2/16,  1/16, 2/16},
		{ 2/16, -1/16, -2/16, 4/16,  1/16, 2/16}
	},
	PARASOL = {
		{-1/16, -8/16, -1/16, 1/16,  0, 1/16},
		{-2/16, -6/16, -2/16, 2/16, -5/16, 2/16},
		{-5/16, -4/16, -5/16, 5/16, -3/16, 5/16},
		{-4/16, -3/16, -4/16, 4/16, -2/16, 4/16},
		{-3/16, -2/16, -3/16, 3/16, -1/16, 3/16}
	},
	RED45 = {
		{-1/16, -0.5, -1/16, 1/16, 1/8, 1/16},
		{-3/16, 1/8, -3/16, 3/16, 1/4, 3/16},
		{-5/16, -1/4, -5/16, -1/16, 1/8, -1/16},
		{1/16, -1/4, -5/16, 5/16, 1/8, -1/16},
		{-5/16, -1/4, 1/16, -1/16, 1/8, 5/16},
		{1/16, -1/4, 1/16, 5/16, 1/8, 5/16}
	},
	BROWN45 = {
		{-1/16, -0.5, -1/16, 1/16, 1/16, 1/16},
		{-3/8, 1/8, -7/16, 3/8, 1/4, 7/16},
		{-7/16, 1/8, -3/8, 7/16, 1/4, 3/8},
		{-3/8, 1/4, -3/8, 3/8, 5/16, 3/8},
		{-3/8, 1/16, -3/8, 3/8, 1/8, 3/8}
	},
}


local mushrooms_list = {
	["brown"] = {
		description = "brown mushroom",
		box = BOX.BROWN,
		growing = {
			r = {min=3, max=4},
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:tree"},
			light = {min=1, max=4},
			interval = 1,--100,
			chance = 1,--18,
		},
	},
	["red"] = {
		description = "red mushroom",
		box = BOX.RED,
		growing = {
			r = {min=4, max=5},
			grounds = {soil=2},
			neighbours = {"default:water_flowing"},
			light = {min=3, max=10},
			interval = 50,
			chance = 30,
		},
	},
	["fly_agaric"] = {
		description = "fly agaric",
		box = BOX.FLY_AGARIC,
		growing = {
			r = 4,
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:pinetree"},
			light = {min=2, max=7},
			interval = 101,
			chance = 30,
		},
	},
	["lavashroom"] = {
		description = "Lavashroom",
		box = BOX.LAVASHROOM,
		growing = {
			r = {min=5, max=6},
			grounds = {cracky=3},
			neighbours = {"default:lava_source"},
			light = {min=10, max=14},
			interval = 1010,
			chance = 60,
		},
	},
	["glowshroom"] = {
		description = "Glowshroom",
		box = BOX.GLOWSHROOM,
		growing = {
			r = 3,
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:stone"},
			light = 0,
			interval = 710,
			chance = 120,
		},
	},
	["nether_shroom"] = {
		description = "Nether mushroom",
		box = BOX.NETHER_SHROOM,
		burntime = 6,
	},
	["parasol"] = {
		description = "white parasol mushroom",
		box = BOX.PARASOL,
		growing = {
			r = {min=3, max=5},
			grounds = {soil=1, crumbly=3},
			neighbours = {"default:pinetree"},
			light = {min=1, max=7},
			interval = 51,
			chance = 36,
		},
	},
	["red45"] = {
		description = "45 red mushroom",
		box = BOX.RED45,
		growing = {
			r = {min=3, max=4},
			grounds = {soil=2},
			neighbours = {"default:water_source"},
			light = {min=2, max=3},
			interval = 1000,
			chance = 180,
		},
	},
	["brown45"] = {
		description = "45 brown mushroom",
		box = BOX.BROWN45,
		growing = {
			r = {min=2, max=3},
			grounds = {tree=1},
			neighbours = {"default:water_flowing"},
			light = {min=7, max=11},
			interval = 100,
			chance = 20,
		},
	},
}

local abm_allowed = true
for name,i in pairs(mushrooms_list) do
	local burntime = i.burntime or 1
	local box = {
		type = "fixed",
		fixed = i.box
	}
	local nd = "riesenpilz:"..name
	minetest.register_node(nd, {
		description = i.description,
		tiles = {"riesenpilz_"..name.."_top.png", "riesenpilz_"..name.."_bottom.png", "riesenpilz_"..name.."_side.png"},
		inventory_image = "riesenpilz_"..name.."_side.png",
		walkable = false,
		buildable_to = true,
		drawtype = "nodebox",
		paramtype = "light",
		groups = {snappy=3,flammable=2,attached_node=1},
		sounds =  default.node_sound_leaves_defaults(),
		node_box = box,
		selection_box = box,
		furnace_burntime = burntime
	})

	local g = i.growing

	if g then
		local grounds = g.grounds
		local nds = {}
		for n in pairs(grounds) do
			table.insert(nds, "group:"..n)
		end

		local nbs = table.copy(g.neighbours)
		table.insert(nbs, "air")

		local r = g.r
		local rmin, rmax
		if type(r) == "table" then
			rmin = r.min
			rmax = r.max
		else
			rmin = r or 3
			rmax = rmin
		end

		local l = g.light
		local lmin, lmax
		if type(l) == "table" then
			lmin = l.min
			lmax = l.max
		else
			lmin = l or 3
			lmax = lmin
		end

		minetest.register_abm({
			nodenames = nds,
			neighbors = g.neighbours,
			interval = g.interval,
			chance = g.chance,
			action = function(pos, node)

			-- don't spawn mushroom circles next to other ones
				if minetest.find_node_near(pos, rmax, nd) then
					return
				end

			-- spawn them around the right nodes
				local data = minetest.registered_nodes[node.name]
				if not data
				or not data.groups then
					return
				end
				local groups = data.groups
				for n,i in pairs(grounds) do
					if groups[n] ~= i then
						return
					end
				end

			-- find their neighbours
				for _,n in pairs(nbs) do
					if not minetest.find_node_near(pos, rmin, n) then
						return
					end
				end

			-- should disallow lag
				abm_allowed = false
				minetest.after(2, function() abm_allowed = true end)

			-- witch circles
				for _,p in pairs(vector.circle(math.random(rmin, rmax))) do
					local p = vector.add(pos, p)

				-- currently 3 is used here, approved by its use in the mapgen
					if math.random(3) == 1 then

					-- don't only use the current y for them
						for y = 2,0,-1 do
							local pos = {x=p.x, y=p.y+y, z=p.z}
							if minetest.get_node(pos).name ~= "air" then
								break
							end
							local f = minetest.get_node({x=p.x, y=p.y+y-1, z=p.z}).name
							if f ~= "air" then

							-- they grown on walkable, cubic nodes
								local data = minetest.registered_nodes[f]
								if data
								and data.walkable
								and (not data.drawtype
									or data.drawtype == "normal"
								) then

								-- they also need specific light strengths
									local light = minetest.get_node_light(pos, 0.5)
									if light >= lmin
									and light <= lmax then
										minetest.set_node(pos, {name=nd})
										print("[riesenpilz] a mushroom grew at "..vector.pos_to_string(pos))
									end
								end
								break
							end
						end
					end
				end
				print("[riesenpilz] "..nd.." mushrooms grew at "..minetest.pos_to_string(pos))
			end
		})
	end
end


--Mushroom Blocks


local function pilznode(name, desc, textures, sapling)
minetest.register_node("riesenpilz:"..name, {
	description = desc,
	tiles = textures,
	groups = {oddly_breakable_by_hand=3},
	drop = {max_items = 1,
		items = {{items = {"riesenpilz:"..sapling},rarity = 20,},
				{items = {"riesenpilz:"..name},rarity = 1,}}},
})
end


local r = "riesenpilz_"
local h = "head_"
local s = "stem_"
local rh = r..h
local rs = r..s

local GS = "giant mushroom "
local GSH = GS.."head "
local GSS = GS.."stem "

local pilznode_list = {
	{"stem", GSS.."beige", {rs.."top.png", rs.."top.png", "riesenpilz_stem.png"}, "stem"},
	{s.."brown", GSS.."brown", {rs.."top.png", rs.."top.png", rs.."brown.png"}, s.."brown"},
	{s.."blue", GSS.."blue", {rs.."top.png",rs.."top.png",rs.."blue.png"}, s.."blue"},
	{"lamellas", "giant mushroom lamella", {"riesenpilz_lamellas.png"}, "lamellas"},
	{h.."red", GSH.."red", {"riesenpilz_head.png", "riesenpilz_lamellas.png", "riesenpilz_head.png"}, "red"},
	{h.."orange", GSH.."orange", {rh.."orange.png"}, "lavashroom"},
	{h.."yellow", GSH.."yellow", {rh.."yellow.png"}, "lavashroom"},
	{h.."brown", GSH.."brown", {r.."brown_top.png", r.."lamellas.png", r.."brown_top.png"}, "brown"},
	{h.."brown_full", GSH.."full brown", {r.."brown_top.png"},"brown"},
	{h.."blue_bright", GSH.."blue bright", {rh.."blue_bright.png"},"glowshroom"},
	{h.."blue", GSH.."blue", {rh.."blue.png"},"glowshroom"},
	{h.."white", GSH.."white", {rh.."white.png"},"parasol"},
	{h.."binge", GSH.."binge", {rh.."binge.png", rh.."white.png", rh.."binge.png"},"parasol"},
	{h.."brown_bright", GSH.."brown bright", {rh.."brown_bright.png", rh.."white.png", rh.."brown_bright.png"},"parasol"},
}

for _,i in ipairs(pilznode_list) do
	pilznode(i[1], i[2], i[3], i[4])
end


minetest.register_node("riesenpilz:head_red_side", {
	description = "giant mushroom head red side",
	tiles = {"riesenpilz_head.png",	"riesenpilz_lamellas.png",	"riesenpilz_head.png",
					"riesenpilz_head.png",	"riesenpilz_head.png",	"riesenpilz_lamellas.png"},
	paramtype2 = "facedir",
	groups = {oddly_breakable_by_hand=3},
	drop = {max_items = 1,
		items = {{items = {"riesenpilz:fly_agaric"},rarity = 20,},
				{items = {"riesenpilz:head_red"},rarity = 1,}}},
})

minetest.register_node("riesenpilz:ground", {
	description = "dirt with rotten grass",
	tiles = {"riesenpilz_ground_top.png","default_dirt.png","default_dirt.png^riesenpilz_ground_side.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
	drop = 'default:dirt'
})


c = {
	air = minetest.get_content_id("air"),

	stem = minetest.get_content_id("riesenpilz:stem"),
	head_red = minetest.get_content_id("riesenpilz:head_red"),
	lamellas = minetest.get_content_id("riesenpilz:lamellas"),

	head_brown = minetest.get_content_id("riesenpilz:head_brown"),

	head_red_side = minetest.get_content_id("riesenpilz:head_red_side"),

	stem_brown = minetest.get_content_id("riesenpilz:stem_brown"),
	head_brown_full = minetest.get_content_id("riesenpilz:head_brown_full"),
	head_orange = minetest.get_content_id("riesenpilz:head_orange"),
	head_yellow = minetest.get_content_id("riesenpilz:head_yellow"),

	stem_blue = minetest.get_content_id("riesenpilz:stem_blue"),
	head_blue = minetest.get_content_id("riesenpilz:head_blue"),
	head_blue_bright = minetest.get_content_id("riesenpilz:head_blue_bright"),

	head_white = minetest.get_content_id("riesenpilz:head_white"),
	head_binge = minetest.get_content_id("riesenpilz:head_binge"),
	head_brown_bright = minetest.get_content_id("riesenpilz:head_brown_bright"),

	red = minetest.get_content_id("default:copperblock"),
	brown = minetest.get_content_id("default:desert_stone"),
	tree = minetest.get_content_id("default:tree"),
}



--Growing


minetest.register_tool("riesenpilz:growingtool", {
	description = "growingtool",
	inventory_image = "riesenpilz_growingtool.png",
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if puncher:get_wielded_item():get_name() == "riesenpilz:growingtool" then
		local name = node.name
		if name == "riesenpilz:red" then
			riesenpilz_hybridpilz(pos)
		elseif name == "riesenpilz:fly_agaric" then
			riesenpilz_minecraft_fliegenpilz(pos)
		elseif name == "riesenpilz:brown" then
			riesenpilz_brauner_minecraftpilz(pos)
		elseif name == "riesenpilz:lavashroom" then
			riesenpilz_lavashroom(pos)
		elseif name == "riesenpilz:glowshroom" then
			riesenpilz_glowshroom(pos)
		elseif name == "riesenpilz:parasol" then
			riesenpilz_parasol(pos)
		elseif name == "default:apple" then
			riesenpilz_apple(pos)
		end
	end
end)



if riesenpilz.enable_mapgen then
	dofile(minetest.get_modpath("riesenpilz") .. "/mapgen.lua")
end

riesenpilz.inform("loaded", 1, load_time_start)
