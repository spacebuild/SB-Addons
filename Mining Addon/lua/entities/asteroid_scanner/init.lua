AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Energy_Increment = 2
local BeepCount = 3
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.SensorLength = 500
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Sensor Length" })
		self.Outputs = Wire_CreateOutputs(self, { "Resource Ammount", "On" })
	else
		self.Inputs = {{Name="On"},{Name="Sensor Length"}}
	end
	--self:ShowOutput()
end

function ENT:TurnOn()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	self:Sense()
	self:ShowOutput()
	if not (WireAddon == nil) then 
		Wire_TriggerOutput(self, "On", 1)
	end
end

function ENT:TurnOff(warn)
	if (!warn) then self:EmitSound( "Buttons.snd17" ) end
	self.Active = 0
	self:SetOOO(0)
	self:ShowOutput()
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self, "Resource Ammount", 0)
		Wire_TriggerOutput(self, "On", 0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive( value )
	elseif (iname == "Sensor Length") then
		self.SensorLength = tonumber(value)
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self, true )
	end
end

function ENT:Sense()
	local RD = CAF.GetAddon("Resource Distribution")
	if (RD.GetResourceAmount(self, "energy") <= 0) then
		self:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	else
		if (BeepCount > 0) then
			BeepCount = BeepCount - 1
		else
			self:EmitSound( "Buttons.snd17" )
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
		end
		
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos()+(self:GetAngles():Up()*self.SensorLength)
		trace.filter = { self }
		local tr = util.TraceLine( trace )
		if tr.Entity and tr.Entity.mine_amount ~= nil then
			self.TargetsResources = math.Clamp(tr.Entity.mine_amount + math.random(-20,20),0,9999999999999999999999) --Live on the edge, technology isn't 100% accurate. ;) 
		else
			self.TargetsResources = 0
		end
		local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( tr.HitPos+(tr.HitNormal*BeepCount) )
		util.Effect( "scan_beam", effectdata, true, true )
	end
	if not (WireAddon == nil) then
		if self.environment then
			Wire_TriggerOutput(self, "Resource Ammount", self.TargetsResources or 0)
		end
	end
	RD.ConsumeResource(self, "energy", Energy_Increment*(self.SensorLength/10))
end

function ENT:ShowOutput()
	if self.Active == 1 then
		self:SetNetworkedInt( "Mineable Ammount", self.TargetsResources or 0)
	else
		self:SetNetworkedInt( "Mineable Ammount", 0)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Sense()
		self:ShowOutput()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end
