include('shared.lua')     

surface.CreateFont( "arial", 60, 600, true, false, "PackageText" )

function ENT:Draw()
	self:DrawModel()
		
	local n=0
	local ang=self:GetAngles()
	local rot = Vector(-90,90,-90)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local pos = self:GetPos() + (self:GetForward() * -10) + (self:GetUp() * 40.05) + (self:GetRight() * 10)
	cam.Start3D2D(pos,ang,0.05)

		surface.SetFont("PackageText")
		surface.SetTextColor(255,255,255,150)
		surface.SetTextPos(0,120)
		surface.DrawText(string.upper(self:GetNetworkedString("DisplayText1")))

		surface.SetFont("PackageText")
		surface.SetTextColor(255,255,255,150)
		surface.SetTextPos(0,190)
		surface.DrawText(string.upper(self:GetNetworkedString("DisplayText2")))
		
	cam.End3D2D()

end