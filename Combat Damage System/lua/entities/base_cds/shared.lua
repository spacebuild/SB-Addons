ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName = "Gun - Base"
ENT.Author 		= "Spacetech"
ENT.Contact 	= "Spacetech326@gmail.com"

ENT.Spawnable	   = false
ENT.AdminSpawnable = false

--[[ All Functions:
	Global Functions:
		self.BaseClass.Trace(self, Angle, IgnoreEntTable, ReturnEnt)
		self.BaseClass.TraceHitNormal(self, Angle)
]]

--[[
	GLOBAL FUNCTIONS START
]]

-- self.BaseClass.Trace(self, Angle, IgnoreEntTable, ReturnEnt)
function ENT:Trace(Angle, IgnoreEntTable, ReturnEnt)
	if(!Angle) then return end
	local Pos = self:GetPos()
	local Trace = {}
	Trace.start = Pos
	Trace.endpos = Trace.start + (Angle * 20480)
	if(IgnoreEntTable) then
		table.insert(IgnoreEntTable, self)
		Trace.filter = IgnoreEntTable
	else
		Trace.filter = self	
	end
	local tr = util.TraceLine(Trace)
	if(ReturnEnt) then
		return tr.Entity
	else
		return tr.HitPos
	end
end

-- self.BaseClass.TraceHitNormal(self, Angle)
function ENT:TraceHitNormal(Angle)
	if(!Angle) then return end
	local Pos = self:GetPos()
	local Trace = {}
	Trace.start = Pos
	Trace.endpos = Trace.start + (Angle * 20480)
	Trace.filter = self
	local tr = util.TraceLine(Trace)
	return tr.HitNormal
end

--[[
	GLOBAL FUNCTIONS END
]]