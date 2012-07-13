--Written by Lifecell a.k.a Hein
--Thanks to Lifesupport 2 team for few part of their code.

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "lifecube/poweron.wav" )

include('shared.lua')


local Ground = 1 + 0 + 2 + 8 + 32
--Generate by default
local methane_Increment = 50
local nitrous_Increment = 50
local nitrogen_Increment = 50
local naturalgas_Increment = 50
local propane_Increment = 50
--local othergas_Increment = 10
--local more_Increment = 10

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0

self.methane = methane_Increment
self.nitrous = nitrous_Increment
self.nitrogen = nitrogen_Increment
self.naturalgas = naturalgas_Increment
self.propane = propane_Increment
    
	self.time = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Need methane", "Need nitrous", "Need nitrogen", "Need naturalgas", "Need propane" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "methane Output", "nitrous Output", "nitrogen Output", "naturalgas Output", "propane Output"})
	end
	self:SetColor( Color(100, 200, 220, 255 ))
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		--self:EmitSound( "lifecube/poweron.wav" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
        self:SetColor(Color( 220, 200, 100, 255 ))
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		--self:StopSound( "lifecube/poweron.wav" )
		if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "On", 0)
			Wire_TriggerOutput(self, "methane Output", 0)
            Wire_TriggerOutput(self, "nitrous Output", 0)
            Wire_TriggerOutput(self, "nitrogen Output", 0)
            Wire_TriggerOutput(self, "naturalgas Output", 0)
            Wire_TriggerOutput(self, "propane Output", 0)

		end
		self:SetOOO(0)
        self:SetColor( Color(100, 200, 220, 255 ))
	end
end
 
function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
    
    elseif (iname == "Need methane") then
        if (value > -1) then
		    self.methane = value
        end
	
    elseif (iname == "Need nitrous") then
        if (value > -1) then
		    self.nitrous = value
        end
	
    elseif (iname == "Need nitrogen") then
        if (value > -1) then
		    self.nitrogen = value
        end
	
    elseif (iname == "Need naturalgas") then
        if (value > -1) then
		    self.naturalgas = value
        end
	
    elseif (iname == "Need propane") then
        if (value > -1) then
		    self.propane = value
        end
	end

end


function ENT:Damage()

end

function ENT:Repair()
	self:SetColor(Color( 10, 96, 0, 255 ))
	self.health = self.maxhealth
end

function ENT:Destruct()
	--self:StopSound( "lifecube/poweron.wav" )
		LS_Destruct( self )
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--self:StopSound( "lifecube/poweron.wav" )
end

function ENT:Extract_Energy()

    if (self.methane > 0) then RD_SupplyResource(self, "methane", self.methane) end
    if (self.nitrous > 0) then RD_SupplyResource(self, "nitrous", self.nitrous) end
    if (self.nitrogen > 0) then RD_SupplyResource(self, "nitrogen", self.nitrogen) end
    if (self.naturalgas > 0) then RD_SupplyResource(self, "naturalgas", self.naturalgas) end
    if (self.propane > 0) then RD_SupplyResource(self, "propane", self.propane) end

	if not (WireAddon == nil) then 
        Wire_TriggerOutput(self, "methane Output", self.methane)
        Wire_TriggerOutput(self, "nitrous Output", self.nitrous)
        Wire_TriggerOutput(self, "nitrogen Output", self.nitrogen)
        Wire_TriggerOutput(self, "naturalgas Output", self.naturalgas)
        Wire_TriggerOutput(self, "propane Output", self.propane )

    end



end

function ENT:Leak() 

end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Extract_Energy()
	end

	
	self:NextThink(CurTime() + 2)
	return true
end

