local function AddPlayerModel( name, model )

    list.Set( "PlayerOptionsModel", name, model )
    player_manager.AddValidModel( name, model )
    
end

AddPlayerModel("USAF Pilot", "models/player/pilot_usaf.mdl" )
