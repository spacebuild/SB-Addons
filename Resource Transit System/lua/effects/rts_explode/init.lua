--[[
--Incinerate Effect
local effectdata = EffectData()
	effectdata:SetStart	(self.Entity:GetPos()+  self.Entity:GetUp() * 25)
	effectdata:SetScale(50)
	effectdata:SetMagnitude(0.15)
util.Effect( "rts_explode", effectdata )
]]
local matRefraction	= Material( "refract_ring" )
matRefraction:SetMaterialInt("$nocull",1)

--[[---------------------------------------------------------
   Init( data table )
---------------------------------------------------------]]
function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	--self.Attachment = data:GetAttachment()
	self.Scale = data:GetScale()
	self.Magnitude = data:GetMagnitude()
	self.LifeSpan = CurTime() + self.Magnitude
	self.MaxLifeSpan = CurTime() + self.Magnitude
	
	self.StartAlpha = 35
	self.Emitter = ParticleEmitter( self.Position )
	self.angle = 0
	
	self.CurrentSize = 0
	self.MaxSize = self.Scale
	self.CurrentRefract = 0.3
	self.RefractModifier = 0.05
	
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
		self.CurrentRefract = 0.2
		self.RefractModifier = 0.03
	end
				
end

--[[---------------------------------------------------------
   THINK
---------------------------------------------------------]]
function EFFECT:Think( )
	local HowFast = self.Scale / 15
	local LifeSpan = self.LifeSpan - CurTime()
	self.CurrentSize = self.CurrentSize +   HowFast * 15 * FrameTime()
	self.CurrentRefract = self.CurrentRefract - self.RefractModifier*FrameTime()
	if LifeSpan > 0 then 
		for i=1,math.Round(100 * FrameTime() * HowFast) do
			local Angle = Vector(math.Rand(-100,100),math.Rand(-100,100),0):GetNormalized()
			local Angle2 = Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100)):GetNormalized()
			--local particle = self.Emitter:Add( "particles/smokey",  self.Position )
			local particle = self.Emitter:Add( "particles/flamelet"..math.Round(math.Rand(1,5)),  self.Position )
				particle:SetVelocity(Angle * HowFast * 5)
				particle:SetDieTime( HowFast/7 )
				particle:SetStartAlpha( self.StartAlpha )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 1 )
				particle:SetEndSize( math.Rand( self.Scale/20, self.Scale/10 ) )
				particle:SetRoll( math.Rand( self.Scale/10, self.Scale/2.5 ) )
				particle:SetRollDelta( math.random( -1, 1 ) )
				--particle:SetColor(105,175,125)
				particle:SetColor(155,155,155)
				particle:VelocityDecay( false )
			
			local particle2 = self.Emitter:Add( "particles/flamelet"..math.Round(math.Rand(1,5)),  self.Position +Angle2 * math.Rand(1,self.Scale/5 ))
				particle2:SetVelocity(Angle2)
				particle2:SetDieTime( HowFast/math.Rand(7,13) )
				particle2:SetStartAlpha( self.StartAlpha )
				particle2:SetEndAlpha( 0 )
				particle2:SetStartSize( 1 )
				particle2:SetEndSize( math.Rand( self.Scale/math.Rand(8,15), self.Scale/math.Rand(15,30) ) )
				particle2:SetRoll( math.Rand( self.Scale/10, self.Scale/2.5 ) )
				particle2:SetRollDelta( math.random( -1, 1 ) )
				--particle:SetColor(105,175,125)
				local temp2  = math.Rand(155,255)
				particle2:SetColor(math.Rand(155,255),temp2, temp2)
				particle2:VelocityDecay( false )
		end
		return true
	elseif (LifeSpan > (LifeSpan * -25)) then
		self.Emitter:Finish()
		--return false	
	else
		return true
	end
end

--If you don't have a render function it errors out
function EFFECT:Render() 
	if self.CurrentSize < self.MaxSize then
		
		matRefraction:SetMaterialFloat( "$refractamount", math.sin(self.CurrentRefract*math.pi) * 0.2 )
		render.SetMaterial( matRefraction )
		render.UpdateRefractTexture()
		
		render.DrawQuadEasy( self.Position, Vector(0,0,1),self.CurrentSize, self.CurrentSize)
	else
		self.Remove(self)
	end
end

