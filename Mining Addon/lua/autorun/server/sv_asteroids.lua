-- shanjaq: Start Asteroid mod.

local pi = 3.14159

--Compatibility Global
AddCSLuaFile( "autorun/client/cl_asteroids.lua" )
ASTEROID_MOD = 1

--name, rarity(1 to 3, 3 being most common and 1 being most rare)
AsteroidResources = {}
local ResRarityList = {}

function AddAsteroidResource(name, rarity)
	local found = 0
	for _, res in pairs( AsteroidResources ) do
		if (res.name == name) then
			found = 1
			break
		end
	end
	
	if ( found == 0 ) then
		local hash = { }
		hash.name = name
		hash.rarity = rarity
		hash.yield = 0
		table.insert(AsteroidResources, hash)
		
		ResRarityList[rarity] = ResRarityList[rarity] or {}
		table.insert(ResRarityList[rarity], hash)
	end
end

local function GetResource(rarity)
	-- if(ResRarityList[rarity] == nil or false) then
		-- Error("ResRarityList[rarity] == nil\n")
		-- return false
	-- else
		return table.Copy(ResRarityList[rarity][math.random(1, #ResRarityList[rarity])])
	--end
end

local SmallAsteroids = {
	{ "models/props_wasteland/rockgranite02b.mdl", 57.2894 },
	{ "models/props_wasteland/rockgranite02a.mdl", 60.7747 },
	{ "models/props_wasteland/rockcliff01k.mdl", 81.2065 },
	{ "models/props_wasteland/rockgranite01b.mdl", 111.72 },
	{ "models/props_wasteland/rockgranite02c.mdl", 61.1406 },
	{ "models/props_wasteland/rockgranite03a.mdl", 33.7145 },
	{ "models/props_wasteland/rockgranite03b.mdl", 28.0294 },
	{ "models/props_wasteland/rockgranite03c.mdl", 35.5362 }
}

local MediumAsteroids = {
	{ "models/props_wasteland/rockcliff01J.mdl", 113.354 },
	{ "models/props_wasteland/rockcliff01g.mdl", 108.035 },
	{ "models/props_wasteland/rockcliff01e.mdl", 127.419 },
	{ "models/props_wasteland/rockcliff01b.mdl", 109.144 },
	{ "models/props_wasteland/rockcliff01c.mdl", 111.324 },
	{ "models/props_wasteland/rockcliff01f.mdl", 119.122 },
	{ "models/props_wasteland/rockgranite01c.mdl", 140.461 },
	{ "models/props_wasteland/rockcliff07b.mdl", 152.839 },
	{ "models/props_wasteland/rockgranite01a.mdl", 115.488 },
	{ "models/props_wasteland/rockcliff06d.mdl", 141.219 },
	{ "models/props_wasteland/rockcliff07e.mdl", 151.832 }
}

local LargeAsteroids = {
	{ "models/props_wasteland/rockgranite04b.mdl", 224.265 },
	{ "models/props_wasteland/rockgranite04a.mdl", 229.364 },
	{ "models/props_wasteland/rockcliff06i.mdl", 266.996 }
}

--	{ "models/props_foliage/rock_coast02g.mdl", 241.328 },
--	{ "models/props_foliage/rock_coast02c.mdl", 256.952 }

local HugeAsteroid = { {"models/props_wasteland/rockgranite04c.mdl", 590.478} }

function SpawnAsteroid(model, pos, size, rarity)
	local asteroid = ents.Create( "prop_physics" )
	asteroid:SetModel( model )
	asteroid:SetPos( pos )
	asteroid:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360))) 
	asteroid:Spawn()
	asteroid:SetGravity(0.00001)
	local phys = asteroid:GetPhysicsObject()
	if(!phys:IsValid()) then return end
	phys:Wake()
	phys:SetMass(size * 16)
	phys:EnableGravity(false)
	phys:EnableDrag(false)
	
	timer.Simple(10, function(phys) phys:EnableMotion(false) end, phys) -- No more randomly spinning asteriods in space
	timer.Simple(11, function(phys) phys:EnableMotion(true) end, phys) -- No more randomly spinning asteriods in space
	
	asteroid.IsAsteroid = 1
	asteroid.CDSIgnore = true
	asteroid.resource = GetResource(rarity)
	asteroid.resource.yield = math.random(1, math.floor(size))
end 

function Asteroid_Field(pos, radius, density)
	local volume = radius * radius * radius * pi * 4 / 3
	local maxvol = volume * density
	local filled = 0
	local nr = 0
	for var = 0, 30 do --max 30 asteroids per field, or when filled >= maxvol
		local asteroid_group = nil
		local rnd_type = math.random(1, 10)
		if (rnd_type <= 3) then
			asteroid_group = SmallAsteroids
		elseif (rnd_type <= 8) then
			asteroid_group = MediumAsteroids
		elseif (rnd_type <= 10) then
			asteroid_group = LargeAsteroids
		elseif (rnd_type <= 11) then
			asteroid_group = HugeAsteroid
		end
		local pick = math.random(1, #asteroid_group)
		local model = asteroid_group[pick][1]
		local size = asteroid_group[pick][2]
		local subvol = size * size * size * pi * 4 / 3
		local res_rarity = 0
		local res_chance = math.random(1, 100)
		if ( res_chance <= 10 ) then
			res_rarity = 1
		elseif ( res_chance <= 40 ) then
			res_rarity = 2
		else
			res_rarity = 3
		end
		
		
		timer.Simple(0.7 + nr, SpawnAsteroid, model, pos+(VectorRand()*radius), size, res_rarity)
		filled = filled + subvol
		nr = nr + 0.7
		if filled >= maxvol then break end
	end
end


function AsteroidSpamSector()
	if (InSpace == 1) then
		local num_fields = math.random(2, 4)
		for i = 1, num_fields do
			local radius = math.random(1000, 3000)
			local volume = Allocate_Volume(radius, "asteroids")
			if (volume.num > 0) then
				local density = (math.random(6, 20) / radius)
				timer.Simple(7 + i - 1 , Asteroid_Field, volume.pos, radius, density )
			end
		end
		Msg( "Spawned " .. num_fields .. " Asteroid fields.\n" )
	end
end

function AsteroidSpamWait()
	--AddAsteroidResource("iron", 3)
	--AddAsteroidResource("lead", 3)
	--AddAsteroidResource("aluminium", 3)
	--AddAsteroidResource("silicon", 2) Why?
	--AddAsteroidResource("thorium", 2)
	--AddAsteroidResource("tungsten", 2)
	AddAsteroidResource("titanium", 2)
	--AddAsteroidResource("gold", 1)
	--AddAsteroidResource("uranium", 1) Why?
	--AddAsteroidResource("platinum", 1) Why?
	AddAsteroidResource("redterracrystal", 3)
	AddAsteroidResource("greenterracrystal", 1)
	timer.Simple(7, AsteroidSpamSector)
end
hook.Add( "InitPostEntity", "AsteroidSpamSector", AsteroidSpamWait )

function AsteroidSayHook( ply, txt )
	if not ply:IsAdmin() then return end	
	if(string.sub(txt, 1, 10 ) == "!spamroids") then
		Msg(tostring(ply).." is doing !spamroids\n")
		AsteroidReset()
	end
end
hook.Add( "PlayerSay", "AsteroidSay", AsteroidSayHook )

function AsteroidReset()
	local stuff = ents.FindByClass( "prop_physics" )
	for _, ent in ipairs( stuff ) do
		if not ent.planet and  ent.IsAsteroid == 1 then
				if(ent:IsValid()) then
					ent:Remove()
				end
		end
	end
	AsteroidSpamSector()
end
timer.Create("AsteroidTimer", 1200, 0, AsteroidReset)

function AsteriodPhysGravGunPickup(ply, ent)
	if(!ent:IsValid()) then return end
	if(string.find(string.lower(ent:GetModel()), string.lower("models/props_wasteland/rockgranite")) == 1 or string.find(string.lower(ent:GetModel()), string.lower("models/props_wasteland/rockcliff")) == 1) then
		return false
	end
end
hook.Add("GravGunPunt", "AsteriodGravGunPunt", AsteriodPhysGravGunPickup)
hook.Add("GravGunPickupAllowed", "AsteriodGravGunPickupAllowed", AsteriodPhysGravGunPickup)
hook.Add("PhysgunPickup", "AsteriodPhysgunPickup", AsteriodPhysGravGunPickup)

function AsteriodCanTool(ply, tr, toolgun)
	if(tr.HitWorld) then return end
	ent = tr.Entity
	if(!ent:IsValid()) then return end
	if(string.find(string.lower(ent:GetModel()), string.lower("models/props_wasteland/rockgranite")) == 1 or string.find(string.lower(ent:GetModel()), string.lower("models/props_wasteland/rockcliff")) == 1) then
		return false
	end
end
hook.Add("CanTool", "AsteriodCanTool", AsteriodCanTool)

-- shanjaq: End Asteroid mod.
