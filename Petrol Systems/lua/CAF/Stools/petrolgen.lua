if not CAF or not CAF.GetAddon("Resource Distribution") then return end

TOOL.Category			= "Petrol"
TOOL.Name				= "#PetrolGenerators"

TOOL.DeviceName			= "Petrol Generator"
TOOL.DeviceNamePlural	= "Petrol Generators"
TOOL.ClassName			= "petrol_generators"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "bigenergygen"
TOOL.CCVar_sub_type		= "default"
TOOL.CCVar_model		= "models/props_vehicles/generatortrailer01.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "rdgenerators"
TOOL.Limit				= 30

RD2ToolSetup.SetLang("Petrol Devices","Create Devices attached to any surface.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {
	extra_num = 0,
	extra_bool = 0,
}

function TOOL.ExtraCCVarsCP( tool, panel )
	panel:NumSlider( "Extra Number", "receptacles_extra_num", 0, 10, 0 )
	panel:CheckBox( "Extra Bool", "receptacles_extra_bool" )
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}
	Extra_Data.extra_num		= self:GetClientNumber("extra_num")
	Extra_Data.extra_bool		= self:GetClientNumber("extra_bool") == 1
	return Extra_Data
end


local function petrol_generator_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
end

local function petrol_drill_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
	local volume_mul = 1
	local base_volume = 2137039
	local base_mass = 25
	local base_health = 180
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	CAF.GetAddon("Resource Distribution").SupplyResource(ent, "Crude Oil", math.Round(2000 * volume_mul))
	ent.MAXRESOURCE = math.Round(2000 * volume_mul)
	local mass = math.Round(base_mass * volume_mul)
	ent.mass = mass
	local maxhealth = math.Round(base_health * volume_mul)
	return mass, maxhealth
end

TOOL.Devices = {
	bigenergygen = {
		Name	= "Energy Generator",
		type	= "bigenergygen",
		class	= "bigenergygen",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/props_vehicles/generatortrailer01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_generator_func,
			},
		},
	},
	bigcoolantgen = {
		Name	= "Coolant Generator",
		type	= "bigcoolantgen",
		class	= "bigcoolantgen",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/props_vehicles/generatortrailer01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_generator_func,
			},
		},
	},
	bighydrogen = {
		Name	= "Hydrogen Generator",
		type	= "bighydrogen",
		class	= "bighydrogen",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/props_vehicles/generatortrailer01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_generator_func,
			},
		},
	},
	bigairgen = {
		Name	= "Oxygen Generator",
		type	= "bigairgen",
		class	= "bigairgen",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/props_vehicles/generatortrailer01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_generator_func,
			},
		},
	},
	oildrill = {
		Name	= "Oil Drill",
		type	= "oildrill",
		class	= "oildrill",
		devices = {
			large = {
				Name	= "Large",
				model	= "models/props_combine/combinethumper001a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_drill_func,
			},
			small = {
				Name	= "Small",
				model	= "models/props_combine/combinethumper002.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_drill_func,
			},
		},
	},
}