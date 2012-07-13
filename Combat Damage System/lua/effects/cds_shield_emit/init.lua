local RND_Scale_Factor = .1
--local MatA = Material("cds/spherez/cds_spherez")
--local MatB = Material("cds/spherez/shield_base")
local MatA = Material("models/props_combine/com_shield001a")
local MatB = Material("models/props_combine/com_shield001b")

function EFFECT:Init(data)
	local ent = data:GetEntity()
	if not (ent and ValidEntity(ent)) then return end
	self.Parent = ent
	
	self.Entity:SetPos(ent:GetPos())
	self.Entity:SetAngles(ent:GetAngles())
	self.Entity:SetModel("models/cds/spherez/HRes_Sphere.mdl")
	self.Entity:SetParent(ent)
	
end

function EFFECT:Think()
	if not (self.Parent and ValidEntity(self.Parent)) then return false end
	
	local rad = self.Parent:GetNWInt("Radius") or -1
	--Msg("Rad: ", rad,"\n")
	self.On = not ((rad == -1) or (rad == 0))
	
	if self.On ~= -1 then
		self.Rad = (rad + (math.sin(CurTime()) * (rad * RND_Scale_Factor))) / 1024	
		self.Entity:SetRenderBounds(Vector() * self.Rad * -.5, Vector() * self.Rad * .5)
		self.Entity:SetModelScale(Vector() * self.Rad)
	end
	
	return ValidEntity(self.Parent)
end

function EFFECT:Render()
	if self.On then
		render.MaterialOverride(MatB)
		self.Entity:DrawModel()
		render.MaterialOverride(MatA)
		self.Entity:DrawModel()
		render.MaterialOverride()
	end
end
