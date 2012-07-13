AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')


function ENT:Initialize()
	-- Entity settings
	self:SetModel( "models/props_wasteland/coolingtank01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetColor(Color( 0, 255, 0, 255 ))
	-- If we have wire installed, create an output
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Crude Oil" }) end
	-- Valid?
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	-- Add the crude oil resource, with a capacity of 50,000
	self.val1 = 0
	RD_AddResource(self, "Crude Oil", 50000)
	
end

function ENT:SpawnFunction( ply, tr )
	-- Did we hit summat? ;o
	if ( !tr.Hit ) then return end
	-- Create thy entity
	local ent = ents.Create( "crudetank" )
	ent:SetPos( tr.HitPos + Vector(0, 0, 100) )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
	-- Update overlay, so player is not clueless
	self.val1 = RD_GetResourceAmount(self, "Crude Oil")
	self:SetOverlayText( "Crude Oil Tank\nCrude Oil: " .. self.val1 )
	-- If wiremod is installed, update the output
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "Crude Oil", self.val1) end
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
