

EFFECT.Mat = Material( "effects/tool_tracer" )

--[[---------------------------------------------------------
   Init( data table )
---------------------------------------------------------]]
function EFFECT:Init( data )

	self.Position = data:GetStart()			-- position passes, well duh, position
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Scale = data:GetScale()			-- use scale to pass radius
	self.Magnitude = data:GetMagnitude()	-- use magnitude to pass bomb lifespan
	
	self.LifeSpan = CurTime() + self.Magnitude
	
	-- Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	
	self.Alpha = 255

end

--[[---------------------------------------------------------
   THINK
---------------------------------------------------------]]
function EFFECT:Think( )

	self.Alpha = self.Alpha - FrameTime() * 2048
	
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	if (self.Alpha < 0) then return false end
	return true

end

--[[---------------------------------------------------------
   Draw the effect
---------------------------------------------------------]]
function EFFECT:Render( )

	if ( self.Alpha < 1 ) then return end
	
	
		
	-- setup our variables
	local start_pos = self.StartPos
	local end_pos = self.EndPos
	local dir = ( self.EndPos - self.StartPos );
	local increment = dir:Length() / 12;
	dir:Normalize();
	
	-- set material
	render.SetMaterial(Material("sprites/physbeam.vmt"));
	
	-- start the beam with 14 points
	render.StartBeam( 14 );
	
	-- add start
	render.AddBeam(
		start_pos,				-- Start position
		32,					-- Width
		CurTime(),				-- Texture coordinate
		Color( 255, 255, 255, 255 )		-- Color
	);
	
	--
	local i;
	for i = 1, 12 do
		-- get point
		--math.sin( math.rad(30) )
		--local point = ( start_pos + dir * ( i * increment ) ) + VectorRand() * math.random( 1, increment * i  );
		local point = ( start_pos + dir * ( i * increment ) ) + Vector(math.random(1,18),math.random(1,18),math.sin(math.rad(i * 15)) * (increment * 3 + math.random(1,18)));
		
		-- texture coords
		local tcoord = CurTime() + ( 1 / 12 ) * i;
		
		-- add point
		render.AddBeam(
			point,
			32 / 12 * i,
			tcoord,
			Color(  (13-i)*20, (13-i)*20, 255, 255 )
		);
		
	end
	
	-- add the last point
	render.AddBeam(
		end_pos,
		1,
		CurTime() + 1,
		Color(  0, 0, 255, 255 )
	);
	
	-- finish up the beam
	render.EndBeam();
	

	
	

end
