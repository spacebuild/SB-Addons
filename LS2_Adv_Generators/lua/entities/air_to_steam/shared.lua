ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName 	= "Air-To-Steam generator"

list.Set( "LSEntOverlayText" , "air_to_steam", {HasOOO = true, num = 2, strings = {ENT.PrintName.."\n","\nEnergy: ","\nAir: "},resnames = {"energy", "air"}} )
