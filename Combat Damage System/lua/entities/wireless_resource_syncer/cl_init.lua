include('shared.lua')

local ToolTip = ENT.PrintName
local EntIndex = false

function ENT:Draw()
	self:DrawModel()
	if(LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance(self:GetPos()) < 512) then
		local ToolTip = tostring(self:GetNetworkedString("ToolTip1"))..tostring(self:GetNetworkedString("ToolTip2"))..tostring(self:GetNetworkedString("ToolTip3"))	
		AddWorldTip(EntIndex, ToolTip, 0.5, self:GetPos(), self)
	end
end
