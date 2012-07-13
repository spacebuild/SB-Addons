include('shared.lua') 
   
 --CreateConVar( "cl_drawthrusterseffects", "1" ) 
   
 local matHeatWave		= Material( "sprites/heatwave" ) 
 local matFire			= Material( "effects/fire_cloud1" ) 
 local matPlasma			= Material( "effects/strider_muzzle" ) 
   
   
 -- Thrusters only really need to be twopass when they're active.. something to think about..
 ENT.RenderGroup 		= RENDERGROUP_BOTH 
   
 /*--------------------------------------------------------- 
    Name: Initialize 
 ---------------------------------------------------------*/ 
 function ENT:Initialize() 
   
 	self.ShouldDraw = 1 
 	self.NextSmokeEffect = 0 
 	 
 	-- Make the render bounds a bigger so the effect doesn't get snipped off
 	mx, mn = self:GetRenderBounds() 
 	self:SetRenderBounds( mn + Vector(0,0,128), mx, 0 ) 
 	 
 	self.Seed = math.Rand( 0, 10000 ) 
   
 end 
   
   
 /*--------------------------------------------------------- 
    Name: Draw 
 ---------------------------------------------------------*/ 
 function ENT:Draw() 
   
 	self.BaseClass.Draw( self ) 
	-- Fix By Terence 24th March (Added wire check)
 	if not (WireAddon == nil) then Wire_Render(self) end
	
 end 
   
 /*--------------------------------------------------------- 
    Name: DrawTranslucent 
    Desc: Draw translucent 
 ---------------------------------------------------------*/ 
 function ENT:DrawTranslucent() 
   
 	if ( self.ShouldDraw == 0 ) then return end 
   
 	self.BaseClass.DrawTranslucent( self ) 
 		 
 	if ( !self:IsOn() ) then  
 		self.OnStart = nil 
 	return end 
 	 
 	if ( self:GetEffect() == "none" ) then return end 
 	 
 	self.OnStart = self.OnStart or CurTime() 
 	 
 	local EffectThink = self[ "EffectDraw_"..self:GetEffect() ] 
 	if ( EffectThink ) then EffectThink( self ) end 
 	 
 end 
   
   
 /*--------------------------------------------------------- 
    Name: Think 
    Desc: Client Think - called every frame 
 ---------------------------------------------------------*/ 
 function ENT:Think() 
   
 	self.ShouldDraw = GetConVarNumber( "cl_drawthrusterseffects" ) 
 	 
 	local bDraw = true 
   
 	if ( self.ShouldDraw == 0 ) then bDraw = false end 
 	 
 	if ( !self:IsOn() ) then bDraw = false end 
 	if ( self:GetEffect() == "none" ) then bDraw = false end 
   
 	if ( !bDraw ) then return end 
 	 
 	local EffectThink = self[ "EffectThink_"..self:GetEffect() ] 
 	if ( EffectThink ) then EffectThink( self ) end 
   
 end 
   
   
 function ENT:EffectThink_fire() 
 end 
   
 function ENT:EffectDraw_fire() 
   
 	local vOffset = self:LocalToWorld( self:GetOffset() ) 
 	local vNormal = (vOffset - self:GetPos()):GetNormalized() 
   
 	local scroll = self.Seed + (CurTime() * -10) 
 	 
 	local Scale = math.Clamp( (CurTime() - self.OnStart) * 5, 0, 1 ) 
 		 
 	render.SetMaterial( matFire ) 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 	scroll = scroll * 0.5 
 	 
 	render.UpdateRefractTexture() 
 	render.SetMaterial( matHeatWave ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0) ) 
 	render.EndBeam() 
 	 
 	 
 	scroll = scroll * 1.3 
 	render.SetMaterial( matFire ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 end 
   
   
 function ENT:EffectDraw_plasma() 
   
 	local vOffset = self:LocalToWorld( self:GetOffset() ) 
 	local vNormal = (vOffset - self:GetPos()):GetNormalized() 
   
 	local scroll = CurTime() * -20 
 		 
 	render.SetMaterial( matPlasma ) 
 	 
 	scroll = scroll * 0.9 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 16, scroll, Color( 0, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 8, 16, scroll + 0.01, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 64, 16, scroll + 0.02, Color( 0, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 	scroll = scroll * 0.9 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 16, scroll, Color( 0, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 8, 16, scroll + 0.01, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 64, 16, scroll + 0.02, Color( 0, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 	scroll = scroll * 0.9 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 16, scroll, Color( 0, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 8, 16, scroll + 0.01, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 64, 16, scroll + 0.02, Color( 0, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 end 
   
   
 function ENT:EffectThink_smoke() 
   
 	self.SmokeTimer = self.SmokeTimer or 0 
 	if ( self.SmokeTimer > CurTime() ) then return end 
 	 
 	self.SmokeTimer = CurTime() + 0.015 
   
 	local vOffset = self:LocalToWorld( self:GetOffset() ) + Vector( math.Rand( -3, 3 ), math.Rand( -3, 3 ), math.Rand( -3, 3 ) ) 
 	local vNormal = (vOffset - self:GetPos()):GetNormalized() 
   
 	local emitter = ParticleEmitter( vOffset ) 
 	 
 		local particle = emitter:Add( "particles/smokey", vOffset ) 
 			particle:SetVelocity( vNormal * math.Rand( 10, 30 ) ) 
 			particle:SetDieTime( 2.0 ) 
 			particle:SetStartAlpha( math.Rand( 50, 150 ) ) 
 			particle:SetStartSize( math.Rand( 16, 32 ) ) 
 			particle:SetEndSize( math.Rand( 64, 128 ) ) 
 			particle:SetRoll( math.Rand( -0.2, 0.2 ) ) 
 			particle:SetColor( 200, 200, 210 ) 
 				 
 	emitter:Finish() 
   
 end 
   
   
 function ENT:EffectThink_magic() 
   
 	self.SmokeTimer = self.SmokeTimer or 0 
 	if ( self.SmokeTimer > CurTime() ) then return end 
 	 
 	self.SmokeTimer = CurTime() + 0.01 
   
 	local vOffset = self:LocalToWorld( self:GetOffset() ) 
 	local vNormal = (vOffset - self:GetPos()):GetNormalized() 
 	 
 	vOffset = vOffset + VectorRand() * 5 
   
 	local emitter = ParticleEmitter( vOffset ) 
 	 
 		local particle = emitter:Add( "sprites/gmdm_pickups/light", vOffset ) 
 			particle:SetVelocity( vNormal * math.Rand( 80, 160 ) ) 
 			particle:SetDieTime( 0.5 ) 
 			particle:SetStartAlpha( 255 ) 
 			particle:SetEndAlpha( 255 ) 
 			particle:SetStartSize( math.Rand( 1, 3 ) ) 
 			particle:SetEndSize( 0 ) 
 			particle:SetRoll( math.Rand( -0.2, 0.2 ) ) 
 				 
 	emitter:Finish() 
   
 end 
   
   
 function ENT:EffectDraw_rings() 
   
 	self.RingTimer = self.RingTimer or 0 
 	if ( self.RingTimer > CurTime() ) then return end 
 	self.RingTimer = CurTime() + 0.01 
   
 	local vOffset = self:LocalToWorld( self:GetOffset() ) 
 	local vNormal = (vOffset - self:GetPos()):GetNormalized() 
 		 
 	local effectdata = EffectData() 
 		effectdata:SetOrigin( vOffset ) 
 		effectdata:SetNormal( vNormal ) 
 	util.Effect( "thruster_ring", effectdata )	 
 	 
 end