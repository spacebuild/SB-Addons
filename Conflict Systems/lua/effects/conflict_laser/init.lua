

--EFFECT.Mat = Material( "cable/redlaser"  )
--EFFECT.Mat = Material( "trails/electric"  )
EFFECT.Mat = Material( "trails/laser"  )

function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Dir 		= self.EndPos - self.StartPos
	self.LifeSpan	= data:GetMagnitude()
	self.Width 		= data:GetScale()
	self.Color 		= data:GetAngle()
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = self.LifeSpan
	--self.Length = math.Rand( 0.1, 0.15 )
	
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
			
	
	--render.DrawBeam( self.StartPos, self.EndPos, self.Width, 0.5, 0.5, Color(self.Color.x, self.Color.y, self.Color.z, 255 * fDelta) )
	
	local width = math.sin( math.rad(fDelta * 180) ) * self.Width
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, width, 0.5, CurTime(), Color(self.Color.p, self.Color.y, self.Color.r, 255 * fDelta) )
	
	render.SetMaterial( Material( "sprites/orangeflare1"  ) )
	render.DrawSprite( self.StartPos,width*3,width*3, Color(self.Color.p, self.Color.y, self.Color.r, 255 * fDelta))

end
