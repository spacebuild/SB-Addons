ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName 	= "Air-To-Coolant"

list.Set( "LSEntOverlayText" , "air_to_coolant", {HasOOO = true, num = 1, strings = {ENT.PrintName.."\n","\nAir: ","\nEnergy: "},resnames = {"air","energy"}} )
