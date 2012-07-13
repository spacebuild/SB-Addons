local CDS = {}
CDSAttacks = {}
CDSDamageTypes = {}

local status = false
local affected = {}
local protection = {}

local damagetypes = {}
local attacktypes = {}
protection.player = 1 --15
protection.entities = 1 --90


include "CAF/Addons/shared/cds_damage_info.lua";

CDS.ArmorTypes = ArmorTypes
CDS.ArmorWeights = ArmorWeights
CDS.HealthMultiplier = 10;
PrintTable(CDS.ArmorTypes);
--[[
	Normal stuff
]]
CreateConVar("CDS_SB_Adaptive_Temp", "1") --Turn adaptive Temperature (SB3) on/off
CreateConVar("CDS_SpawnProtect", "1")  --Spawn protection
CreateConVar("CDS_Disable_Use", "0") --Disable the ability to press use on the weapons
CreateConVar("CDS_Damage_Enabled", "1")

local function Setup(ent, enttype, ply)
	if not ent or not ValidEntity(ent) then return end
	if enttype == "PLAYER" or enttype == "NPC" then
		ent:SetMaxHealth(ent:Health())
	else
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			local vol = phys:GetVolume()
			vol = math.Round(vol)
			MsgN("Entity old Health: " .. ent:Health());
			ent:SetMaxHealth((vol/1000) * CDS.HealthMultiplier)
			if(ent:GetMaxHealth( ) <= 0) then
				ent:SetMaxHealth(1);
			end
			ent:SetHealth(ent:GetMaxHealth( ))
			MsgN("Entity new Health: " .. ent:Health());
		end
		CDS.setArmor(ent, 1, 0.33, 0.33, 0.33)
	end
end

local function Spawnadd(ent, enttype, ply)
	if not ent or not ValidEntity(ent) then return false, "Not a Valid Entity" end
	ent.caf = ent.caf or {}
	ent.caf.custom = ent.caf.custom or {}
	
	if not table.HasValue(affected, ent) then
		if ent.caf.custom.canreceivedamage then
			table.insert(affected, ent)
			Setup(ent, enttype, ply)
			if server_settings.Bool( "CDS_SpawnProtect" ) then
				if enttype and (enttype == "PLAYER" or enttype == "NPC") then
					timer.Simple(protection.player, function(ent) ent.caf.custom.canreceivedamage = true; end, ent)
				else	
					timer.Simple(protection.entities, function(ent) ent.caf.custom.canreceivedamage = true; end, ent)
				end
				ent.caf.custom.canreceivedamage = false
			end
		end
	end
end

local function cds_spawn_maxhealth(ply)
	ply:SetMaxHealth(ply:Health())
end

local function UpdateMassAndColor()
	for k, ent in pairs(affected) do
		if ent and ValidEntity(ent) and not (ent:IsPlayer() or ent:IsNPC()) then
			local armor = ent:getCustomArmor();
			if (armor) then
				if not ent.caf.custom.masschangeoverride then
					local armorvalue = armor:GetArmor()
					local types = {"Shock", "Kinetic", "Energy"}
					local totalfortypes = 0;
					for l, w in pairs(types) do
						totalfortypes = totalfortypes + ( armor:GetArmormultiplier(w) * CDS.ArmorWeights[w])
					end
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						local vol = phys:GetVolume()
						vol = math.Round(vol)
						local mass = (ent:Health() / ent:GetMaxHealth())*(vol/100) * totalfortypes
						if mass < 1 then
							mass = 1 --To be sure
						end
						phys:SetMass( mass) 
						phys:Wake();
					end
				end
				local c = ent:GetColor();  local r,g,b,a = c.r, c.g, c.b, c.a;
				a =  100 + math.Round((ent:Health() / ent:GetMaxHealth()) * 155)
				ent:SetColor(Color(r, g, b, a));
			end
		end
	end
end

--[[
	The Constructor for this Custom Addon Class
]]
function CDS.__Construct()
	if status then return false , "This Addon is already Active!" end
	if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then return false, "Resource Distribution is Required and needs to be Active!" end
	--hook.Add( "PlayerSpawn", "CDS_Core_MaxhHealth", cds_spawn_maxhealth)
	--CAF.AddHook("OnEntitySpawn", Spawnadd)
	--CAF.AddHook("think3", UpdateMassAndColor)
	--status = true
	return false, "Disabled Use"
end

--[[
	The Destructor for this Custom Addon Class
]]
function CDS.__Destruct()
	if not status then return false, "This addon is already disabled!" end
	--CAF.RemoveHook("OnEntitySpawn", Spawnadd)
	--hook.Remove( "PlayerSpawn", "CDS_Core_MaxhHealth")
	--CAF.RemoveHook("think3", UpdateMassAndColor)
	--status = false
	return false, "Disabled Use"
end

--[[
	Get the required Addons for this Addon Class
]]
function CDS.GetRequiredAddons()
	return {"Resource Distribution"}
end

--[[
	Get the Boolean Status from this Addon Class
]]
function CDS.GetStatus()
	return status
end

--[[
	Get the Version of this Custom Addon Class
]]
function CDS.GetVersion()
	return 0.1, "Alpha"
end

--[[
	Get any custom options this Custom Addon Class might have
]]
function CDS.GetExtraOptions()
	return {}
end

--[[
	Get the Custom String Status from this Addon Class
]]
function CDS.GetCustomStatus()
	return "Not Implemented Yet"
end

function CDS.AddResourcesToSend()
	
end

function CDS.setArmor(ent, armor, Shock, Kinetic, Energy)
	if not status then return false, "Disabled" end
	if ent.caf.custom.canreceivedamage and not (ent:IsPlayer() or ent:IsNPC()) then
		if(ent:getCustomArmor() == nil) then
			ent:setCustomArmor(CustomArmor.Create())
		end
		
		armor = math.Clamp( armor, 1, 5 );
		Shock = math.Clamp( Shock, 0, 1 );
		Kinetic = math.Clamp( Kinetic, 0, 1 );
		Energy = math.Clamp( Energy, 0, 1 );
		
		local total = Shock + Kinetic + Energy
		
		local amax = 1;
		amax = amax - Shock;
		
		if(Kinetic > amax) then
			Kinetic = amax;
		end
		amax = amax - Kinetic
		
		if(Energy > amax) then
			Energy = amax;
		end
		amax = amax - Energy
		
		if (amax > 0) then
			Shock = Shock + amax
		end
			
		ent:getCustomArmor():SetArmor(armor);
		ent:getCustomArmor():setArmorMultiplier("Shock", Shock/total or 0)
		ent:getCustomArmor():setArmorMultiplier("Kinetic", Kinetic/total or 0)
		ent:getCustomArmor():setArmorMultiplier("Energy", Energy/total or 0)
		
		if not ent.caf.custom.masschangeoverride then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				local vol = phys:GetVolume()
				vol = math.Round(vol)
				MsgN("Ent Physics Object Volume: ",vol)
				MsgN("Ent Physics Object Old Mass: ",phys:GetMass())
				local mass = (ent:Health() / ent:GetMaxHealth()) *(vol/100) * ( armor * ((Shock * CDS.ArmorWeights["Shock"]) +(Kinetic * CDS.ArmorWeights["Kinetic"]) + (Energy * CDS.ArmorWeights["Energy"]) ) );
				if mass < 1 then
					mass = 1 --To be sure
				end
				phys:SetMass( mass) 
				MsgN("Ent Physics Object New Mass: ",phys:GetMass())
				phys:Wake();
			end
		end
	end
end

local ignoreclasses = {"info_player_start"}

function CDS.Attack(ent, customAttack)
	if not status then return false, "Disabled" end
	if not ent or not ValidEntity(ent) or not customAttack then return false, "Invalid parameters" end
	if(table.HasValue(ignoreclasses, ent:GetClass())) then return false, "Ignored Entity" end
	if ent.caf.custom.canreceivedamage then
		local armor = ent:getCustomArmor()
		local types = {"Shock", "Kinetic", "Energy"}
		local damage = 0;
		local piercing = customAttack:GetPiercing()
		piercing = piercing - armor:GetArmor()
		for k, dtype in pairs(types) do
			local dam = customAttack:GetAttack(dtype)
			dam = math.Round(dam - ((armor:GetArmormultiplier(dtype) - 0.1) * dam))
			damage = damage + dam;
		end
		if(piercing > 0) then
			damage = damage * piercing
		elseif (piercing == 0) then
			-- Do nothing
		elseif (piercing == -1) then
			damage = math.Round(damage * 0.1)
		elseif (piercing == -2) then
			damage = math.Round(damage * 0.05)
		end 
		if(damage > 0) then
			CDS.Damage(ent, damage, customAttack:GetAttacker(), customAttack:GetWeaponEntity())
		end
	end
	return true;
end

function CDS.Damage(ent, amount, attacker, inflictor)
	if not status then return false, "Disabled" end
	if not ent or not ValidEntity(ent) or not amount then return false, "Invalid parameters" end
	ent.caf.custom.takingcustomdamage = true;
	local newhealth = ent:Health() - amount;
	ent.caf.custom.takingcustomdamage = true;
	ent:TakeDamage( amount, attacker, inflictor )
	ent.caf.custom.takingcustomdamage = false;
	if ent:IsValid() and not ent:IsPlayer() and not ent:IsNPC() then
		ent:SetHealth(newhealth)
		if (ent:Health()/ent:GetMaxHealth()) * 100 < math.random(1, 10) then
			constraint.RemoveAll( ent )
		end
	end
	if (ent:Health() <= 0) and not ent:IsPlayer() then
		CDS.RemoveEnt(ent)
	end
end

local function NormalDamage( ent, inflictor, attacker, amount, dmginfo )
	if not status then return end
	ent.caf = ent.caf or {}
	ent.caf.custom = ent.caf.custom or {}
	if ent.caf.custom.takingcustomdamage then
		return
	else
		dmginfo:ScaleDamage( 0.0 )
		--CDS.Attack(ent, "Explosion", { range = 50, damage = 30, armordamage = 50, inflictor = ent.owner, ignore = { ent }})
		local attack = GetNewCustomAttack()
		attack:SetPiercing(0)
		for k,dtype in ipairs({"Shock", "Kinetic", "Energy"}) do --split evenly
			attack:SetAttack(dtype,amount/3)
		end
		attack:SetAttacker(attacker)
		attack:SetWeaponEntity(inflictor)
		CDS.Attack(ent, attack)
	end
end
hook.Add( "EntityTakeDamage", "Custom Damage System CDS 3 Entity Take Damage", NormalDamage )

function CDS.SetSpawnProtection(ply, ent)
	if ply and type(ply) == "number" then protection.player = ply end
	if ent and type(ent) == "number" then protection.entities = ent end
end

function CDS.HasLOS(ent, target)
	if not status then return false, "Disabled" end
	if not ent or not target then return false end
	local tr = util.TraceLine(
	{
		start 	= ent:GetPos(),
		endpos 	= target:LocalToWorld( target:OBBCenter() ),
		filter 	= { ent }
	} )
	if not tr.Hit or (tr.Hit and tr.Entity == target) then --When we don't hit something it means we can still see it (hollow objects!)
		return true
	end
	return false
end

function CDS.HasLOSOnPos(pos, target)
	if not status then return false, "Disabled" end
	if not pos or not target then return false end
	local tr = util.TraceLine(
	{
		start 	= pos,
		endpos 	= target:LocalToWorld( target:OBBCenter() ),
	} )
	if not tr.Hit or (tr.Hit and tr.Entity == target) then --When we don't hit something it means we can still see it (hollow objects!)
		return true
	end
	return false
end

local function RemoveEntity( ent )
	if ent and ValidEntity(ent) and not ent:IsPlayer() and not ent:IsNPC() then
		ent:Remove()
	end
end

function CDS.RemoveEnt(ent)
	if not status then return false, "Disabled" end
	if not ent or not ValidEntity(ent) then return false, "Missing Arguments" end
	local Effect = EffectData()
	Effect:SetOrigin(ent:GetPos())
	Effect:SetScale(3)
	Effect:SetMagnitude(100)
	util.Effect("cds_disintergrate", Effect, true, true)
	timer.Simple(1, RemoveEntity, ent)
end

--Non Meta stuff

CAF.RegisterAddon("Custom Damage System", CDS, "3")

--Include Damage and Attack type files

local Files = file.Fin( "cds_attacks/*.lua" 
for k, File in ipairs(Files) do
	Msg("Loading cds attack type: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_attacks/"..File)
	if(not ErrorCheck) then
		CAF.WriteToDebugFile("attacktypeerrors", tostring(PCallError))
	else
		Msg("Loaded: Successfully\n")
	end
end

local Files = file.Find( "cds_damagetypes/*.lua" , LUA_PATH)
for k, File in ipairs(Files) do
	Msg("Loading cds attack type: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_damagetypes/"..File)
	if(not ErrorCheck) then
		CAF.WriteToDebugFile("damagetypeerrors", tostring(PCallError))
	else
		Msg("Loaded: Successfully\n")
	end
end