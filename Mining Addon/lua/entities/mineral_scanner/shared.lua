ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"

ENT.HasOOO = true

list.Set( "LSEntOverlayText" , "mineral_scanner", {
func = function( ent )
	return "Mineral Scanner "..ent.OverlayTextOOO.."\nRange: "..ent.Entity:GetNetworkedInt( 1 ).."\nEnergy: "..ent.Entity:GetResourceAmount( "energy" )
end} )
