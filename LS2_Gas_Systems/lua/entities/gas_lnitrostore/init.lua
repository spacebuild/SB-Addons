AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_borealis/bluebarrel001.mdl")
    self.BaseClass.Initialize(self)
    self:SetColor(Color(0, 38, 123, 255))
    
	self.damaged = 0
    self.maxhealth = 500
    self.health = self.maxhealth
    
    LS_RegisterEnt(self, "Storage")
    RD_AddResource(self, "nitrous", 8000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Nitrous Oxide", "Max Nitrous Oxide" }) end
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(80)
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
	self:SetColor(Color(0, 38, 123, 255))
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
        Wire_TriggerOutput(self, "Nitrous Oxide", RD_GetResourceAmount( self, "nitrous" ))
        Wire_TriggerOutput(self, "Max Nitrous Oxide", RD_GetNetworkCapacity( self, "nitrous" ))
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
