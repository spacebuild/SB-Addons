-- Combat Damage Systems: Conflict
-- By: Solthar
-- 
-- Dumbfire Rocket

AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	self:SetupMissile("models/weapons/W_missile_launch.mdl",1500)
	self:SetupVelocity (100, 150, 22.25)
	self:IsMirv(false)
	self:IsTracking(true,25)
	self:AddTrail(255,25,155,155)
	self:LaunchMissile()
end


function ENT:OnExplode()
	self:IsMirv(true, 1.0, 14, 85,"conflict_missile_homing")
	self:InitializeMIRV()
end