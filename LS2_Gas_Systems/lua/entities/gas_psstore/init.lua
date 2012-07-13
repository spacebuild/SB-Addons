AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Small Processed Gas Tank"
end

function ENT:Initialize()
	self:SetModel("models/props_junk/propane_tank001a.mdl")
    self.BaseClass.Initialize(self)

    local phys = self:GetPhysicsObject()
    
    RD_AddResource(self, "nitrogen",3000)
    RD_AddResource(self, "methane",3000)
    RD_AddResource(self, "propane",3000)

    self.damaged = 0
    self.maxhealth = 600
    self.health = self.maxhealth
    
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Nitrogen", "Methane", "Propane", "Max Nitrogen", "Max Methane", "Max Propane" }) end
	
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
	self:SetColor(Color(255, 255, 255, 255))
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
        Wire_TriggerOutput(self, "Methane", RD_GetResourceAmount( self, "methane" ))
        Wire_TriggerOutput(self, "Propane", RD_GetResourceAmount( self, "propane" ))
        Wire_TriggerOutput(self, "Max Nitrogen",RD_GetNetworkCapacity( self, "nitrogen" ))
        Wire_TriggerOutput(self, "Max Methane", RD_GetNetworkCapacity( self, "methane" ))
        Wire_TriggerOutput(self, "Max Propane", RD_GetNetworkCapacity( self, "propane" ))
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
