

EFFECT.Mat = Material( "trails/electric.vmt" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Dir 		= self.EndPos - self.StartPos
	
	
	
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = math.Rand( 1.2, 1.3 )
	self.Length = math.Rand( 0.1, 0.15 )
	
	
	
	
	-- Die when it reaches its target
	self.DieTime = CurTime() + 1
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	if ( CurTime() > self.DieTime ) then
		return false 
	end
	
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
			
	render.SetMaterial( self.Mat )
	
	render.DrawBeam( self.EndPos+ Vector( math.random( -20, 20 ), math.random( -20, 20 ), math.random( -20, 20 ) ), self.StartPos, 25, 10, 20, Color( 255, 255, 255, 255 ) )
	render.DrawBeam( self.EndPos+ Vector( math.random( -20, 20 ), math.random( -20, 20 ), math.random( -20, 20 ) ), self.StartPos, 35, 5, 10, Color( 255, 255, 255, 255 ) )
	render.DrawBeam( self.EndPos+ Vector( math.random( -20, 20 ), math.random( -20, 20 ), math.random( -20, 20 ) ), self.StartPos, 30, 30, 20, Color( 255, 255, 255, 255 ) )
end
