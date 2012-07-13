AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Resources = {"energy", "oxygen", "nitrogen", "water", "steam", "heavy water", "hydrogen", "carbon dioxide", "liquid nitrogen", "hot liquid nitrogen", "methane", "propane", "deuterium", "tritium"}
ENT.MaxAmount = 500000

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	local RD = CAF.GetAddon("Resource Distribution")
	self:SetColor(Color(0, 0, 0, 255))
	self:SetMaterial("models/shiny")
	
	for k, res in pairs(self.Resources) do
		RD.AddResource(self, res, self.MaxAmount)
	end
	
	local Phys = self:GetPhysicsObject()
	if(Phys:IsValid()) then
		Phys:Wake()
	end
	
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, {"Resource Amount"})
		Wire_TriggerOutput(self, "Resource Amount", self.MaxAmount)
	end
end

function ENT:Think()
	local RD = CAF.GetAddon("Resource Distribution")
	for k, res in pairs(self.Resources) do
		if(RD.GetResourceAmount(self, res) < self.MaxAmount) then
			RD.SupplyResource(self, res, self.MaxAmount)
		end
	if (self.NextOverlayTextTime) and (CurTime() >= self.NextOverlayTextTime) then
		if (self.NextOverlayText) then
			self:SetNetworkedString( "GModOverlayText", self.NextOverlayText )
			self.NextOverlayText = nil
		end
	end
	self.NextOverlayTextTime = CurTime() + 0.2 + math.random() * 0.2
	end
	self:NextThink(CurTime() + 1)
	return true
end


function ENT:OnRemove()
	--self.BaseClass.OnRemove(self) --use this if you have to use OnRemove
	CAF.GetAddon("Resource Distribution").Unlink(self)
	CAF.GetAddon("Resource Distribution").RemoveRDEntity(self)
	if not (WireAddon == nil) then Wire_Remove(self) end
end