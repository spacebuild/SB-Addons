

ENT.Type 			= "anim"
ENT.Base 			= "base_rd_entity"

ENT.PrintName		= "Powered Thruster"
ENT.Author			= "Syncaidius"
ENT.Contact			= ""
ENT.Purpose			= "To move your contraption and eat your resources."
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:GetOverlayText()
	local txt = ""
	local force = self:GetNetworkedInt( 3 )
	local resource = self:GetNetworkedString( 2 )
	local consumption = math.floor( self:GetNetworkedInt( 1 ) )
	
	if (self.OOOActive == 1) then
		txt = self.PrintName.." (ON)\nForce: " .. force .. "\nResource: " .. resource .. "\nConsumption: " .. consumption.."/sec"
	else
		txt =  self.PrintName.." (OFF)\nForce: " .. force .. "\nResource: " .. resource .. "\nConsumption: " .. consumption.."/sec"
	end
	
	local PlayerName = self:GetPlayerName()
	if ( !SinglePlayer() and PlayerName ~= "") then
		txt = txt .. "\n- " .. PlayerName .. " -"
	end
	
	return txt
end

function ENT:SetEffect( name )
	self:SetNetworkedString( "Effect", name )
end
function ENT:GetEffect( name )
	return self:GetNetworkedString( "Effect" )
end

function ENT:SetOn( boolon )
	self:SetNetworkedBool( "On", boolon, true )
end
function ENT:IsOn( name )
	return self:GetNetworkedBool( "On" )
end

function ENT:SetOffset( v )
	self:SetNetworkedVector( "Offset", v, true )
end
function ENT:GetOffset( name )
	return self:GetNetworkedVector( "Offset" )
end

function ENT:NetSetForce( force )
	self:SetNetworkedInt(4, math.floor(force*100))
end
function ENT:NetGetForce()
	return self:GetNetworkedInt(4)/100
end

local Limit = .1
local LastTime = 0
local LastTimeA = 0
function ENT:NetSetMul( mul )
	if (CurTime() < LastTimeA + .05) then
		LastTimeA = CurTime()
		return
	end
	LastTimeA = CurTime()
	
	if (CurTime() > LastTime + Limit) then
		self:SetNetworkedInt(5, math.floor(mul*100))
		LastTime = CurTime()
	end
end

function ENT:NetGetMul()
	return self:GetNetworkedInt(5)/100
end
