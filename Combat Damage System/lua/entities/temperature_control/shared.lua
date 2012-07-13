ENT.Type 		= "anim"
ENT.Base 		= "base_rd_entity"
ENT.PrintName		= "Temperature Regulator"
ENT.Author		= "SnakeSVx"
ENT.Contact		= "stijn.sv@gmail.com"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

list.Set( "LSEntOverlayText" , "temperature_control", {num = 2, strings = {ENT.PrintName.."\nEnergy: ", "\nCoolant: "},resnames = {"energy", "coolant"}} )

RD2_AddStoolItem('cdstech', ENT.PrintName, 'models/props_c17/consolebox01a.mdl', 'temperature_control')
