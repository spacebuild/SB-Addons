--[[ BASE_CDS
	WRITTEN BY SPACETECH
]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.LastUse = 0
ENT.LSCheck = true
ENT.IsMissileBomb = false

ENT.WarningSound = "common/warning.wav"
ENT.APCEngineStartSound = "apc_engine_start"
ENT.APCEngineStopSound = "apc_engine_stop"
ENT.AirboatEngineIdleSound = "Airboat_engine_idle"
ENT.AirboatEngineStopSound = "Airboat_engine_stop"
ENT.MissleLaunchSound = "weapons/rpg/rocketfire1.wav"
	
util.PrecacheSound(ENT.WarningSound)
util.PrecacheSound(ENT.APCEngineStartSound)
util.PrecacheSound(ENT.APCEngineStopSound)
util.PrecacheSound(ENT.AirboatEngineIdleSound)
util.PrecacheSound(ENT.AirboatEngineStopSound)
util.PrecacheSound(ENT.MissleLaunchSound)

-- Hopefully I didn't miss any...
--[[ All Functions:
	Global Functions:
		self.BaseClass.Initialize(self, LSCheck, MissileCheck)
		self.BaseClass.Shoot(self)
		self.BaseClass.UpdateActive(self)
		self.BaseClass.SetToolTip(self, TableValues)
		self.BaseClass.Warning(self)
		self.BaseClass.UseResource(self, Name, Amount)
		self.BaseClass.CanUse(self, activator)
		self.BaseClass.Think(self, Override)
		self.BaseClass.SetUpWireSupport(self)
		self.BaseClass.TriggerInput(self, iname, value)
		self.BaseClass.PreEntityCopy(self)
		self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
		self.BaseClass.OnRemove(self)
		self.BaseClass.PhysicsCollideEffect(self, ColorVector)
		self.BaseClass.BFPhysicsCollide(self, data, physobj)
		self.BaseClass.OnOffUse(self, activator)
	Missile Functions:
		self.BaseClass.CreateMissile(self, Class)
		self.BaseClass.KeyValue(self, key, value)
		self.BaseClass.MissilePhysicsUpdate(self, PhysObj)
		self.BaseClass.UseFuel(self)
		self.BaseClass.MissileNoFuel(self)
		self.BaseClass.Trail(self, ColorVector)
		self.BaseClass.CheckTrailEnt(self)
	Factory Functions:
		self.BaseClass.SetupFactory(self)
		self.BaseClass.FactoryThink(self)
		self.BaseClass.FactoryTurnOn(self)
		self.BaseClass.FactoryTurnOff(self)
	Gun Functions:
		self.BaseClass.CreateBeam(self, Time)
	Bomb Functions:
		self.BaseClass.CreateBomb(self, Class)
	Ammo Crate Functions:
		self.BaseClass.SetUpCrate(self)
		self.BaseClass.CrateThink(self)
]]

--[[
	GLOBAL FUNCTIONS START
]]

-- self.BaseClass.Initialize(self, LSCheck, MissileCheck)
function ENT:Initialize(LSCheck, MissileBombCheck, Launcher, SimpleUseCheck)
	if(!CombatDamageSystem or !LIFESUPPORT) then self:Remove() return end
	self.ToolTip = self.PrintName
	self.CDS_IgnoreColor = true
	self.DisableUse = false
	
	self.health = 2000
	self.armor = 20
	self.heat = 0

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if(SimpleUseCheck == nil or SimpleUseCheck == true) then
		self:SetUseType(SIMPLE_USE)
	end
	
	if(LSCheck == nil or LSCheck == true) then
		RD_AddResource(self, "energy", 0)
		RD_AddResource(self, "coolant", 0)
	else
		self.LSCheck = false
	end
	
	if(Launcher == true) then
		self.FuelMissleUse = 1
	end
	
	self.Phys = self:GetPhysicsObject()
	if(self.Phys:IsValid()) then
		self.Phys:Wake()
		if(MissileCheck == true) then
			self.Phys:EnableDrag(false)
			self.Phys:EnableGravity(false)
		end
	end
	if(MissileBombCheck == true) then
		self.IsMissileBomb = true
		-- Anti I'm goning to dupe a missile/bomb using wire grabber
		timer.Simple(0.1, function ()
			if(!self.SFG) then
				self:Remove()
			end
		end)
		self.CreationTime = CurTime() + 0.25
	end
	if(self.OnOff) then
		self:SetNetworkedString("OnOff", "Off")
	end
end

-- self.BaseClass.Shoot(self)
function ENT:Shoot()
	if(!self.Cooldown) then return false end
	if(self.Cooldown ~= -1) then
		if(self.LastUse + self.Cooldown >= CurTime()) then
			return false
		end
	end
	
	local HeatMulti = 1
	local ResourceTable = {}
	
	if(self.ExplosionUse) then
		table.insert(ResourceTable, {"ammo_explosion", self.ExplosionUse})
	end
	if(self.BasicUse) then
		table.insert(ResourceTable, {"ammo_basic", self.BasicUse})
	end
	if(self.PierceUse) then
		table.insert(ResourceTable, {"ammo_pierce", self.PierceUse})
	end
	if(self.FuelUse) then
		table.insert(ResourceTable, {"ammo_fuel", self.FuelUse})
	end
	if(self.EnergyUse) then
		table.insert(ResourceTable, {"energy", self.EnergyUse})
	end
	if(self.CoolantUse) then
		table.insert(ResourceTable, {"coolant", self.CoolantUse})
	end
	
	for k, v in pairs(ResourceTable) do
		if(RD_GetResourceAmount(self, v[1]) < v[2]) then
			if(v[1] == "coolant" and !self.RequireCoolant) then
				HeatMulti = math.random(8, 12)
			else
				self:Warning()
				return false
			end
		end
	end
	
	for k, v in pairs(ResourceTable) do
		self:UseResource(v[1], v[2])
	end
	local heat_amount = 10 * HeatMulti
	cds_heatpos(self:GetPos(), heat_amount, math.random(heat_amount * .75, heat_amount * 1.25), self)
	
	self.LastUse = CurTime()
	return true
end

-- self.BaseClass.UpdateActive(self)
function ENT:UpdateActive()
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "On", self.Active)
	end
end

-- self.BaseClass.Warning(self)
function ENT:Warning()
	if(!self.LastSound) then self.LastSound = CurTime()-5 end
	if(self.LastSound + 1 < CurTime()) then
		self:EmitSound(self.WarningSound)
		self.LastSound = CurTime()
	end
end

-- self.BaseClass.UseResource(self, Name, Amount)
function ENT:UseResource(Name, Amount, Entity)
	local Ent = self
	if(Entity) then
		Ent = Entity
	end
	local ResouceAmount = RD_GetResourceAmount(Ent, Name)
	if(ResouceAmount > Amount) then
		RD_ConsumeResource(Ent, Name, Amount)
	else
		RD_ConsumeResource(Ent, Name, ResouceAmount)
	end
end

-- self.BaseClass.CanUse(self, activator)
function ENT:CanUse(activator)
	self.Activator = activator
	if(self.DisableUse == false) and not server_settings.Bool( "CDS_Disable_Use" ) then
		return true
	else
		return false
	end
end

-- self.BaseClass.Think(self, Override)
function ENT:Think(Override)
	if(self.CreationTime or !self.Cooldown or !WireAddon) then return end
	
	local CanFire = 1
	local CanFireTable = {}
	local ShotsLeftTable = {}
	
	if(self.ExplosionUse) then
		table.insert(CanFireTable, {"ammo_explosion", self.ExplosionUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "ammo_explosion")/self.ExplosionUse))
	end
	if(self.BasicUse) then
		table.insert(CanFireTable, {"ammo_basic", self.BasicUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "ammo_basic")/self.BasicUse))
	end
	if(self.PierceUse) then
		table.insert(CanFireTable, {"ammo_pierce", self.PierceUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "ammo_pierce")/self.PierceUse))
	end
	if(self.FuelUse) then
		table.insert(CanFireTable, {"ammo_fuel", self.FuelUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "ammo_fuel")/self.FuelUse))
	end
	if(self.EnergyUse) then
		table.insert(CanFireTable, {"energy", self.EnergyUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "energy")/self.EnergyUse))
	end
	if(self.CoolantUse) then
		table.insert(CanFireTable, {"coolant", self.CoolantUse})
		table.insert(ShotsLeftTable, math.floor(RD_GetResourceAmount(self, "coolant")/self.CoolantUse))
	end
	
	table.sort(ShotsLeftTable)
	
	for k, v in pairs(CanFireTable) do
		if(RD_GetResourceAmount(self, v[1]) < v[2]) then
			if(v[1] ~= "coolant" or (v[1] == "coolant" and self.RequireCoolant)) then
				CanFire = 0
			end
		end
	end
	
	if(self.LastUse + self.Cooldown >= CurTime()) then
		CanFire = 0
	end
	
	Wire_TriggerOutput(self, "Can Fire", CanFire)
	Wire_TriggerOutput(self, "Shots Left", ShotsLeftTable[1])
	
	if(self.BaseClass.Trace(self, self:GetUp(), false, true):IsValid()) then	
		Wire_TriggerOutput(self, "Hit Ent", 1)
	else
		Wire_TriggerOutput(self, "Hit Ent", 0)
	end
	
	if(Override) then return end
	self:NextThink(CurTime() + 1)
	return true
end

-- self.BaseClass.SetUpWireSupport(self)
function ENT:SetUpWireSupport()
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"Fire", "Disable Use", "Draw Beam"})
		self.Outputs = Wire_CreateOutputs(self, {"Disable Use", "Can Fire", "Shots Left", "Hit Ent"})
	end
end

-- self.BaseClass.TriggerInput(self, iname, value)
function ENT:TriggerInput(iname, value)
	if(iname == "Fire" and value == 1) then
		self:Shoot()
	end
	if(iname == "Disable Use") then
		if(value == 1) then
			self.DisableUse = true
			Wire_TriggerOutput(self, "Disable Use", 1)
		else
			self.DisableUse = false
			Wire_TriggerOutput(self, "Disable Use", 0)
		end
	end
	if(iname == "Draw Beam") then
		if(value == 1) then
			self:SetNetworkedBool("DrawBeam", true)
		else
			self:SetNetworkedBool("DrawBeam", false)
		end
	end
end

-- self.BaseClass.PreEntityCopy(self)
function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self)
	if(WireAddon ~= nil) then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
		end
	end
end

-- self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if(WireAddon ~= nil) and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end

-- self.BaseClass.OnRemove(self)
function ENT:OnRemove(GenCheck)
	if(self.resources2) then
		Dev_Unlink_All(self)
	end
	if(GenCheck) then
		self:StopSound(self.AirboatEngineIdleSound)
	end
	self:CheckTrailEnt()
end

-- self.BaseClass.PhysicsCollideEffect(self, ColorVector)
function ENT:PhysicsCollideEffect()
	local Effect = EffectData()
	Effect:SetScale(20)
	Effect:SetOrigin(self:GetPos())
	Effect:SetMagnitude(math.random(2, 3))
	util.Effect("cds_missile_hit", Effect, true, true)
end

-- self.BaseClass.BFPhysicsCollide(self, data, physobj)
function ENT:BFPhysicsCollide(data, physobj)
	local DataPhys = data.HitObject
	if(self:GetPhysicsObject() == DataPhys or self.CreationTime >= CurTime()) then return end
	self.BaseClass.PhysicsCollideEffect(self)
	self:DoHit()
end

-- self.BaseClass.OnOffUse(self, activator)
function ENT:OnOffUse(activator)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	if(self.Active == 1) then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

-- self.BaseClass.KeyValue(self, key, value)
function ENT:KeyValue(key, value)
	if(key == "Fuel") then
		self.Fuel = tonumber(value)
	end
	if(key == "FuelUse") then
		self.FuelUse = tonumber(value)
	end
	if(key == "SFG") then
		self.SFG = true
	end
end

--[[
	GLOBAL FUNCTIONS END
]]

--[[
	MISSILE FUNCTIONS START
]]

-- self.BaseClass.CreateMissile(self, Class)
function ENT:CreateMissile(Class)
	local Missile = ents.Create(Class)
	if(!Missile:IsValid()) then return end
	Missile:SetPos(self:GetPos())
	Missile:SetAngles(self:GetAngles())
	Missile:SetPhysicsAttacker(self.Activator)
	Missile:SetKeyValue("Fuel", self.FuelUse)
	Missile:SetKeyValue("FuelUse", self.FuelMissleUse)
	Missile:SetKeyValue("SFG", 1)
	Missile:Spawn()
	Missile:Activate()
	Missile.Activator = self.Activator
	constraint.NoCollide(self, Missile, 0, 0)
	self:EmitSound(self.MissleLaunchSound)
end

-- self.BaseClass.MissilePhysicsUpdate(self, PhysObj)
function ENT:MissilePhysicsUpdate(PhysObj)
	if(!self.Fuel or !self.FuelUse or self.Fuel == 0) then
		self.BaseClass.MissileNoFuel(self)
		self.BaseClass.CheckTrailEnt(self)
		return
	end
	PhysObj:ApplyForceCenter(self:GetUp() * 5000000)
	self.BaseClass.UseFuel(self)
end

-- self.BaseClass.UseFuel(self)
function ENT:UseFuel()
	if(self.Fuel > self.FuelUse) then
		self.Fuel = self.Fuel - self.FuelUse
	else
		self.Fuel = 0
	end
end

-- self.BaseClass.MissileNoFuel(self)
function ENT:MissileNoFuel()
	if(!self.Changed) then
		if(self.planet) then
			self.Phys:EnableDrag(true)
			self.Phys:EnableGravity(true)
		end
		self.Changed = true
	end
end

-- self.BaseClass.Trail(self, ColorVector)
function ENT:Trail(ColorVector)
	local TrailEnt = ents.Create("point_tesla")
	TrailEnt:SetPos(self:GetPos())
	TrailEnt:Spawn()
	TrailEnt:SetParent(self)
	self.TrailEnt = TrailEnt
	
	local Effect = EffectData()
	Effect:SetScale(20)
	Effect:SetStart(ColorVector)
	Effect:SetEntity(self.TrailEnt)
	Effect:SetOrigin(self:GetPos())
	Effect:SetMagnitude(math.random(1, 2))
	util.Effect("cds_smoke_trail", Effect, true, true)
end

-- self.BaseClass.CheckTrailEnt(self)
function ENT:CheckTrailEnt()
	if(self.TrailEnt and self.TrailEnt:IsValid()) then
		self.TrailEnt:Remove()
	end
end

--[[
	MISSILE FUNCTIONS END
]]

--[[
	FACTORY FUNCTIONS START
]]

-- self.BaseClass.SetupFactory(self)
function ENT:SetupFactory()
	if(ASTEROID_MOD) then
		RD_AddResource(self, "titanium", 0)
	end
	RD_AddResource(self, self.GenResource, 0)
	
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On"})
		self.Outputs = Wire_CreateOutputs(self, {"On", "Ammo Amount", "Max Ammo Amount"})
	end	
end

-- self.BaseClass.FactoryThink(self)
function ENT:FactoryThink()
	if(!self.UseEnergyAmount) then
		self.UseEnergyAmount = 60
	end
	
	if(!self.UseCoolantAmount) then
		self.UseCoolantAmount = 50
	end
	
	if(!self.UseTitaniumAmount) then
		self.UseTitaniumAmount = 25
	end
	
	if(!self.SupplyResourceAmount) then
		self.SupplyResourceAmount = 60
	end
	
	if(self.Active == 1) then
		if(RD_GetResourceAmount(self, "energy") >= self.UseEnergyAmount) then
			/*if(ASTEROID_MOD and RD_GetResourceAmount(self, "titanium") < self.UseTitaniumAmount) then
				self:TurnOff()
			end*/
			
			if(RD_GetResourceAmount(self, "coolant") < self.UseCoolantAmount) then
				self.BaseClass.Warning(self)
				cds_heatpos(self:GetPos(), 3, 250)
			else
				self.BaseClass.UseResource(self, "coolant", self.UseCoolantAmount)
			end
			self.BaseClass.UseResource(self, "energy", self.UseEnergyAmount)
			
			if(ASTEROID_MOD) then
				self.BaseClass.UseResource(self, "titanium", self.UseTitaniumAmount)
			end
			
			RD_SupplyResource(self, self.GenResource, self.SupplyResourceAmount)
		else
			self:TurnOff()
		end
	end
	
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Ammo Amount", RD_GetResourceAmount(self, self.GenResource))
		Wire_TriggerOutput(self, "Max Ammo Amount", RD_GetNetworkCapacity(self, self.GenResource))
	end	
end

-- self.BaseClass.FactoryTurnOn(self)
function ENT:FactoryTurnOn()
	if(self.Active == 1) then return end
	self:EmitSound(self.AirboatEngineIdleSound)
	self.Active = 1
	self:SetNetworkedString("OnOff", "On")
	self:UpdateActive()
end

-- self.BaseClass.FactoryTurnOff(self)
function ENT:FactoryTurnOff()
	if(self.Active == 0) then return end
	self:StopSound(self.AirboatEngineIdleSound)
	self:EmitSound(self.AirboatEngineStopSound)
	self.Active = 0
	self:SetNetworkedString("OnOff", "Off")
	self:UpdateActive()
end

--[[
	FACTORY FUNCTIONS END
]]

--[[
	GUN FUNCTIONS START
]]

-- self.BaseClass.CreateBeam(self, Time)
function ENT:CreateBeam(Time)
	if(!Time) then
		Time = 0.6
	end
	if(self:GetNetworkedBool("DrawBeam") ~= true) then
		self:SetNetworkedBool("DrawBeam", true)
		timer.Simple(Time, self.SetNetworkedBool, self, "DrawBeam", false)	
	end
end

--[[
	GUN FUNCTIONS END
]]

--[[
	BOMB FUNCTIONS START
]]

-- self.BaseClass.CreateBomb(self, Class)
function ENT:CreateBomb(Class)
	local Bomb = ents.Create(Class)
	if(!Bomb:IsValid()) then return end
	Bomb:SetPos(self:GetPos())
	Bomb:SetAngles(self:GetAngles())
	Bomb:SetPhysicsAttacker(self.Activator)
	Bomb:SetKeyValue("SFG", 1)
	Bomb:Spawn()
	Bomb:Activate()
	Bomb.Activator = self.Activator
	constraint.NoCollide(self, Bomb, 0, 0)
	Bomb:GetPhysicsObject():ApplyForceCenter(self:GetUp() * 1000)
end

--[[
	BOMB FUNCTIONS END
]]

--[[
	CRATE FUNCTIONS START
]]

-- self.BaseClass.SetUpCrate(self)
function ENT:SetUpCrate()
	RD_AddResource(self, self.AmmoType, 2000)
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, {"Ammo Amount", "Max Ammo"})
		Wire_TriggerOutput(self, "Max Ammo", 2000)
	end
end

-- self.BaseClass.CrateThink(self)
function ENT:CrateThink()
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Ammo Amount", RD_GetResourceAmount(self, self.AmmoType))
	end
end

--[[
	CRATE FUNCTIONS END
]]
