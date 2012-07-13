local tMats = {}

tMats.Glow1 = Material("sprites/light_glow02")

for _,mat in pairs(tMats) do

	mat:SetMaterialInt("$spriterendermode",9)
	mat:SetMaterialInt("$ignorez",1)
	mat:SetMaterialInt("$illumfactor",8)
	
end

EFFECT.Mat = Material( "effects/select_ring" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

 	self.vOffset = data:GetOrigin()
	self.Position = data:GetOrigin()
	self.Position.z = self.Position.z
	self.TimeLeft = CurTime() + 2
	self.FAlpha = 155
	self.GAlpha = 155
	self.GSize = 6

	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
	
	local Pos = self.Position

	self.smokeparticles = {}
	local rVec = VectorRand()*5	
	local vOffset = data:GetOrigin() 

 	local emitter = ParticleEmitter( vOffset ) 
 	 
 		for i=0, 20 do 
 		 
 			local particle = emitter:Add( "effects/spark", vOffset ) 
 			if (particle) then 
 				 
 				particle:SetVelocity( VectorRand() * math.Rand(100, 1000) ) 
 				 
 				particle:SetLifeTime( 0 ) 
 				particle:SetDieTime( math.Rand(1, 2) ) 
 				 
 				particle:SetStartAlpha( 255 ) 
 				particle:SetEndAlpha( 75 ) 
 				 
 				particle:SetStartSize( 40 ) 
 				particle:SetEndSize( 0 ) 
 				 
 				particle:SetRoll( math.Rand(0, 360) ) 
 				particle:SetRollDelta( math.Rand(-5, 5) ) 
				
				particle:SetColor( 255, 205, 65)
 				 
 				particle:SetAirResistance( 5 ) 
 				 
 				particle:SetGravity( Vector( 0, 0, -600 ) ) 
 			 
 			end 
			
		end 

		for i=0, 6 do
				
			local particle1 = emitter:Add( "particle/particle_composite", vOffset + Vector( math.random( -50, 100 ), math.random( -50, 100 ), math.random( -50, 100 ) ) )
			if (particle1) then 
				particle1:SetVelocity( Vector( 0, 0, -100 ) )			
				particle1:SetDieTime( math.random( 8, 15 ) ) 			
				particle1:SetStartAlpha( math.random( 40, 255 ) ) 			
				particle1:SetStartSize( math.random( 80, 150 ) ) 			
				particle1:SetEndSize( math.random( 10, 150 ) ) 
				particle1:SetEndAlpha( math.random( 25, 100 ) ) 			
				particle1:SetRoll( 0 )			
				particle1:SetRollDelta( 0 ) 			
				particle1:SetColor( 45, 45, 45) 			
				particle1:VelocityDecay( true )
			end			  
		end
 		 
 	emitter:Finish() 
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
	local ftime = FrameTime()
	
	if self.FAlpha > 0 then
		self.FAlpha = self.FAlpha - 150*ftime
	end
	
	self.GAlpha = self.GAlpha - 77.5*ftime
	self.GSize = self.GSize - 3*timeleft*ftime
		
	return true
	else
		for __,particle in pairs(self.smokeparticles) do
		particle:SetStartAlpha( 20 )
		particle:SetEndAlpha( 0 )
		end
	return false	
	end

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

local startpos = self.Position
render.SetMaterial(tMats.Glow1)
if self.FAlpha > 0 then
	render.DrawSprite(startpos,1550,800,Color(255,245,235,self.FAlpha))
end

end
