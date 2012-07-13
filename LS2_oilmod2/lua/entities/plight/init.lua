AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_wasteland/prison_lamp001c.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.flashlight = ents.Create("effect_flashlight")
	self.flashlight:SetPos( self:GetPos() )
	self.flashlight:SetAngles( self:GetAngles() )
	self.flashlight:SetParent( self )
	self.flashlight:SetColor(Color( 0, 0, 0, 255 ))
	self.flashlight:Spawn()
	
	-- Wake the physics model, or it wont move till we manipulate it!
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.active = 0
	
	-- Crappy variables..
	self.timer = 0
	self.timera = 5
	
	-- use stuff
	self.toggle = false -- On or off
	self.togglestring = "Off" -- string for the toggle
	self.togglebouncekil = 3 -- You can only toggle when this is zero!
	
	-- Energy Variable!
	self.val1 = 0
	RD_AddResource(self, "12V Energy", 0)
	
	-- Create a wiremod input so we cAN TURN LIGHT ON OR OFF :) 
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	
	
end

function ENT:SpawnFunction( ply, tr )
	-- Check the trace is OK
	if ( !tr.Hit ) then return end

	-- Create our entity
	local ent = ents.Create( "plight" )
	ent:SetPos(tr.HitPos + Vector(0,0,32))
	ent:Spawn()
	ent:Activate()
	return ent
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
			return
		end
		if(self.toggle == true) then
			self.toggle = false
			self.togglestring = "Off"
			self.togglebouncekil = 3
			return
		end
	end
end


function ENT:Think()

	-- Set the overlay text
	self:SetOverlayText( "Light\n(" .. self.togglestring .. ")\n12V Energy: " .. self.val1)

	-- This de-bounces the use key
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end
	
	-- Count down to next think
	self.timer = self.timer + 1
	if(self.timer < self.timera) then return end
	
	-- Update the internal variable
	self.val1 = RD_GetResourceAmount(self, "12V Energy")
	
	-- We can only beon if we flicked teh switchz0rs
	if(self.toggle == true or self.active == 1) then
		if(self.val1 > 1) then
		 -- Take the NRG
		 RD_ConsumeResource(self, "12V Energy", 1)
		 -- Make light bright
		 self.flashlight:SetColor(Color( 255, 255, 255, 255 ))
		else
		 self.toggle = false
		 self.togglestring = "Off"
		 self.flashlight:SetColor(Color( 0, 0, 0, 255 ))
		end
	
	else
	self.flashlight:SetColor(Color( 0, 0, 0, 255 ))
	end
	-- Thinky stuff :P
	
	
	-- Reset the timer
	self.timer = 0
end

-- Wiremod function!
function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self.active = 1
			self.togglestring = "On"
		else
			self.active = 0
			self.togglestring = "Off"
		end	
	end
end

function ENT:OnRemove()
	Dev_Unlink_All(self)
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
