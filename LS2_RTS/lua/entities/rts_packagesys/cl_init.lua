include('shared.lua')     

-- function ENT:Draw()      
-- self.BaseClass.Draw(self)  
-- We want to override rendering, so don't call baseclass.                                   
-- Use this when you need to add to the rendering.        
--self:DrawModel()       // Draw the model.   
-- end  
 
surface.CreateFont( "arial", 60, 600, true, false, "PackageText" )
surface.CreateFont( "arial", 80, 600, true, false, "PackageTextHeader" )

function ENT:Draw()
	self:DrawModel()
		
	local ang=self:GetAngles()
	local rot = Vector(0,90,0)
	local TempY = 0
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
--	self:SetNetworkedInt("Max",self.packetsize)
--	self:SetNetworkedInt("PercentDone",0)
--	self:SetNetworkedInt("ReqEnergy",self.energyuse)
--	self:SetNetworkedString("Resource",ResTypesByID[1])
--	self:SetNetworkedBool("Recharging",false)
	
	local pos = self:GetPos() + (self:GetForward() ) + (self:GetUp() ) + (self:GetRight() *13)
	cam.Start3D2D(pos,ang,0.05)

		--surface.SetDrawColor(0,0,0,125)--
		--surface.DrawRect( 30, 185, 600, 70 )--

		surface.SetFont("PackageTextHeader")
		surface.SetTextColor(0,0,0,175)
		surface.SetTextPos(0,TempY)
		surface.DrawText("Packager System")
		TempY = TempY + 140

		surface.SetFont("PackageText")
		surface.SetTextColor(0,0,0,175)
		surface.SetTextPos(0,TempY)
		surface.DrawText("Energy Needed: "..self:GetNetworkedString("ReqEnergy"))
		TempY = TempY + 70
		
		surface.SetFont("PackageText")
		surface.SetTextColor(0,0,0,175)
		surface.SetTextPos(0,TempY)
		surface.DrawText("Resource: "..self:GetNetworkedString("Resource"))
		TempY = TempY + 70

		surface.SetFont("PackageText")
		surface.SetTextColor(0,0,0,175)
		surface.SetTextPos(0,TempY)
		if (self:GetNetworkedBool("Recharging") == true) then
			surface.DrawText("Status: Active")
			TempY = TempY + 70
			
			surface.SetDrawColor(0,0,0,175)
			surface.DrawRect( 0, TempY-5, 500, 70 )
			
			surface.SetDrawColor(2.5*(100-self:GetNetworkedInt("PercentDone")),2.5*self:GetNetworkedInt("PercentDone"),0,255)
			surface.DrawRect( 0, TempY-5, self:GetNetworkedInt("PercentDone")*5 , 70 )

			surface.SetFont("PackageText")
			surface.SetTextColor(255,255,255,175)
			surface.SetTextPos(10,TempY)
			surface.DrawText(self:GetNetworkedInt("PercentDone").."%")
			
			surface.SetDrawColor(255,255,255,255)
			surface.DrawOutlinedRect( 0, TempY-5, 500, 70 )
			
		else
			surface.DrawText("Status: Inactive")
			TempY = TempY + 70
		end
		 

			--Stop rendering
	cam.End3D2D()
	

end