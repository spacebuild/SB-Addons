
TOOL.Category		= "Petrol"
TOOL.Name			= "Wheel (Petrol)"
TOOL.Command		= nil
TOOL.ConfigName		= nil
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar[ "torque" ] 		= "3000"
TOOL.ClientConVar[ "friction" ] 	= "1"
TOOL.ClientConVar[ "nocollide" ] 	= "1"
TOOL.ClientConVar[ "forcelimit" ] 	= "0"
TOOL.ClientConVar[ "fwd" ] 			= "1"	-- Forward
TOOL.ClientConVar[ "bck" ] 			= "-1"	-- Back
TOOL.ClientConVar[ "stop" ] 		= "0"	-- Stop
TOOL.ClientConVar[ "model" ] 		= "models/props_vehicles/carparts_wheel01a.mdl"
TOOL.ClientConVar[ "rx" ] 			= "90"
TOOL.ClientConVar[ "ry" ] 			= "0"
TOOL.ClientConVar[ "rz" ] 			= "90"


-- Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then
	language.Add( "Tool_petrol_wheel_name", "Petrol Wheel Tool (wire)" )
    language.Add( "Tool_petrol_wheel_desc", "Attaches a petrol-consuming wheel to something." )
    language.Add( "Tool_petrol_wheel_0", "Click on a prop to attach a wheel." )
	
	language.Add( "PetrolWheelTool_group", "Input value to go forward:" )
	language.Add( "PetrolWheelTool_group_reverse", "Input value to go in reverse:" )
	language.Add( "PetrolWheelTool_group_stop", "Input value for no acceleration:" )
	language.Add( "PetrolWheelTool_group_desc", "All these values need to be different." )
	
	language.Add( "undone_PetrolWheel", "Undone Petrol Wheel" )
	language.Add( "Cleanup_pterol_wheels", "Petrol Wheels" )
	language.Add( "Cleaned_pterol_wheels", "Cleaned up all Petrol Wheels" )
	language.Add( "SBoxLimit_pterol_wheels", "You've reached the pterol wheels limit!" )

end

if (SERVER) then
    CreateConVar('sbox_maxpetrol_wheels', 20)
	resource.AddFile("settings/controls/petrol_wheel.txt")
end 

cleanup.Register( "petrol_wheels" )

/*---------------------------------------------------------
   Places a wheel
---------------------------------------------------------*/
function TOOL:LeftClick( trace )

	if ( trace.Entity and trace.Entity:IsPlayer() ) then return false end
	
	-- If there's no physics object then we can't constraint it!
	if ( SERVER and !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()

	if ( !self:GetSWEP():CheckLimit( "petrol_wheels" ) ) then return false end

	local targetPhys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	-- Get client's CVars
	local torque		= self:GetClientNumber( "torque" )
	local friction 		= self:GetClientNumber( "friction" )
	local nocollide		= self:GetClientNumber( "nocollide" )
	local limit			= self:GetClientNumber( "forcelimit" )
	local model			= self:GetClientInfo( "model" )
	
	local fwd			= self:GetClientNumber( "fwd" )
	local bck			= self:GetClientNumber( "bck" )
	local stop			= self:GetClientNumber( "stop" )
	
	if ( !util.IsValidModel( model ) ) then return false end
	if ( !util.IsValidProp( model ) ) then return false end
	
	if ( fwd == stop or bck == stop or fwd == bck ) then return false end
	
	
	-- Create the wheel
	local wheelEnt = MakePetrolWheel( ply, trace.HitPos, Angle(0,0,0), model, nil, nil, nil, fwd, bck, stop, toggle )
	
	
	-- Make sure we have our wheel angle
	self.wheelAngle = Angle( tonumber(self:GetClientInfo( "rx" )), tonumber(self:GetClientInfo( "ry" )), tonumber(self:GetClientInfo( "rz" )) )
	
	local TargetAngle = trace.HitNormal:Angle() + self.wheelAngle	
	wheelEnt:SetAngles( TargetAngle )
	
	local CurPos = wheelEnt:GetPos()
	local NearestPoint = wheelEnt:NearestPoint( CurPos - (trace.HitNormal * 512) )
	local wheelOffset = CurPos - NearestPoint
		
	wheelEnt:SetPos( trace.HitPos + wheelOffset + trace.HitNormal )
	
	-- Wake up the physics object so that the entity updates
	wheelEnt:GetPhysicsObject():Wake()
	
	local TargetPos = wheelEnt:GetPos()
			
	-- Set the hinge Axis perpendicular to the trace hit surface
	local LPos1 = wheelEnt:GetPhysicsObject():WorldToLocal( TargetPos + trace.HitNormal )
	local LPos2 = targetPhys:WorldToLocal( trace.HitPos )
	
	local constraint, axis = constraint.Motor( wheelEnt, trace.Entity, 0, trace.PhysicsBone, LPos1,	LPos2, friction, torque, 0, nocollide, false, ply, limit )
	
	undo.Create("PetrolWheel")
	undo.AddEntity( axis )
	undo.AddEntity( constraint )
	undo.AddEntity( wheelEnt )
	undo.SetPlayer( ply )
	undo.Finish()
	
	ply:AddCleanup( "petrol_wheels", axis )
	ply:AddCleanup( "petrol_wheels", constraint )
	ply:AddCleanup( "petrol_wheels", wheelEnt )
	
	wheelEnt:SetMotor( constraint )
	wheelEnt:SetDirection( constraint.direction )
	wheelEnt:SetAxis( trace.HitNormal )
	wheelEnt:SetToggle( toggle )
	wheelEnt:DoDirectionEffect()
	wheelEnt:SetBaseTorque( torque )

	return true

end


/*---------------------------------------------------------
   Apply new values to the wheel
---------------------------------------------------------*/
function TOOL:RightClick( trace )

	if ( trace.Entity and trace.Entity:GetClass() ~= "petrol_wheel" ) then return false end
	if (CLIENT) then return true end
	
	local wheelEnt = trace.Entity
	
	-- Only change your own wheels..
	if ( wheelEnt:GetTable():GetPlayer():IsValid() and
	     wheelEnt:GetTable():GetPlayer() ~= self:GetOwner() ) then
		 
		 return false 
		 
	end

	-- Get client's CVars
	local torque		= self:GetClientNumber( "torque" )
	local toggle		= self:GetClientNumber( "toggle" ) ~= 0
	local fwd			= self:GetClientNumber( "fwd" )
	local bck			= self:GetClientNumber( "bck" )
	local stop			= self:GetClientNumber( "stop" )
		
	wheelEnt:GetTable():SetTorque( torque )
	wheelEnt:GetTable():SetFwd( fwd )
	wheelEnt:GetTable():SetBck( bck )
	wheelEnt:GetTable():SetStop( stop )

	return true

end

if ( SERVER ) then

	/*---------------------------------------------------------
	   For duplicator, creates the wheel.
	---------------------------------------------------------*/
	function MakePetrolWheel( pl, Pos, Ang, Model, Vel, aVel, frozen, fwd, bck, stop, toggle, direction, Axis, Data )
		
		if ( !pl:CheckLimit( "petrol_wheels" ) ) then return false end
		
		local wheel = ents.Create( "petrol_wheel" )
		if ( !wheel:IsValid() ) then return end
		
		wheel:SetModel( Model )
		wheel:SetPos( Pos )
		wheel:SetAngles( Ang )
		wheel:Spawn()
		
		wheel:SetPlayer( pl )
		
		duplicator.DoGenericPhysics( wheel, pl, Data )
		
	
		wheel.model = model
		wheel.fwd = fwd
		wheel.bck = bck
		wheel.stop = stop
		
		wheel:SetFwd( fwd )
		wheel:SetBck( bck )
		wheel:SetStop( stop )

		if ( axis ) then
			wheel.Axis = axis
		end
		
		if ( direction ) then
			wheel:SetDirection( direction )
		end
		
		if ( toggle ) then
			wheel:SetToggle( toggle )
		end
		
		
		
		pl:AddCount( "petrol_wheels", wheel )
		
		return wheel
		
	end

	duplicator.RegisterEntityClass( "gmod_petrol_wheel", MakePetrolWheel, "Pos", "Ang", "model", "Vel", "aVel", "frozen", "fwd", "bck", "stop", "Axis", "Data" )
	
	
end

function TOOL:UpdateGhostWireWheel( ent, player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	
	local tr 	= util.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if ( trace.Entity:IsPlayer() ) then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Ang = trace.HitNormal:Angle() + self.wheelAngle
	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - (trace.HitNormal * 512) )
	local WheelOffset = CurPos - NearestPoint
	
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos + trace.HitNormal + WheelOffset )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )
	
end

/*---------------------------------------------------------
   Maintains the ghost wheel
---------------------------------------------------------*/
function TOOL:Think()

	if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() ~= self:GetClientInfo( "model" )) then
		self.wheelAngle = Angle( tonumber(self:GetClientInfo( "rx" )), tonumber(self:GetClientInfo( "ry" )), tonumber(self:GetClientInfo( "rz" )) )
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostWireWheel( self.GhostEntity, self:GetOwner() )
	
end
