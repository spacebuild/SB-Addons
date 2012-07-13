-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging System
-- Purpose: Packages goods for transport. 
-- Uses: Resource Distribution 2, Life Support 2, Wire

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient/energy/electric_loop.wav" )
util.PrecacheSound( "AlyxEMP.Discharge" )
util.PrecacheSound( "common/warning.wav")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_lab/teleplatform.mdl" )
	self.BaseClass.Initialize(self)
	
	-- use stuff
	self.packetsize = 5000 			-- Default size of packets to launch
	self.currentpacketsize = 0		-- Current load size
	self.resourcetype = 1			-- resource type
	self.reloadtime = 0				-- How long until the packager can fire again
	self.charging = 0				-- 0 = inactive, 1 = packaging
	--self.Cycle = 0
	self.energyuse = math.Round(self.packetsize/10)	-- A simple linear growth for this one
	self.NextCheckTime = 0
	
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "Compress", "Resource Type", "Package Size" })
		self.Outputs = Wire_CreateOutputs( self, { "Ready" ,"Package Size", "Energy Use", "Compressing Package" })	
	 end

	-- The resources Get defined
	RD_AddResource(self, "energy", 0)
	RD_AddResource(self, "air", 0)
	RD_AddResource(self, "coolant", 0)
	RD_AddResource(self, "water", 0)
	RD_AddResource(self, "heavy water", 0)
	
	self.ResTable = {}
	rts_UpdateRequest()
	self:ReadyResources()

	self:SetNetworkedInt("Max",self.packetsize)
	self:SetNetworkedInt("PercentDone",0)
	self:SetNetworkedInt("ReqEnergy",self.energyuse)
	self:SetNetworkedString("Resource",self.ResTable[1])
	self:SetNetworkedBool("Recharging",false)
	

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

-- Wiremod function!
function ENT:TriggerInput(iname, value)
	self:ReadyResources()

	if(iname == "Compress") then
		if((value == 1) and (self.reloadtime < CurTime())) then
			if (RD_GetResourceAmount(self, "energy") >  self.energyuse) then
				self.charging = 1
				self.counter = 0
				self:SetNetworkedBool("Recharging",true)

				--self:EmitSound( "ambient/energy/electric_loop.wav")
			end
		end	
	end
	if(iname == "Resource Type") then
		if ((value >= 0) and (value <= (table.getn(self.ResTable))) and (value ~= self.resourcetype) and (self.charging == 0)) then
			--Chage resource type if value is within range, and it isn't the same resource type
			--and it isn't charging a packet
			if (value == 0) then value = 1 end
			self.resourcetype = math.Round(value)			--Lurk-moar found this one, forgot to round the input :-P
			self.currentpacketsize=0
			self.reloadtime = CurTime() + 5
			self:SetNetworkedString("Resource",self.ResTable[self.resourcetype])
			-- if you change the resource
			-- be nice and show it on the tooltip
			--self.Cycle = 2
		end	
	end
	if((iname == "Package Size") and (self.charging == 0)) then
		--minimum packet size is 100
		if (value < 100) then
			self.packetsize = 100
		--no max, if you can afford the energy, you can package it
		else 
			--Change Packet Size
			self.packetsize = math.Round(value)
		end	
		if (self.currentpacketsize > self.packetsize) then
			self.currentpacketsize = self.packetsize
		end
		self.energyuse = math.Round(self.packetsize/10)
		self:SetNetworkedInt("ReqEnergy",self.energyuse)
		self:SetNetworkedInt("Max",self.packetsize)
	end
end

function ENT:Use()
	self:ReadyResources()

	if(self.reloadtime < CurTime()) then
		if (RD_GetResourceAmount(self, "energy") >  self.energyuse) then
			self.charging = 1
			self.counter = 0
			self:SetNetworkedBool("Recharging",true)
			--self:EmitSound( "ambient/energy/electric_loop.wav")

		end
	end	
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "ambient/energy/electric_loop.wav" )
	self:StopSound( "AlyxEMP.Discharge" )
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	-- check for updates from the global functions every 5 seconds
	self.NextCheckTime = (self.NextCheckTime + 1) % 50
	if (self.NextCheckTime == 0) then self:ReadyResources() end

	
	self.energy 	= RD_GetResourceAmount(self, "energy")
	self.varmod		= 0
	
	
	local tempvarname = self.ResTable[self.resourcetype]
	local tempvalue = RD_GetResourceAmount(self, tempvarname)

	if (self.charging == 1) then
		--Setting networked vars is expensive, so lets do it every five seconds
		self.counter = (self.counter + 1) % 50
		if (self.counter == 0) then
			self:SetNetworkedInt("PercentDone",math.Round(self.currentpacketsize/self.packetsize*100))
		end
		
		
		self.reloadtime = CurTime() + 5
		--self.Cycle = 3.5
		if ((self.currentpacketsize + 10) > self.packetsize) then
			self.varmod = (self.currentpacketsize + 10) - self. packetsize
			self.charging = 2
		else
			self.varmod = 0
		end
		
		if (tempvalue >= 10) then
			RD_ConsumeResource(self, tempvarname, 10 - self.varmod)
			self.currentpacketsize = self.currentpacketsize + 10 - self.varmod
		else
			RD_ConsumeResource(self, tempvarname, tempvalue - self.varmod)
			self.currentpacketsize = self.currentpacketsize + tempvalue - self.varmod
		end
		local effectdata = EffectData()
			effectdata:SetStart	(self:GetPos()+ Vector(math.Rand(-30,30),math.Rand(-30,30),0))
			effectdata:SetOrigin(self:GetPos()+  self:GetUp() * 50 + Vector(math.Rand(-20,20),math.Rand(-20,20),0))
			effectdata:SetEntity(self)
			effectdata:SetAttachment( 1 )
		util.Effect	( "rts_zap", effectdata ) 


		--self.energyuse 	= math.Round(self.packetsize/10)
			
		if (self.charging == 2) then
			self:StopSound( "ambient/energy/electric_loop.wav" )

			local ent = ents.Create( "rts_package" )
			ent:SetPos( self:GetPos() +  self:GetUp() * 10)
			ent:SetAngles( self:GetAngles() )
			ent:Spawn()
			ent:SetWeight(tempvarname,self.packetsize)
			ent:Activate()

			self.currentpacketsize = 0
			self.reloadtime = CurTime() + 5
			self:EmitSound( "AlyxEMP.Discharge", 100, 100)
			
			ent.resourcename = tempvarname

			self.counter = 0
			self.charging = 0
			self.currentpacketsize = 0
			self:SetNetworkedInt("PercentDone",0)
			self:SetNetworkedBool("Recharging",false)

		end
	end	
---------------------WIRE MOD OUTPUTS-------------------------------------------------
	if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "Ready", (self.reloadtime < CurTime()))
			Wire_TriggerOutput(self, "Energy Use", self.energyuse)
			Wire_TriggerOutput(self, "Compressing Package", self.charging)
			Wire_TriggerOutput(self, "Packet Size", self.currentpacketsize)
			Wire_TriggerOutput(self, "Max Load", self.packetsize)
	end	

	self:NextThink( CurTime() + 0.1 )
	return true
end

function ENT:Destruct()
	LS_Destruct( self, true )
end