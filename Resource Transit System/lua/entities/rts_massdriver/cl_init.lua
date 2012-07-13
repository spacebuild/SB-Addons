--Resource Transit Systems Info Overlay

 include('shared.lua')
 
surface.CreateFont( "arial", 60, 600, true, false, "RTSText" )
surface.CreateFont( "arial", 80, 600, true, false, "RTSHeader" )
--surface.CreateFont( "arial", 40, 600, true, false, "Flavour" )

function ENT:Draw()
	self:DrawModel()
	local trace = LocalPlayer():GetEyeTrace()
	if (trace.Entity == self) then
	--if (1 == 0) then
			
		local rot = Vector(0,0,90)
		local TempY = 0
		
		local pos = self:GetPos() + (self:GetForward() ) + (self:GetUp() * 40 ) + (self:GetRight())
		local angle =  (LocalPlayer():GetPos() - trace.HitPos):Angle()
		
		
		angle.r = angle.r  + 90
		angle.y = angle.y + 90
		angle.p = 0
		
		cam.Start3D2D(pos,angle,0.03)
		
			surface.SetDrawColor(0,0,0,125)
			surface.DrawRect( 500, 0, 1000, 500 )
			
			surface.SetDrawColor(0,155,0,255)
			surface.DrawRect( 0,   250, 500, 5 )
			surface.DrawRect( 0,   250, 5  , 1000 )
			
			surface.DrawRect(  495,   0, 5  , 500 )
			surface.DrawRect( 1495,   0, 5  , 500 )
			surface.DrawRect( 500,   0,   1000  , 5 )
			surface.DrawRect( 500,   495, 1000  , 5 )
			
			--surface.DrawRect( 0, 495, 500, 5 )
			--surface.DrawRect( 495, 0, 5  , 500 )
			
			TempY = TempY + 10
			surface.SetFont("RTSHeader")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("Device: Mass Driver")
			TempY = TempY + 90
	
			surface.SetFont("RTSText")
			surface.SetTextColor(155,255,155,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("Resource: "..self:GetNetworkedString("Resource"))
			TempY = TempY + 70
			
			surface.SetFont("RTSText")
			surface.SetTextColor(155,255,155,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("Req. Energy: ".. self:GetNetworkedString( "Energy"))
			TempY = TempY + 70 
			
			surface.SetFont("RTSText")
			surface.SetTextColor(155,255,155,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("Packet: ".. self:GetNetworkedString( "Packet"))
			TempY = TempY + 70
			
			surface.SetFont("RTSText")
			surface.SetTextColor(155,255,155,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("Status: ".. self:GetNetworkedString( "Status"))
			TempY = TempY + 70

			surface.SetFont("RTSText")
			surface.SetTextColor(155,255,155,255)
			surface.SetTextPos(500,TempY)
			surface.DrawText("OverDrive: ".. self:GetNetworkedString( "OverDrive"))
			TempY = TempY + 70
			
	
				--Stop rendering
		cam.End3D2D()
	end
end