AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")

include('shared.lua')

function ENT:Initialize()
	-- Create the physical of this entity
	self:SetModel( "models/props_wasteland/kitchen_fridge001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor(Color( 120, 96, 96, 255 ))
	
	-- Wake the ohysics model if it is valid
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	RD.AddResource(self, "12V Energy", 100)
	RD.AddResource(self, "energy", 1000)
	RD.AddResource(self, "Petrol", 800)
	RD.AddResource(self, "Crude Oil", 1000)
	RD.AddResource(self, "Oil", 800)
	RD.AddResource(self, "hydrogen", 600)
	RD.AddResource(self, "liquid nitrogen", 600)
	RD.AddResource(self, "oxygen", 600)
end

function ENT:SpawnFunction( ply, tr )
	-- Check the trace is OK
	if ( not tr.Hit ) then return end

	-- Create our entity
	local ent = ents.Create( "thecache" )
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
self.BaseClass.Think(self)
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

--Duplicator support (TAD2020)
function ENT:PreEntityCopy()
	RD.BuildDupeInfo(self)
	if (WireAddon == 1) then
		local DupeInfo = Wire_BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD.ApplyDupeInfo(Ent, CreatedEntities)
	if (WireAddon == 1) then
		if (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			Wire_ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end
