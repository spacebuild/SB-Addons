if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

TOOL.Category = 'Conflict Systems'
TOOL.Name			= "#Conflict Link"
TOOL.Command		= nil
TOOL.ConfigName		= ""
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

--Custom Var
TOOL.Stage			= 0				-- 0 = nothing, 1 == first stage selected
TOOL.Turret			= nil			-- link to the turret entity
TOOL.SecSys			= nil			-- link to the secondary system

--Put it in the life support tab, if enabled
--if (CLIENT and LocalPlayer():GetInfo("RD_UseLSTab") == "1") then TOOL.Tab = "Life Support" end

TOOL.ClientConVar[ "conflicttype" ] = "0"
TOOL.ent = {}


cleanup.Register( "ConflictSystems" )


-- Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "Tool_Conflict_Link_name", "Conflict Systems Link Tool" )
	language.Add( "Tool_Conflict_Link_desc", "Links a turret to a secondary system." )
	language.Add( "Tool_Conflict_Link_0", "Left click to select a turret." )
	language.Add( "Tool_Conflict_Link_1", "Left click to select a control system. \nRight click to cancel." )
	
	language.Add( "Tool_turret_type", "Type of weapon" )
	
	language.Add( "Undone_Conflict_Link", "Undone Conflict Link" )
	
	language.Add( "Cleanup_Conflict_Links", "Weapon" )
	language.Add( "Cleaned_Conflict_Links", "Cleaned up all Weapons" )
	language.Add( "SBoxLimit_Conflict_Link", "You've reached the Weapon limit!" )

end

function TOOL:LeftClick( trace )

if ( !trace.Hit ) then return end
	
	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if (CLIENT) then return true end
	
	local conflicttype	= self:GetClientNumber( "conflicttype" ) 
	local ply = self:GetOwner()
	if (trace.Entity == nil) then
		ply:SendLua("GAMEMODE:AddNotify(\"".."Please select a Conflict Systems Turret.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
	else
		if (self:GetStage() == 0) then
			if ((trace.Entity.IsConflictTurret or 0) == 1) then
				self.Turret = trace.Entity
				--self.Stage = 1
				self:SetStage(1)
			else 
				-- incompatable object
				ply:SendLua("GAMEMODE:AddNotify(\"".."Please Select a Conflict Systems Turret.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
			end
		elseif (self:GetStage() == 1) then
			if ((trace.Entity.IsConflictSecondary or 0) == 1) then
				trace.Entity:AddEntityLink(self.Turret)
				self.Turret = nil
				--self.Stage = 0
				self:SetStage(0)
			else
				-- incompatable object
				ply:SendLua("GAMEMODE:AddNotify(\"".."Please Select a Conflict Control System.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
			end
		end
	end
	--undo.Create("ConflictSystems")
--		undo.AddEntity( self.ent )
--		undo.AddEntity( weld )
--		undo.AddEntity( nocollide )
--		undo.SetPlayer( ply )
--	undo.Finish()
	return true

end

function TOOL:RightClick( trace )
	
if ( !trace.Hit ) then return end
	
	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	if (CLIENT) then return true end
	local ply = self:GetOwner()
	
	
	local conflicttype	= self:GetClientNumber( "conflicttype" ) 
	if ((self:GetStage() == 0) and not (trace.Entity == nil)) then
		if ((trace.Entity.IsConflictSecondary or 0) == 1) then
			trace.Entity:RemoveEntityLink(self.Turret)
			ply:SendLua("GAMEMODE:AddNotify(\"".."Conflict System Link Removed.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
		else
			ply:SendLua("GAMEMODE:AddNotify(\"".."Conflict Systems Link Tool Reset.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
		end
		self.Turret = nil
		self:SetStage(0)
	else
		ply:SendLua("GAMEMODE:AddNotify(\"".."Conflict Systems Link Tool Reset.".."\", NOTIFY_ERROR, 5) surface.PlaySound(\"".."ambient/water/drip"..math.random(1, 4)..".wav".."\")");
		self.Turret = nil
		self:SetStage(0)
	end
	

	return true

end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Text = "#Tool_ConflictSystems_name", Description	= "#Tool_ConflictSystems_desc" }  )
	CPanel:AddControl( "Label", { Text = "Use to link between turrets and the control systems", Description	= "Use to link between turrets and the control systems" }  )
end
