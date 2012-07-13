ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName		= "Multi Sensor"
ENT.Author		= "SnakeSVx"
ENT.Contact		= "stijn.sv@gmail.com"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:GetOverlayText()
	local txt = ""
	
	if (self.OOOActive == 1) then
		txt = "Sensor (ON)\nHealth: " .. tostring(self:GetNetworkedInt( 1 )).."\nArmor: " .. tostring(self:GetNetworkedInt( 2 )).."\nTemperature: " .. tostring(self:GetNetworkedInt( 3 ))
	else
		txt =  "Sensor (OFF)"
	end
	
	local PlayerName = self:GetPlayerName()
	if ( !SinglePlayer() and PlayerName ~= "") then
		txt = txt .. "\n- " .. PlayerName .. " -"
	end
	
	return txt
end

RD2_AddStoolItem('cdstech', ENT.PrintName, 'models/props_lab/huladoll.mdl', 'sensor_all')
