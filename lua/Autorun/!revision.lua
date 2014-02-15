function Revision()
-- return " v1337 gary D: broke mah revision script" end

-- local __files, __addons = file.Find("addons/*", "GAME" )
-- if( !__addons ) then return "... WAIT!! Why the fuck did you delete your addon folder??" end
-- local NeuroplanesFolderName = nil
-- PrintTable( __addons )
	-- for k,v in pairs( __addons ) do
		-- if( string.find( string.lower(v), "neurobase" ) || string.find( string.lower(v), "nbase") ) then
			-- NeuroplanesFolderName = v
			-- print( v )
			-- break 	
		-- end
	-- end
	-- print( "FOLDER -",NeuroplanesFolderName)
	-- if( NeuroplanesFolderName ) then
		-- local svnfile = file.Read("addons/"..string.lower(NeuroplanesFolderName).."/.svn/wc.db", "GAME" )
		-- print( svnfile )
		-- if( !svnfile ) then return "Revision not found" end
		
		-- local idx1,idx2 = string.find( svnfile, "/svn/neurobase/!svn/rvr/" )
		-- local a,b = string.find( svnfile, "http://svn")
		-- return string.Replace( string.Replace( string.sub( svnfile, idx2, a ), string.char(10),""), "h", "" )
	-- end
	return "Revision not found"
end
