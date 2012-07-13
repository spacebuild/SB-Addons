AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()
	-- Entity properties and crap
	self:SetModel( "models/props_c17/oildrum001.mdl" )
	self.BaseClass.Initialize(self)
	self.damaged = 0
	
	-- Create a wire output if wire is installed
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Oil" }) end
	
	-- Add resource
	RD_AddResource(self, "Oil", 4000)
	LS_RegisterEnt(self, "Storage")
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self:SetColor(Color( 255, 255, 255, 255 ))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	local Effect = EffectData()
		Effect:SetOrigin(self:GetPos())
		Effect:SetScale(1)
		Effect:SetMagnitude(25)
	util.Effect("Explosion", Effect, true, true)
	self:Remove()
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	-- If wire is installed, update the output!
	if not (WireAddon == nil) then
		self.Oil = RD_GetResourceAmount(self, "Oil")
		Wire_TriggerOutput(self, "Oil", self.Oil)
	end
	
	self:NextThink(CurTime() + 1)
	return true
end
