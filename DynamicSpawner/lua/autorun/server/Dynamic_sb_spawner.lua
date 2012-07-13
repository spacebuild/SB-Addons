CreateConVar("sbep_autospawner","1", {FCVAR_NONE,FCVAR_ARCHIVE})
CreateConVar("sbep_autospawner_habitable_count","1", {FCVAR_NONE,FCVAR_ARCHIVE})
CreateConVar("sbep_autospawner_max_planets","6", {FCVAR_NONE,FCVAR_ARCHIVE})

resource.AddFile("models/Levybreak/Planets/planet1.mdl")
resource.AddFile("models/Levybreak/Landforms/landform1.mdl")
resource.AddFile("models/Levybreak/Landforms/landform2.mdl")

--[[
function SBEP_FindSpawnpoints()
	local possiblespawns = ents.FindByClass("logic_case")
	local spawns = {}
	for k,v in pairs(possiblespawns) do
		local tbl = v:GetKeyValues()
		if table.HasValue(tbl,"DynamicSpawnpoint") then
			table.insert(spawns,v)
		end
	end
	return spawns
end 
]]

local function ReOrganiseTable(tbl)
	if not tbl then return {} end
	local output = {}
	for k,v in pairs(tbl) do
		table.insert(output,v)
	end
	return output
end 

local SB = CAF.GetAddon("Spacebuild")


function SBEP_CreateRandEnv(ent,name,radius)
	if type(name) == "number" then name = "Space Object "..name end
	
	local radius = math.Clamp(tonumber(radius),200,9001)
	local temp1 = math.random(40,900)
	local temp2 = math.Clamp(math.random(40,900),40,temp1)-math.random(2,6)
	
	local contents = {}
	table.insert(contents,math.random(0,100))
	table.insert(contents,math.random(0,100-contents[1]))
	table.insert(contents,math.random(0,100-(contents[1]+contents[2])))
	table.insert(contents,100-(contents[1]+contents[2]+contents[3]))
	
	local rand = math.random(1,#contents)
	local co2 = contents[rand]
	table.remove(contents,rand)
	
	rand = math.random(1,#contents)
	local n = contents[rand]
	table.remove(contents,rand)
	
	rand = math.random(1,#contents)
	local h = contents[rand]
	table.remove(contents,rand)
	
	rand = math.random(1,#contents)
	local o2 = contents[rand]
	table.remove(contents,rand)
	
	local env = ents.Create("base_sb_planet2")
	env:SetModel("models/props_lab/huladoll.mdl")
	env:SetPos(ent:GetPos())
	env:SetAngles( ent:GetAngles() )
	env:Spawn()
	env:CreateEnvironment(ent, radius, math.random(0.1,2.5), math.random(0.5,2), math.random(0.5,2), temp1, temp2,  o2, co2, n, h, flags, name)
	if math.random(0,100) >= 70 and (temp1 > 400 or temp2 > 400) then
		env.sbenvironment.sunburn = true
	end
end

function SBEP_CreateHabitableEnv(ent,name,radius)
	if type(name) == "number" then name = "Space Object "..name end
	
	local radius = math.Clamp(radius,200,9001)
	local temp1 = math.random(289,298)
	local temp2 = math.Clamp(math.random(289,298),260,temp1)
	
	local o2 = math.Clamp(math.random(0,100),5,100)
	local co2 = math.random(0,100-o2)
	local n = math.random(0,100-(o2+co2))
	local h = 100-(o2+co2+n)
	
	local flags = 0	
	
	local env = ents.Create("base_sb_planet2")
	env:SetModel("models/props_lab/huladoll.mdl")
	env:SetPos(ent:GetPos())
	env:SetAngles( ent:GetAngles() )
	env:Spawn()
	
	
	env:CreateEnvironment(ent, radius, math.random(1,1.1), math.random(0.5,2), math.random(0.5,2), temp1, temp2,  o2, co2, n, h, flags, name)
end

--local groups_in_use = {}
function SBEP_BaseSpawnFunction()
	local active = GetConVarNumber("sbep_autospawner")
	local habitableleft = GetConVarNumber("sbep_autospawner_habitable_count")
	if CAF then
		local SB = CAF.GetAddon("Spacebuild")
		if active and (active == 1) and CAF.GetAddon("Spacebuild") and SB.GetStatus() then
			local mapname = string.lower(game.GetMap())
			local filename = file.Find("SBEP/Spawnfiles/"..mapname.."/*.txt", "DATA")
			local delay = 1
			for i=1,GetConVarNumber("sbep_autospawner_max_planets") do
				if filename == {} or filename == nil then filename = file.Find("SBEP/Spawnfiles/"..mapname.."/*.txt", "DATA") end
				filename = ReOrganiseTable(filename)
				if filename and filename ~= {} then
					local numz = 1
					if filename and #filename > 1 then numz = math.random(1, #filename) end
					local filez = "SBEP/Spawnfiles/"..mapname.."/"..(filename[numz] or "lolnothere")
					while not file.Exists(filez) do --hur, hur. loop.
						filename = file.Find("SBEP/Spawnfiles/generic/*.txt", "DATA")
						numz = math.random(1, tonumber(#filename))
						filez = "SBEP/Spawnfiles/generic/"..filename[numz]
						print(filez)
					end
					if filez then
						local contents = glon.decode(file.Read(filez))
						local volumetbl = SB.FindVolume("Planet_"..i, tonumber(contents['Settings'].Radius)+50)
						timer.Simple(delay,SBEP_SpawnFile,filez,volumetbl.pos)
						local dummy = ents.Create("info_target")
						dummy:SetPos(volumetbl.pos)
						dummy:Spawn()
						local HabMod = contents['Settings'].Habtype
						if habitableleft >= 1 and HabMod ~= "InHabitable" then
							timer.Simple(delay,SBEP_CreateHabitableEnv,dummy,string.gsub(filename[numz],".txt",""),tonumber(contents['Settings'].Radius)+50)
							habitableleft = habitableleft - 1
						elseif HabMod ~= "Habitable" then
							timer.Simple(delay,SBEP_CreateRandEnv,dummy,string.gsub(filename[numz],".txt",""),tonumber(contents['Settings'].Radius)+50)
						else
							ErrorNoHalt("Planet "..string.gsub(filename[numz],".txt","").." has a Habtype that is neither habitable or inhabitable. It's "..HabMod.." which is most likely not a valid type!")
						end
						filename[numz] = nil
					end
					delay = delay + 1
				end
			end
		end
	end
end
hook.Add("InitPostEntity","InitPostEntity_SBEP_BaseSpawnFunction",function() timer.Simple(0.2,SBEP_BaseSpawnFunction) end)

--[[
function SBEP_SpawnFile(filez,offset) --old, pre-glon saves
	print("SpawnFile Running")
	if not file.Exists(filez) then print("File "..filez.." Does not exist!") end
	local data = file.Read(filez)
	local spawnlist = util.KeyValuesToTable(data)
	for k,v in pairs(spawnlist) do
		if type(v) =="table" then
			local spawn = ents.Create("prop_physics")
			spawn:SetModel(v["model"])
			spawn:SetPos(Vector(v["x"],v["y"],v["z"])+offset)
			spawn:SetAngles(Angle(v["pit"],v["yaw"],v["rol"]))
			spawn:SetSkin(v["skin"])
			spawn:SetKeyValue("gmod_allowphysgun","0")
			spawn:SetKeyValue("gmod_allowtools","weld")
			spawn:PhysicsInit(SOLID_VPHYSICS)
			spawn:Spawn()
			--spawn:SetMoveType(MOVETYPE_NONE)
			spawn.Autospawned = true
			if CAF and CAF.GetAddon("CDS") then
				if not spawn.caf then spawn.caf = {} end
				if not spawn.caf.custom then spawn.caf.custom = {} end
				spawn.caf.custom.canreceivedamage = false
				spawn.caf.custom.canreceiveheatdamage = false
			end
			local phys = spawn:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:Sleep()
				phys:EnableMotion(false)
			end
			spawn:SetUnFreezable(false)
		end
	end
end ]]


function SBEP_SpawnFile(filez,offset)
	if not file.Exists(filez) then print("File "..filez.." Does not exist!") end
	local data = glon.decode(file.Read(filez))
	for k,v in ipairs(data) do
		local spawn = ents.Create("prop_physics")
		spawn:SetModel(v.Model)
		spawn:SetPos(v.Pos+offset)
		spawn:SetAngles(v.Ang)
		spawn:SetSkin(v.Skin)
		spawn:SetColor(Color(v.Color.r,v.Color.g,v.Color.b,v.Color.a))
		spawn:SetOwner(GetWorldEntity())
		if v.Matl then
			spawn:SetMaterial(v.Matl)
		end
		spawn:SetKeyValue("gmod_allowphysgun","0")
		spawn:SetKeyValue("gmod_allowtools","weld")
		spawn:PhysicsInit(SOLID_VPHYSICS)
		spawn:Spawn()
		--spawn:SetMoveType(MOVETYPE_NONE)
		spawn.Autospawned = true
		if CAF and CAF.GetAddon("CDS") then
			if not spawn.caf then spawn.caf = {} end
			if not spawn.caf.custom then spawn.caf.custom = {} end
			spawn.caf.custom.canreceivedamage = false
			spawn.caf.custom.canreceiveheatdamage = false
		end
		local phys = spawn:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:Sleep()
			phys:EnableMotion(false)
		end
		spawn:SetUnFreezable(false)
	end
end 

local function physgunPickup( userid, ent )
	if ent and ent.Autospawned and ent.Autospawned == true then
		return false
	end
end
hook.Add( "PhysgunPickup", "PlanetaryAutoSpawner_physgunPickup", physgunPickup )

--I am so lazy. :D
oldprintz = print
function print(txt)
	oldprintz(txt)
	return txt
end 