--[[ Serverside Custom Addon file Base ]]--
MA = {}

local RD = {}

local respawn = {}
local asteroid_entities = {}

local asteroid_resources = {}
local mining_resources = {}
local crystal_resources = {}
local drill_resources = {}

local asteroids = {}
MA.asteroid_models = {}
MA.asteroid_models["mine"] = "models/ce_ls3additional/asteroids/asteroid_400.mdl" --Will remove soon
MA.asteroid_models["titanium"] = 0 --Skin numbers in the "metal" land-based mines
MA.asteroid_models["naquadah"] = 1
MA.asteroid_models["200"] = "models/ce_ls3additional/asteroids/asteroid_200.mdl"
MA.asteroid_models["250"] = "models/ce_ls3additional/asteroids/asteroid_250.mdl"
MA.asteroid_models["300"] = "models/ce_ls3additional/asteroids/asteroid_300.mdl"
MA.asteroid_models["350"] = "models/ce_ls3additional/asteroids/asteroid_350.mdl"
MA.asteroid_models["400"] = "models/ce_ls3additional/asteroids/asteroid_400.mdl"
MA.asteroid_models["450"] = "models/ce_ls3additional/asteroids/asteroid_450.mdl"
MA.asteroid_models["500"] = "models/ce_ls3additional/asteroids/asteroid_500.mdl"
MA.asteroid_models["broken"] = ""

local sizes = {}
table.insert(sizes,"200")
table.insert(sizes,"250")
table.insert(sizes,"300")
table.insert(sizes,"350")
table.insert(sizes,"400")
table.insert(sizes,"450")
table.insert(sizes,"500")



function MA.RegisterAsteroidType(t, m)
	MA.asteroid_models[t] = m
end

--[[asteroids[1]= {}
asteroids[1].coordinates = Vector(0, 0 , 0)
asteroids[1].radius = 256
asteroids[1].size = "small"
asteroids[1].type = "mine"
asteroids[2] = {}
asteroids[2].coordinates = Vector(126, 2000 , 699)
asteroids[2].radius = 128
asteroids[2].size = "medium"
asteroids[2].type = "asteroid"
asteroids[3] = {}
asteroids[3].coordinates = Vector(3000, -3300 , 1000)
asteroids[3].radius = 1024
asteroids[3].size = "large"
asteroids[3].type = "crystal"]]

local file2 = util.TableToKeyValues(asteroids)
CAF.WriteToDebugFile("test_mining", file2)

local status = false

local function DelayedSpawn(ent)
	if ent and ValidEntity(ent) then
		ent:Spawn()
	end
end

local function PhysgunPickup(ply , ent)
	local notallowed =  { "asteroid", "crystal", "crystal_tower", "mine", "drill"}
	if table.HasValue(notallowed, ent:GetClass()) then
		return false
	end
end
hook.Add("PhysgunPickup", "AMA physgunpick", PhysgunPickup) 

function SpawnRoids()
if string.find(string.lower(gmod.GetGamemode().Name),"spacebuild") and string.find(string.lower(gmod.GetGamemode().Name),"3") then
	for i=1,27 do
		local atype = math.random(1,#sizes)
		local volumetbl = GAMEMODE:FindVolume("Asteroid_"..i, tonumber(sizes[atype]))
		if volumetbl then
			local ent1 = ents.Create("asteroid")
			ent1:SetModel(MA.asteroid_models[sizes[atype]])
			ent1:SetPos(volumetbl.pos)
			ent1:PhysicsInit( SOLID_VPHYSICS )
			ent1:SetMoveType( MOVETYPE_VPHYSICS )
			ent1:SetSolid( SOLID_VPHYSICS )
			local phys = ent1:GetPhysicsObject()
			ent1.mine_amount = phys:GetVolume()
			ent1.id = i
			ent1.type = sizes[atype]
			ent1.volname = "Asteroid_"..i
			asteroid_entities[i] = {['id'] = i, ['resources'] = resources_as}
		end
	end
end
end
hook.Add("InitPostEntity","SpawnTheAsteroids",timer.Simple(1,SpawnRoids))

--[[
	The Constructor for this Custom Addon Class
]]
function RD.__Construct()
	if status then return false, "Already Active!" end
	if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then return false, "Resource Distribution is Required and needs to be Active!" end
	local hasspawned = false
	local map = game.GetMap( )
	hasspawned = true
	local contents = file.Read("mine_spawns/" .. map .. ".txt")
	Msg(contents)
	if contents then
		hasspawned = true
		--Load map presets then give the asteroids an ID
		asteroids = util.KeyValuesToTable(contents)
		for k, v in pairs(asteroids)do
			local ent1 = ents.Create("mine") 
			--local resources_as = math.random(v.min, v.max)
			
			--if v.type == "mine" then
				ent1:SetPos(Vector(v.coordinates.x, v.coordinates.y, v.coordinates.z))
				ent1:Spawn()
				ent1:PhysicsInit( SOLID_VPHYSICS )
				ent1:SetMoveType( MOVETYPE_NONE )
				ent1:SetSolid( SOLID_VPHYSICS )
				ent1:SetSkin(MA.asteroid_models[v.type])
			--end
			local phys = ent1:GetPhysicsObject( )
			ent1.mine_amount = phys:GetVolume() * 2
			ent1.id = k
			ent1.type = v.type
			asteroid_entities[k] = {['id'] = k, ['resources'] = resources_as}
			
		end
		--hook.Add("Think", "AMA Think", update12)
	end
	contents = file.Read("drill_spawns/" .. map .. ".txt")
	Msg(contents)
	if contents then
		hasspawned = true
		--Load map presets then give the asteroids an ID
		asteroids = util.KeyValuesToTable(contents)
		for k, v in pairs(asteroids)do
			local ent1 = ents.Create("asteroid") 
			--local resources_as = math.random(v.min, v.max)
			
			--if v.type == "mine" then
					ent1:SetModel(MA.asteroid_models[v.type] or MA.asteroid_models["mine"])
					ent1:PhysicsInit( SOLID_VPHYSICS )
					ent1:SetMoveType( MOVETYPE_VPHYSICS )
					ent1:SetSolid( SOLID_VPHYSICS )
					ent1:SetPos(Vector(v.coordinates.x, v.coordinates.y, v.coordinates.z))
			--end
			local phys = ent1:GetPhysicsObject( )
			ent1.mine_amount = phys:GetVolume()
			ent1.id = k
			ent1.type = v.type
			asteroid_entities[k] = {['id'] = k, ['resources'] = resources_as}
			
		end
	end
	contents = file.Read("crystal_spawns/" .. map .. ".txt")
	Msg(contents)
	if contents then
		hasspawned = true
		--Load map presets then give the asteroids an ID
		asteroids = util.KeyValuesToTable(contents)
		for k, v in pairs(asteroids)do
			local ent1 = ents.Create("asteroid") 
			--local resources_as = math.random(v.min, v.max)
			
			--if v.type == "mine" then
					ent1:SetModel(MA.asteroid_models[v.type] or MA.asteroid_models["mine"])
					ent1:PhysicsInit( SOLID_VPHYSICS )
					ent1:SetMoveType( MOVETYPE_VPHYSICS )
					ent1:SetSolid( SOLID_VPHYSICS )
					ent1:SetPos(Vector(v.coordinates.x, v.coordinates.y, v.coordinates.z))
			--end
			local phys = ent1:GetPhysicsObject( )
			ent1.mine_amount = phys:GetVolume()
			ent1.id = k
			ent1.type = v.type
			asteroid_entities[k] = {['id'] = k, ['resources'] = resources_as}
			
		end
	end
	if hasspawned then
		status = true
		return true
	else
		return false , "No Spawn List for this Map available"
	end
end

--[[
	The Destructor for this Custom Addon Class
]]
function RD.__Destruct()
	if not status then return false, "Addon is already disabled!" end
	CAF.RemoveHook("think3", update12)
	--hook.Remove("Think", "AMA Think")
	status = false
	return true
end

--[[
	Get the required Addons for this Addon Class
]]
function RD.GetRequiredAddons()
	return {"Resource Distribution"}
end

--[[
	Get the Boolean Status from this Addon Class
]]
function RD.GetStatus()
	return status
end

--[[
	Get the Version of this Custom Addon Class
]]
function RD.GetVersion()
	return 3.01, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
]]
function RD.GetExtraOptions()
	return {}
end

--[[
	Get the Custom String Status from this Addon Class
]]
function RD.GetCustomStatus()
	return "Not Implemented Yet"
end

--[[
	You can send all the files from here that you want to add to send to the client
]]
function RD.AddResourcesToSend()
	
end

--[[ Asteroid destruction call, called when an asteroid is destroyed from being hit or over mined.]]
function RD.Destruct( class,id,pos,type,reason,volumename )
	
	if class == "asteroid" then
		asteroid_entities[id] = nil
		if reason == 1 then
			timer.Simple(10,SpawnAsteroid,id, volumename)
		elseif reason == 2 then
			timer.Simple(30,SpawnAsteroid,id, volumename)
		end
	else
		if reason == 1 then
			timer.Simple(10,function() 
				local ent1 = ents.Create(class) 
				ent1:SetPos(pos)
				ent1:Spawn()
				ent1:PhysicsInit( SOLID_VPHYSICS )
				ent1:SetMoveType( MOVETYPE_NONE )
				ent1:SetSolid( SOLID_VPHYSICS )
				ent1:SetSkin(skin)
			local phys = ent1:GetPhysicsObject()
			ent1.mine_amount = phys:GetVolume()*2
			ent1.id = id
			ent1.type = type
			asteroid_entities[k] = {['id'] = ent.id, ['resources'] = resources_as}
			end)
		elseif reason == 2 then
			timer.Simple(30,function() 
				local ent1 = ents.Create(class) 
				ent1:SetPos(pos)
				ent1:Spawn()
				ent1:PhysicsInit( SOLID_VPHYSICS )
				ent1:SetMoveType( MOVETYPE_NONE )
				ent1:SetSolid( SOLID_VPHYSICS )
				ent1:SetSkin(skin)
			local phys = ent1:GetPhysicsObject()
			ent1.mine_amount = phys:GetVolume()*2
			ent1.id = id
			ent1.type = type
			asteroid_entities[k] = {['id'] = ent.id, ['resources'] = resources_as}
			end)
		end
	end
end

function SpawnAsteroid(i,name)
	GAMEMODE:RemoveVolume(name)
	local atype = math.random(1,#sizes)
	local volumetbl = GAMEMODE:FindVolume(name, tonumber(sizes[atype])+50)
	if volumetbl then
		local ent1 = ents.Create("asteroid") 
		ent1:SetModel(MA.asteroid_models[sizes[atype]])
		ent1:SetPos(volumetbl.pos)
		ent1:PhysicsInit( SOLID_VPHYSICS )
		ent1:SetMoveType( MOVETYPE_VPHYSICS )
		ent1:SetSolid( SOLID_VPHYSICS )
		local phys = ent1:GetPhysicsObject()
		ent1.mine_amount = phys:GetVolume()
		ent1.id = i
		ent1.type = sizes[atype]
		ent1.volname = name
		asteroid_entities[i] = {['id'] = i, ['resources'] = resources_as}
	end
end

CAF.RegisterAddon("Mining Addon", RD, "2") 

