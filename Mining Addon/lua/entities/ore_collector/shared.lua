ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"

list.Set( "LSEntOverlayText" , "ore_collector", {
func = function( ent )
	return "Ore Collector "..ent.OverlayTextOOO.."\nRange: "..ent.Entity:GetNetworkedInt( 1 ).."\nEnergy: "..ent.Entity:GetResourceAmount( "energy" )
end} )
