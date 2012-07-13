

--EFFECT.Mat = Material( "cable/redlaser"  )
--EFFECT.Mat = Material( "trails/electric"  )
EFFECT.Mat = Material( "trails/laser"  )

function EFFECT:Init( data )
	
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	--self.LifeSpan	= data:GetMagnitude()
	self.Width 		= data:GetScale()
	self.Color 		= data:GetAngle()
	self.Dir 		= (self.EndPos - self.StartPos):GetNormal()
	self.Distance	= self.StartPos:Distance(self.EndPos)
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.LifeSpan	= self.Distance / 4000
	
	self.TracerTime = self.LifeSpan
	self.Length = math.Rand( 0.1, 0.15 )
	
	-- Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
end


function EFFECT:Think( )
	if ( CurTime() > self.DieTime ) then
		return false 
	end
	return true
end

function EFFECT:Render( )
	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	
	local lStartPos = self.Dir * ((1 - fDelta) *  self.Distance)
	
			
	render.SetMaterial( self.Mat )
	--render.DrawBeam( self.StartPos, self.EndPos, self.Width, 0.5, 0.5, Color(self.Color.x, self.Color.y, self.Color.z, 255 * fDelta) )
	--render.DrawBeam( self.StartPos, self.EndPos, self.Width, 0.5, 0.5, Color(150, 80, 3, 255 * fDelta) )
	
	--render.DrawBeam( self.StartPos + lStartPos,  self.StartPos + lEndPos, self.Width, 0.5, 0.5, Color(150, 80, 3, 255) )
	render.StartBeam( 11 )
	for i = 0,10 do 
		local lEndPos   = lStartPos + self.Dir * i * -20
		local lWidth = self.Width*3 / (i+1)
		local lAlpha = (10-i)/10 * 255
		render.AddBeam( self.StartPos + lEndPos, self.Width, CurTime()+1, Color(self.Color.p, self.Color.y, self.Color.r, lAlpha) )
	end
	render.EndBeam()
	
	render.SetMaterial( Material( "sprites/orangeflare1"  ) )
	render.DrawSprite( self.StartPos + lStartPos,self.Width,self.Width,Color(150, 80, 3, 255))
end
