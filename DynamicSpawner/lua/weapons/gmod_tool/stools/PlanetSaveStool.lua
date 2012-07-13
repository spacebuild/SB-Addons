
TOOL.Category = 'Dynamic Planets'
TOOL.Name = '#Tool_PlanetSaveStool_name'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end

if ( CLIENT ) then
	language.Add( "Tool_PlanetSaveStool_name", "Dynamic Planet Saver" )
	language.Add( "Tool_PlanetSaveStool_desc", "Saves planets you've contructed for the dynamic planet addon." )
	language.Add( "Tool_PlanetSaveStool_0", "Left Click to select the prop whose position will be the center and save." )
	
	TOOL.ClientConVar[ "slider_num" ] = 0
	TOOL.ClientConVar[ "cmbo_choice" ] = 0
	TOOL.ClientConVar[ "model_name" ] = ""
	TOOL.ClientConVar[ "model_skin" ] = 0
	TOOL.ClientConVar[ "planet_name" ] = ""
	TOOL.ClientConVar[ "only_inhabitable" ] = 0
	TOOL.ClientConVar[ "only_habitable" ] = 0
	
end

local ModelTable = {"models/Levybreak/Planets/planet1.mdl"}

local AllowedClasses = {"prop_physics","prop_dynamic","gmod_prop"}

local function FindPropsAndSave(ent,radius,name,habtype)
	local tbl = {}
	tbl["Settings"] = {}
	tbl["Settings"].Radius = radius
	tbl["Settings"].Name = name
	if habtype then tbl["Settings"].Habtype = habtype end
	local i = 0
	for k,v in pairs(ents.FindInSphere(ent:GetPos(),radius)) do
		if table.HasValue(AllowedClasses, v:GetClass()) then
			i = i+1
			tbl[i] = {}
			tbl[i].Ang = v:GetAngles()
			tbl[i].Pos = v:GetPos()-ent:GetPos()
			tbl[i].Skin = v:GetSkin()
			tbl[i].Model = v:GetModel()
			tbl[i].Color = Color(v:GetColor())
			local matl = v:GetMaterial()
			v:SetMaterial("")
			if v:GetMaterial() ~= matl then
				tbl[i].Matl = matl
			end
			v:SetMaterial(matl)
		end
	end
	tbl[i+1] = {}
	tbl[i+1].Ang = Angle(0,0,0)
	tbl[i+1].Pos = Vector(0,0,0)
	tbl[i+1].Skin = GetConVarNumber("PlanetSaveStool_model_skin")
	tbl[i+1].Model = GetConVarString("PlanetSaveStool_model_name")
	tbl[i+1].Color = Color(255,255,255,255)
	file.Write("SBEP/Spawnfiles/generic/"..name..".txt",glon.encode(tbl))
end


function TOOL:LeftClick( tr )

	if tr.HitWorld or not tr.Entity:IsValid() then return false end

	if CLIENT then return true end

	if self:GetClientNumber("cmbo_choice") == 0 then
		if self:GetClientNumber("only_habitable") == 1 then
			FindPropsAndSave(tr.Entity,self:GetClientNumber("slider_num"),self:GetClientInfo("planet_name"),"Habitable")
		elseif self:GetClientNumber("only_inhabitable") == 1 then
			FindPropsAndSave(tr.Entity,self:GetClientNumber("slider_num"),self:GetClientInfo("planet_name"),"InHabitable")
		else
			FindPropsAndSave(tr.Entity,self:GetClientNumber("slider_num"),self:GetClientInfo("planet_name"))
		end
	elseif self:GetClientNumber("cmbo_choice") == 1 then
		if self:GetClientNumber("only_habitable") == 1 then
			FindPropsAndSave(tr.Entity,3000,self:GetClientInfo("planet_name"),"Habitable")
		elseif self:GetClientNumber("only_inhabitable") == 1 then
			FindPropsAndSave(tr.Entity,3000,self:GetClientInfo("planet_name"),"InHabitable")
		else
			FindPropsAndSave(tr.Entity,3000,self:GetClientInfo("planet_name"))
		end
	end
	return true
end

function TOOL:RightClick( tr )
	if CLIENT then return false end
	
	return false
end

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Text = "#Tool_PlanetSaveStool_name", Description	= "#Tool_PlanetSaveStool_desc" }  )
	
	
	local cmbo = {}
	cmbo.Label = "Size"
	cmbo.MenuButton = 0
	cmbo.Options = {}
	cmbo.Options["3000 Units"] = {PlanetSaveStool_cmbo_choice = 1}
	cmbo.Options["No Atmosphere Model (Slider Value)"] = {PlanetSaveStool_cmbo_choice = 0}

	CPanel:AddControl( "ComboBox", cmbo)
	
	CPanel:AddControl( "Slider", { Label = "Fallback Size", Command = "PlanetSaveStool_slider_num", min = 0, max = 10000})
	

	local prpsel = {}
	prpsel.Label = "Model"
	prpsel.ConVar = "PlanetSaveStool_model_name"
	local crap = CPanel:AddControl( "PropSelect", prpsel)
	for k,v in ipairs(ModelTable) do
		crap:AddModel(v)
	end
	
	CPanel:AddControl( "Slider", { Label = "Model Skin", Command = "PlanetSaveStool_model_skin", min = 0, max = 12})
	
	CPanel:AddControl( "TextBox", { Label = "Planet Name", Command = "PlanetSaveStool_planet_name", MaxLength = 128 } )
	
	CPanel:AddControl( "CheckBox", { Label = "Only Habitable", Command = "PlanetSaveStool_only_habitable" } )
	
	CPanel:AddControl( "CheckBox", { Label = "Only InHabitable", Command = "PlanetSaveStool_only_inhabitable" } )
	
	CPanel:AddControl( "Label", { Text = "1.Spawn Landform from spawnmenu\n2.Decorate with other props\n3.If using a preset landform, select\n it's radius from the combo box.\nIf not, select No Atmosphere Model and\n set the slider to the desired value\n4.Select Atmosphere Model\n5.Select Atmosphere Skin\n6.Name the planet\n7. Left click on the landform\n8.Congratulations, your planet is now saved!"})
end




