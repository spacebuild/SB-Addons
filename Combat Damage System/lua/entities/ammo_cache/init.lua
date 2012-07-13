AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, false)
	RD_AddResource(self, "ammo_basic", 4000)
	RD_AddResource(self, "ammo_explosion", 4000)
	RD_AddResource(self, "ammo_fuel", 4000)
	RD_AddResource(self, "ammo_pierce", 4000)
	
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, {"Ammo Basic", "Ammo Explosion", "Ammo Fuel", "Ammo Pierce", "Max Ammo"})
		Wire_TriggerOutput(self, "Max Ammo", 4000)
	end	
end

function ENT:Think()
	if(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Ammo Basic", RD_GetResourceAmount(self, "ammo_basic"))
		Wire_TriggerOutput(self, "Ammo Explosion", RD_GetResourceAmount(self, "ammo_explosion"))
		Wire_TriggerOutput(self, "Ammo Fuel", RD_GetResourceAmount(self, "ammo_fuel"))
		Wire_TriggerOutput(self, "Ammo Pierce", RD_GetResourceAmount(self, "ammo_pierce"))
	end
	self:NextThink(CurTime() + 1)
	return true
end
