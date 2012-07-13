AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		
	end
end

function ENT:Destruct()

end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:EmitSound( "Airboat_engine_idle" )
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(1)
		self.time = 10
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "Airboat_engine_idle" )
		self:EmitSound( "Airboat_engine_stop" )
		self:StopSound( "apc_engine_start" )
		self.Active = 0
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:SetActive( value, caller )
	if self.Active == 0 then
		self:TurnOn()
		self.caller = caller
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "Airboat_engine_idle" )
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
		if self.time > 0 then
			self.time = self.time - 1
		else
			local attack = CustomAttack.Create(nil, self, self.caller)
			attack:AddAttack("Shock", 100)
			attack:AddAttack("Kinetic", 100)
			attack:AddAttack("Energy", 100)
			attack:setPiercing(2)
			CDSAttacks.Explosion(attack , 512, 1, true)
			self:Remove()
		end
	end
	self:NextThink( CurTime() + 1 )
	return true
end
