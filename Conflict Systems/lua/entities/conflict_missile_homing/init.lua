-- Combat Damage Systems: Conflict
-- By: Solthar
-- 
-- Base Missile

AddCSLuaFile( "shared.lua" )
include('shared.lua')

local sMissileLarge = "models/weapons/W_missile_closed.mdl"

function ENT:Initialize()   
	self:SetupMissile(sMissileLarge)
	self:SetupVelocity (550, 1050, 3)
	self:IsMirv(false)
	self:IsTracking(true, 90)
	self:LaunchMissile()
	self:AddTrail(255,25,155,155)
end


