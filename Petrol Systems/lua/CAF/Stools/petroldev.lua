if not CAF or not CAF.GetAddon("Resource Distribution") then return end

TOOL.Category			= "Petrol"
TOOL.Name				= "#PetrolDevices"

TOOL.DeviceName			= "Petrol Device"
TOOL.DeviceNamePlural	= "Petrol Devices"
TOOL.ClassName			= "petrol_devices"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "batterycharger"
TOOL.CCVar_sub_type		= "normal"
TOOL.CCVar_model		= "models/props_c17/consolebox05a.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "rddevices"
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


local function petrol_device_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
end

TOOL.Devices = {
	batterycharger = {
		Name	= "Battery Charger",
		type	= "batterycharger",
		class	= "batterycharger",
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_c17/consolebox05a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_device_func,
			},
		},
	},
	batteryinverter = {
		Name	= "Battery Inverter",
		type	= "batteryinverter",
		class	= "batteryinverter",
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_c17/consolebox03a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_device_func,
			},
		},
	},
	crackingtower = {
		Name	= "Cracking Tower",
		type	= "crackingtower",
		class	= "crackingtower",
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_canal/bridge_pillar02.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_device_func,
			},
		},
	},
	oildistil = {
		Name	= "Oil Distiller",
		type	= "oildistil",
		class	= "oildistil",
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_c17/furnitureboiler001a.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= petrol_device_func,
			},
		},
	},
}
