-- Turret's Target Selection Screen
-- Was fun getting this to actually work!
--

include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self.model = "models/props_vents/vent_large_grill001.mdl" 
	self.Entity:SetMaterial("models/dog/eyeglass")
	self.IsConflictSecondary = 1
	
	self.Entity:SetModel( self.model ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   	
	self.Entity:SetSolid( SOLID_VPHYSICS )        	

	self.entTurret = {}
	
	-- These settings are the same as in cl_init.lua
	self.iPage 	= 	 0		--What page are we on?
	self.iOffset 	= 	0			--What's the current offset for the page?
	self.iPageSize	=	8												--How many items per page to display?
	self.iTarget	= 	0 			--the current target
	self.iState 	= 	0
	
	self.fXMultiplier = 600
	self.fYMultiplier = 460
	
	self.UseNext	= CurTime()
	
	--self:SetNetworkedBool("CSI_isConnected",false)
	
	
end

-- Returns true of targx,targy is within the defined coords
function ENT:InBounds2D(targx,targy,x,y,xsize,ysize)
	if (targx > x) and (targx < (x+xsize)) and (targy > y) and (targy < (y+ysize)) then
		return true
	else
		return false
	end
end

--Run when something changes
function ENT:UpdateTurrets()
	 for i, entTurret in ipairs(self.entTurret) do
	 	if ValidEntity(entTurret) then
		 	if (self.iTarget == 0) then												--if there's no target
		 		entTurret.TargetPlayer 	= nil
		 		entTurret.Target		= nil
		 		entTurret.AttackMode 	= false
		 		entTurret.Active 		= false
		 		--MsgN("(Conflict Systems Error): Deactivating your "..entTurret.DisplayName.." due to lack of targetted player.\n")
 			else																	--if the targetter has a player selected
		 		entTurret.TargetPlayer = self.iTarget								--set the turrets target to the selected player
		 		
		 		entTurret.Target = nil												--reset the turret's target to nil, just in case
		 		entTurret:FindTargetOwnedBy(self.iTarget)							--find a target owned by the curretly targetted player
		 		
		 	
		 		--entTurret.PauseStart = CurTime()
		 		--entTurret.PauseUntil = CurTime() + entTurret.TargetLockTime
		 		--entTurret.NextAttack = CurTime() + entTurret.TargetLockTime
		 		
		 		entTurret.Active = true												--activate the turret
		 		
		 		
		 		if (self.iState == 0) then										
		 			entTurret.AttackMode = false									--Our weapons have locked onto the player, and are not attacking
		 		else
		 			entTurret.AttackMode = true										--BATTLEMODE!
		 		end
		 	end
		 else
		 	
		 	table.remove( self.entTurret,i ) 										--If the turret's no longer valid, remove the damn thing from the list!
		 	--Msg("Removing Entity: "..i.."\n")
		 end
	 end  
end

function ENT:Use( activator, caller ) 
	-- NOTE: Prev/Next buttons are NOT added yet.
	--       I should add those later


	if (self.UseNext < CurTime()) then
		self.UseNext = CurTime() + 0.5		-- To prevent spamming traces
		
		-- Run the exact same trace as we do in cl_init.lua
		local trace = {}
			trace.start = activator:GetShootPos()
			trace.endpos = activator:GetAimVector() * 60 + trace.start
			trace.filter = activator
		local trace = util.TraceLine(trace)
		
		-- If the trace hits this entity...
		if (trace.Entity == self.Entity) then
			
			-- Convert the trace's hitpos into coords local to this entity.
			local vPosition = self.Entity:WorldToLocal(trace.HitPos)
			local fX = 0
			local fY = 0
			
			-- If the z pos is greater than 0, we hit the front
			if (vPosition.z > 0 ) then
				fY = math.Clamp((vPosition.x + 13.829 ),0,27.5 )/27.5
				fX = math.Clamp((vPosition.y + 17.4077),0,35   )/35
			end
			
			-- time to figure out what we hit!
			local iNameCount = 0			
			local n = 0
			for k, _player in pairs(player.GetAll()) do
	 			iNameCount = iNameCount + 1
	 			--Only check the players that are on the current page
	 			if ( iNameCount > (self.iPage * self.iPageSize)) and ( iNameCount < (self.iPage * self.iPageSize + self.iPageSize)) then
	 				if (self:InBounds2D(fX*self.fXMultiplier,fY*self.fYMultiplier,0,n*self.fYMultiplier/10,400,self.fYMultiplier/10) ) then
						if (self.iTarget == _player) then
							if self.iState == 1 then
								self.iState = 0			--	Tracking player, but not attacking
							else
								self.iState = 1			--	Tracking player, AND attacking.  pew! pew! pew!
							end
							self:SetNetworkedInt( "iState",self.iState)
						else
	 						self.iTarget = _player	-- 	set the current target to the player
	 						self:SetNetworkedInt( "TargetID",self.iTarget:EntIndex() )
	 						self.iState = 0			--	Tracking player, but not attacking
	 						self:SetNetworkedInt( "iState",self.iState)
						end
						-- Update Connected turrets
						self:UpdateTurrets()	
	 				end
	 				n = n + 1
	 			end
			end
		end
	end
end

function ENT:AddEntityLink( eTurret )
	-- Only add the turret to the table if it's not already there!
	if not (table.HasValue(self.entTurret, eTurret) ) then
		table.insert(self.entTurret,eTurret)
	end
end

function ENT:RemoveEntityLink( eTurret )
	if (table.HasValue(self.entTurret, eTurret) ) then
		 for i, v in ipairs(self.entTurret) do
		 	if (v == eTurret) then
		 		local tRemove = table.remove(self.entTurret,i)
		 		return
		 	end
		 end  
	end
end

function ENT:Think()
	
	self.Entity:NextThink( CurTime() + 1)
	self:UpdateTurrets()	--run the update function every second, so if any new turrets get added they're synced.

	
end