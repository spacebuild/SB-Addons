-- Combat Damage Systems: Conflict
-- By: Solthar
-- 
-- Dumbfire Rocket

AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	self:SetupMissile("models/weapons/W_missile_launch.mdl")
	self:SetupVelocity (1250, 1050, 2.25)
	self:IsMirv(false)
	self:IsTracking(false)
	self:AddTrail(255,25,155,155)
	self:LaunchMissile()
end


