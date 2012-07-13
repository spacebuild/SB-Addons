include('shared.lua')     

surface.CreateFont( "arial", 50, 400, true, false, "ConflictScreen" )
surface.CreateFont( "arial", 50, 700, true, false, "ConflictScreenSelect" )

local textureAttack = surface.GetTextureID("VGUI/minixhair" )

function ENT:InBounds2D(targx,targy,x,y,xsize,ysize)
	if (targx > x) and (targx < (x+xsize)) and (targy > y) and (targy < (y+ysize)) then
		return true
	else
		return false
	end
end


function ENT:Draw()
	self.Entity:DrawModel()
	
	-- Get the Networked Info
	local iPage 	= 	self:GetNetworkedInt( "PageNumber" ) or 0		--What page are we on?
	local iOffset 	= 	self:GetNetworkedInt( "Offset" ) or 0			--What's the current offset for the page?
	local iPageSize	=	8												--How many items per page to display?
	local iState 	= 	self:GetNetworkedInt( "iState" ) or 0 			--Nick of the current target
	local iTarget	= 	self:GetNetworkedInt( "TargetID" ) or 0 			--Nick of the current target
		
	local n
	local ang=self.Entity:GetAngles()
	local rot = Vector(-90,90,-90)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	
	local trace = {}
		trace.start = LocalPlayer():GetShootPos()
		trace.endpos = LocalPlayer():GetAimVector() * 60 + trace.start
		trace.filter = LocalPlayer()
	local trace = util.TraceLine(trace)

	local n = 0
	local boolPointing = false
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * -11.5 + (self.Entity:GetUp() * 0.05) + (self.Entity:GetRight() * 15))
	local fX = 0
	local fY = 0
	local iNameCount = 0
	
	local fXMultiplier = 600
	local fYMultiplier = 460
	local vPosition = Vector(0,0,0)
	cam.Start3D2D(pos,ang,0.05)
		
		-- Just the background of the screen
		surface.SetDrawColor( 0,   0, 0,  55 ) 
		surface.DrawRect(0,0,fXMultiplier,fYMultiplier)
		
		-- Trace from the player to the screen
		-- so we know what to highlight and where
		-- to draw the cursor
		if (trace.Entity == self.Entity) then
			vPosition = self.Entity:WorldToLocal(trace.HitPos)
			fY = math.Clamp((vPosition.x + 13.829 ),0,27.5 )/27.5
			fX = math.Clamp((vPosition.y + 17.4077),0,35   )/35
			
			if (vPosition.z > 0 ) then
				boolPointing = true
			end
		end
 		
		
		
		-- draw a slightly darker background with
		-- an even darker line between em to show
		-- where names go.
		surface.SetDrawColor( 55, 55, 55, 55 ) 
		for i=0,iPageSize do
			surface.DrawRect(0,i*fYMultiplier/10,fXMultiplier,fYMultiplier/10+1)
		end
		
		-- Display the players name and change the text when you mouseover
		-- 'em. Also, only show the players on the current page.
		for k, _player in pairs(player.GetAll()) do
 			iNameCount = iNameCount + 1
 			if ( iNameCount > (iPage * iPageSize)) and ( iNameCount < (iPage * iPageSize + iPageSize)) then
 				
 				if (iTarget == _player:EntIndex()) then
 					surface.SetTextColor(255, 55, 55,200)
 					surface.SetFont("ConflictScreenSelect")
 					surface.SetDrawColor(155, 55, 55, 100 ) 
 					surface.DrawRect(0,n*fYMultiplier/10,fXMultiplier,fYMultiplier/10-1)
 					
 					if (iState == 1) then
 						surface.SetTexture(textureAttack) 
  						surface.DrawTexturedRect( 5 , n*fYMultiplier/10 + 5 , 40, 40 )
 					end
 					
 				elseif (self:InBounds2D(fX*fXMultiplier,fY*fYMultiplier,0,n*fYMultiplier/10,400,fYMultiplier/10) ) then
 					surface.SetTextColor(255,255, 55,200)
 					surface.SetFont("ConflictScreenSelect")
 					surface.SetDrawColor(155,155, 55, 100 ) 
 					surface.DrawRect(0,n*fYMultiplier/10,fXMultiplier,fYMultiplier/10-1)
 				else
 					surface.SetTextColor(255,255,255,200)
 					surface.SetFont("ConflictScreen")
 				end
 			
				surface.SetTextPos(50,n*fYMultiplier/10)
				surface.DrawText(_player:Nick())
				n = n + 1
			end
		end  
		
		-- Next Page / Previous
		surface.SetFont("ConflictScreen")
		
		-- Previous Page
		if (iPage > 0 ) and (self:InBounds2D(fX*fXMultiplier,fY*fYMultiplier,0,(iPageSize+1)*fYMultiplier/10,fXMultiplier/2,fYMultiplier/10+1) ) then
			surface.SetDrawColor(155,155, 55, 100 ) 
			surface.SetTextColor(255,255, 55,200)
		elseif (iPage > 0 ) then
			surface.SetDrawColor( 55, 55, 55, 55 ) 
			surface.SetTextColor(255,255,255,200)
		else
			surface.SetDrawColor( 55, 55, 55, 55 ) 
			surface.SetTextColor( 55, 55, 55, 55)
		end
		surface.DrawRect(0,(iPageSize+1)*fYMultiplier/10,fXMultiplier/2,fYMultiplier/10+1)
		surface.SetTextPos(fXMultiplier/4-15,(iPageSize+1)*fYMultiplier/10)
		surface.DrawText("<<<")
		
		-- NextPage
		if ((iPage * iPageSize + iPageSize) < n ) and (self:InBounds2D(fX*fXMultiplier,fY*fYMultiplier,fXMultiplier/2-1,(iPageSize+1)*fYMultiplier/10,fXMultiplier/2,fYMultiplier/10+1) ) then
			surface.SetDrawColor(155,155, 55, 100 ) 
			surface.SetTextColor(255,255, 55,200)
		elseif ((iPage * iPageSize + iPageSize) < n ) then
			surface.SetDrawColor( 55, 55, 55, 55 ) 
			surface.SetTextColor(255,255,255,200)
		else
			surface.SetDrawColor( 55, 55, 55, 55 ) 
			surface.SetTextColor( 55, 55, 55, 55)
		end
		surface.DrawRect(fXMultiplier/2-1,(iPageSize+1)*fYMultiplier/10,fXMultiplier/2,fYMultiplier/10+1)
		surface.SetTextPos(fXMultiplier/2+fXMultiplier/4-15,(iPageSize+1)*fYMultiplier/10)
		surface.DrawText(">>>")
		
		--Draw some faint 'no target' text in the empty boxes
		for i=(n % iPageSize),iPageSize do
				surface.SetFont("ConflictScreen")
				surface.SetTextColor( 55, 55, 55, 55)
				surface.SetTextPos(50,i*fYMultiplier/10)
				surface.DrawText("No Target")
		end
		
		surface.SetTextColor(255,255,255,200)
		surface.DrawText(vPosition.x.. " "..vPosition.y)
		-- if the trace hits the front of the
		-- screen, draw a pointer.
		if (boolPointing) then
			surface.SetTexture(surface.GetTextureID("gui/Arrow"))
			surface.SetDrawColor(255, 255,255,155 ) 
			surface.DrawTexturedRect( fX*fXMultiplier-15, fY*fYMultiplier, 30, 30 )
		end
	cam.End3D2D()

end