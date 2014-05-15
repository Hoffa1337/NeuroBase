
local function CreateNeuroEntity( Player, Pos, Ang, Model, Class, VName, VTable )

    if (!gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable )) then return end
 /*   
	local MaxCarsAllowed  = GetConVarNumber( "scar_maxscars" )
	local nrOfCars = Player:GetCount( "SCar" )   
	local carInfo = SCarRegister:GetInfo( Class )
	
	if carInfo.IsMissingDependencies then
		Player:PrintMessage( HUD_PRINTTALK, carInfo.Name.." Dependency info: "..carInfo.DependencyNotice)
		return false
	end
	
	if !game.SinglePlayer() and carInfo and carInfo.AdminOnly and !Player:IsAdmin() and GetConVarNumber( "scar_admincarspawn" ) == 0 then
		Player:PrintMessage( HUD_PRINTTALK, carInfo.Name.." is admin only")
		return false 	
	end		   	   
	   
	if !game.SinglePlayer() and nrOfCars >= MaxCarsAllowed - 1 then 	
		Player:PrintMessage( HUD_PRINTTALK, "You have reached SCar spawn limit")
		return false 
	end	
*/	
    local Ent = ents.Create( Class )
    if (!Ent) then return NULL end
    
    Ent:SetModel( Model )
    
    // Fill in the keyvalues if we have them
    if ( VTable && VTable.KeyValues ) then
        for k, v in pairs( VTable.KeyValues ) do
            Ent:SetKeyValue( k, v )
        end        
    end
        
    Ent:SetAngles( Ang )
    Ent:SetPos( Pos )
        
    Ent:Spawn()
    Ent:Activate()
    
    Ent.VehicleName     = VName
    Ent.VehicleTable     = VTable
    
    // We need to override the class in the case of the Jeep, because it
    // actually uses a different class than is reported by GetClass
    Ent.ClassOverride     = Class
	
    gamemode.Call( "PlayerSpawnedVehicle", Player, Ent )
    return Ent    
    
end

local function ConsCmdSpawnNeuroEntity( Player, command, arguments )
    if ( arguments[1] == nil ) then return end
	
	if !Player or !Player.IsPlayer or !Player:IsPlayer() then
		Player = game.GetWorld()
	end
/*	
	if SCarGetFastConvar["scar_scarspawnadminonly"] == 1 and Player:IsAdmin() == false then 
		Player:PrintMessage( HUD_PRINTTALK, "Only admins are allowed to spawn SCars")
		return false 
	end
*/	
    local vname = arguments[1]
    local VehicleList = list.Get( "NeuroTecEntities" )
    local vehicle = VehicleList[ vname ]

    // Not a valid vehicle to be spawning..
    if ( !vehicle ) then return end
	
    local tr = Player:GetEyeTraceNoCursor()
    
    local Angles = Player:GetAngles()
        Angles.pitch = 0
        Angles.roll = 0
        Angles.yaw = Angles.yaw + 180
    

    local Ent = CreateNeuroEntity( Player, tr.HitPos, Angles, vehicle.Model, vehicle.Class, vname, vehicle )
    if ( !IsValid( Ent ) ) then return end
    /*
    if ( vehicle.Members ) then
        table.Merge( Ent, vehicle.Members )
        duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members );
    end
    */
    undo.Create( "NeuroTec Entities" )
        undo.SetPlayer( Player )
        undo.AddEntity( Ent )
        undo.SetCustomUndoText( "Undone "..vehicle.Name )
    undo.Finish( "NeuroTec Entities ("..tostring( vehicle.Name )..")" )
    
    Player:AddCleanup( "NeuroTec Entities", Ent )
end

concommand.Add( "gm_spawn_neuroent", ConsCmdSpawnNeuroEntity )