/* Explosion effect by Qiler */
--Edited by Syncaidius for Gas Systems

function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Scale = data:GetScale()
	local Particles = data:GetMagnitude()
	self.emitter = ParticleEmitter( Pos )
	self.IsDead = false
	self.Origin = Pos
	self.Ptable = {}
	
	for i = 1, Particles do 
		self.Ptable[i] = {}
		self.Ptable[i].RanVec = Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-5, 5))
		self.Ptable[i].RanNum = math.random(18,20) + 1
		self.Ptable[i].CurP = 1
		self.Ptable[i].LPos = Pos
		self.Ptable[i].Origin = Pos
		self.Ptable[i].EScale = Scale
		self.Ptable[i].RSpeed = math.random(20,25)
	end
end

function EFFECT:Think( )

	if self.IsDead then return false end
	local CPar1 = 0
	local CPar2 = 0
	
	for k = 1, table.getn(self.Ptable) do
		if self.Ptable[k].RanNum > self.Ptable[k].CurP then
			
			local RRanVec = self.Ptable[k].RanVec + Vector(math.Rand(-0.0001, 0.0001),math.Rand(-0.0001, 0.0001),math.Rand(-0.0001, 0.0001)):GetNormal()
			local NPos = self.Ptable[k].LPos + (( RRanVec * self.Ptable[k].RSpeed )* self.Ptable[k].EScale ) - Vector(0,0,-7)
			
			local tracedata = {} 
			tracedata.start = self.Ptable[k].LPos
			tracedata.endpos = NPos
			local trace = util.TraceLine(tracedata)
			
			if trace.Hit then
				Npos = trace.HitPos
				-- calculate the dotproduct of the normal
				local dot = trace.HitNormal:Dot( trace.Normal * -1 ); 
	      
				-- direction
				self.Ptable[k].RanVec = ( 2 * trace.HitNormal * dot ) + trace.Normal;
				self.Ptable[k].RSpeed = self.Ptable[k].RSpeed / 1.1
				if self.Ptable[k].RSpeed < 0 then self.Ptable[k].RSpeed = 0; end
			else
				self.Ptable[k].RanVec = RRanVec
			end
			local Grav = Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(2, 40))
			local Rcolor = math.random(0,50)
			local particle1 = self.emitter:Add( "particles/smokey", NPos )
			
			particle1:SetVelocity(( Vector(math.Rand(-2, 2),math.Rand(-2, 2),math.Rand(-2, 2))) * self.Ptable[k].EScale )
			particle1:SetDieTime( 6 )
			particle1:SetStartAlpha( 255 )
			particle1:SetEndAlpha(0)
			particle1:SetGravity(Grav)
			particle1:SetStartSize(( 220*((self.Ptable[k].RanNum - self.Ptable[k].CurP)/self.Ptable[k].RanNum) + math.random(-100*((self.Ptable[k].RanNum - self.Ptable[k].CurP)/self.Ptable[k].RanNum),50*((self.Ptable[k].RanNum - self.Ptable[k].CurP)/self.Ptable[k].RanNum))) * self.Ptable[k].EScale )
			particle1:SetEndSize(( 940*((self.Ptable[k].RanNum - self.Ptable[k].CurP)/self.Ptable[k].RanNum)) * self.Ptable[k].EScale )
			particle1:SetRoll( math.random( -500, 500 )/100 )
			particle1:SetRollDelta( math.random( -120, 120 )/1000 )
			particle1:SetColor( Rcolor,Rcolor,Rcolor )
			--self.Ptable[k].Emit:Finish()
			
			local Rcolor = math.random(230,250)
			local particle2 = self.emitter:Add( "particles/flamelet"..math.random(1,3).."", NPos )

			particle2:SetVelocity(( Vector(math.Rand(-2, 2),math.Rand(-2, 2),math.Rand(-2, 2))) * self.Ptable[k].EScale )
			particle2:SetDieTime( 2 - (4*(self.Ptable[k].CurP / self.Ptable[k].RanNum)))
			particle2:SetStartAlpha( 255 - (255*(self.Ptable[k].CurP / self.Ptable[k].RanNum)))
			particle2:SetEndAlpha(0)
			particle2:SetStartSize(( 180*((self.Ptable[k].RanNum-self.Ptable[k].CurP)/self.Ptable[k].RanNum) + math.random(-10*((self.Ptable[k].RanNum-self.Ptable[k].CurP)/self.Ptable[k].RanNum),1*((self.Ptable[k].RanNum - self.Ptable[k].CurP)/self.Ptable[k].RanNum ))) * self.Ptable[k].EScale)
			particle2:SetEndSize(( 200*((self.Ptable[k].RanNum-self.Ptable[k].CurP)/self.Ptable[k].RanNum)) * self.Ptable[k].EScale )
			particle2:SetRoll( math.random( -500, 500 )/100 )
			particle2:SetRollDelta( math.random( -120, 120 )/1000 )
			particle2:SetColor( 230,Rcolor,Rcolor )
						
			CPar1 = CPar1 + self.Ptable[k].RanNum
			CPar2 = CPar2 + self.Ptable[k].CurP				
			self.Ptable[k].CurP = self.Ptable[k].CurP + 1
			self.Ptable[k].RSpeed = self.Ptable[k].RSpeed - 1.1
			if self.Ptable[k].RSpeed < 0 then self.Ptable[k].RSpeed = 0; end
			self.Ptable[k].LPos = NPos
		end
		
	end
	
	if CPar1 <= CPar2 then
		self.IsDead = true
		return false;
	end
	
	return true;
	
end

function EFFECT:Render()
end
