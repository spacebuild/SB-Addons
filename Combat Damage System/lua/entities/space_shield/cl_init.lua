include('shared.lua')

local Strength = "Strength: 0"

function ENT:GetToolTip()
	return self.BaseClass.GetToolTip(self).."\n"..Strength
end

function ENT:RecvBeamNetVar(name, Key, Value)
	if(name == "Int" and Key == "str") then
		Strength = "Strength: "..Value
	end
end
