-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Microwave Reciever
-- Purpose: transports energy wirelessly, but be warned;
-- beam attenuation can be a bitch
-- Uses: Resource Distribution 2, Life Support 2, GCombat, Wire

-- now no longer uses traces for targetting
-- WORKS IN A CONE with a userdefined radius

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local ReloadTime = 0.5
local AttenuationConstant = 31500	--The higher it is, the slower the exponential growth



function ENT:Initialize()
	self:SetModel( "models/props_c17/utilityconnecter006c.mdl" )
	self.BaseClass.Initialize(self)
	
	local RD = CAF.GetAddon("Resource Distribution")
	RD.RegisterNonStorageDevice(self)
	
	-- The variables
	self.on = 0
	self.attenuation = 0
	self.distance = 0
	self.state = "Off"
	self.reloadtime = 0
	self.multiplier = 1
	
	
	--new variables
	self.Spread = 1.75						-- how many degree's you can be away from the transmitter and still recieve
	self:SetNetworkedInt("Spread",self.Spread)
	
	-- Add wire support, of course
	if not (WireAddon == nil) then 
		self.Inputs = Wire_CreateInputs(self, { "On", "Multiplier","Spread" }) 
		self.Outputs = Wire_CreateOutputs(self, {"On", "Distance", "Attenuation" })
	end
	
end

function ENT:CalculateAttenuation()
	if self.distance == 0 then
		self.attenuation = 0
	else
		-- Exponential attenuation with distance
		-- if distance >= ~26055 = 100% Signal Loss
		-- 20825 = ~50% Signal Loss
		-- 15938 = ~25% Signal Loss
		-- 10000 = ~15% Signal Loss
		
		-- NEW! 
		-- Beam spread is now an available option,
		-- and it has more of an effect than distance.
		-- Omni-directional transmitters won't be very efficiant, if at all.
		
		self.attenuation = math.Round(self.distance ^ (self.distance/((AttenuationConstant ^ (math.Min(1,self.Spread/2)))+self.distance))) 
		if (self.attenuation > 100) then self.attenuation = 100 end
	end
end

function ENT:DoTrace()
	local Trace = util.QuickTrace( self:GetPos(), self:GetUp() * 30000, { self } )
	if not (Trace.Hit) then
		self.distance = 30000
	else
		self.distance = Trace.Fraction * 30000
	end
	self:CalculateAttenuation()
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end 

function ENT:Use()
 	if (self.reloadtime < CurTime()) then
 		if (self.on == 1) then
 			self.on = 0
 			self.state = "Off"
 		else
 			self.on = 1
 			self.state = "On"
 		end
 		self:SetOverlayText("Transmitter ("..self.state..")\nDist: "..math.Round(self.distance).."\n"..self.attenuation.."% Loss")
	end	
	self.reloadtime = CurTime() + ReloadTime
end

function ENT:TriggerInput(iname, value)
	if(iname == "On") then
 		if (self.on == 1) then
 			self.on = 1
 			self.state = "On"
 		else
 			self.on = 0
 			self.state = "Off"
 		end
 		self:SetOverlayText("Transmitter ("..self.state..")\nDist: "..math.Round(self.distance).."\n"..self.attenuation.."% Loss")
	elseif(iname == "Multiplier") then
		if not (self.multiplier == value) then
			self.multiplier = math.Clamp(value,1,100)
		end
	elseif(iname == "Spread") then
		self.Spread = math.Clamp(value,1.75,180)
		self:SetNetworkedInt("Spread",self.Spread)
	end
	
	
end

function ENT:Think()
	self.BaseClass.Think(self)
	local RD = CAF.GetAddon("Resource Distribution")
	if (self.on == 1) then 
		if (RD.GetResourceAmount(self, "energy") >= (100*self.multiplier)) then
			local energy_available = RD.ConsumeResource(self, "energy",100*self.multiplier)
			--self:DoTrace()
	
			--allow power transmission to the transmitters themselves
			--to allow people to do things like relay stations
			local tTargets = ents.FindByClass("rts_reciever")
			local TargetEnt = {}
			local TargetDist = {}
			local MaxDist = 0
			local TotalDist = 0
			local x = 1
			local tDist = 0
			local tDist2 = 0
			for _, Ent in pairs(tTargets) do
				--tAng = (Ent:GetPos() - self:GetPos()):Normalize():Angle()
				--tSum = math.abs(tAng.p) + math.abs(tAng.y) + math.abs(tAng.r)
				
				--We don't want to supply power to ourselves
				if not (self == Ent) then
					--Calculate the angle of deviation from the target axis
					--relative to the parent entity.
					tDist =  self:GetPos():Distance(Ent:GetPos())
					tDist2 =(self:GetPos()+self:GetUp()*tDist):Distance(Ent:GetPos())
					tAng = math.Rad2Deg(math.atan2( tDist2, tDist))
					
					-- if we are within the current spread of the beam
					if ( tAng <= self.Spread ) then
						TargetEnt[x] = Ent
						TargetDist[x] = tDist
						x = x + 1
						TotalDist = TotalDist + tDist
						if (tDist > MaxDist) then
							MaxDist = tDist
						end
					end
				end
			end
				
			--Now we supply power to the target entitys.
			if x > 1 then
				local shared_energy = math.floor(energy_available / (x - 1) )
				local en = 0;
				for i = 1,x-1 do
					local dist = (TargetDist[i] / TotalDist)
					local sub = shared_energy * (self.attenuation / 100)
					en = math.floor((shared_energy - sub) * dist)
				
					-- Give more energy to the closest recievers
					RD.SupplyResource(TargetEnt[i], "energy",en)
				end
			end		
		end
	end

	
	self:SetOverlayText("Transmitter ("..self.state..")\nDist: "..math.Round(self.distance).."\n"..self.attenuation.."% Loss")
	if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "On", self.on)
			Wire_TriggerOutput(self, "Distance", self.distance)
			Wire_TriggerOutput(self, "Attenuation", self.attenuation)
	end	
	
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self, true )
	end
end