TOOL.Category			= "Blackhole"
TOOL.Name				= "#Blackholecache"

TOOL.DeviceName			= "Blackhole_cache"
TOOL.DeviceNamePlural	= "Blachole_caches"
TOOL.ClassName			= "blackholecaches"

TOOL.DevSelect			= true
TOOL.CCVar_type			= "black_hole_cache"
TOOL.CCVar_sub_type		= "Medium"
TOOL.CCVar_model		= "models/Combine_Helicopter/helicopter_bomb01.mdl"

TOOL.Limited			= true
TOOL.LimitName			= "blackholecaches"
TOOL.Limit				= 30
TOOL.AdminOnly 			= true

CAFToolSetup.SetLang("Blackhole Cache","Create a Blackhole cache attached to any surface.","Left-Click: Spawn a Device.")

function TOOL.EnableFunc()
	if not CAF then
		return false;
	end
	if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then
		return false;
	end
	return true;
end

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


local function black_hole_cache(ent,type,sub_type,devinfo,Extra_Data,ent_extras)
end

TOOL.Devices = {
		black_hole_cache = {
		Name	= "Blackhole_cache",
		type	= "black_hole_cache",
		class	= "black_hole_cache",
		devices = {
			Medium = {
				Name	= "Default",
				model	= "models/Combine_Helicopter/helicopter_bomb01.mdl",
				skin	= 0,
				legacy	= false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				func	= black_hole_cache,
			},
		},
	},
}


	
	
	
