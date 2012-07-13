AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)	
end

--call only once and only before ent:Spawn()
function ENT:Setup()
	-- Create a thumper
	local thump = ents.Create( "prop_thumper" )
	thump:SetPos( self:GetPos() )
	thump:SetAngles( self:GetAngles() )
	thump:SetModel( self:GetModel() )
	thump:Spawn()
	thump:Activate()
	thump:SetParent( self )
	
	thump.Entity:SetMoveType( MOVETYPE_NONE )
	thump.Entity:SetSolid( SOLID_NONE )
	thump.Entity:SetNotSolid( true )
	
	self:DeleteOnRemove( thump )
	self.Thump = thump
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--Because we have a sub-etitity, we must detroy it, or it will persist!
	self.Thump.Entity:Remove()
end


function ENT:Think()
	inc = math.ceil(self.MAXRESOURCE)
	RD.SupplyResource(self, "Crude Oil", inc)
	self.BaseClass.Think(self)
	self:NextThink(CurTime() + 1)
	return true
end