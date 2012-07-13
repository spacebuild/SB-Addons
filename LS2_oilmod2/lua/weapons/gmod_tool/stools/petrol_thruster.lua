
TOOL.Category		= "Petrol"
TOOL.Name			= "Thruster (Petrol)"
TOOL.Command		= nil
TOOL.ConfigName		= ""
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

if ( CLIENT ) then
    language.Add( "Tool_petrol_thruster_name", "Petrol Thruster Tool" )
    language.Add( "Tool_petrol_thruster_desc", "Spawns an Petrol-powered thruster (Made by Shadow25)" )
    language.Add( "Tool_petrol_thruster_0", "Primary: Create/Update Thruster" )
	language.Add( "sboxlimit_petrol_thrusters", "You've hit the petrol thrusters limit!" )
	language.Add( "undone_petrolthruster", "Undone petrol Thruster" )
	language.Add( "cleanup_petrol_thrusters", "petrol Thrusters" )
	language.Add( "cleaned_petrol_thrusters", "Cleaned up all petrol Thrusters" )
end

TOOL.ClientConVar[ "force" ] = "1500"
TOOL.ClientConVar[ "model" ] = "models/props_c17/lampShade001a.mdl"
TOOL.ClientConVar[ "keygroup" ] = "7"
TOOL.ClientConVar[ "keygroup_back" ] = "4"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "collision" ] = "0"
TOOL.ClientConVar[ "effect" ] = "fire"
TOOL.ClientConVar[ "damageable" ] = "0"
TOOL.ClientConVar[ "sound" ] = "1"

cleanup.Register( "petrol_thrusters" )

if (SERVER) then
    CreateConVar('sbox_maxpetrol_thrusters', 20)
end 

function TOOL:RightClick( trace )
	
	if trace.Entity and trace.Entity:IsPlayer() then return false end
 	 
 	-- If there's no physics object then we can't constraint it!
 	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
 	 
 	if (CLIENT) then return true end 
	
	if (trace.Entity:GetClass() ~= "gmod_thruster") then return false end
 	 
 	local ply = self:GetOwner() 
	
	local tbl = trace.Entity:GetTable()
 	 
 	local force			= trace.Entity.force
 	local model			= trace.Entity:GetModel() 
 	local key 			= tbl.key  
 	local key_bk 		= tbl.key_bck 
 	local toggle		= tbl.toggle
 	local collision		= tbl.nocollide 
 	local effect		= tbl.effect 
 	local damageable	= tbl.damageable 
 	local sound			= tbl.sound 
 	
 	if ( !self:GetSWEP():CheckLimit( "petrol_thrusters" ) ) then return false end 
   
 	if (!util.IsValidModel(model)) then return false end 
 	if (!util.IsValidProp(model)) then return false end		-- Allow ragdolls to be used?
   
    local pos = trace.Entity:GetPos()
	local ang = trace.Entity:GetAngles()
	
	local constr = constraint.FindConstraint( trace.Entity, "Weld" ) 
   
 	thruster = MakepetrolThruster( ply, model, ang, pos, key, key_bk, force, toggle, effect, sound, damageable ) 
	
	thruster:SetPos( pos ) 
	thruster:SetAngles( ang )
	
	constraint.Weld( thruster, constr.Entity[2].Entity , 0, 0, 0, collision == 0 )
 	 
 	local const, nocollide 
 	 
 	undo.Create("petrolThruster") 
 		undo.AddEntity( thruster ) 
 		undo.AddEntity( const ) 
 		undo.SetPlayer( ply ) 
 	undo.Finish() 
 		 
 	ply:AddCleanup( "petrol_thrusters", thruster ) 
 	ply:AddCleanup( "petrol_thrusters", const ) 
 	ply:AddCleanup( "petrol_thrusters", nocollide ) 
 	
	trace.Entity:Remove()
	 
 	return true 
   
 end

function TOOL:LeftClick( trace ) 
   
 	if trace.Entity and trace.Entity:IsPlayer() then return false end
 	 
 	-- If there's no physics object then we can't constraint it!
 	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
 	 
 	if (CLIENT) then return true end 
 	 
 	local ply = self:GetOwner() 
 	 
 	local force			= self:GetClientNumber( "force" ) 
 	local model			= self:GetClientInfo( "model" ) 
 	local key 			= self:GetClientNumber( "keygroup" )  
 	local key_bk 		= self:GetClientNumber( "keygroup_back" )  
 	local toggle		= self:GetClientNumber( "toggle" )  
 	local collision		= self:GetClientNumber( "collision" )  
 	local effect		= self:GetClientInfo( "effect" )  
 	local damageable	= self:GetClientNumber( "damageable" )  
 	local sound			= self:GetClientNumber( "sound" )  
 	 
 	-- If we shot another petrol thruster change its force
 	if ( trace.Entity:IsValid() and trace.Entity:GetClass() == "petrol_thruster" and trace.Entity.pl == ply ) then
   
 		trace.Entity:SetForce( force ) 
 		trace.Entity:SetEffect( effect ) 
 		trace.Entity:SetToggle( toggle == 1 ) 
 		trace.Entity.ActivateOnDamage = ( damageable == 1 ) 
   
 		trace.Entity.force	= force 
 		trace.Entity.toggle	= toggle 
 		trace.Entity.effect	= effect 
 		trace.Entity.damageable = damageable 
   
 		return true 
 	end 
 	 
 	if ( !self:GetSWEP():CheckLimit( "petrol_thrusters" ) ) then return false end 
   
 	if (!util.IsValidModel(model)) then return false end 
 	if (!util.IsValidProp(model)) then return false end		-- Allow ragdolls to be used?
   
 	local Ang = trace.HitNormal:Angle() 
 	Ang.pitch = Ang.pitch + 90 
   
 	thruster = MakepetrolThruster( ply, model, Ang, trace.HitPos, key, key_bk, force, toggle, effect, sound, damageable ) 
 	 
 	local min = thruster:OBBMins() 
 	thruster:SetPos( trace.HitPos - trace.HitNormal * min.z ) 
 	 
 	local const, nocollide 
 	 
 	-- Don't weld to world
 	if ( trace.Entity:IsValid() ) then 
 	 
 		const = constraint.Weld( thruster, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, true ) 
 		 
 		-- Don't disable collision if it's not attached to anything
 		if ( collision == 0 ) then  
 		 
 			thruster:GetPhysicsObject():EnableCollisions( false ) 
 			thruster.nocollide = true 
 			 
 		end 
 		 
 	end 
 	 
 	undo.Create("petrolThruster") 
 		undo.AddEntity( thruster ) 
 		undo.AddEntity( const ) 
 		undo.SetPlayer( ply ) 
 	undo.Finish() 
 		 
 	ply:AddCleanup( "petrol_thrusters", thruster ) 
 	ply:AddCleanup( "petrol_thrusters", const ) 
 	ply:AddCleanup( "petrol_thrusters", nocollide ) 
 	 
 	return true 
   
 end

if (SERVER) then

	function MakepetrolThruster( pl, Model, Ang, Pos, key, key_bck, force, toggle, effect, sound, damageable, nocollide, Vel, aVel, frozen ) 
 	 
 		if ( !pl:CheckLimit( "petrol_thrusters" ) ) then return false end 
 	 
 		local thruster = ents.Create( "petrol_thruster" ) 
 		if (!thruster:IsValid()) then return false end 
 		thruster:SetModel( Model ) 
   
 		thruster:SetAngles( Ang ) 
 		thruster:SetPos( Pos ) 
 		thruster:Spawn() 
   
 		thruster:GetTable():SetEffect( effect ) 
 		thruster:GetTable():SetForce( force ) 
 		thruster:GetTable():SetToggle( toggle == 1 ) 
 		thruster.ActivateOnDamage = ( damageable == 1 ) 
 		thruster:GetTable():SetSound( sound ) 
 		thruster:GetTable():SetPlayer( pl ) 
   
 		numpad.OnDown( 	 pl, 	key, 	"petrolThruster_On", 		thruster, 1 ) 
 		numpad.OnUp( 	 pl, 	key, 	"petrolThruster_Off", 	thruster, 1 ) 
 		 
 		numpad.OnDown( 	 pl, 	key_bck, 	"petrolThruster_On", 		thruster, -1 ) 
 		numpad.OnUp( 	 pl, 	key_bck, 	"petrolThruster_Off", 	thruster, -1 ) 
   
 		if ( nocollide == true ) then thruster:GetPhysicsObject():EnableCollisions( false ) end 
   
 		local ttable = { 
 			key	= key, 
 			key_bck = key_bck, 
 			force	= force, 
 			toggle	= toggle, 
 			pl	= pl, 
 			effect	= effect, 
 			nocollide = nocollide, 
 			damageable = damageable, 
 			sound = sound 
 			} 
   
 		table.Merge(thruster:GetTable(), ttable ) 
 		 
 		pl:AddCount( "petrol_thrusters", thruster ) 
 		 
 		DoPropSpawnedEffect( thruster ) 
   
 		return thruster 
 		 
 	end 
	
	duplicator.RegisterEntityClass( "petrol_thruster", MakepetrolThruster, "Model", "Ang", "Pos", "key", "key_bck", "force", "toggle", "effect", "sound", "damageable", "nocollide", "Vel", "aVel", "frozen" )

end

function TOOL:UpdateGhostpetrolThruster( ent, player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if (trace.Entity and trace.Entity:GetClass() == "petrol_thruster" or trace.Entity:IsPlayer()) then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local min = ent:OBBMins()
	 ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )
	
end


function TOOL:Think()

	if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() ~= self:GetClientInfo( "model" )) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostpetrolThruster( self.GhostEntity, self:GetOwner() )
	
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_petrol_thruster_name", Description = "#Tool_petrol_thruster_desc" })

	panel:AddControl("ComboBox", {
		Label = "#Presets",
		MenuButton = "1",
		Folder = "petrol_thruster",

		Options = {
			Default = {
				petrol_thruster_force = "20",
				petrol_thruster_model = "models/props_junk/plasticbucket001a.mdl",
				petrol_thruster_effect = "fire",
			}
		},

		CVars = {
			[0] = "petrol_thruster_model",
			[1] = "petrol_thruster_force",
			[2] = "petrol_thruster_effect"
		}
	})

	panel:AddControl("ComboBox", {
		Label = "#Thruster_Model",
		MenuButton = "0",

		Options = {
			["#Thruster"]				= { petrol_thruster_model = "models/dav0r/thruster.mdl" },
			["#Paint_Bucket"]			= { petrol_thruster_model = "models/props_junk/plasticbucket001a.mdl" },
			["#Small_Propane_Canister"]	= { petrol_thruster_model = "models/props_junk/PropaneCanister001a.mdl" },
			["#Medium_Propane_Tank"]	= { petrol_thruster_model = "models/props_junk/propane_tank001a.mdl" },
			["#Cola_Can"]				= { petrol_thruster_model = "models/props_junk/PopCan01a.mdl" },
			["#Bucket"]					= { petrol_thruster_model = "models/props_junk/MetalBucket01a.mdl" },
			["#Vitamin_Jar"]			= { petrol_thruster_model = "models/props_lab/jar01a.mdl" },
			["#Lamp_Shade"]				= { petrol_thruster_model = "models/props_c17/lampShade001a.mdl" },
			["#Fat_Can"]				= { petrol_thruster_model = "models/props_c17/canister_propane01a.mdl" },
			["#Black_Canister"]			= { petrol_thruster_model = "models/props_c17/canister01a.mdl" },
			["#Red_Canister"]			= { petrol_thruster_model = "models/props_c17/canister02a.mdl" }
		}
	})

	panel:AddControl("ComboBox", {
		Label = "#Thruster_Effects",
		Description = "#Thruster_Effects_Desc",
		MenuButton = "0",

		Options = {
			["#No_Effects"] = { petrol_thruster_effect = "none" },
			["#Flames"] = { petrol_thruster_effect = "fire" },
			["#Plasma"] = { petrol_thruster_effect = "plasma" },
			["#Smoke"] = { petrol_thruster_effect = "smoke" },
			["#Rings"] = { petrol_thruster_effect = "rings" }
		}
	})
	
	panel:AddControl("Slider", {
		Label = "#Thruster_force",
		Type = "Float",
		Min = "1",
		Max = "10000",
		Command = "petrol_thruster_force"
	})
	
	panel:AddControl("Numpad", {
		Label = "#Thruster_group",
		Label2 = "#Thruster_group_back",
		Command = "petrol_thruster_keygroup",
		Command2 = "petrol_thruster_keygroup_back",
		ButtonSize = "22"
	})
	
	panel:AddControl("CheckBox", {
		Label = "#Thruster_toggle",
		Command = "petrol_thruster_toggle"
	})
	
	panel:AddControl("CheckBox", {
		Label = "#Thruster_collision",
		Command = "petrol_thruster_collision"
	})

	panel:AddControl("CheckBox", {
		Label = "#Thruster_damageable",
		Command = "petrol_thruster_damageable"
	})

	panel:AddControl("CheckBox", {
		Label = "#Sound",
		Command = "petrol_thruster_sound"
	})

end
