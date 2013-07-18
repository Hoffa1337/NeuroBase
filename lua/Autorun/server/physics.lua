--[[
//----- ConVars
local MaxVelocity = CreateConVar( "phys_maxvelocity", "10000", {FCVAR_NOTIFY , FCVAR_ARCHIVE , FCVAR_GAMEDLL} );
local MaxAngularVelocity = CreateConVar( "phys_maxangularvelocity", "3600", {FCVAR_NOTIFY , FCVAR_ARCHIVE , FCVAR_GAMEDLL} );
local GravityX = CreateConVar( "phys_gravity_x", "0", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local GravityY = CreateConVar( "phys_gravity_y", "0", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local GravityZ = CreateConVar( "phys_gravity_z", "-600", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local CollisionsPerObjectPerTimestep = CreateConVar( "phys_collisions_object_timestep", "10", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local CollisionsPerTimestep = CreateConVar( "phys_collisions_timestep", "250", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local MinFrictionMass = CreateConVar( "phys_minfrictionmass", "10", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local MaxFrictionMass = CreateConVar( "phys_maxfrictionmass", "2500", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
local AirDensity = CreateConVar( "phys_airdensity", "2", {FCVAR_NOTIFY , FCVAR_GAMEDLL} );
//original lines 
-- local MaxVelocity = CreateConVar( "phys_maxvelocity", "10000", {FCVAR_NOTIFY , FCVAR_ARCHIVE , FCVAR_GAMEDLL} );
-- local MaxAngularVelocity = CreateConVar( "phys_maxangularvelocity", "3600", FCVAR_NOTIFY | FCVAR_ARCHIVE | FCVAR_GAMEDLL );
-- local GravityX = CreateConVar( "phys_gravity_x", "0", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local GravityY = CreateConVar( "phys_gravity_y", "0", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local GravityZ = CreateConVar( "phys_gravity_z", "-600", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local CollisionsPerObjectPerTimestep = CreateConVar( "phys_collisions_object_timestep", "10", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local CollisionsPerTimestep = CreateConVar( "phys_collisions_timestep", "250", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local MinFrictionMass = CreateConVar( "phys_minfrictionmass", "10", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local MaxFrictionMass = CreateConVar( "phys_maxfrictionmass", "2500", FCVAR_NOTIFY | FCVAR_GAMEDLL );
-- local AirDensity = CreateConVar( "phys_airdensity", "2", FCVAR_NOTIFY | FCVAR_GAMEDLL );

/*------------------------------------
	UpdatePerformanceSettings	
------------------------------------*/
local function UpdatePerformanceSettings( ... )

	// is the physics library loaded?
	if( !physics ) then
	
		return;
	
	end

	// get existing
	local settings = physics.GetPerformanceSettings();

	// build/modify
	settings.maxVelocity = MaxVelocity:GetFloat();
	settings.maxAngularVelocity = MaxAngularVelocity:GetFloat();
	settings.minFrictionMass = MinFrictionMass:GetFloat();
	settings.maxFrictionMass = MaxFrictionMass:GetFloat();
	settings.maxCollisionsPerObjectPerTimestep = CollisionsPerObjectPerTimestep:GetInt();
	settings.maxCollisionChecksPerTimestep = CollisionsPerTimestep:GetInt();

	// set
	physics.SetPerformanceSettings( settings );

end

/*------------------------------------
	UpdateGravity	
------------------------------------*/
local function UpdateGravity( ... )

	// is the physics library loaded?
	if( !physics ) then
	
		return;
	
	end

	//  set gravity
	physics.SetGravity( Vector( GravityX:GetFloat(), GravityY:GetFloat(), GravityZ:GetFloat() ) );
	
end

/*------------------------------------
	UpdateAirDensity	
------------------------------------*/
local function UpdateAirDensity( ... )

	// is the physics library loaded?
	if( !physics ) then
	
		return;
	
	end

	//  set gravity
	physics.SetAirDensity( AirDensity:GetFloat() );
	
end

//----- Install ConVar change callbacks
cvars.AddChangeCallback( "phys_maxvelocity", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_maxangularvelocity", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_collisions_object_timestep", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_collisions_timestep", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_minfrictionmass", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_maxfrictionmass", UpdatePerformanceSettings );
cvars.AddChangeCallback( "phys_gravity_x", UpdateGravity );
cvars.AddChangeCallback( "phys_gravity_y", UpdateGravity );
cvars.AddChangeCallback( "phys_gravity_z", UpdateGravity );
cvars.AddChangeCallback( "phys_airdensity", UpdateAirDensity );

/*------------------------------------
	InitPostEntity	
------------------------------------*/
local function InitPostEntity( )

	// load module
	// this needs to be done after the engine has
	// loaded the vphysics library
	// I'm assuming here that at this time, since entities are
	// spawning and utilizing vphysics
	//
	// it's loaded.
	require( "vphysics" );
	
	// update everything
	UpdatePerformanceSettings();
	UpdateGravity();
	UpdateAirDensity();

end
hook.Add( "InitPostEntity", "LoadPhysicsModule", InitPostEntity );
]]--