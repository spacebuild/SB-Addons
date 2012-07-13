TOOL.Category = '(Combat Damage System)'
TOOL.Name = '#CDS Munitions'
TOOL.Command = nil
TOOL.ConfigName = ''

-- Use LS tab?
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

if ( CLIENT ) then
	language.Add( 'Tool_'..TOOL.Mode..'_name', 'Combat Damage System Munitions' )
	language.Add( 'Tool_'..TOOL.Mode..'_desc', 'Create Munitions attached to any surface.' )
	language.Add( 'Tool_'..TOOL.Mode..'_0', 'Left-Click: Spawn a box of munitions.  Right-Click: Repair box.' )

	language.Add( 'Undone_'..TOOL.Mode, 'Munitions Undone' )
	language.Add( 'Cleanup_'..TOOL.Mode, 'CDS: Munitions' )
	language.Add( 'Cleaned_'..TOOL.Mode, 'Cleaned up all CDS: Munitions' )
	language.Add( 'sboxlimit_'..TOOL.Mode, 'Maximum CDS: Munitions Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

-- Register our tool and all the fillings = RD2_ToolRegister( TOOL, Models_List, "custom callback", TOOL.Mode, "sbox limit" )
RD2_ToolRegister( TOOL, nil, nil, TOOL.Mode, 24 )
