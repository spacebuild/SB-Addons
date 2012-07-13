AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')



function ENT:Initialize()
	-- Enity Settings and shit
	self:SetModel( "models/props_junk/metalgascan.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self, { "Petrol" }) end
	-- Physics model valid?
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	-- Resource Variable
	self.val1 = 0
	RD_AddResource(self, "Petrol", 1500)
end

ENT.aHealth = 40  
function ENT:OnTakeDamage(dmg)  	
if(self.val1 > 1000) then
self.aHealth = self.aHealth - dmg:GetDamage()  	
end


	if self.aHealth <= 0 and self.val1 > 1000  then
		
	
		local Effect = EffectData()
		Effect:SetOrigin(self:GetPos())
		Effect:SetScale(self.val1 / 1000)
		Effect:SetMagnitude(self.val1 / 100)
		util.Effect("Explosion", Effect, true, true)

		
		-- Destroy our intity.. mwahahaha
		self:Remove()  	
	end  
end 
function ENT:SpawnFunction( ply, tr )
	-- Is our trace correct, so that we can ACTUALLY spawn the thing?!
	if ( !tr.Hit ) then return end
	-- Creat thy entity ;o
	local ent = ents.Create( "petrolcan" )
	ent:SetPos( tr.HitPos + Vector(0, 0, 100) )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
	-- Update the overlay, so that player isnt clueless >.>
	self.val1 = RD_GetResourceAmount(self, "Petrol")
	self:SetOverlayText( "Petrol Can\nPetrol: " .. self.val1 )
	-- If wire is installed, update the output!
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "Petrol", self.val1) end
	
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
