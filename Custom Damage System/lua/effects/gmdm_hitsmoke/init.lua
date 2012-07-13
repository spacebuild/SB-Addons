

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local Scale = data:GetScale()
	
	local SurfaceColor = render.GetSurfaceColor( Pos+Norm, Pos-Norm*100 ) * 255
	
	SurfaceColor.r = math.Clamp( SurfaceColor.r+40, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g+40, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b+40, 0, 255 )
	
	local Dist = LocalPlayer():GetPos():Distance( Pos )

	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )
		
	local emitter = ParticleEmitter( Pos + Norm * 32 )
	
	emitter:SetNearClip( 0, 128 )
	
		--for i=0, 2 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 10 )
				particle:SetVelocity( Norm * math.Rand( 50, 100 ) + VectorRand() * 50 )
				particle:SetDieTime( 4 )
				particle:SetStartAlpha( math.Rand( 150, 200 ) )
				particle:SetStartSize( math.Rand( 32, 64 ) )
				particle:SetEndSize( math.Rand( 80, 256 ) )
				particle:SetRoll( 0 )
				particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
				particle:SetAirResistance( 100 )
		
		--end

		for i=0, 2 do
		
			local particle = emitter:Add( "particles/smokey", Pos + Norm * 32 )
			
				particle:SetVelocity( Norm * 300 + VectorRand() * 200 )
				particle:SetDieTime( math.Rand( 3, 8 ) )
				particle:SetStartAlpha( 150 )
				particle:SetStartSize( math.Rand( 32,48 ) )
				particle:SetEndSize( 60 )
				particle:SetRoll( 0 )
				particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
				particle:SetGravity( Vector( 0, 0, math.Rand( -200, -150 ) ) )
				particle:SetAirResistance( 100 )
				
		end
		
	emitter:Finish()
		
	local emitter = ParticleEmitter( Pos, true )
	
		for i =0, 8 * Scale do
		
			local particle
			
			if ( math.random( 0, 1 ) == 1 ) then
				particle = emitter:Add( "effects/fleck_cement1", Pos )
			else
				particle = emitter:Add( "effects/fleck_cement2", Pos )
			end

				particle:SetVelocity( (Norm + VectorRand() * 0.5) * math.Rand( 100, 700 ) )
				--particle:SetLifeTime( i )
				particle:SetDieTime( 4 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 255 )
				local Size = FleckSize * math.Rand( 0.5, 1.5 )
				particle:SetStartSize( Size )
				particle:SetEndSize( 0 )
				particle:SetLighting( true )
				particle:SetGravity( Vector( 0, 0, -500 ) )
				particle:SetAirResistance( 40 )
				particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 800 )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
				
				if ( math.fmod( i, 2 ) == 0 ) then
					particle:SetColor( 0, 0, 0 )
				end
		
		end

	
	emitter:Finish()
	
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()	
end



