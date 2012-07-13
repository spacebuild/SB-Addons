AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.MaxDistance = 10000
--ENT.WiredOutPuts = {"On", "Disable Use", "Has Pair", "Syncing", "Distance", "Max Distance"}

function ENT:Initialize()
	--self:SetModel("models/props_combine/combinethumper002.mdl")
	self.BaseClass.Initialize(self, false)
	self.channel = 0
	self.Resources = {}
	
	if(ASTEROID_MOD) then
		for k, res in pairs(AsteroidResources) do
			table.insert(self.Resources, res.name)
		end
	end
	
	if(CombatDamageSystem) then
		for k, res in pairs(CDS_GetResources()) do
			table.insert(self.Resources, res)
		end
	end
	
	for k, res in pairs(self.Resources) do
		RD_AddResource(self, res, 0)
		--table.insert(self.WiredOutPuts, res) Wire can't suppot this many things :(
	end
	
	self.Pair = false
	self.Active = 0
	self.Syncing = 0
	self.HasPair = 0	
	self.Owner = self:GetPlayer()
	
	if(self.Phys:IsValid()) then
		self.Phys:SetMass(5000)
	end
	
	self:CheckPair()
	self:UpdateToolTip()
	
	if(WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On", "Disable Use", "Channel"})
		self.Outputs = Wire_CreateOutputs(self, {"On", "Disable Use", "Has Pair", "Syncing", "Distance", "Max Distance", "Channel"})
		Wire_TriggerOutput(self, "Max Distance", self.MaxDistance)
		Wire_TriggerOutput(self, "Channel", self.channel)
	end
end
	
function ENT:Use(activator, caller)
	self.BaseClass.OnOffUse(self, activator)
end

function ENT:TurnOn()
	if(self.Active == 1) then return end
	self.Active = 1	
	self:EmitSound(self.APCEngineStartSound)
	self.BaseClass.UpdateActive(self)
	self:UpdateToolTip()
end

function ENT:TurnOff()
	if(self.Active == 0) then return end
	self.Active = 0
	self:StopSound(self.APCEngineStartSound)
	self:EmitSound(self.APCEngineStopSound)
	self.BaseClass.UpdateActive(self)
	self:UpdateToolTip()
end

function ENT:CheckPair()
	if(self.Pair == false) then
		for k, v in pairs(ents.FindByClass("wireless_resource_syncer")) do
			if(v:IsValid() and self.Owner == v:GetPlayer() and v ~= self and v.channel == self.channel) then
				self.Pair = v
				if(WireAddon ~= nil) then
					Wire_TriggerOutput(self, "Has Pair", 1)
				end
				return true
			end
		end
	elseif(self.Pair:IsValid() and (self.channel == self.Pair.channel)) then
		return true
	else
		self.Pair = false
		if(WireAddon ~= nil) then
			Wire_TriggerOutput(self, "Has Pair", 0)
		end		
	end
	return false
end

function ENT:UpdateToolTip()
	local Syncing = "Off"
	if(self.Syncing == 1) then
		Syncing = "On"
	end
	local Active = "Off"
	if(self.Active == 1) then
		Active = "On"
	end
	self:SetNetworkedString("ToolTip1", self.PrintName..": "..Active)
	self:SetNetworkedString("ToolTip2", "\nSyncing: "..Syncing)
	self:SetNetworkedString("ToolTip3", "\nChannel: "..self.channel)
end

function ENT:Think()
	local Energy = RD_GetResourceAmount(self, "energy")
	local Coolant = RD_GetResourceAmount(self, "coolant")
	
	if(self:CheckPair() == false) then
		if(self.Active == 1) then
			--self:TurnOff()
		end
	elseif(WireAddon ~= nil) then
		Wire_TriggerOutput(self, "Distance", self:GetPos():Distance(self.Pair:GetPos()))
	end
	
	if(self.Active == 1) then		
		-- For Just Being On
		self.BaseClass.UseResource(self, "energy", math.Round(math.random(2, 4)))
		self.BaseClass.UseResource(self, "coolant", math.Round(math.random(2, 4)))
		
		local Distance = 1
		if(self.Pair) then
			Distance = self:GetPos():Distance(self.Pair:GetPos())
		end

		if(Energy == 0 or Coolant == 0 or Distance > self.MaxDistance) then
			if(Coolant == 0) then
				cds_heatpos(self:GetPos(), 3, 250)
			end
			if(Energy == 0 or Distance > self.MaxDistance) then
				self.BaseClass.Warning(self)
			end
			
			if(self.Syncing == 1) then
				self.Syncing = 0
				if(WireAddon ~= nil) then
					Wire_TriggerOutput(self, "Syncing", 0)
				end
				self:UpdateToolTip()
			end
		elseif(self.Pair and self.Pair.Active == 1) then
			-- Real Sync Part Start
			for k, res in pairs(self.Resources) do
				if(RD_GetNetworkCapacity(self.Pair, res) > 0) then
					local ResourceTransfer = math.random(25, 50) / 2
					local ResourceAmount = RD_GetResourceAmount(self, res)
					local ResourceAmountPair = RD_GetResourceAmount(self.Pair, res)
					
					if(ResourceAmount > ResourceTransfer and ResourceAmount > RD_GetResourceAmount(self.Pair, res)) then
						for x=1, 99 do
							if(ResourceAmountPair > ResourceAmount + ResourceTransfer) then
								Error("WRS DEBUG\n")
								Error(ResourceAmountPair..":ResourceAmountPair\n")
								Error(ResourceAmount..":ResourceAmount\n")
								Error(ResourceTransfer..":ResourceTransfer\n")
								ResourceTransfer = ResourceTransfer / 2
							else
								break
							end
						end

						ResourceTransfer = math.Round(ResourceTransfer)
						RD_SupplyResource(self.Pair, res, ResourceTransfer)
						self.BaseClass.UseResource(self, res, ResourceTransfer)
					end
				end
			end
			if(self.Syncing == 0) then
				self.Syncing = 1
				if(WireAddon ~= nil) then
					Wire_TriggerOutput(self, "Syncing", 1)
				end
				self:UpdateToolTip()
			end
			-- Old Setup...For Backup Purposes....
			-- local AirTransfer = math.Round(math.random(25, 50) / 2)
			-- if(Air > AirTransfer and Air > RD_GetResourceAmount(self.Pair, "air")) then
				-- RD_SupplyResource(self.Pair, "air", AirTransfer)
				-- self.BaseClass.UseResource(self, "air", AirTransfer)
			-- end
			-- Real Sync Part End
		elseif(self.Syncing == 1) then
			self.Syncing = 0
			if(WireAddon ~= nil) then
				Wire_TriggerOutput(self, "Syncing", 0)
			end
			self:UpdateToolTip()
		end
	elseif(self.Syncing == 1) then
		self.Syncing = 0
		if(WireAddon ~= nil) then
			Wire_TriggerOutput(self, "Syncing", 0)
		end
		self:UpdateToolTip()
	end
	
	if(WireAddon ~= nil) then
		for k, res in pairs(self.Resources) do
			Wire_TriggerOutput(self, res, RD_GetResourceAmount(self, res))
		end
	end
end

function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif(iname == "Disable Use") then
		if(value == 1) then
			self.DisableUse = true
			Wire_TriggerOutput(self, "Disable Use", 1)
		else
			self.DisableUse = false
			Wire_TriggerOutput(self, "Disable Use", 0)
		end
	elseif(iname == "Channel") then
		if (value < 0) then
			self.channel = 0
		else
			self.channel = value
		end
		Wire_TriggerOutput(self, "Channel", self.channel)
		self:UpdateToolTip()
	end
end

function ENT:OnRemove()
	self:StopSound(self.APCEngineStartSound)
	self.BaseClass.OnRemove(self)
end
