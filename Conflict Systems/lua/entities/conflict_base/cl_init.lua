 include('shared.lua')
 
if CLIENT then
	surface.CreateFont( "arial", 60, 600, true, false, "ConflictText" )
	surface.CreateFont( "arial", 40, 600, true, false, "Flavour" )
end

function ENT:Draw()
	self.Entity:DrawModel()
	local trace = LocalPlayer():GetEyeTrace()
	if (trace.Entity == self) then
	--if (1 == 1) then
			
		local rot = Vector(0,0,90)
		local TempY = 0
		
		--local pos = self.Entity:GetPos() + (self.Entity:GetForward() ) + (self.Entity:GetUp() * 40 ) + (self.Entity:GetRight())
		local pos = self.Entity:GetPos() + Vector(0,0,50)  
		local angle =  (LocalPlayer():GetPos() - trace.HitPos):Angle()
		angle.r = angle.r  + 90
		angle.y = angle.y + 90
		angle.p = 0
		
		local textStartPos = -625
		
		cam.Start3D2D(pos,angle,0.03)
		
			surface.SetDrawColor(0,0,0,125)
			surface.DrawRect( textStartPos, 0, 1250, 500 )
			
			surface.SetDrawColor(155,155,155,255)
			surface.DrawRect( textStartPos, 0, -5, 500 )
			surface.DrawRect( textStartPos, 0, 1250, -5 )
			surface.DrawRect( textStartPos, 500, 1250, -5 )
			surface.DrawRect( textStartPos+1250, 0, 5, 500 )
			
			TempY = TempY + 10
			surface.SetFont("ConflictText")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(textStartPos+15,TempY)
			surface.DrawText(self.Entity:GetNetworkedString("OwnedBy").."'s "..self.Entity:GetNetworkedString("DisplayName"))
			TempY = TempY + 70
	
			surface.SetFont("Flavour")
			surface.SetTextColor(155,155,255,255)
			surface.SetTextPos(textStartPos+15,TempY)
			surface.DrawText("Optimum Range: "..self.Entity:GetNetworkedInt("Range")..", Falloff: "..self.Entity:GetNetworkedInt("Falloff"))
			TempY = TempY + 70
			
			surface.SetFont("Flavour")
			surface.SetTextColor(155,155,255,255)
			surface.SetTextPos(textStartPos+15,TempY)
			surface.DrawText("Tracking: "..self.Entity:GetNetworkedInt("Tracking").." degrees / second")
			TempY = TempY + 70
			
			-- Print the used resources
			local stringUsage = ""
			local x = self.Entity:GetNetworkedInt("NumRes")
			if ( (x or 0) > 0 ) then
				for i = 1,x do
					stringUsage = stringUsage.."["..self.Entity:GetNetworkedString("ResourceName"..i)..": "..self.Entity:GetNetworkedString("ResourceValue"..i).."] "
				end
				
				surface.SetFont("Flavour")
				surface.SetTextColor(155,155,255,255)
				surface.SetTextPos(textStartPos+15,TempY)
				surface.DrawText("Usage: ")
				TempY = TempY + 70
				surface.SetTextPos(textStartPos+15,TempY)
				surface.DrawText("   "..stringUsage)
				TempY = TempY + 70
			end
			
			local sFlavour1 = self.Entity:GetNetworkedString("sFlavour1")
			local sFlavour2 = self.Entity:GetNetworkedString("sFlavour2")
			surface.SetFont("Flavour")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(textStartPos+15,TempY)
			surface.DrawText(sFlavour1.." "..sFlavour2)
			--TempY = TempY + 50
			--surface.SetTextPos(textStartPos+15,TempY)
			--surface.DrawText(sFlavour2)
			TempY = TempY + 70
			
			--surface.DrawRect( 495,   0, 5  , TempY )

		--Stop rendering
		cam.End3D2D()
	end
	-- if the overlay is activated, and the owner is the client...
	-- (don't want to spam others :-P )
	
	-- mode 1: range overlay
	if ((self.Entity:GetNetworkedInt("UseOverlay") == 1) and (LocalPlayer():Nick() == self.Entity:GetNetworkedString("OwnedBy")) ) then
		
		-- Draw the optimum range -sphere- on mouse over
		-- One circle for each axis
		local range = self.Entity:GetNetworkedInt("Range")
		local vecTemp 
		--render.SetMaterial( Material( "cable/redlaser" ) )  	
		render.SetMaterial( Material( "cable/xbeam" ) )  	
		render.StartBeam( 19 ); 
		for i=0,18 do
			vecTemp = Vector( math.sin(math.rad(i*20))*range, math.cos(math.rad(i*20))*range, 0 )
			render.AddBeam( self:LocalToWorld(vecTemp), 32, CurTime(),CurTime(), Color( 64,  64, 255, 155 )		 )
		end
		render.EndBeam()
		render.StartBeam( 19 ); 
		for i=0,18 do
			vecTemp = Vector( 0,math.sin(math.rad(i*20))*range, math.cos(math.rad(i*20))*range)
			render.AddBeam( self:LocalToWorld(vecTemp), 32, CurTime(),CurTime(), Color( 64,  64, 255, 155 )		 )
		end
		render.EndBeam()
		render.StartBeam( 19 ); 
		for i=0,18 do
			vecTemp = Vector(math.sin(math.rad(i*20))*range, 0, math.cos(math.rad(i*20))*range)
			render.AddBeam( self:LocalToWorld(vecTemp), 32, CurTime(),CurTime(), Color( 64,  64, 255, 155 )		 )
		end
		render.EndBeam()
		
		-- Now draw the range markers
		render.DrawBeam( self:LocalToWorld(Vector(range,0,0)),self:LocalToWorld(Vector(range*-1,0,0)), 16, 0,0, Color( 64,  64, 255, 105 )		 )
		render.DrawBeam( self:LocalToWorld(Vector(0,range,0)),self:LocalToWorld(Vector(0,range*-1,0)), 16, 0,0, Color( 64,  64, 255, 105 )		 )
		render.DrawBeam( self:LocalToWorld(Vector(0,0,range)),self:LocalToWorld(Vector(0,0,range*-1)), 16, 0,0, Color( 64,  64, 255, 105 )		 )
		local fMod = math.floor(range / 500)
		local multi = 1
		for i=1,fMod do
			if ((i % 2) == 1) then
				multi = 1
			else
				multi = 1.5
			end
			render.DrawBeam( self:LocalToWorld(Vector(i*500,-100*multi,0)),self:LocalToWorld(Vector(i*500,100*multi,0)), 16, 0,0, Color( 64,  64, 255, 105 )		 )
			render.DrawBeam( self:LocalToWorld(Vector(i*-500,-100*multi,0)),self:LocalToWorld(Vector(i*-500,100*multi,0)), 16, 0,0, Color( 64,  64, 255, 105 )		 )

			render.DrawBeam( self:LocalToWorld(Vector(-100*multi,i*500,0)),self:LocalToWorld(Vector(100*multi,i*500,0)), 32, 0,0, Color( 64, 255, 64, 105 )		 )
			render.DrawBeam( self:LocalToWorld(Vector(-100*multi,i*-500,0)),self:LocalToWorld(Vector(100*multi,i*-500,0)), 32, 0,0, Color( 64, 255, 64, 105 )		 )
			
			render.DrawBeam( self:LocalToWorld(Vector(0,-100*multi,i*500)),self:LocalToWorld(Vector(0,100*multi,i*500)), 32, 0,0, Color( 64, 255, 64, 105 )		 )
			render.DrawBeam( self:LocalToWorld(Vector(0,-100*multi,i*-500)),self:LocalToWorld(Vector(0,100*multi,i*-500)), 32, 0,0, Color( 64, 255, 64, 105 )		 )
		end
		
		local TurretID = self.Entity:GetNetworkedInt("TurretID")
		if not (TurretID == nil ) then
			local Turret = ents.GetByIndex(TurretID)
			render.SetMaterial( Material( "cable/redlaser" ) )  	
			render.DrawBeam( Turret:GetPos(),Turret:GetPos()+Turret.Entity:GetForward() * range, 16, 0,0, Color( 64, 255, 64, 105 )		 )
			self.Entity:SetRenderBoundsWS( Turret:GetPos(),Turret:GetPos()+Turret.Entity:GetForward() * range)
		end
		
	end
	
	--targeting overlay only
	if ((self.Entity:GetNetworkedInt("UseOverlay") == 2) and (LocalPlayer():Nick() == self.Entity:GetNetworkedString("OwnedBy")) ) then
		local TurretID = self.Entity:GetNetworkedInt("TurretID")
		if not (TurretID == nil ) then
			local Turret = ents.GetByIndex(TurretID)
			render.SetMaterial( Material( "cable/redlaser" ) )  	
			render.DrawBeam( Turret:GetPos(),Turret:GetPos()+Turret.Entity:GetForward() * range, 16, 0,0, Color( 64, 255, 64, 105 )		 )
			self.Entity:SetRenderBoundsWS( Turret:GetPos(),Turret:GetPos()+Turret.Entity:GetForward() * range)
		end
	end
end