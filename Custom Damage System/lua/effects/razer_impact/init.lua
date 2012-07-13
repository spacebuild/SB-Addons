local Glow1 = Material("sprites/light_glow02")

Glow1:SetMaterialInt("$spriterendermode",9)
Glow1:SetMaterialInt("$ignorez",1)
Glow1:SetMaterialInt("$illumfactor",8)
Glow1:SetMaterialFloat("$alpha",0.6)
Glow1:SetMaterialInt("$nocull",1)


function EFFECT:Init( data )

	self.Position = data:GetOrigin()
	self.beam_mode = data:GetScale()  --the sneakiness!
	local Norm = Vector(0,0,1)

--	self.Position = self.Position + Norm * 2

	local emitter = ParticleEmitter( self.Position )
	local ForwardAngle = data:GetAngle():Forward()

	--base explosion
	local max_particles = 20
	if (self.beam_mode == 1) then max_particles = 4 end
		for i=1, max_particles do

			local particle = emitter:Add("effects/fire_cloud1", self.Position)

				particle:SetVelocity( (ForwardAngle*350) + Vector(math.random(-180,180),math.random(-180,180),math.random(-180,180)) )
				particle:SetDieTime( math.Rand( 0.3, 0.7 ) )
				particle:SetStartAlpha( math.Rand( 220, 240 ) )
				particle:SetStartSize( 4 )
				particle:SetEndSize( math.Rand( 30, 50 ) )
				particle:SetRoll( math.Rand( 360,480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				if (self.beam_mode == 0) then
					particle:SetColor( 0, 255, 255 )
				else
					particle:SetColor( 255, 0, 0 )
				end
				particle:VelocityDecay( true )

			end

	emitter:Finish()
	self.TimeLeft = CurTime() + 2
	self.Fade = 1

end


function EFFECT:Think( )

	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		self.Fade = (timeleft / 2)
		
		return true
	else
		return false	
	end
end


function EFFECT:Render()
	local startpos = self.Position

	--Base glow
	render.SetMaterial(Glow1)
	if (self.beam_mode == 0) then
		render.DrawSprite(startpos,300*self.Fade,120*self.Fade,Color(math.random(10,30), 255, 255,255*self.Fade))
	else
		render.DrawSprite(startpos,300*self.Fade,120*self.Fade,Color(255, math.random(10,30), math.random(10,30),255*self.Fade))
	end
end



