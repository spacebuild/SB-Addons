AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local BeamLength = 512
local Energy_Increment = 200
local Minelevel = 200
local Maxlength = 1024
--local Refire_Rate = 0.6

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.Minelevel = Minelevel
	self.BeamLength = BeamLength
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "MiningPower", "Range" })
		self.Outputs = Wire_CreateOutputs(self, {"On" })
	else
		self.Inputs = {{Name="On"},{Name="MiningPower"},{Name="Range"}}
	end
end

function ENT:TurnOn()
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "Airboat_engine_idle" )
		self:EmitSound( "Airboat_engine_stop" )
		self:StopSound( "apc_engine_start" )
		self.Active = 0
	end
end

function ENT:SetActive( value )
	if not (value == nil) then
		if (value ~= 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
				self:TurnOff()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
	if (inname == "MiningPower") then
		self.Minelevel = value
	end
	if (iname == "Range") then
		if value > Maxlength then
			self.Beamlength = Maxlength
			return
		end
		self.Beamlength = value
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self:SetColor(Color(255, 255, 255, 255))
	self:SetHealth( self:GetMaxHealth( ))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Mining Addon") then
		CAF.GetAddon("Mining Addon").Destruct( self, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "Airboat_engine_idle" )
end

function ENT:Mine()
	local ent = self
	local RD = CAF.GetAddon("Resource Distribution")
	self.energy =  RD.GetResourceAmount(self, "energy")
	--Msg(self.energy)
	--[[local mul = 1
	if GAMEMODE.IsSpacebuildDerived and self.environment and (self.environment:IsSpace() or self.environment:IsStar() )then
		mul = 0 --Make the device still absorb energy, but not produce any air anymore
	elseif GAMEMODE.IsSpacebuildDerived and self.environment and  self.environment:IsEnvironment() and not self.environment:IsPlanet() then
		mul = 0.5
	end]] --Useless Old crap. Mul isn't used anywhere >.>
	local einc = math.Round((Energy_Increment * (self.Minelevel / 200)) * (self.BeamLength / 512))
	einc = einc --What the...
	if (self.energy >= einc) then
		RD.ConsumeResource(self, "energy", einc)
		local Pos = ent:GetPos()
		local Ang = ent:GetAngles()
		--Ang:RotateAroundAxis(Ang:Up(), 180)  --the thing spawns backwards  o_O
		Pos = Pos+Ang:Up()*16
		local trace = {}
		trace.start = Pos
		if string.lower(self:GetModel()) == "models/props_trainstation/tracklight01.mdl" then
			trace.endpos = Pos+(Ang:Forward()*self.BeamLength)
		else
			trace.endpos = Pos+(Ang:Up()*self.BeamLength)
		end
		trace.filter = { ent }
		local tr = util.TraceLine( trace )
		--[[Msg("Asteroid ")
		Msg(tr.Entity)
		Msg(" " .. tr.Entity.mine_amount .." remaining\n")]]
		if (tr.Entity.mine_amount ~= nil and tr.Entity.mine_amount > 0) then
			local take = self.Minelevel*4001 --testing speed pl0x
			if tr.Entity.mine_amount < take then
				take = tr.Entity.mine_amount
			end
			if string.lower(tr.Entity:GetClass()) == "asteroid" then
				local notes = "naquadah, titanium, nitrogen, hydrogen, O2, CO2"
				--local take = units --Useless var, only refenced in the line below.
				local n_amt = math.Round(take * 0.35) --Methinks these values could use more randomization. Or, better yet, seperate aseroids for each type! That way the resources could actually have Rarities and Values! *giddy*
				local t_amt = math.Round(take * 0.3)
				local h_amt = math.Round(take * 0.20)
				local ni_amt = math.Round(take * 0.05)
				local o2_amt = math.Round(take * 0.05)
				local co2_amt = math.Round(take * 0.05)
		
				RD.SupplyResource(self, "naquadah", n_amt)
				RD.SupplyResource(self, "titanium", t_amt)
				RD.SupplyResource(self, "nitrogen", h_amt)
				RD.SupplyResource(self, "hydrogen", ni_amt)
				RD.SupplyResource(self, "oxygen", o2_amt)
				RD.SupplyResource(self, "carbon dioxide", co2_amt)
				tr.Entity.mine_amount = tr.Entity.mine_amount - take
				if (tr.Entity.mine_amount < 1) then
					CAF.GetAddon("Mining Addon").Destruct( tr.Entity, 2) --Mined out of resources
					tr.Entity:Remove()
				end
			elseif string.lower(tr.Entity:GetClass()) == "mine" then
				if tr.Entity:GetSkin() == 0 then
					RD.SupplyResource(self, "titanium", take)
					tr.Entity.mine_amount = tr.Entity.mine_amount - take
				elseif tr.Entity:GetSkin() == 1 then
					RD.SupplyResource(self, "naquadah", take)
					tr.Entity.mine_amount = tr.Entity.mine_amount - take
				end
				if (tr.Entity.mine_amount < 1) then
					CAF.GetAddon("Mining Addon").Destruct( tr.Entity, 2) --Mined out of resources
					tr.Entity:Remove()
				end
			end
		end
		local effectdata = EffectData()
		effectdata:SetEntity( ent )
		effectdata:SetOrigin( Pos )
		effectdata:SetStart( tr.HitPos )
		effectdata:SetAngle( Ang )
		util.Effect( "mining_beam", effectdata, true, true )
		--Msg('Thought')
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			self:Mine()
	end
	self:NextThink( CurTime() + 1 )
	return true
end
