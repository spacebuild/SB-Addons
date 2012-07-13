include('shared.lua')     

surface.CreateFont( "arial", 50, 600, true, false, "PackageText" )

local textureGauge = surface.GetTextureID("VGUI/slider" )

function ENT:Draw()
	self.Entity:DrawModel()
	
	-- Get the linked turret's info
	local bOnline = self:GetNetworkedEntity( "CSI_isConnected" )
	
		
	local n=0
	local ang=self.Entity:GetAngles()
	local rot = Vector(-90,90,-90)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * -10) + (self.Entity:GetUp() * 1.05) + (self.Entity:GetRight() * 10)
	cam.Start3D2D(pos,ang,0.05)

		if (bOnline == false) then
			surface.SetFont("PackageText")
			surface.SetTextColor(240,  0,  0,200)
			surface.SetTextPos(100,140)
			surface.DrawText("     No      ")
			surface.SetTextPos(100,180)
			surface.DrawText("    Link     ")
		else
			local ClipSize 		= self:GetNetworkedInt( "CSI_ClipSize")
			local RoundsLeft 	= self:GetNetworkedInt( "CSI_RoundsLeft")
			local fAngMod =  360 / ClipSize
			local x,y,t
			local lx = math.sin( math.rad( 0 ) ) *-1
			local ly = math.cos( math.rad( 0 ) ) *-1
			local trianglevertex = {{ }} --create the two dimensional table   
			for i = 1,RoundsLeft do
				x = math.sin( math.rad( i*fAngMod ) ) *-1
				y = math.cos( math.rad( i*fAngMod ) ) *-1
				--surface.SetDrawColor( 0, 255, 0, 200 ) 
				--surface.DrawLine(x*30+200,y*30+200,x*80+200,y*80+200)
				trianglevertex[1] = {}
				trianglevertex[1]["x"] = 200 + lx * 30
				trianglevertex[1]["y"] = 200 + ly * 30
				trianglevertex[1]["u"] = 0
				trianglevertex[1]["v"] = 1 

				trianglevertex[2] = {}
				trianglevertex[2]["x"] = 200 + x * 30
				trianglevertex[2]["y"] = 200 + y * 30
				trianglevertex[2]["u"] = 0
				trianglevertex[2]["v"] = 0 
				
				trianglevertex[3] = {}
				trianglevertex[3]["x"] = 200 + x * 80
				trianglevertex[3]["y"] = 200 + y * 80
				trianglevertex[3]["u"] = 1
				trianglevertex[3]["v"] = 0 
				
				trianglevertex[4] = {}
				trianglevertex[4]["x"] = 200 + lx * 80
				trianglevertex[4]["y"] = 200 + ly * 80
				trianglevertex[4]["u"] = 1
				trianglevertex[4]["v"] = 1 
				
				surface.SetDrawColor( 255, 255, 255, 200 ) --set the additive color
				--surface.SetTexture(surface.GetTextureID("models/weapons/v_crowbar/crowbar_cyl" ))
 				--surface.SetTexture(surface.GetTextureID("sprites/grip" ))
 				surface.SetTexture(textureGauge)
				surface.DrawPoly( trianglevertex )
				lx = x
				ly = y
			end
			
			local PU = self:GetNetworkedInt( "CSI_PauseUntil")
			local PS = self:GetNetworkedInt( "CSI_PauseStart")
			fAngMod = math.Round(math.Clamp( (CurTime()-PS) / (PU - PS), 0,1) * 360)
			lx = math.sin( math.rad( 0 ) ) *-1
			ly = math.cos( math.rad( 0 ) ) *-1
			i=0
			repeat
				--t = i / 360 * 5
				x = math.sin( math.rad( (i) ) ) *-1
				y = math.cos( math.rad( (i) ) ) *-1
				
				trianglevertex[1] = {}
				trianglevertex[1]["x"] = 200 + lx * 95
				trianglevertex[1]["y"] = 200 + ly * 95
				trianglevertex[1]["u"] = 0
				trianglevertex[1]["v"] = 1 
  
				trianglevertex[2] = {}
				trianglevertex[2]["x"] = 200 + x * 95
				trianglevertex[2]["y"] = 200 + y * 95
				trianglevertex[2]["u"] = 0
				trianglevertex[2]["v"] = 0 
				
				trianglevertex[3] = {}
				trianglevertex[3]["x"] = 200 + x * 105
				trianglevertex[3]["y"] = 200 + y * 105
				trianglevertex[3]["u"] = 1
				trianglevertex[3]["v"] = 0 
				
				trianglevertex[4] = {}
				trianglevertex[4]["x"] = 200 + lx * 105
				trianglevertex[4]["y"] = 200 + ly * 105
				trianglevertex[4]["u"] = 1
				trianglevertex[4]["v"] = 1 
				
				surface.SetDrawColor( 255, 255, 255, 200 ) --set the additive color

				--surface.SetTexture(surface.GetTextureID("sprites/orangecore1" ))
				surface.SetTexture(textureGauge)
				surface.DrawPoly( trianglevertex )
				lx = x
				ly = y
				i = i + 22.5
			until i > fAngMod
			--surface.SetTexture(surface.GetTextureID("sprites/orangeflare1" ))
			--surface.DrawTexturedRect( lx*80+160-5, ly*80+160-5, lx*80+160+5, ly*80+160+5)
			--render.SetMaterial( Material( "sprites/orangeflare1"  ) )
		--render.DrawSprite( self.StartPos + lStartPos,self.Width,self.Width,Color(80,150, 3, 255))

		end	
	cam.End3D2D()

end