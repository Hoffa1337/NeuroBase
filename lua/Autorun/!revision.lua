function Revision()
-- return " v1337 gary D: broke mah revision script" end

local __addons = file.Find("addons/*", "GAME" )
if( !__addons ) then return "Why on earth did you delete your addon folder??" end
local NeuroplanesFolderName = nil
	for k,v in pairs( __addons ) do
		if( string.find( string.lower(v[2]), "neurobase" ) != nil || string.find(string.lower(v[2]), "nbase") != nil ) then
			NeuroplanesFolderName = v
			break 
		end
	end
	-- print( "FOLDER -",NeuroplanesFolderName)
	if( NeuroplanesFolderName ) then
		local svnfile = file.Read("addons/"..NeuroplanesFolderName.."/.svn/entries")
		if( !svnfile ) then return "Revision not found" end
		
		local idx1,idx2 = string.find( svnfile, "dir" )
		local a,b = string.find( svnfile, "http://svn")
		return string.Replace( string.Replace( string.sub( svnfile, idx2, a ), string.char(10),""), "h", "" )
	end
	return "Revision not found"
end
