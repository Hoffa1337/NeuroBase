local meta = FindMetaTable( "Player" )
if (!meta) then return end

// In this file we're adding functions to the player meta table.
// This means you'll be able to call functions here straight from the player object
// You can even override already existing functions.

function meta:GetScriptedVehicle()

	return self:GetNetworkedEntity( "ScriptedVehicle", NULL )

end

function meta:SetScriptedVehicle( veh )

	self:SetNetworkedEntity( "ScriptedVehicle", veh )
	-- self:SetViewEntity( veh )

end

-- print ("floppy boobs")