ArmorTypes = {
	Generic	=	{
		Name =	"Generic - Alloy",
		Description	= 	"This is the standard armor/shielding for every prop.\n It is balanced accross the 3 major types of damage",
		Multipliers	=	{
				Shock			= 	0.33,
				Kinetic			= 	0.33,
				Energy			= 	0.33
		}
	},
	Reflective	= 	{
		Name			=	"Speciality - Reflective",
		Description		= 	"This is a specialized armor focused on reducing damage from Energy based weapons.",
		Multipliers		=	{
				Shock		= 	0,
				Kinetic		= 	0,
				Energy		= 	1
		}
	},
	Baffle	= 	{
		Name			=	"Speciality - Baffle",
		Description		= 	"This is a specialized armor focused on reducing damage from Kinetic based weapons.",
		Multipliers		=	{
				Shock		= 	0,
				Kinetic		= 	1,
				Energy		= 	0
		}
	},
	Honeycomb	=	{
		Name			=	"Speciality - Honeycomb",
		Description		= 	"This is a specialized armor focused on reducing damage from Shock based weapons.",
		Multipliers		=	{
				Shock		= 	1,
				Kinetic		= 	0,
				Energy		= 	0
		}
	},
	Ceramic	=	{
		Name			=	"Composite - Ceramic",
		Description		= 	"This armor is balanced between protecting against Shock and Energy Damage.",
		Multipliers		=	{
				Shock		= 	0.5,
				Kinetic		= 	0,
				Energy		= 	0.5
		}
	},
	Steel	=	{
		Name			=	"Composite - Steel",
		Description		= 	"This armor is balanced between protecting against Shock and Kinetic Damage.",
		Multipliers		=	{
				Shock		= 	0.5,
				Kinetic		= 	0.5,
				Energy		= 	0
		}
	},
	Emissive	=	{
		Name			=	"Composite - Emissive",
		Description	= 	"This armor is balanced between protecting against Kinetic and Energy Damage.",
		Multipliers	=	{
				Shock		= 	0,
				Kinetic		= 	0.5,
				Energy		= 	0.5
		}
	}
}

ArmorWeights = {
	Shock	= 	0.75,
	Kinetic	= 	0.5,
	Energy	= 	0.25
}

local customAttack = {}
customAttack.__index = customAttack

function customAttack:GetPiercing()
	return self.Pierce or 0
end

function customAttack:SetPiercing(num)
	self.Pierce = num or 0
	return self.Pierce
end

function customAttack:GetAttack(dtype)
	if not self.Attack then self.Attack = {} end
	return self.Attack[dtype] or 0
end

function customAttack:SetAttack(dtype,amt)
	if not self.Attack then self.Attack = {} end
	self.Attack[dtype] = amt or 0
end

function customAttack:GetAttacker()
	return self.Attacker or NULL
end

function customAttack:SetAttacker(ent)
	self.Attacker = ent
end

function customAttack:GetWeaponEntity()
	return self.WepEnt or NULL
end

function customAttack:SetWeaponEntity(ent)
	self.WepEnt = ent
end

function GetNewCustomAttack()
	local cattack = {}
	return setmetatable(cattack,customAttack)
end 





local armorObj = {}
armorObj.__index = armorObj

function armorObj:GetArmor()
	return self.Armor or 0
end

function armorObj:SetArmor(num)
	self.Armor = num or 0
end

function armorObj:GetArmormultiplier(dtype)
	if not self.AMul then self.AMul = {} end
	return self.AMul[dtype] or 0
end

function armorObj:setArmorMultiplier(dtype,amt)
	if not self.AMul then self.AMul = {} end
	self.AMul[dtype] = amt or 0
end

function GetNewArmorObject()
	local armor = {}
	return setmetatable(armor,armorObj)
end 



local Entity = FindMetaTable("Entity")
function Entity:getCustomArmor()
	return self.__CustomArmor or GetNewArmorObject()
end 

function Entity:setCustomArmor(armorObj)
	self.__CustomArmor = armorObj or GetNewArmorObject()
end 