AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function MakeOilDrill( pl, Ang, Pos, large )
	local drill = ents.Create( "oildrill" )
	drill:SetPos( Pos )
	drill:SetAngles( Ang )
	drill:Setup( large )
	drill:SetPlayer( pl )
	drill:Spawn()
	drill:Activate()
	
	local rtable = { pl = pl, large = large }
	table.Merge(drill:GetTable(), rtable )
	
	return drill
end
duplicator.RegisterEntityClass( "oildrill", MakeOilDrill, "Ang", "Pos", "large" )


function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	local phys = self:GetPhysicsObject()
	if ( self.Large ) then
		self:SetOverlayText( "Large Oil Drill" )
		if ( phys:IsValid() ) then
			phys:SetMass(18000) --make is heavy, very
		end
	else
		self:SetOverlayText( "Small Oil Drill" )
		if ( phys:IsValid() ) then
			phys:SetMass(9000) --make is heavy, but not as much as the large one
		end
	end
	
	LS_RegisterEnt(self, "Generator")
	RD_AddResource(self, "Crude Oil", 0)
	
end

--call only once and only before ent:Spawn()
function ENT:Setup( large )
	self.Large = large
	
	local UseModel = "models/props_combine/combinethumper002.mdl"  	--small
	if ( large ) then
		UseModel = "models/props_combine/combinethumper001a.mdl"	--large
	end
	self:SetModel( UseModel )
	
	-- Create a thumper
	local thump = ents.Create( "prop_thumper" )
	thump:SetPos( self:GetPos() )
	thump:SetAngles( self:GetAngles() )
	thump:SetModel( UseModel )
	thump:Spawn()
	thump:Activate()
	thump:SetParent( self )
	
	thump.Entity:SetMoveType( MOVETYPE_NONE )
	thump.Entity:SetSolid( SOLID_NONE )
	thump.Entity:SetNotSolid( true )
	
	self:DeleteOnRemove( thump )
	self.Thump = thump
	
end

function ENT:SpawnFunction( ply, tr )
	
	-- Check we have a valid trace
	if ( !tr.Hit ) then return end
	
	return MakeOilDrill( ply, Angle(0,0,0), tr.HitPos, true )
	
end


function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--Because we have a sub-etitity, we must detroy it, or it will persist!
	self.Thump.Entity:Remove()
end


function ENT:Think()
	self.BaseClass.Think(self)
	--???: Think it needs to comsume energy
	--TODO: it should only "drill" when on ground
	-- Remark: Yup....
	if ( self.Large ) then
		RD_SupplyResource(self, "Crude Oil", 2000) --large
	else
		RD_SupplyResource(self, "Crude Oil", 890) --small
	end
	self:NextThink( CurTime() + 1 )
	return true
end

