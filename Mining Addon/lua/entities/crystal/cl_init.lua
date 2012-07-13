include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:DrawTranslucent( bDontDrawModel )
	if ( bDontDrawModel ) then return end
	self:Draw()
end
