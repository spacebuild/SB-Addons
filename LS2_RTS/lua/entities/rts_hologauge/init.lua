-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging Factory Crate
-- Purpose: holds resources and storage
-- Uses: Resource Distribution 2, Life Support 2


AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()   
	self.model = "models/Gibs/HGIBS_spine.mdl"
	self.NextUse = 0
	self.TimeToNextCheck = 0
	self:SetMaterial("models/props_pipes/pipesystem01a_skin1")
	
	

	self:SetModel( self.model ) 	
	self:PhysicsInit( SOLID_VPHYSICS )      	
	self:SetMoveType( MOVETYPE_VPHYSICS )   	
	self:SetSolid( SOLID_VPHYSICS )        	

	-- The resources Get defined
	RD_AddResource(self, "air", 0)
	RD_AddResource(self, "coolant", 0)
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "water", 0)
	RD_AddResource(self, "heavy water", 0)

	self.NextCheckTime = 0
	self.ResTable = {}
	rts_UpdateRequest()
	self:ReadyResources()

	self.ResourceType = 1
	self.ResourceName = self.ResTable[self.ResourceType]
 	self:SetNetworkedString("Resource", "["..self.ResourceType.."] "..self.ResourceName)
 	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "Resource ID" })
		self.Outputs = Wire_CreateOutputs( self, { "Resource ID" ,"Current", "Max","Percent"})	
	 end

end 

function ENT:TriggerInput(iname, value)
	value = math.Round(value)
	self:ReadyResources()
	if (iname == "Resource ID") then
		if ((value > 0) and (value <= (table.getn(self.ResTable))) and (value ~= self.ResourceType)) then
			self.ResourceType = value
			self.ResourceName = self.ResTable[self.ResourceType]
		 	self:SetNetworkedString("Resource", "["..self.ResourceType.."] "..self.ResourceName)
		end
	end
end


--Dynamic Resource Allocation Solution!
function ENT:ReadyResources()
	local iCount = rts_NumberOfResources()
	if (table.getn(self.ResTable) < iCount) then
		--Error("Woo! It updated!\n")
		for x = (table.getn(self.ResTable)+1),iCount do
			self.ResTable[x] = rts_ResourceName(x)
			RD_AddResource(self, self.ResTable[x], 0)
		end
	end
end  


function ENT:Use()
	-- Only check for new resources once every 15 seconds
	-- and then, only if they use the device :-)
	self:ReadyResources()

	if (self.NextUse < CurTime()) then
		self.ResourceType = (self.ResourceType + 1) 
		if (self.ResourceType  > table.getn(self.ResTable) ) then self.ResourceType = 1 end
		
		self.ResourceName = self.ResTable[self.ResourceType]
		self:SetNetworkedString("Resource", "["..self.ResourceType.."] "..self.ResourceName)
		self.NextUse = CurTime() + 0.5 --delay to keep from toggling it multiple times 
	end
	self.ResourceName = self.ResTable[self.ResourceType]
		
	self:NextThink( CurTime()+0.01)

end

function ENT:Think()
	-- check for updates from the global functions every 5 seconds
	self.NextCheckTime = (self.NextCheckTime + 1) % 5
	if (self.NextCheckTime == 0) then self:ReadyResources() end
		
 	self:SetNetworkedInt("ResAmount", RD_GetResourceAmount(self, self.ResourceName))
 	self:SetNetworkedInt("ResMaxAmount", RD_GetNetworkCapacity(self, self.ResourceName))
	
 	if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "Resource ID", self.ResourceType)
			Wire_TriggerOutput(self, "Current", RD_GetResourceAmount(self, self.ResourceName))
			Wire_TriggerOutput(self, "Max", RD_GetNetworkCapacity(self, self.ResourceName))
			Wire_TriggerOutput(self, "Percent", RD_GetResourceAmount(self, self.ResourceName) / RD_GetNetworkCapacity(self, self.ResourceName) * 100)
	end	
 	
	self:NextThink( CurTime() + 1)
	return true
 end
 