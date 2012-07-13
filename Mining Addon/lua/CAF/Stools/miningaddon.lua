TOOL.Category			= "Asteroid Mining Addon"
TOOL.Name				= "Asteroid Mining Addon Devices"

TOOL.DeviceName			= "Asteroid Mining Addon Device"
TOOL.DeviceNamePlural	= "Asteroid Mining Addon Devices"
TOOL.ClassName			= "mining"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "mine"
TOOL.CCVar_sub_type		= "normal"
TOOL.CCVar_model		= "models/props_trainstation/TrackLight01.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "mining"
TOOL.Limit				= 10

RD2ToolSetup.SetLang("Asteroid Mining Addon Devices","Create Mining Devices.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {
}

function TOOL.ExtraCCVarsCP( tool, panel )
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}
	return Extra_Data
end

local function resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume() or mass*20
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "naquadah", math.Round(vol / 2))
	CAF.GetAddon("Resource Distribution").AddResource(ent, "titanium", math.Round(vol / 2))
	return mass, maxhealth
end

local function refined_resource_storage_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	local phys = ent:GetPhysicsObject()
	local vol = phys:GetVolume() or mass*20
	vol = math.Round(vol)
	CAF.GetAddon("Resource Distribution").AddResource(ent, "refined naquadah", math.Round(vol / 4))
	CAF.GetAddon("Resource Distribution").AddResource(ent, "refined titanium", math.Round(vol / 4))
	return mass, maxhealth
end

local function mining_laser_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	return mass, maxhealth
end

local function resource_refinery_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	local vol = math.Round(ent:GetPhysicsObject():GetVolume()) or 20000
	ent:SetConversionSpeed(vol/1000)
	return mass, maxhealth
end

local function asteroid_scanner_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
	local mass = 100
	local maxhealth = 100
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	return mass, maxhealth
end

TOOL.Devices = {
	mining_laser = {
		Name	= "Mining Laser",
		type	= "mining_laser",
		class	= "mining_laser",
		func	= mining_laser_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_trainstation/TrackLight01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "CE Mining Laser Mk1",
				model	= "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "mining_laser",
	},
	
	resource_storage = {
		Name	= "Resource Storage",
		type	= "resource_storage",
		class	= "resource_storage",
		func	= resource_storage_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/ce_ls3additional/resource_cache/resource_cache_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "CE Small Storage",
				model	= "models/ce_miningmodels/miningstorage/storage_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "resource_storage",
	},
	resource_refinery = {
		Name	= "Resource Refinery",
		type	= "resource_refinery",
		class	= "resource_refinery",
		func	= resource_refinery_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_wasteland/kitchen_stove002a.mdl", --Mmm.. needs custom model.
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Customz = {
				Name	= "CE Shadow Series Mk1 Refinery",
				model	= "models/ce_miningmodels/miner_bodies/shadowseries/shadowseries_mk1.mdl", --Not sure if CE meant this to be a refinery, but ah well. ;)
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "resource_refinery",
	},
	refined_resource_storage = {
		Name	= "Refined Resource Storage",
		type	= "refined_resource_storage",
		class	= "resource_storage",
		func	= refined_resource_storage_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/ce_ls3additional/resource_cache/resource_cache_large.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
			Custom1 = {
				Name	= "CE Small Storage",
				model	= "models/ce_miningmodels/miningstorage/storage_small.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "resource_storage",
	},
	asteroid_scanner = {
		Name	= "Asteroid Scanner",
		type	= "asteroid_scanner",
		class	= "asteroid_scanner",
		func	= asteroid_scanner_func,
		devices = {
			normal = {
				Name	= "Default",
				model	= "models/props_combine/combine_mine01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
			},
		},
		['class'] = "asteroid_scanner",
	},
}