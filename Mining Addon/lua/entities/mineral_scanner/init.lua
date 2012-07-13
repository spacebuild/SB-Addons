AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "Canals.d1_canals_01_chargeloop" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	RD_AddResource(self, "energy", 0)
	self.Active = 0
	
	self.range = 500
	self:SetNetworkedInt( 1, self.range )
	
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "On", "Range" })
		self.Outputs = Wire_CreateOutputs(self, { "Active" })
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(80)
		phys:Wake()
	end
end

function ENT:TurnOn()
	if ( self.Active == 0 ) then
		self.Active = 1
		self:SetOOO(1)
		self:EmitSound( "Canals.d1_canals_01_chargeloop" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Active", 1) end
	end
end

function ENT:TurnOff()
	if ( self.Active == 1 ) then
		self.Active = 0
		self:SetOOO(0)
		self:StopSound( "Canals.d1_canals_01_chargeloop" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Active", 0) end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "Canals.d1_canals_01_chargeloop" )
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Range") then
		if (value ~= 0) then
			self.range = math.abs(math.floor(value))
		else
			self.range = 0
		end
		self:SetNetworkedInt( 1, self.range )
	end
end

function ENT:Scan()
	if ( RD_GetResourceAmount(self, "energy") >= math.floor(self.range/25) ) then
		RD_ConsumeResource(self, "energy", math.floor(self.range/25))
		local closeents = ents.FindInSphere(self:GetPos(), self.range)
		for _, check in pairs( closeents ) do
			if (check.IsAsteroid == 1) then
				local effectdata = EffectData()
					effectdata:SetOrigin( check:GetPos() )
					effectdata:SetStart( self:GetPos() + Vector(22,0,65) ) --move beam start to front of dish
				util.Effect( "ScanBeam", effectdata )
				
				local color = "255 0 0" --red (check.resource.rarity == 3)
				if (check.resource.rarity == 1) then
					color = "0 0 255" --blue
				elseif (check.resource.rarity == 2) then
					color = "0 255 0" --green
				end
				check:Fire("color",color,"0.0", "0.2") 
				check:Fire("color","255 255 255","0.4") 
				check:Fire("color",color,"0.6") 
				check:Fire("color","255 255 255","0.8") 
				
			end
		end
		
	else
		self:EmitSound( "common/warning.wav" )
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if ( self.Active == 1 ) then self:Scan() end
	
	self:NextThink( CurTime() + 2 )
	return true
end
