include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	local trace = LocalPlayer():GetEyeTrace()
	if (trace.Entity == self) then
			
		-- Draw the optimum range -sphere- on mouse over
		-- One circle for each axis
		
		local spread = self:GetNetworkedInt("Spread")
		local range = 5000
		local timeMod = math.fmod(CurTime(), 3)
		local timeMod2 = math.fmod(CurTime(), 30)*12
		local vecTemp 
		--render.SetMaterial( Material( "cable/redlaser" ) )  	
		render.SetMaterial( Material( "cable/xbeam" ) )  	
		--render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(0,0,range)), 5, 0,0, Color( 64,  64, 255, 105 )		 )
		
		local beamspread =math.sin(math.rad(spread))*range
		--render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(0,beamspread, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		--render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(0,beamspread*-1, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		--render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(beamspread,0, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		--render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(beamspread*-1,0, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(math.sin(math.rad(timeMod2))*beamspread		,math.cos(math.rad(timeMod2))*beamspread, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(math.sin(math.rad(timeMod2))*beamspread*-1	,math.cos(math.rad(timeMod2))*beamspread*-1, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		
		render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(math.sin(math.rad(timeMod2+90))*beamspread		,math.cos(math.rad(timeMod2+90))*beamspread, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		render.DrawBeam( self:LocalToWorld(Vector(0,0,0)),self:LocalToWorld(Vector(math.sin(math.rad(timeMod2+90))*beamspread*-1	,math.cos(math.rad(timeMod2+90))*beamspread*-1, math.cos(math.rad(spread))*range)), 3, 0,0, Color( 64,  64, 255, 105 )		 )		
		
		render.StartBeam( 19 ); 
		local pulseDist = (math.cos(math.rad(spread))*range/3*timeMod)
		beamspread =math.sin(math.rad(spread))*pulseDist
		for i=0,18 do
			
			vecTemp = Vector( math.sin(math.rad(i*20))*beamspread, math.cos(math.rad(i*20))*beamspread, pulseDist )
			render.AddBeam( self:LocalToWorld(vecTemp), 32, CurTime(),CurTime(), Color( 64,  64, 255, 155 )		 )
		end
		render.EndBeam()

		
		
	end
end