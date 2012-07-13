-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Microwave Reciever
-- Purpose: transports energy wirelessly, but be warned;
-- beam attenuation can be a bitch
-- Uses: Resource Distribution 2, Life Support 2, GCombat, Wire

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--util.PrecacheSound( "common/warning.wav")
include('shared.lua')

local ReloadTime = 15


function ENT:Initialize()
	self:SetModel( "models/props_industrial/oil_storage.mdl" )
	self.BaseClass.Initialize(self)
	
	-- The resources Get defined
	RD_AddResource(self, "energy", 0)
end




function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--self:StopSound( "NPC_Strider.Shoot" )
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	self.energy 	= RD_GetResourceAmount(self, "energy")
	
	self:SetOverlayText( " [ Microwave Reciever ] \nEnergy: "..self.energy)
	
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:Destruct()
	LS_Destruct( self, true )
end