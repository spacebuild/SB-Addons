if not CAF or not CAF.GetAddon("Resource Distribution") then return end

TOOL.Category			= "CDS"
TOOL.Name				= "#Test_Stuff"

TOOL.DeviceName			= "Test"
TOOL.DeviceNamePlural	= "Tests"
TOOL.ClassName			= "test_cds_stuff"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "test_bomb"
TOOL.CCVar_sub_type		= "test"
TOOL.CCVar_model		= "models/props_wasteland/laundry_washer003.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "test_cds_stuff"
TOOL.Limit				= 30

CAFToolSetup.SetLang("CDS Test Stuff","Create CDS Test stuff attached to any surface.","Left-Click: Spawn a Device.  Reload: Repair Device.")


TOOL.ExtraCCVars = {

}

function TOOL.ExtraCCVarsCP( tool, panel )
	
end

function TOOL:GetExtraCCVars()
	local Extra_Data = {}

	return Extra_Data
end


local function gas_generator_func(ent,type,sub_type,devinfo,Extra_Data,ent_extras) 
	local mass = 100
	local maxhealth = 50
	return mass, maxhealth 
end

TOOL.Devices = {
	test_bomb = {
		Name	= "Test Bomb 1",
		type	= "test_bomb",
		class	= "test_bomb",
		devices = {
			test = {
				Name	= "Default",
				model	= "models/props_wasteland/laundry_washer003.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= gas_generator_func,
			},
		},
	},
	test_weapon = {
		Name	= "Test Weapon 1",
		type	= "test_weapon",
		class	= "test_weapon",
		devices = {
			test = {
				Name	= "Default",
				model	= "models/props_wasteland/laundry_washer003.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= gas_generator_func,
			},
		},
	},
}


	
	
	
