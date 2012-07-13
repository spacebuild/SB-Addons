AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')



-- Init func ;o
function ENT:Initialize()
	-- Model we will be using
	self:SetModel( "models/props_canal/bridge_pillar02.mdl" )
	-- Physics settings
	self.BaseClass.Initialize(self)
	
	-- Toggling Variables
	self.toggle = false -- On or off
	self.togglebouncekil = 3 -- You can only self.toggle when this is zero!
	
	-- *************************************
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	
	-- Resource distribution stuff, Here we define what we are using, creating and destroying

	RD.AddResource(self, "Crude Oil", 0)
	RD.AddResource(self, "Petrol", 0)
	RD.AddResource(self, "Oil", 0)
	RD.AddResource(self, "energy", 0)
	-- **************************************
end


-- Wiremod function!
function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self.toggle = true
			self:SetOOO(1)
		else
			self.toggle = false
			self:SetOOO(0)
		end	
	end
end

function ENT:Use()
    -- This stops "Bouncing" Where it self.toggles off and on really fast
	-- Every think self.togglebouncekil is decremented till it is 0
	-- at wich point you can self.toggle
	-- Each time you self.toggle it's set back to 5, Therefore disallowing control
	-- For a period of time!
	if(self.togglebouncekil == 0) then
		if(self.toggle == false) then
			self.toggle = true
			self.togglebouncekil = 3
			self:SetOOO(1)
			return
		end
		if(self.toggle == true) then
			self.toggle = false
			self.togglebouncekil = 3
			self:SetOOO(0)
			return
		end
	end
end


function ENT:Think()
	self.BaseClass.Think(self)
	
	-- This is used to stop the use-button bouncing
	-- You can only self.toggle when its 0, this brings it back to zero after a self.toggle
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end
	
	-- We can only Crack if we are actually turned on right? lol
	if (self.toggle == true) then
		self.Crude = RD.GetResourceAmount(self, "Crude Oil")
		self.energy = RD.GetResourceAmount(self, "energy")
		
		-- If we have more than 400 energy, We can heat up the coils to atmosphericly distil the crude oil
		if (self.energy > 400) then
			-- But this can only be acheived if we actualy HAVE crude oil :/
			if (self.Crude > 1600) then
				-- So now we have the required ameneties, let's start cracking our oil eh? :)
				-- HEating the coils uses 720 energy!
				RD.ConsumeResource(self, "energy", 80)
				-- We use 100 Crude oil to to make our products
				RD.ConsumeResource(self, "Crude Oil", 1600)
				-- WE have consumed, so now lets make our products
				-- Oil is for lubricant you know ;O
				--  waste ALOT during atmospheric distilations, fact of nature...
				RD.SupplyResource(self, "Petrol", 600)
				RD.SupplyResource(self, "Oil", 700)
				-- We have sucesfully cracked :D (And after looking at this code, i aint surprised...)
			else -- Turn off if we cant run!
				self.toggle = false
				self.togglebouncekil = 3
			end -- Crude oil check
		else  -- Turn off if we cant run
			self.toggle = false
			self:SetOOO(0)
			self.togglebouncekil = 3	
		end -- Energy check
	end -- self.toggle
	
	
	self:NextThink( CurTime() + 1 )
	return true
end
