if not CAF or not CAF.GetAddon("Resource Distribution") then return end

TOOL.Category			= "Petrol"
TOOL.Name			= "#PetrolStorage"

TOOL.DeviceName			= "Petrol Storage"
TOOL.DeviceNamePlural		= "Petrol Storage"
TOOL.ClassName			= "petrol_storage"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "battery"
TOOL.CCVar_sub_type		= "default"
TOOL.CCVar_model		= "models/items/car_battery01.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "rdstorage"
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


local function petrol_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
	local volume_mul = 1 
	local base_volume = 4084
	local base_mass = 20
	local base_health = 150
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	local res = ""
	if type == "crudetank" then
		res = "Crude Oil"
	elseif type == "oiltank" then
		res = "Oil"
	elseif type == "petroltank" then
		res = "Petrol"
	end
	CAF.GetAddon("Resource Distribution").AddResource(ent, res, math.Round(4000 * volume_mul))
	ent.MAXRESOURCE = math.Round(4000 * volume_mul)
	local mass = math.Round(base_mass * volume_mul)
	ent.mass = mass
	local maxhealth = math.Round(base_health * volume_mul)
	return mass, maxhealth 
end

TOOL.Devices = {
	battery = {
		Name	= "Battery",
		type	= "battery",
		class	= "battery",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/items/car_battery01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
		},
	},
	crudetank = {
		Name	= "Crude Oil Storage",
		type	= "crudetank",
		class	= "crudetank",
		devices = {
			default = {
				Name	= "Tank",
				model	= "models/props_wasteland/coolingtank01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
			small = {
				Name	= "Barrel",
				model	= "models/props_c17/oildrum001.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
		},
	},
	oiltank = {
		Name	= "Oil tank",
		type	= "oiltank",
		class	= "oiltank",
		devices = {
			default = {
				Name	= "Tank",
				model	= "models/props_wasteland/horizontalcoolingtank04.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
			small = {
				Name	= "Can",
				model	= "models/props_junk/gascan001a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
			medium = {
				Name	= "Barrel",
				model	= "models/props_c17/oildrum001.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
		},
	},
	petroltank = {
		Name	= "Petrol Tank",
		type	= "petroltank",
		class	= "petroltank",
		devices = {
			default = {
				Name	= "Tank",
				model	= "models/props_wasteland/horizontalcoolingtank04.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
			small = {
				Name	= "Can",
				model	= "models/props_junk/metalgascan.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
			medium = {
				Name	= "Barrel",
				model	= "models/props_c17/oildrum001_explosive.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
		},
	},
	thecache = {
		Name	= "The Everything Cache",
		type	= "thecache",
		class	= "thecache",
		devices = {
			default = {
				Name	= "Default",
				model	= "models/props_wasteland/kitchen_fridge001a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_storage_func,
			},
		},
	},
}