ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName		= "Health Sensor"
ENT.Author		= "SnakeSVx"
ENT.Contact		= "stijn.sv@gmail.com"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:GetOverlayText()
	local txt = ""
	
	if (self.OOOActive == 1) then
		txt = "Health Sensor (ON)\nHealth: " .. tostring(self:GetNetworkedInt( 1 ))
	else
		txt =  "Health Sensor (OFF)"
	end
	
	local PlayerName = self:GetPlayerName()
	if ( !SinglePlayer() and PlayerName ~= "") then
		txt = txt .. "\n- " .. PlayerName .. " -"
	end
	
	return txt
end

RD2_AddStoolItem('cdstech', ENT.PrintName, 'models/props_lab/huladoll.mdl', 'sensor_health')
