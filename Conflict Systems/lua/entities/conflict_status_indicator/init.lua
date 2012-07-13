-- Turret's Status Indicator
--
--

include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self.model = "models/props_c17/clock01.mdl" 
	self.Entity:SetMaterial("models/dog/eyeglass")
	self.IsConflictSecondary = 1
	
	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS )        	

	self.entTurret = nil
	self._ClipSize = 0
	self._RoundsLeft = 0
	self._PauseUntil = 0
	self._PauseStart = 0
	self:SetNetworkedBool("CSI_isConnected",false)
end

function ENT:AddEntityLink( eTurret )
	self.entTurret = eTurret
	
	self._ClipSize = self.entTurret.ClipSize
	self:SetNetworkedInt( "CSI_ClipSize",self._ClipSize)
	
	self._RoundsLeft = self.entTurret.CurrentClipSize
	self:SetNetworkedInt( "CSI_RoundsLeft",self._RoundsLeft)

	self._PauseUntil = self.entTurret.PauseUntil
	self:SetNetworkedInt( "CSI_PauseUntil",self._PauseUntil)

	self._PauseStart = self.entTurret.PauseStart
	self:SetNetworkedInt( "CSI_PauseStart",self._PauseStart)

	self:SetNetworkedBool("CSI_isConnected",true)
end

function ENT:RemoveEntityLink( eTurret )
	self.entTurret = nil
	self:SetNetworkedBool("CSI_isConnected",false)
end

function ENT:Think()
	--Update the networked variables only if they change.
	self.Entity:NextThink( CurTime() + 0.2)
	
	if (self.entTurret == nil) then return end
	if not (self.entTurret:IsValid()) then return end
	
	
	--Maximum Clip Size
	if 	(self._RoundsLeft ~= self.entTurret.CurrentClipSize) then
		self._RoundsLeft = self.entTurret.CurrentClipSize
		self:SetNetworkedInt( "CSI_RoundsLeft",self._RoundsLeft)
	end
	
	--Current Clip Size / Rounds Left
	if 	(self._ClipSize ~= self.entTurret.ClipSize) then
		self._ClipSize = self.entTurret.ClipSize
		self:SetNetworkedInt( "CSI_ClipSize",self._ClipSize)
	end

	if 	(self._PauseUntil ~= self.entTurret.PauseUntil) then
		self._PauseUntil = self.entTurret.PauseUntil
		self:SetNetworkedInt( "CSI_PauseUntil",self._PauseUntil)
	end
	if 	(self._PauseStart ~= self.entTurret.PauseStart) then
		self._PauseStart = self.entTurret.PauseStart
		self:SetNetworkedInt( "CSI_PauseStart",self._PauseStart)
	end

	
end