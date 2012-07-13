AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )



function ENT:Initialize()
	self:SetModel( "models/props_wasteland/kitchen_stove002a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor(Color(160,160,30,255))

	local phys = self:GetPhysicsObject()
	phys:SetMass(200)
	if (phys:IsValid()) then
		phys:Wake()
	end

-- Crappy variables..
self.on = false
self.onstring = "off"

self.timer = 0
self.timera = 5
self.latch = false

-- use stuff
self.toggle = false -- On or off
self.togglestring = "Off" -- string for the toggle
self.togglebouncekil = 3 -- You can only toggle when this is zero!
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	
	-- This one is probably the most complicated script so hold on ;O
	self.val2 = 0 -- 12V Energy (uses)
	self.val3 = 0 -- Oil (Uses)
	self.val4 = 0 -- Petrol (uses)
	-- The resources Get defined
	RD_AddResource(self, "Munitions", 0)
	RD_AddResource(self, "12V Energy", 0)
	RD_AddResource(self, "Oil", 0)
	RD_AddResource(self, "Petrol", 0)
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local ent = ents.Create( "munitiongen" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()
	return ent
end



function ENT:Think()
	-- Variables to update and shizz
	self.val2 = RD_GetResourceAmount(self, "12V Energy")
	self.val3 = RD_GetResourceAmount(self, "Oil")
	self.val4 = RD_GetResourceAmount(self, "Petrol")
	self:SetOverlayText( "Munitions Gen (" .. self.togglestring .. ")\n\nPetrol: " .. self.val4 .. "\nOil: " .. self.val3 .. "\n12V Energy: " .. self.val2)

	-- Use key bounce removal variable
	-- It is set to 3 when entity is used, then counts down to zero, 
	-- you can only use entity WHEN it is zero
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end
	
	self.timer = self.timer + 1
	if(self.timer < self.timera) then return end

	
	
	-- We can only work if we are switched on -_-
	if(self.toggle == true or self.active == 1) then
		if(self.val4 > 50 and self.val3 > 30 and self.val2 > 2) then
			-- Code when on
			RD_ConsumeResource(self, "12V Energy", 2)
			RD_ConsumeResource(self, "Oil", 30)
			RD_ConsumeResource(self, "Petrol", 50)
			-- Supply the energy
			RD_SupplyResource(self, "Munitions", 100)
			self.togglestring = "On"
		else
			-- We dont have enough energy, so we turn off... 
			self.toggle = false
			self.togglestring = "Off"
			self:StopSound( "apc_engine_start" )

		end
	else
	self:StopSound( "apc_engine_start" )

	end
	self.timer = 0
end

-- Wiremod function!
function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self.active = 1
			self.togglestring = "On"
			self:EmitSound( "apc_engine_start" )
		else
			self.active = 0
			self.togglestring = "Off"
			self:StopSound( "apc_engine_start" )
			self:EmitSound( "apc_engine_stop" )
		end	
	end
end

function ENT:Use()
    -- This stops "Bouncing" Where it toggles off and on really fast
	-- Every think togglebouncekil is decremented till it is 0
	-- at wich point you can toggle
	-- Each time you toggle it's set back to 3, Therefore disallowing control
	-- For a period of time!
	if(self.togglebouncekil == 0) then
		if(self.toggle == false) then
			self.toggle = true
			self.togglestring = "On"
			self.togglebouncekil = 3
			self:EmitSound( "apc_engine_start" )
			return
		end
		if(self.toggle == true) then
			self.toggle = false
			self.togglestring = "Off"
			self.togglebouncekil = 3
			self:EmitSound( "apc_engine_stop" )
			return
		end
	end
end

function ENT:OnRemove()
	Dev_Unlink_All(self)
	self:StopSound( "apc_engine_start" )
	self:StopSound( "apc_engine_stop" )
end

--Duplicator support (TAD2020)
function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self)
	if (WireAddon == 1) then
		local DupeInfo = Wire_BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if (WireAddon == 1) then
		if (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			Wire_ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end
