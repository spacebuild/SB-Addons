AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Energy_Increment = 100
local sequence_close = nil
local sequence_open = nil

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	sequence_open = self:LookupSequence("close")
	sequence_close = self:LookupSequence("open")
	
	LS_RegisterEnt(self)

	RD_AddResource(self, "energy", 0)
	
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Out" }) end

end

function ENT:SpawnFunction( ply, trace )
	if ( !trace.Hit ) then return end
	local ent = ents.Create( "LS-Naquada-Reactor" )
	ent:SetModel( "models/Naquada-Reactor.mdl" )
	ent:SetPos( trace.HitPos )
	ent:Spawn()
	ent:Activate()
	ent.Active = 1
	return ent
end

function ENT:Setup()
	self:TriggerInput("On", 0)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value ~= 0) then
			if ( self.Active == 0 ) then
				self:SetSequence(sequence_open)
				self:SetMaterial( "models/Reactor-Skin" )
				self.Active = 1
				Wire_TriggerOutput(self, "Out", self.Active)
			end
		else
			if ( self.Active == 1 ) then
				local sequence = self:LookupSequence("open")
				self:SetSequence(sequence_close)
				self:SetMaterial( "models/Reactor-Skin-off" )
				self.Active = 0
				Wire_TriggerOutput(self, "Out", self.Active)
			end
		end
	end
end

function ENT:OnRemove()
	Dev_Unlink_All(self)
end

function ENT:Output()
	return 1
end


function ENT:Think()
	if ( self.Active == 0 ) then
		if (self:GetSequence() == sequence_open) then
			self:SetSequence(sequence_close)
			self:SetMaterial( "models/Reactor-Skin-off" )
		end
		self:SetOverlayText( "Naquada Reactor\n(OFF)" )
	else
		if (self:GetSequence() == sequence_close) then
			self:SetSequence(sequence_open)
			self:SetMaterial( "models/Reactor-Skin" )
		end
		self:SetOverlayText( "Naquada Reactor\n(ON)" )
	end
	if ( self.Active == 1 ) then
		RD_SupplyResource(self, "energy", Energy_Increment)
	end
	self:NextThink( CurTime() + 1 )
	return true
end


function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if ( self.Active == 0 ) then
			local sequence = self:LookupSequence("close")
			self:SetSequence(sequence)
			self:SetMaterial( "models/Reactor-Skin" )
			self.Active = 1
		else
			local sequence = self:LookupSequence("open")
			self:SetSequence(sequence)
			self:SetMaterial( "models/Reactor-Skin-off" )
			self.Active = 0
		end
	end
end


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