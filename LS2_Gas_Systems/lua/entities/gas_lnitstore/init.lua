AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Large Nitrogen Tank"
end

function ENT:Initialize()
	self:SetModel("models/props_borealis/bluebarrel001.mdl")
    self.BaseClass.Initialize(self)
    self:SetColor(Color(0, 123, 38, 255))
    
	self.damaged = 0
    self.maxhealth = 200
    self.health = self.maxhealth
    
    LS_RegisterEnt(self, "Storage")
    RD_AddResource(self, "nitrogen", 8000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Nitrogen", "Max Nitrogen" }) end
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100)
	end
end


function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self:SetColor(Color(0, 123, 38, 255))
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
    LS_Destruct(self)
end

function ENT:Output()
	return 1
end

function ENT:UpdateWireOutputs()
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self, "Nitrogen", RD_GetResourceAmount( self, "nitrogen" ))
        Wire_TriggerOutput(self, "Max Nitrogen", RD_GetNetworkCapacity( self, "nitrogen" ))
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
    self:UpdateWireOutputs()
    
	self:NextThink( CurTime() + 1 )
	return true
end


function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
