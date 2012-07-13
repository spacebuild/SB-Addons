local Glow1 = Material("lights/white005")

Glow1:SetMaterialInt("$spriterendermode",9)
Glow1:SetMaterialInt("$ignorez",1)
Glow1:SetMaterialInt("$illumfactor",8)
Glow1:SetMaterialFloat("$alpha",0.6)
Glow1:SetMaterialInt("$nocull",1)


/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.Start = data:GetStart()
	self.UpAngle = data:GetAngle():Up()
	self.BeamWidth = 16
	self.BeamType = data:GetScale()  --the sneakiness!
	self.TimeLeft = CurTime() + 2
	self.Alpha = 1
	self.Entity:SetRenderBounds( Vector()*-8192, Vector()*8192 )	
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	
	

	local Pos = self.Position
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		self.Fade = (timeleft / 2)
		
		return true
	else
		return false	
	end

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	local pos = self.Position
	local pos2 = self.Start
	
	if self.Fade == nil then self.Fade = 0 end
	if (self.BeamType == 1) then
		Glow1:SetMaterialFloat("$alpha",self.Fade)
		Glow1:SetMaterialVector("$color",Vector(1, 0, 0))
	else
		Glow1:SetMaterialFloat("$alpha",self.Fade)
		Glow1:SetMaterialVector("$color",Vector(0, 1, 1))
	end
	render.SetMaterial(Glow1)
	

	local start1 = pos+(self.UpAngle*(self.BeamWidth*self.Fade))
	local start2 = pos-(self.UpAngle*(self.BeamWidth*self.Fade))
	
	local end1 = pos2+(self.UpAngle*(self.BeamWidth*self.Fade))
	local end2 = pos2-(self.UpAngle*(self.BeamWidth*self.Fade))
	if (self.BeamType == 1) then
		end1 = end1 + ((self.UpAngle*(pos:Distance(pos2) / 16))*self.Fade)
		end2 = end2 - ((self.UpAngle*(pos:Distance(pos2) / 16))*self.Fade)
	end
		
	render.DrawQuad(start1, end1, end2, start2)
	render.DrawQuad(start2, end2, end1, start1)
	
end
