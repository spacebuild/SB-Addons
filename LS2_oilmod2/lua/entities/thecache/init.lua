AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


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
	RD_AddResource(self, "12V Energy", 100)
	RD_AddResource(self, "energy", 1000)
	RD_AddResource(self, "Petrol", 800)
	RD_AddResource(self, "Crude Oil", 1000)
	RD_AddResource(self, "Oil", 800)
	RD_AddResource(self, "hydrogen", 600)
	RD_AddResource(self, "coolant", 600)
	RD_AddResource(self, "air", 600)
	RD_AddResource(self, "TiberiumChemicals", 1000)
	RD_AddResource(self, "RawTiberium", 1000)
	RD_AddResource(self, "ProcessedTiberium", 1000)
	RD_AddResource(self, "Munitions", 750)
end

function ENT:SpawnFunction( ply, tr )
	-- Check the trace is OK
	if ( !tr.Hit ) then return end

	-- Create our entity
	local ent = ents.Create( "thecache" )
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	-- Set the overlay text
	self:SetOverlayText( "Everything cache:\n Holds Tiberium, Munitions, Hydrogen\nstandard life supporting and petrol")
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
