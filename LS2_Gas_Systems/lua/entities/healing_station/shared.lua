ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName 	= "Health Dispenser"

list.Set( "LSEntOverlayText" , "healing_station", {num = 3, strings = {ENT.PrintName.."\nAir: ","\nEnergy: ","\nCoolant: "},resnames = {"air","energy","coolant"}} )
