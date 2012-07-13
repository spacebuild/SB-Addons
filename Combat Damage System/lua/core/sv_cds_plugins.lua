/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	This code will load all Weapon Types and Attacks into CDS.
*******************************************************************************************************/

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

local files = file.Find("materials/cds/*", "GAME")
for k,v in pairs(files) do
	resource.AddFile("materials/cds/" .. v)
end

local files = file.Find("materials/cds/sprites/*", "GAME")
for k,v in pairs(files) do
	resource.AddFile("materials/cds/sprites/" .. v)
end

local Files = file.Find("cds_types/*.lua", LUA_PATH)
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_types/"..File)
	if(!ErrorCheck) then
		ErrorOffStuff(PCallError)
	else
		Msg("Loaded: Successfully\n")
	end
end

local Files = file.Find("cds_attacks/*.lua", LUA_PATH)
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_attacks/"..File)
	if(!ErrorCheck) then
		ErrorOffStuff(PCallError)
	else
		Msg("Loaded Successfully\n")
	end
end
