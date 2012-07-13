local matRefraction	= Material( "refract_ring" )

function EFFECT:Init( data )
	self.Entity:SetPos(data:GetOrigin())
	self.TimeLeft = data:GetMagnitude()+CurTime()
	self.Refract = 0
	self.Size = 24
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
end

function EFFECT:Think( )
	local timeleft = self.TimeLeft-CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		self.Size = self.Size+300*ftime
		self.Refract = self.Refract+1.3*ftime
		return true
	else
		return false	
	end
end

function EFFECT:Render()
	local Distance = EyePos():Distance(self.Entity:GetPos())
	local Pos = self.Entity:GetPos()+(EyePos()-self.Entity:GetPos()):GetNormal()*Distance*(self.Refract^(0.3))*0.8
	matRefraction:SetMaterialFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	render.SetMaterial( matRefraction )
	render.UpdateRefractTexture()
	render.DrawSprite( Pos, self.Size, self.Size )
end