local matRefract = Material("models/spawn_effect")
local matIce	 = Material("cds/freeze_effect")

function EFFECT:Init(data)
	self.Time = data:GetMagnitude()
	self.LifeTime = CurTime() + self.Time
	local ent = data:GetEntity()
	if(!ent:IsValid()) then return end
	self.ParentEntity = ent
	self.ParentEntity:SetMaterial(matIce)
	self.Entity:SetModel(ent:GetModel())
	self.Entity:SetPos(ent:GetPos())
	self.Entity:SetAngles(ent:GetAngles())
	self.Entity:SetParent(ent)
end

function EFFECT:Think()
	if (not self.ParentEntity or not self.ParentEntity:IsValid()) then return false end
	return (self.LifeTime > CurTime()) 
end

function EFFECT:Render()
	local Fraction = math.abs((CurTime()-self.LifeTime)/self.Time)
	Fraction = math.Clamp(Fraction, 0, 1)
	self.Entity:SetColor(Color(255, 255, 255, Fraction*200))
	local EyeNormal = self.Entity:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01
	cam.Start3D(Pos, EyeAngles())
		render.MaterialOverride(matIce)
			self.Entity:DrawModel()
		render.MaterialOverride(0)
		if (render.GetDXLevel() >= 80) then
			render.UpdateRefractTexture()
			matRefract:SetMaterialFloat("$refractamount", Fraction/16)
			render.MaterialOverride(matRefract)
				self.Entity:DrawModel()
			render.MaterialOverride(0)
		end
	cam.End3D()
end