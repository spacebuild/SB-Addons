AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local BeamLength = 512
local Energy_Increment = 200
local Refire_Rate = 0.6

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD_AddResource(self, "energy", 0)
	self.Active = 0
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Fire" }) end
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(120)
		phys:Wake()
	end
end

function ENT:TurnOn()
	if ( self.Active == 0 ) then
		self.Active = 1
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if ( self.Active == 1 ) then
		self.Active = 0
		self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		self:SetActive(value)
	end
end

local function Discharge(ent)
	local Pos = ent:GetPos()
	local Ang = ent:GetAngles()
--	Ang:RotateAroundAxis(Ang:Up(), 180)  --the thing spawns backwards  o_O
	Pos = Pos+Ang:Up()*16
	local trace = {}
	trace.start = Pos
	trace.endpos = Pos+(Ang:Forward()*BeamLength)
	trace.filter = { ent }
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		local hitent = tr.Entity
		if (hitent.IsAsteroid == 1 and hitent.resource ~= nil and hitent.resource ~= false) then
			if (math.random(1, (hitent.resource.yield or 1)) < 12) then
			local try = math.ceil(hitent.resource.yield/25)
				for var = 0, try, 1  do
				--while (hitent.resource.yield > 0) do
					local raw_res = ents.Create( "raw_resource" )
						raw_res:SetPos( hitent:GetPos()+(VectorRand()*40) )
						raw_res:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360))) 
					raw_res:Spawn()
					
					local phys = raw_res:GetPhysicsObject()
					phys:EnableMotion(true)
					phys:EnableGravity(false)
					raw_res.grav = 0
					
					local Ang = raw_res:GetUp()
					local force = Ang * 200
					phys:ApplyForceCenter(force)
					
					raw_res.resource.name = hitent.resource.name
					raw_res.resource.rarity = hitent.resource.rarity
					if (raw_res.resource.rarity == 3) then
						raw_res:SetColor(Color(255, 0, 0, 255 ))
					elseif (raw_res.resource.rarity == 2) then
						raw_res:SetColor(Color( 0, 255, 0, 255 ))
					elseif (raw_res.resource.rarity == 1) then
						raw_res:SetColor(Color( 0, 0, 255, 255 ))
					end
					
					if (hitent.resource.yield >= 25) then
						raw_res.resource.yield = 25
						hitent.resource.yield = hitent.resource.yield - 25
					else
						raw_res.resource.yield = hitent.resource.yield
						hitent.resource.yield = 0
					end
					raw_res:SetOverlayText( raw_res.resource.name .. ": " .. raw_res.resource.yield )
				end
				--hitent:SetKeyValue("exploderadius","1")
				--hitent:SetKeyValue("explodedamage","1")
				--hitent:Fire("break","","0.0")
				--hitent:Fire("kill","","0.1")
				hitent:Remove()
			end
		else
			util.BlastDamage(ent,ent,tr.HitPos,1,40)
		end
	end
	local effectdata = EffectData()
	effectdata:SetEntity( ent )
	effectdata:SetOrigin( Pos )
	effectdata:SetStart( tr.HitPos )
	effectdata:SetAngle( Ang )
	util.Effect( "mining_beam", effectdata, true, true )
end

function ENT:Attack()
	if ( RD_GetResourceAmount(self, "energy") >= Energy_Increment ) then
		RD_ConsumeResource(self, "energy", Energy_Increment)
		Discharge(self)
	else
		self:EmitSound( "common/warning.wav" )
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if ( self.Active == 1 ) then
		self:Attack()
	end
	self:NextThink(CurTime() + Refire_Rate)
	return true
end
