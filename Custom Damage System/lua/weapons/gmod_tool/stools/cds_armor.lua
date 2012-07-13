
include("CAF/Addons/Shared/cds_damage_info.lua");
local ArmorTypes = ArmorTypes; --Store localy so it can't be modified

TOOL.Mode		= "cds_armor"
TOOL.Category		= "Custom Damage System"
TOOL.Name		= "#Armor Stool"
TOOL.Command		= nil
TOOL.ConfigName	= ''

if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end

if ( CLIENT ) then
	language.Add( "Tool_cds_armor_name", "CDS Armor Selection Tool" )
	language.Add( "Tool_cds_armor_desc", "Sets the armor values for a specific Entity. The Modifiers can only be a total of 1.0" )
	language.Add( "Tool_cds_armor_0", "Left Click: Apply the settings to the prop!" )
	language.Add( "cds_armor_Density", "Armor Density:" )
	language.Add( "cds_armor_Kinetic", "Kinetic Modifier:" )
	language.Add( "cds_armor_Shock", "Shock Modifier:" )
	language.Add( "cds_armor_Energy", "Energy Modifier:" )
end

TOOL.ClientConVar[ "density" ] = "1"
TOOL.ClientConVar[ "kinetic" ] = "0.33"
TOOL.ClientConVar[ "shock" ] = "0.33"
TOOL.ClientConVar[ "energy" ] = "0.33"

function TOOL:LeftClick( trace )
	if ( not trace.Entity or (trace.Entity:IsValid() and trace.Entity:IsPlayer() )) then return end
	if ( CLIENT ) then return true end
	
	CAF.GetAddon("Custom Damage System").setArmor(trace.Entity, self:GetClientNumber( "density" ) , self:GetClientNumber( "shock" ) , self:GetClientNumber( "kinetic" ) , self:GetClientNumber( "energy" ) )

	self:ClearObjects()	--clear objects

	--success!
	return true
end

function TOOL:RightClick( trace )
	if ( not trace.Entity or (trace.Entity:IsValid() and trace.Entity:IsPlayer() )) then return end
	if ( CLIENT ) then return true end
	local ent = trace.Entity;
	local armor = ent:getCustomArmor();
	local phys = ent:GetPhysicsObject();
	if not armor then
		Msg("No Armor Found\n");
	else
		Msg("Printing CDS Armor Data for Entity\n");
		Msg("MaxHealth "..ent:GetMaxHealth().."\n");
		Msg("Health "..ent:Health().."\n");
		Msg("Density "..armor:GetArmor().."\n");
		Msg("Shock "..armor:GetArmormultiplier("Shock").."\n");
		Msg("Kinetic "..armor:GetArmormultiplier("Kinetic").."\n");
		Msg("Energy "..armor:GetArmormultiplier("Energy").."\n");
		if phys:IsValid() then
			Msg("Volume "..phys:GetVolume().."\n");
			Msg("Mass "..phys:GetMass().."\n");
		end
	end
	self:ClearObjects() --clear objects

	--success!
	return true
end

function TOOL:Think( ) 
	--Do value checks here?
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#Tool_cds_armor_name", Description	= "#Tool_cds_armor_desc" }  )
	
	local p = vgui.Create( "DPanel" )
	p:SetTall( 200 )
	
	local lbl = vgui.Create("DLabel", p);
	lbl:SetPos(10 , 0 );
	lbl:SetText("Select Preset:");
	lbl:SetWide(150);
	
	local selection = vgui.Create("DMultiChoice", p)
	selection:SetPos(10, 20);
	selection:SetWide(150);
	for k, v in pairs(ArmorTypes) do
		selection:AddChoice( k ) 
	end
	
	local nsshock = vgui.Create("DNumSlider", p); --35 height
	local nskinetic = vgui.Create("DNumSlider", p); --35 height
	local nsenergy = vgui.Create("DNumSlider", p); --35 height
	local nsdensity = vgui.Create("DNumSlider", p); --35 height
	
	nsshock:SetText("#cds_armor_Shock");
	nsshock:SetPos(10, 40);
	nsshock:SetConVar( "cds_armor_shock" )
	nsshock:SetDecimals( 2 )
	nsshock:SetMinMax( 0, 1);
	nsshock:SetWide(150);
	
	nskinetic:SetText("#cds_armor_Kinetic");
	nskinetic:SetPos(10, 80);
	nskinetic:SetConVar( "cds_armor_kinetic" )
	nskinetic:SetDecimals( 2 )
	nskinetic:SetMinMax( 0, 1);
	nskinetic:SetWide(150);
	
	nsenergy:SetText("#cds_armor_Energy");
	nsenergy:SetPos(10, 120);
	nsenergy:SetConVar( "cds_armor_energy" )
	nsenergy:SetDecimals( 2 )
	nsenergy:SetMinMax( 0, 1);
	nsenergy:SetWide(150);
	
	nsdensity:SetText("#cds_armor_Density");
	nsdensity:SetPos(10, 160);
	nsdensity:SetConVar( "cds_armor_density" )
	nsdensity:SetDecimals( 0 )
	nsdensity:SetMinMax( 1, 5);
	nsdensity:SetWide(150);
	
	local function CheckValues()
		local ns, nk,ne = nsshock:GetValue(), nskinetic:GetValue(), nsenergy:GetValue();
		if ns + nk + ne > 1 then
			if ns > 1 then
				ns = 1
				nsshock:SetValue(ns)
			elseif ns < 0 then
				ns = 0;
				nsshock:SetValue(ns)
			end
			if ns + nk > 1 then
				nk = nk - ns;
				if nk > 0 then
					nk = 0;
				end
				nskinetic:SetValue(nk)
			end
			if ns + nk + ne > 1 then
				ne = 1 - nk - ns;
				nsenergy:SetValue(ne)
			end
		end
	end
	
	function nsshock:OnValueChanged( val )
		CheckValues()
	end
	
	function nskinetic:OnValueChanged( val )
		CheckValues()
	end
	
	function nsenergy:OnValueChanged( val )
		CheckValues()
	end
	
	function selection:OnSelect( index, value, data ) 
		
	end
	
	panel:AddPanel(p);
	

	
end

