AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	-- Check we have a valid trace
	if ( !tr.Hit ) then return end
	
	return MakeOilDrill( ply, Angle(0,0,0), tr.HitPos, true )
	
end
