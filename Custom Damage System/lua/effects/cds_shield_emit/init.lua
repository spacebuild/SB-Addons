local mat = Material("models/shadertest/predator")
mat:SetMaterialFloat("$envmap",			0)
mat:SetMaterialFloat("$envmaptint",		0)
mat:SetMaterialFloat("$refractamount",	-.1)
mat:SetMaterialInt("$ignorez",		1)

function EFFECT:Init(data)
	self.ent = data:GetEntity()
	self.pos = self.ent:GetPos()
	self.mag = self.ent:GetNetworkedInt("SRadius")/2.5
	self.Entity:SetModel("models/props/cs_italy/orange.mdl")
	self.Entity:SetPos(self.ent:GetPos())
	self.Entity:SetAngles(self.ent:GetAngles())
	self.Entity:SetParent(self.ent)
	self.Entity:SetMaterial("models/shadertest/predator")
end

function EFFECT:Think()
	if not self.ent:IsValid() then
		return false
	else
		self.mag = self.ent:GetNetworkedInt("SRadius")/2.5
		local v = Vector(self.mag,self.mag,self.mag)
		self.Entity:SetModelScale(v)
		v = v*2
		self.Entity:SetRenderBoundsWS((v*-1)+self.Entity:GetPos(),v+self.Entity:GetPos())
		self.Entity:NextThink(CurTime()+.5)
		return true
	end
end

function EFFECT:Render()
	self.Entity:DrawModel()
end
