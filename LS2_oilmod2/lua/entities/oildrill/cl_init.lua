include('shared.lua')

function ENT:DrawTranslucent()
	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512 ) then
		AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self  )
	end
end
