 include('shared.lua')     

-- function ENT:Draw()      
-- self.BaseClass.Draw(self)  
-- We want to override rendering, so don't call baseclass.                                   
-- Use this when you need to add to the rendering.        
--self:DrawModel()       // Draw the model.   
-- end  
 
surface.CreateFont( "arial", 60, 600, true, false, "PackageText" )
-- 	self:SetNetworkedString("Resource", self.ResourceType)
-- 	self:SetNetworkedInt("ResAmount", RD_GetResourceAmount(self, self.ResourceType))
-- 	self:SetNetworkedInt("ResMaxAmount", RD_GetNetworkCapacity(self, self.ResourceType))

function ENT:Draw()
	self:DrawModel()
		
	self.LastValue = 0
	local n=0
	local ang=self:GetAngles()
	local rot = Vector(-90,90,0)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local pos = self:GetPos() + (self:GetForward() * -1) + (self:GetUp() * 12) + (self:GetRight() * -0.5)
	cam.Start3D2D(pos,ang,0.05)
	
-- Resource bar
		-- Semitransparent graph background
		surface.SetDrawColor(0,0,0,125)
		surface.DrawRect( 30, 185, 600, 70 )
		
		local lTemp =0
		if (self:GetNetworkedInt("ResMaxAmount")) > 0 then
			lTemp = self:GetNetworkedInt("ResAmount") / self:GetNetworkedInt("ResMaxAmount")
			-- Main bargraph
			surface.SetDrawColor((1-lTemp) * 255,lTemp * 255,0,255)
			surface.DrawRect( 30, 185, lTemp * 600, 70 )

			--Internal gauge text
			surface.SetFont("PackageText")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(30,190)
			surface.DrawText(self:GetNetworkedInt("ResAmount").."/"..self:GetNetworkedInt("ResMaxAmount"))

			-- Outline
			surface.SetDrawColor(0,0,0,255)
			surface.DrawOutlinedRect( 30, 185, 600, 70 )
			

		else
			surface.SetFont("PackageText")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(30,190)
			surface.DrawText("No Resource")
		end


		surface.SetFont("PackageText")
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos(0,120)
		surface.DrawText(string.upper(self:GetNetworkedString("Resource")))

		
			--Stop rendering
	cam.End3D2D()

end