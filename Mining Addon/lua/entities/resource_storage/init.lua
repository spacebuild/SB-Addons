AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, {"On" })
	end
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:SetActive( value )

end

function ENT:TriggerInput(iname, value)

end

function ENT:Damage()

end

function ENT:Repair()

end

function ENT:Destruct()

end

function ENT:OnRemove()

end


function ENT:Think()
	self.BaseClass.Think(self)

	self:NextThink( CurTime() + 1 )
	return true
end
