/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		CDS:Combat Damage System
This will startup the system and load all required code.Below you will have various settings you can change
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
local MaxHealth = 20000 --Maximum health allowed(anti-cheat)
local MinHealth = 200 --nimimum health allowed
local MaxArmor = 75 --maximum armor allowed(anti-cheat)


		/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		Convars, you can alter the default setting by changing the value in them(1 / 0)
For the rest you can alter them by entering the command in the console
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
local version = "SVN(1.0.2)"

local function registerPF()
	if SVX_PF then
		PF_RegisterPlugin("Combat Damage System", version, nil, "CDS_Enabled", "1", "Addon")
		PF_RegisterConVar("Combat Damage System", "CDS_Enabled", "1", "Main System")
		PF_RegisterConVar("Combat Damage System", "CDS_SB_Adaptive_Temp", "1", "Adaptive Temperature(SB2+ only)")
		PF_RegisterConVar("Combat Damage System", "CDS_SpawnProtect", "1", "Spawn Protection")
		PF_RegisterConVar("Combat Damage System", "CDS_Disable_Use", "0", "Disable Use on CDS weapons")
		PF_RegisterConVar("Combat Damage System", "CDS_Disable_TurretLaser_Damage", "1", "Disable damage caused by env_lasers and gmod_turrets")
		PF_RegisterConVar("Combat Damage System", "CDS_NormalDamage", "0", "Enable damage caused by damage hook")
	else
		CreateConVar("CDS_Enabled", "1") --Enable/disable CDS
		CreateConVar("CDS_SB_Adaptive_Temp", "1") --Turn adaptive Temperature (SB2) on/off
		CreateConVar("CDS_SpawnProtect", "1") --Spawn protection
		CreateConVar("CDS_Disable_Use", "0") --Disable the ability to press use on the weapons
		CreateConVar("CDS_Disable_TurretLaser_Damage", "1") --disables damage caused by gmod_turrets and env_lasers
		CreateConVar("CDS_NormalDamage", "0") --disables damage caused by gmod damage hook call
		--Extra convar: "CDS_Damage_Enabled" --Can be disabled in the plugins folder.
	end
end

timer.Simple(5, registerPF) --Needed to make sure the Plugin Framework gets loaded first

/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		Don't modify anything below here.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
		CombatDamageSystem = 1
local cdsaffected = {}
local cds_function_list = {}

		/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		Hook functions to the CDS_Think function

The think will sent an Entity
to the Function specified
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
		function CDS_Add_Hook(func)
		if not table.HasValue(cds_function_list, func) then
			table.insert(cds_function_list, func)
		end
		end

		/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		Load core and plugins
		* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
		function ErrorOffStuff(String)
		Msg("-----------------------------------------------\n")
		Msg("-----------Combat Damage System ERROR----------\n")
		Msg("-----------------------------------------------\n")
		Msg(tostring(String) .. "\n")
		end

local Files = file.Find("core/*.lua", LUA_PATH)
for k, File in ipairs(Files) do
	Msg("Loading: " .. File .. "...")
	local ErrorCheck, PCallError = pcall(include, "core/" .. File)
	if (  not  ErrorCheck) then
	ErrorOffStuff(PCallError)
	else
		Msg("Loaded: Successfully\n")
	end
end

Files = file.Find("plugins/*.lua", LUA_PATH)
for k, File in ipairs(Files) do
	Msg("Loading: " .. File .. "...")
	local ErrorCheck, PCallError = pcall(include, "plugins/" .. File)
	if (  not  ErrorCheck) then
	ErrorOffStuff(PCallError)
	else
		Msg("Loaded: Successfully\n")
	end
end
/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
		Main functions
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /

		--Tells the system if an entity is already in the CDS check list or not
		function HasValueAff(ent)
		if table.HasValue(cdsaffected, ent) then return true end
		return false
		end

--Insert an entity into the CDS check list
function InsertIntoAff(ent)
	if not HasValueAff(ent) then
		table.insert(cdsaffected, ent)
	end
end

--Returns the MaxArmor value
function CDS_MaxArmor()
	return MaxArmor
end

--Returns the MaxHealth value
function CDS_MaxHealth()
	return MaxHealth
end

--Returns the MinHealth value
function CDS_MinHealth()
	return MinHealth
end

--The Think function(which will call any hooked functions).
function CDS_Think()
	if not server_settings.Bool("CDS_Enabled") then return end
	for _, ent in pairs(cdsaffected) do
		if ent:IsValid() then
			local phys = ent:GetPhysicsObject()
			if ((phys:IsValid() and not ent.CDSIgnore) or ent:IsPlayer() or ent:IsNPC())
					and ent.health and ent.maxhealth and ent.armor and ent.heat then
				for k, v in pairs(cds_function_list) do
					local ok, err = pcall(v, ent)
					if not ok then
						Msg("Error:" .. err .. "\n");
					end
				end
				/ * else
				if not ent.CDSIgnore then
					--Msg("Device not registered: "..tostring(ent:GetClass()).."\n")
				end * /
			end
		else
			table.remove(cdsaffected, _)
		end
	end
end

timer.Create("CDS_Update", 1, 0, CDS_Think)
